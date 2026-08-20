import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/notifications/notification_service.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';
import 'package:meet_action/features/reminders/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final NotificationService notificationService;

  ReminderRepositoryImpl({required this.notificationService});

  @override
  Future<Either<Failure, Unit>> scheduleReminder(
      ReminderNotification notification) async {
    try {
      final intId = notification.id.hashCode & 0x7FFFFFFF;
      await notificationService.scheduleNotification(
        id: intId,
        title: notification.title,
        body: notification.body,
        scheduledDate: notification.triggerDateTime,
      );
      return const Right(unit);
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelReminder(String notificationId) async {
    try {
      final intId = notificationId.hashCode & 0x7FFFFFFF;
      await notificationService.cancelNotification(intId);
      return const Right(unit);
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReminderNotification>>> getRemindersByActionItem(
      String actionItemId) async {
    return const Right([]);
  }
}
