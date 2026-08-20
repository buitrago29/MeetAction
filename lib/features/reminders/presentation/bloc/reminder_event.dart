import 'package:equatable/equatable.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleRemindersEvent extends ReminderEvent {
  final ActionItem actionItem;

  const ScheduleRemindersEvent({required this.actionItem});

  @override
  List<Object?> get props => [actionItem];
}

class CancelReminderEvent extends ReminderEvent {
  final String reminderId;

  const CancelReminderEvent({required this.reminderId});

  @override
  List<Object?> get props => [reminderId];
}
