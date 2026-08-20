import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';
import 'package:meet_action/features/reminders/domain/usecases/schedule_action_item_reminders.dart';
import 'package:meet_action/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:meet_action/features/reminders/presentation/bloc/reminder_event.dart';
import 'package:meet_action/features/reminders/presentation/bloc/reminder_state.dart';

class MockScheduleActionItemReminders extends Mock
    implements ScheduleActionItemReminders {}

void main() {
  late ReminderBloc bloc;
  late MockScheduleActionItemReminders mockScheduleReminders;

  setUpAll(() {
    registerFallbackValue(
      const ScheduleActionItemRemindersParams(
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
    mockScheduleReminders = MockScheduleActionItemReminders();
    bloc = ReminderBloc(scheduleActionItemReminders: mockScheduleReminders);
  });

  tearDown(() {
    bloc.close();
  });

  const tActionItem = ActionItem(
    id: 'item-101',
    meetingId: 'meeting-1',
    assigneeName: 'Carlos Gomez',
    description: 'Entregar reporte final',
    dueDate: null,
    priority: PriorityLevel.high,
  );

  final tReminders = [
    ReminderNotification(
      id: 'rem-1',
      actionItemId: 'item-101',
      title: '🔔 Alerta Preventiva',
      body: 'Recuerda tu compromiso',
      triggerDateTime: DateTime(2026, 8, 24, 17, 0),
    ),
  ];

  test('initial state should be ReminderInitial', () {
    expect(bloc.state, const ReminderInitial());
  });

  group('ScheduleRemindersEvent', () {
    blocTest<ReminderBloc, ReminderState>(
      'should emit [ReminderScheduledState] when scheduling succeeds',
      build: () {
        when(() => mockScheduleReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        return bloc;
      },
      act: (b) => b.add(const ScheduleRemindersEvent(actionItem: tActionItem)),
      expect: () => [
        ReminderScheduledState(reminders: tReminders),
      ],
      verify: (_) {
        verify(() => mockScheduleReminders(any())).called(1);
      },
    );

    blocTest<ReminderBloc, ReminderState>(
      'should emit [ReminderFailureState] when scheduling fails',
      build: () {
        when(() => mockScheduleReminders(any()))
            .thenAnswer((_) async => const Left(NotificationFailure('Error al programar')));
        return bloc;
      },
      act: (b) => b.add(const ScheduleRemindersEvent(actionItem: tActionItem)),
      expect: () => [
        const ReminderFailureState('Error al programar'),
      ],
    );
  });
}
