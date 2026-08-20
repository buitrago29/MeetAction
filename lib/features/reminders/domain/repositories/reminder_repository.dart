import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';

abstract class ReminderRepository {
  Future<Either<Failure, Unit>> scheduleReminder(ReminderNotification notification);
  Future<Either<Failure, Unit>> cancelReminder(String notificationId);
  Future<Either<Failure, List<ReminderNotification>>> getRemindersByActionItem(String actionItemId);
}
