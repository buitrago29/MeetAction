# Reglas de Desarrollo TDD para el Agente MeetAction

1. **Test First**: NUNCA generes código de implementación sin antes haber creado y ejecutado su archivo de prueba correspondiente en el directorio `test/`.
2. **Verificación de Fallo (RED)**: Asegúrate de que la prueba falle inicialmente por la razón correcta antes de implementar.
3. **Mínimo Código Necesario (GREEN)**: Escribe únicamente la cantidad de código requerida para que las pruebas pasen.
4. **Refactorización Limpia (REFACTOR)**: Limpia duplicidades y optimiza la arquitectura manteniendo todas las pruebas en verde (`flutter test`).
5. **Aislamiento de Dominio**: Las entidades y casos de uso en `domain/` nunca deben importar paquetes de Flutter UI, Firebase o librerías de hardware.
