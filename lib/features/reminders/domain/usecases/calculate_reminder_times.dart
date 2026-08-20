import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';

class CalculateReminderTimesParams extends Equatable {
  final ActionItem actionItem;
  final DateTime? referenceTime;

  const CalculateReminderTimesParams({
    required this.actionItem,
    this.referenceTime,
  });

  @override
  List<Object?> get props => [actionItem, referenceTime];
}

class CalculateReminderTimes {
  final Uuid _uuid;

  CalculateReminderTimes({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  List<ReminderNotification> call(CalculateReminderTimesParams params) {
    final actionItem = params.actionItem;
    final dueDate = actionItem.dueDate;
    if (dueDate == null) return [];

    final now = params.referenceTime ?? DateTime.now();
    final reminders = <ReminderNotification>[];

    // 1. 24 hours before due date
    final reminder24h = dueDate.subtract(const Duration(hours: 24));
    if (reminder24h.isAfter(now)) {
      reminders.add(
        ReminderNotification(
          id: _uuid.v4(),
          actionItemId: actionItem.id,
          title: '🔔 Recordatorio de Compromiso (24h)',
          body: 'Recuerda tu compromiso: ${actionItem.description}',
          triggerDateTime: reminder24h,
        ),
      );
    }

    // 2. Morning of due date (08:00 AM)
    final morningDueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      8,
      0,
    );

    if (morningDueDate.isAfter(now) && morningDueDate.isBefore(dueDate)) {
      reminders.add(
        ReminderNotification(
          id: _uuid.v4(),
          actionItemId: actionItem.id,
          title: '🔔 Compromiso para hoy',
          body: 'Recuerda tu compromiso: ${actionItem.description}',
          triggerDateTime: morningDueDate,
        ),
      );
    }

    return reminders;
  }
}
