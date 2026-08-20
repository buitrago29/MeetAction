import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/presentation/widgets/meeting_card.dart';

void main() {
  final tMeeting = Meeting(
    id: 'meet-1',
    title: 'Sprint Planning Q3',
    createdAt: DateTime(2026, 8, 20, 10, 0),
    duration: const Duration(minutes: 30, seconds: 45),
    status: MeetingStatus.completed,
    audioUrl: '/path/audio.m4a',
    participants: const ['Carlos Gomez', 'Ana Ruiz'],
  );

  Widget createWidgetUnderTest({required VoidCallback onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: MeetingCard(
          meeting: tMeeting,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('should render meeting title, formatted duration, and status',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(onTap: () {}));

    expect(find.text('Sprint Planning Q3'), findsOneWidget);
    expect(find.textContaining('30m 45s'), findsOneWidget);
    expect(find.text('Completada'), findsOneWidget);
  });

  testWidgets('should trigger onTap callback when clicked', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(createWidgetUnderTest(onTap: () {
      tapped = true;
    }));

    await tester.tap(find.byType(MeetingCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
