import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';
import 'package:meet_action/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:meet_action/features/reminders/domain/usecases/calculate_reminder_times.dart';

class ScheduleActionItemReminders
    implements UseCase<List<ReminderNotification>, ScheduleActionItemRemindersParams> {
  final ReminderRepository reminderRepository;
  final CalculateReminderTimes calculateReminderTimes;

  ScheduleActionItemReminders({
    required this.reminderRepository,
    required this.calculateReminderTimes,
  });

  @override
  Future<Either<Failure, List<ReminderNotification>>> call(
      ScheduleActionItemRemindersParams params) async {
    final reminders = calculateReminderTimes(
      CalculateReminderTimesParams(actionItem: params.actionItem),
    );

    for (final reminder in reminders) {
      final scheduleResult = await reminderRepository.scheduleReminder(reminder);
      if (scheduleResult.isLeft()) {
        return Left(scheduleResult.getLeft().toNullable()!);
      }
    }

    return Right(reminders);
  }
}

class ScheduleActionItemRemindersParams extends Equatable {
  final ActionItem actionItem;

  const ScheduleActionItemRemindersParams({required this.actionItem});

  @override
  List<Object?> get props => [actionItem];
}
