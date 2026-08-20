# SPEC.md - MeetAction: Grabación Inteligente de Reuniones, Actas y Compromisos

**Nombre Oficial del Producto:** MeetAction  
**Package / Bundle ID:** `com.meetaction.app`  
**Nombre del Proyecto:** `meet_action`  
**Metodología:** Spec-Driven Development (SDD) & Test-Driven Development (TDD)  
**Stack Principal:** Flutter (Dart) + Firebase (Auth, Firestore, Storage, Cloud Functions, FCM) + Google Gemini Multimodal Audio API  
**Versión:** 1.1.0  

---

## 1. Visión General del Sistema y Alcance Estratégico

**MeetAction** es una aplicación móvil multiplataforma (Android & iOS) diseñada para transformar reuniones habladas en activos ejecutables y seguimiento activo de productividad. Captura el audio de reuniones presenciales y virtuales, procesa el contenido mediante **Gemini Multimodal Audio**, y genera automáticamente:

1. **Acta Ejecutiva Formal (*Executive Brief*)**: Síntesis rápida, desglose de temas tratados, argumentos clave y acuerdos/decisiones tomadas.
2. **Matriz Inteligente de Compromisos (*Action Items*)**: Tareas asignadas por persona, con nivel de prioridad (`low`, `medium`, `high`, `urgent`) y fecha límite estimada.
3. **Sistema Proactivo de Recordatorios Push**: Notificaciones locales y remotas (FCM) antes del vencimiento de cada compromiso para garantizar la rendición de cuentas (*accountability*).
4. **Exportación y Difusión Inmediata**: Generación de reportes en PDF formal y formato optimizado para copiar a WhatsApp, Slack o Correo con un solo toque.
5. **Memoria Corporativa y Búsqueda Semántica**: Capacidad de consultar acuerdos y decisiones del historial de reuniones pasadas.

```
lib/
├── core/
│   ├── errors/           # Failure & Exception classes
│   ├── network/          # Network connectivity info
│   ├── notifications/    # Local & Push notification service
│   ├── theme/            # MeetAction Design system & theme styles
│   └── utils/            # Formatters, audio converters & constants
├── features/
│   ├── auth/             # Login, Registro, Gestión de Perfil
│   ├── recording/        # Grabación de audio, waveform, background service
│   ├── meetings/         # Listado, detalle, sincronización y filtros
│   ├── minutes_ai/       # Procesamiento de audio, extracción Gemini, JSON parser
│   ├── action_items/     # Matriz de compromisos, estados (TODO/DONE), filtros
│   ├── reminders/        # Programación y despacho de alertas preventivas push
│   └── export_share/     # Generador de PDF y formateador para WhatsApp/Slack
└── main.dart
```

---

## 2. Modelos de Dominio y Contratos de Datos

### 2.1. Entidad: `Meeting`
```dart
class Meeting {
  final String id;
  final String title;
  final DateTime createdAt;
  final Duration duration;
  final String audioUrl;
  final MeetingStatus status; // [recording, uploading, processing, completed, failed]
  final List<String> participants;
  final MeetingMinutes? minutes;
}
```

### 2.2. Entidad: `MeetingMinutes` (Acta)
```dart
class MeetingMinutes {
  final String executiveSummary;
  final List<TopicDiscussed> topics;
  final List<String> keyDecisions;
  final List<ActionItem> actionItems;
  final String? meetingTone; // [constructive, urgent, consensus, debate]
}

class TopicDiscussed {
  final String title;
  final String keyPoints;
}
```

### 2.3. Entidad: `ActionItem` (Compromiso)
```dart
class ActionItem {
  final String id;
  final String meetingId;
  final String assigneeName;
  final String? assigneeEmail;
  final String description;
  final DateTime? dueDate;
  final PriorityLevel priority; // [low, medium, high, urgent]
  final ActionItemStatus status; // [pending, inProgress, completed]
  final bool reminderScheduled;
}
```

### 2.4. Entidad: `ReminderNotification`
```dart
class ReminderNotification {
  final String id;
  final String actionItemId;
  final String title;
  final String body;
  final DateTime triggerDateTime;
  final bool isDelivered;
}
```

### 2.5. Esquema JSON Estructurado para Gemini (Prompt Output)
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "MeetActionAnalysisResult",
  "type": "object",
  "properties": {
    "title": { "type": "string" },
    "executiveSummary": { "type": "string" },
    "meetingTone": {
      "type": "string",
      "enum": ["constructive", "urgent", "consensus", "debate"]
    },
    "participants": {
      "type": "array",
      "items": { "type": "string" }
    },
    "topics": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "title": { "type": "string" },
          "keyPoints": { "type": "string" }
        },
        "required": ["title", "keyPoints"]
      }
    },
    "keyDecisions": {
      "type": "array",
      "items": { "type": "string" }
    },
    "actionItems": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "assigneeName": { "type": "string" },
          "description": { "type": "string" },
          "suggestedDueDate": { "type": ["string", "null"] },
          "priority": {
            "type": "string",
            "enum": ["low", "medium", "high", "urgent"]
          }
        },
        "required": ["assigneeName", "description", "priority"]
      }
    }
  },
  "required": ["title", "executiveSummary", "participants", "topics", "keyDecisions", "actionItems"]
}
```

---

## 3. Especificación de Casos de Uso y Criterios BDD

### Caso de Uso 1: Grabación de Audio con Servicio en Segundo Plano
```gherkin
Scenario: Iniciar y detener grabación exitosamente
  Given el micrófono del dispositivo tiene permisos concedidos
  When el usuario pulsa el botón "Iniciar Grabación"
  Then el estado de grabación pasa a "recording"
  And la notificación persistente de grabación en segundo plano se activa
  And el temporizador de duración corre en tiempo real
  When el usuario pulsa "Detener y Procesar"
  Then se genera un archivo de audio local (.m4a/.aac)
  And el estado de la reunión cambia a "uploading"
```

### Caso de Uso 2: Procesamiento y Generación de Acta con Gemini
```gherkin
Scenario: Extracción de Acta y Compromisos vía Gemini Flash
  Given un archivo de audio válido en Cloud Storage
  When la Cloud Function procesa el audio con Gemini Flash API
  Then se recibe un payload JSON válido que cumple el esquema MeetActionAnalysisResult
  And se guarda el documento en Cloud Firestore bajo el ID de la reunión
  And el estado de la reunión cambia a "completed"
  And la app MeetAction recibe el evento en tiempo real y actualiza la UI
```

### Caso de Uso 3: Programación y Disparo de Recordatorios Push
```gherkin
Scenario: Programar alerta preventiva de un compromiso
  Given un compromiso con fecha de entrega para el viernes a las 5:00 PM
  When se confirma el acta de la reunión
  Then el sistema programa una notificación local 24 horas antes del vencimiento
  And programa una segunda notificación la mañana del día de entrega
  When llega la hora programada
  Then el dispositivo muestra la notificación "🔔 Recuerda tu compromiso: [Descripción]"
  And al tocar la notificación se abre la pantalla del compromiso con opción de marcar "Completada"
```

### Caso de Uso 4: Exportación y Compartición Rápida
```gherkin
Scenario: Exportar acta a PDF y copiar resumen para WhatsApp
  Given una reunión completada con acta y compromisos
  When el usuario pulsa "Exportar PDF"
  Then se genera un documento PDF profesional con membrete, resumen, decisiones y tabla de tareas
  When el usuario pulsa "Copiar para WhatsApp"
  Then se copia al portapapeles un texto formateado con emojis y viñetas listo para enviar
```

---

## 4. Estrategia de Pruebas TDD (Ciclo Red-Green-Refactor)

En cada iteración se **debe escribir primero la prueba** antes de implementar el código de producción.

| Capa | Tipo de Prueba | Herramientas / Mocks | Objetivo |
| :--- | :--- | :--- | :--- |
| **Domain (Use Cases)** | Unit Tests | `flutter_test`, `mocktail` | Reglas de negocio puras, lógica de recordatorios y validación de compromisos. |
| **Data (Models & Mappers)** | Unit Tests | `flutter_test` | Validar serialización/deserialización del JSON de Gemini y Firestore. |
| **Data (Repositories)** | Contract / Unit Tests | `mocktail`, `fake_cloud_firestore` | Probar sincronización en tiempo real y llamadas a Firebase Storage. |
| **Services (Notifications)** | Unit Tests | `mocktail` | Verificar el cálculo exacto de tiempos para las notificaciones preventivas. |
| **Presentation (State)** | Bloc / State Tests | `bloc_test`, `mocktail` | Validar transiciones de estado de grabación, procesamiento y tareas. |
| **Presentation (UI)** | Widget Tests | `flutter_test` | Render de listas de tareas, chips de prioridad interactivos y waveforms. |
| **End-to-End** | Integration Tests | `integration_test` | Flujo integral: Grabar -> Procesar -> Ver Acta -> Marcar Tarea -> Exportar PDF. |

---

## 5. Plan de Ejecución Fase por Fase (Roadmap TDD)

### Fase 1: Core de Datos y Entidades de Dominio
- [ ] **Test 1.1**: `test/features/meetings/domain/usecases/get_meetings_test.dart`
- [ ] **Test 1.2**: `test/features/minutes_ai/data/models/meeting_analysis_model_test.dart` (Parseo de JSON Gemini con `executiveSummary`, `topics`, `decisions`, `actionItems`).
- [ ] **Test 1.3**: `test/features/action_items/domain/usecases/update_action_item_status_test.dart`
- [ ] **Test 1.4**: `test/features/reminders/domain/usecases/calculate_reminder_times_test.dart` (Cálculo de alertas 24h antes y día del vencimiento).

### Fase 2: Módulo de Grabación de Audio
- [ ] **Test 2.1**: `test/features/recording/domain/usecases/start_recording_test.dart`
- [ ] **Test 2.2**: `test/features/recording/domain/usecases/stop_recording_test.dart`
- [ ] **Test 2.3**: `test/features/recording/presentation/bloc/recording_bloc_test.dart`

### Fase 3: Integración Cloud & Gemini
- [ ] **Test 3.1**: `test/features/minutes_ai/data/datasources/gemini_remote_datasource_test.dart`
- [ ] **Test 3.2**: `test/features/meetings/data/repositories/meeting_repository_impl_test.dart`

### Fase 4: Sistema de Recordatorios y Notificaciones Push
- [ ] **Test 4.1**: `test/features/reminders/data/datasources/local_notification_service_test.dart`
- [ ] **Test 4.2**: `test/features/reminders/presentation/bloc/reminder_bloc_test.dart`

### Fase 5: UI, Interfaz de Usuario y Componentes Visuales
- [ ] **Test 5.1**: `test/features/recording/presentation/widgets/waveform_visualizer_test.dart`
- [ ] **Test 5.2**: `test/features/meetings/presentation/widgets/meeting_detail_view_test.dart`
- [ ] **Test 5.3**: `test/features/action_items/presentation/widgets/action_item_card_test.dart`

### Fase 6: Exportación (PDF & WhatsApp) y Memoria de Reuniones
- [ ] **Test 6.1**: `test/features/export_share/domain/usecases/generate_meeting_pdf_test.dart`
- [ ] **Test 6.2**: `test/features/export_share/domain/usecases/format_whatsapp_summary_test.dart`

---

## 6. Reglas de Desarrollo para Antigravity IDE (`.agents/rules/tdd.md`)

```markdown
# Reglas de Desarrollo TDD para el Agente MeetAction

1. **Test First**: NUNCA generes código de implementación sin antes haber creado y ejecutado su archivo de prueba correspondiente en el directorio `test/`.
2. **Verificación de Fallo (RED)**: Asegúrate de que la prueba falle inicialmente por la razón correcta antes de implementar.
3. **Mínimo Código Necesario (GREEN)**: Escribe únicamente la cantidad de código requerida para que las pruebas pasen.
4. **Refactorización Limpia (REFACTOR)**: Limpia duplicidades y optimiza la arquitectura manteniendo todas las pruebas en verde (`flutter test`).
5. **Aislamiento de Dominio**: Las entidades y casos de uso en `domain/` nunca deben importar paquetes de Flutter UI, Firebase o librerías de hardware.
```
