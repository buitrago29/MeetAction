import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/meetings/presentation/widgets/pre_meeting_setup_dialog.dart';

void main() {
  testWidgets('PreMeetingSetupDialog should validate email format and reject invalid emails', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PreMeetingSetupDialog(),
        ),
      ),
    );

    expect(find.text('Invitados a la Reunión'), findsOneWidget);

    final textField = find.byType(TextField);
    final addButton = find.byIcon(Icons.add);

    // Try entering invalid email
    await tester.enterText(textField, 'correo_invalido');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un correo electrónico válido (ej. usuario@empresa.com)'), findsOneWidget);
    expect(find.byType(Chip), findsNothing);

    // Try entering valid email
    await tester.enterText(textField, 'carlos@empresa.com');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsOneWidget);
    expect(find.text('carlos@empresa.com'), findsOneWidget);
  });

  testWidgets('PreMeetingSetupDialog should return emails list when Comenzar Grabación is tapped', (tester) async {
    List<String>? returnedEmails;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final result = await showDialog<List<String>>(
                  context: context,
                  builder: (_) => const PreMeetingSetupDialog(),
                );
                returnedEmails = result;
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    final addButton = find.byIcon(Icons.add);

    await tester.enterText(textField, 'ana@empresa.com');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Comenzar Grabación'));
    await tester.pumpAndSettle();

    expect(returnedEmails, ['ana@empresa.com']);
  });
}
