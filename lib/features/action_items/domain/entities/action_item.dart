import 'package:equatable/equatable.dart';

enum PriorityLevel {
  low,
  medium,
  high,
  urgent,
}

enum ActionItemStatus {
  pending,
  inProgress,
  completed,
}

class ActionItem extends Equatable {
  final String id;
  final String meetingId;
  final String assigneeName;
  final String? assigneeEmail;
  final String description;
  final DateTime? dueDate;
  final PriorityLevel priority;
  final ActionItemStatus status;
  final bool reminderScheduled;

  const ActionItem({
    required this.id,
    required this.meetingId,
    required this.assigneeName,
    this.assigneeEmail,
    required this.description,
    this.dueDate,
    required this.priority,
    this.status = ActionItemStatus.pending,
    this.reminderScheduled = false,
  });

  ActionItem copyWith({
    String? id,
    String? meetingId,
    String? assigneeName,
    String? assigneeEmail,
    String? description,
    DateTime? dueDate,
    PriorityLevel? priority,
    ActionItemStatus? status,
    bool? reminderScheduled,
  }) {
    return ActionItem(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeEmail: assigneeEmail ?? this.assigneeEmail,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      reminderScheduled: reminderScheduled ?? this.reminderScheduled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        meetingId,
        assigneeName,
        assigneeEmail,
        description,
        dueDate,
        priority,
        status,
        reminderScheduled,
      ];
}
