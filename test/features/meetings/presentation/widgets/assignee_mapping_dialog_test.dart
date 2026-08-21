import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';
import 'package:meet_action/features/meetings/presentation/widgets/assignee_mapping_dialog.dart';

void main() {
  testWidgets('AssigneeMappingDialog should allow mapping detected names to emails and confirm', (tester) async {
    Map<String, Participant>? confirmedMapping;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssigneeMappingDialog(
            detectedNames: const ['Carlos', 'Laura'],
            onConfirm: (mapping) {
              confirmedMapping = mapping;
            },
          ),
        ),
      ),
    );

    expect(find.text('Asignar Correos a Participantes'), findsOneWidget);
    expect(find.text('Carlos'), findsOneWidget);
    expect(find.text('Laura'), findsOneWidget);

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'carlos@empresa.com');
    await tester.enterText(textFields.at(1), 'laura@empresa.com');
    await tester.pumpAndSettle();

    final confirmButton = find.text('Confirmar Asignaciones');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);

    expect(confirmedMapping, isNotNull);
    expect(confirmedMapping!['Carlos']?.email, 'carlos@empresa.com');
    expect(confirmedMapping!['Laura']?.email, 'laura@empresa.com');
  });
}
