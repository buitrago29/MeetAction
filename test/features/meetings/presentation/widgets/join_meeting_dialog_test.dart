import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/meetings/presentation/widgets/join_meeting_dialog.dart';

void main() {
  testWidgets('JoinMeetingDialog should submit entered PIN code', (tester) async {
    String? submittedPin;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JoinMeetingDialog(
            onJoin: (code) {
              submittedPin = code;
            },
          ),
        ),
      ),
    );

    expect(find.text('Unirse a Reunión'), findsOneWidget);

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'MEET-7711');
    await tester.pumpAndSettle();

    final joinButton = find.text('Unirse');
    expect(joinButton, findsOneWidget);
    await tester.tap(joinButton);

    expect(submittedPin, 'MEET-7711');
  });
}
