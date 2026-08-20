import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/export_share/domain/usecases/format_whatsapp_summary.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

void main() {
  late FormatWhatsAppSummary useCase;

  setUp(() {
    useCase = FormatWhatsAppSummary();
  });

  final tMeeting = Meeting(
    id: 'meet-1',
    title: 'Alineación Estratégica Q3',
    createdAt: DateTime(2026, 8, 20, 10, 0),
    duration: const Duration(minutes: 45),
    status: MeetingStatus.completed,
    audioUrl: '/audio/test.m4a',
    participants: const ['Carlos Gomez', 'Ana Ruiz'],
  );

  const tMinutes = MeetingMinutes(
    executiveSummary: 'Se definieron los objetivos trimestrales y la arquitectura del sistema.',
    topics: [
      TopicDiscussed(title: 'Arquitectura', keyPoints: 'Clean Architecture y TDD'),
    ],
    keyDecisions: [
      'Migración obligatoria a Flutter 3.47',
      'Uso de BLoC para la gestión de estados',
    ],
    actionItems: [],
  );

  final tActionItems = [
    ActionItem(
      id: 'ai-1',
      meetingId: 'meet-1',
      assigneeName: 'Carlos Gomez',
      description: 'Implementar servicios de exportación',
      dueDate: DateTime(2026, 8, 25),
      priority: PriorityLevel.urgent,
      status: ActionItemStatus.pending,
    ),
    const ActionItem(
      id: 'ai-2',
      meetingId: 'meet-1',
      assigneeName: 'Ana Ruiz',
      description: 'Diseño de interfaces en Figma',
      dueDate: null,
      priority: PriorityLevel.medium,
      status: ActionItemStatus.completed,
    ),
  ];

  test('should generate structured WhatsApp message with emojis, bold headers and bullet points', () {
    // act
    final result = useCase(
      FormatWhatsAppSummaryParams(
        meeting: tMeeting,
        minutes: tMinutes,
        actionItems: tActionItems,
      ),
    );

    // assert
    expect(result.isRight(), isTrue);
    final text = result.getOrElse((_) => '');
    expect(text, contains('📋 *ACTA DE REUNIÓN: Alineación Estratégica Q3*'));
    expect(text, contains('🗓️ *Fecha:*'));
    expect(text, contains('⏱️ *Duración:*'));
    expect(text, contains('👥 *Participantes:* Carlos Gomez, Ana Ruiz'));
    expect(text, contains('📌 *RESUMEN EJECUTIVO:*'));
    expect(text, contains('🎯 *DECISIONES CLAVE:*'));
    expect(text, contains('• Migración obligatoria a Flutter 3.47'));
    expect(text, contains('✅ *COMPROMISOS Y TAREAS:*'));
    expect(text, contains('👤 *Carlos Gomez*'));
    expect(text, contains('Implementar servicios de exportación'));
    expect(text, contains('Prioridad: Urgente'));
    expect(text, contains('MeetAction IA'));
  });
}
