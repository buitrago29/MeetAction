import 'package:equatable/equatable.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

class ReminderSchedulingState extends ReminderState {
  const ReminderSchedulingState();
}

class ReminderScheduledState extends ReminderState {
  final List<ReminderNotification> reminders;

  const ReminderScheduledState({required this.reminders});

  @override
  List<Object?> get props => [reminders];
}

class ReminderFailureState extends ReminderState {
  final String message;

  const ReminderFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
