import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/meetings/presentation/widgets/meeting_qr_dialog.dart';

void main() {
  testWidgets('MeetingQrDialog should render join PIN and close button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MeetingQrDialog(
            joinCode: 'MEET-9481',
            meetingTitle: 'Reunión de Diseño',
          ),
        ),
      ),
    );

    expect(find.text('Código de la Sala'), findsOneWidget);
    expect(find.text('MEET-9481'), findsOneWidget);
    expect(find.text('Reunión de Diseño'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
  });
}
