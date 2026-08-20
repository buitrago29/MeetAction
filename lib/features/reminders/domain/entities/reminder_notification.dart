import 'package:equatable/equatable.dart';

class ReminderNotification extends Equatable {
  final String id;
  final String actionItemId;
  final String title;
  final String body;
  final DateTime triggerDateTime;
  final bool isDelivered;

  const ReminderNotification({
    required this.id,
    required this.actionItemId,
    required this.title,
    required this.body,
    required this.triggerDateTime,
    this.isDelivered = false,
  });

  ReminderNotification copyWith({
    String? id,
    String? actionItemId,
    String? title,
    String? body,
    DateTime? triggerDateTime,
    bool? isDelivered,
  }) {
    return ReminderNotification(
      id: id ?? this.id,
      actionItemId: actionItemId ?? this.actionItemId,
      title: title ?? this.title,
      body: body ?? this.body,
      triggerDateTime: triggerDateTime ?? this.triggerDateTime,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }

  @override
  List<Object?> get props => [
        id,
        actionItemId,
        title,
        body,
        triggerDateTime,
        isDelivered,
      ];
}
