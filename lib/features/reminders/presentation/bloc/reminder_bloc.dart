import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_action/features/reminders/domain/usecases/schedule_action_item_reminders.dart';
import 'package:meet_action/features/reminders/presentation/bloc/reminder_event.dart';
import 'package:meet_action/features/reminders/presentation/bloc/reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ScheduleActionItemReminders scheduleActionItemReminders;

  ReminderBloc({
    required this.scheduleActionItemReminders,
  }) : super(const ReminderInitial()) {
    on<ScheduleRemindersEvent>(_onScheduleReminders);
  }

  Future<void> _onScheduleReminders(
    ScheduleRemindersEvent event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await scheduleActionItemReminders(
      ScheduleActionItemRemindersParams(actionItem: event.actionItem),
    );

    result.fold(
      (failure) => emit(ReminderFailureState(failure.message)),
      (reminders) => emit(ReminderScheduledState(reminders: reminders)),
    );
  }
}
