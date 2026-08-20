import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';
import 'package:meet_action/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:meet_action/features/reminders/domain/usecases/calculate_reminder_times.dart';
import 'package:meet_action/features/reminders/domain/usecases/schedule_action_item_reminders.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

class MockCalculateReminderTimes extends Mock implements CalculateReminderTimes {}

void main() {
  late ScheduleActionItemReminders useCase;
  late MockReminderRepository mockReminderRepository;
  late MockCalculateReminderTimes mockCalculateReminderTimes;

  setUpAll(() {
    registerFallbackValue(
      ReminderNotification(
        id: 'dummy',
        actionItemId: 'dummy',
        title: 'dummy',
        body: 'dummy',
        triggerDateTime: DateTime.now(),
      ),
    );
    registerFallbackValue(
      const CalculateReminderTimesParams(
        actionItem: ActionItem(
          id: 'dummy',
          meetingId: 'dummy',
          assigneeName: 'dummy',
          description: 'dummy',
          priority: PriorityLevel.low,
        ),
      ),
    );
  });

  setUp(() {
    mockReminderRepository = MockReminderRepository();
    mockCalculateReminderTimes = MockCalculateReminderTimes();
    useCase = ScheduleActionItemReminders(
      reminderRepository: mockReminderRepository,
      calculateReminderTimes: mockCalculateReminderTimes,
    );
  });

  final tDueDate = DateTime(2026, 8, 25, 17, 0);
  final tActionItem = ActionItem(
    id: 'item-101',
    meetingId: 'meeting-1',
    assigneeName: 'Carlos Gomez',
    description: 'Entregar reporte final',
    dueDate: tDueDate,
    priority: PriorityLevel.high,
  );

  final tGeneratedReminders = [
    ReminderNotification(
      id: 'rem-1',
      actionItemId: 'item-101',
      title: '🔔 Recordatorio (24h)',
      body: 'Recuerda tu compromiso',
      triggerDateTime: DateTime(2026, 8, 24, 17, 0),
    ),
    ReminderNotification(
      id: 'rem-2',
      actionItemId: 'item-101',
      title: '🔔 Compromiso para hoy',
      body: 'Recuerda tu compromiso',
      triggerDateTime: DateTime(2026, 8, 25, 8, 0),
    ),
  ];

  test('should calculate and schedule all generated reminder notifications', () async {
    // arrange
    when(() => mockCalculateReminderTimes(any()))
        .thenReturn(tGeneratedReminders);
    when(() => mockReminderRepository.scheduleReminder(any()))
        .thenAnswer((_) async => const Right(unit));

    // act
    final result = await useCase(
      ScheduleActionItemRemindersParams(actionItem: tActionItem),
    );

    // assert
    expect(result, Right(tGeneratedReminders));
    verify(() => mockCalculateReminderTimes(any())).called(1);
    verify(() => mockReminderRepository.scheduleReminder(any())).called(2);
    verifyNoMoreInteractions(mockReminderRepository);
  });

  test('should return empty list when no reminders are generated', () async {
    // arrange
    when(() => mockCalculateReminderTimes(any()))
        .thenReturn([]);

    // act
    final result = await useCase(
      ScheduleActionItemRemindersParams(actionItem: tActionItem),
    );

    // assert
    expect(result.isRight(), isTrue);
    expect(result.getOrElse((_) => []), isEmpty);
    verify(() => mockCalculateReminderTimes(any())).called(1);
    verifyZeroInteractions(mockReminderRepository);
  });

  test('should return Failure when repository fails to schedule', () async {
    // arrange
    const tFailure = NotificationFailure('Schedule error');
    when(() => mockCalculateReminderTimes(any()))
        .thenReturn([tGeneratedReminders.first]);
    when(() => mockReminderRepository.scheduleReminder(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(
      ScheduleActionItemRemindersParams(actionItem: tActionItem),
    );

    // assert
    expect(result, const Left(tFailure));
  });
}
