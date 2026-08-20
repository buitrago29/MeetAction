import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/reminders/domain/usecases/calculate_reminder_times.dart';

void main() {
  late CalculateReminderTimes useCase;

  setUp(() {
    useCase = CalculateReminderTimes();
  });

  final tDueDate = DateTime(2026, 8, 25, 17, 0); // Friday 5:00 PM
  final tActionItem = ActionItem(
    id: 'item-101',
    meetingId: 'meeting-1',
    assigneeName: 'Carlos Gomez',
    description: 'Entregar reporte final',
    dueDate: tDueDate,
    priority: PriorityLevel.high,
  );

  test('should calculate 2 reminder notifications: 24h before and 8:00 AM on due date', () {
    // arrange: reference time is before both reminders
    final referenceTime = DateTime(2026, 8, 23, 10, 0);

    // act
    final result = useCase(
      CalculateReminderTimesParams(
        actionItem: tActionItem,
        referenceTime: referenceTime,
      ),
    );

    // assert
    expect(result.length, 2);

    // 1st reminder: 24h before dueDate (2026-08-24 17:00:00)
    final reminder24h = result.first;
    expect(reminder24h.actionItemId, 'item-101');
    expect(reminder24h.triggerDateTime, DateTime(2026, 8, 24, 17, 0));
    expect(reminder24h.body, contains('Entregar reporte final'));

    // 2nd reminder: morning of due date (2026-08-25 08:00:00)
    final reminderMorning = result[1];
    expect(reminderMorning.actionItemId, 'item-101');
    expect(reminderMorning.triggerDateTime, DateTime(2026, 8, 25, 8, 0));
    expect(reminderMorning.body, contains('Entregar reporte final'));
  });

  test('should only schedule future reminders when reference time is past the 24h mark', () {
    // arrange: reference time is on 2026-08-24 20:00 (after 24h before due date)
    final referenceTime = DateTime(2026, 8, 24, 20, 0);

    // act
    final result = useCase(
      CalculateReminderTimesParams(
        actionItem: tActionItem,
        referenceTime: referenceTime,
      ),
    );

    // assert: only morning of due date is returned
    expect(result.length, 1);
    expect(result.first.triggerDateTime, DateTime(2026, 8, 25, 8, 0));
  });

  test('should return empty list if action item has no due date or due date is in the past', () {
    const itemWithoutDueDate = ActionItem(
      id: 'item-102',
      meetingId: 'meeting-1',
      assigneeName: 'Alice',
      description: 'Tarea sin fecha',
      priority: PriorityLevel.low,
    );

    final result = useCase(
      CalculateReminderTimesParams(
        actionItem: itemWithoutDueDate,
        referenceTime: DateTime(2026, 8, 20),
      ),
    );

    expect(result, isEmpty);
  });
}
