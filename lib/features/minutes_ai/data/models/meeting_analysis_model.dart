import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

class TopicAnalysisModel extends Equatable {
  final String title;
  final String keyPoints;

  const TopicAnalysisModel({
    required this.title,
    required this.keyPoints,
  });

  factory TopicAnalysisModel.fromJson(Map<String, dynamic> json) {
    return TopicAnalysisModel(
      title: json['title'] as String? ?? '',
      keyPoints: json['keyPoints'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'keyPoints': keyPoints,
    };
  }

  TopicDiscussed toDomain() {
    return TopicDiscussed(
      title: title,
      keyPoints: keyPoints,
    );
  }

  @override
  List<Object?> get props => [title, keyPoints];
}

class ActionItemAnalysisModel extends Equatable {
  final String assigneeName;
  final String description;
  final DateTime? suggestedDueDate;
  final PriorityLevel priority;

  const ActionItemAnalysisModel({
    required this.assigneeName,
    required this.description,
    this.suggestedDueDate,
    required this.priority,
  });

  factory ActionItemAnalysisModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDueDate;
    final dueDateRaw = json['suggestedDueDate'];
    if (dueDateRaw != null && dueDateRaw is String && dueDateRaw.isNotEmpty) {
      parsedDueDate = DateTime.tryParse(dueDateRaw);
    }

    final priorityStr = (json['priority'] as String? ?? 'medium').toLowerCase();
    final priority = switch (priorityStr) {
      'urgent' => PriorityLevel.urgent,
      'high' => PriorityLevel.high,
      'low' => PriorityLevel.low,
      _ => PriorityLevel.medium,
    };

    return ActionItemAnalysisModel(
      assigneeName: json['assigneeName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      suggestedDueDate: parsedDueDate,
      priority: priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assigneeName': assigneeName,
      'description': description,
      'suggestedDueDate': suggestedDueDate?.toIso8601String(),
      'priority': priority.name,
    };
  }

  ActionItem toDomain({required String meetingId, String? id}) {
    return ActionItem(
      id: id ?? const Uuid().v4(),
      meetingId: meetingId,
      assigneeName: assigneeName,
      description: description,
      dueDate: suggestedDueDate,
      priority: priority,
      status: ActionItemStatus.pending,
      reminderScheduled: false,
    );
  }

  @override
  List<Object?> get props => [
        assigneeName,
        description,
        suggestedDueDate,
        priority,
      ];
}

class MeetingAnalysisModel extends Equatable {
  final String title;
  final String executiveSummary;
  final String? meetingTone;
  final List<String> participants;
  final List<TopicAnalysisModel> topics;
  final List<String> keyDecisions;
  final List<ActionItemAnalysisModel> actionItems;

  const MeetingAnalysisModel({
    required this.title,
    required this.executiveSummary,
    this.meetingTone,
    required this.participants,
    required this.topics,
    required this.keyDecisions,
    required this.actionItems,
  });

  factory MeetingAnalysisModel.fromJson(Map<String, dynamic> json) {
    return MeetingAnalysisModel(
      title: json['title'] as String? ?? '',
      executiveSummary: json['executiveSummary'] as String? ?? '',
      meetingTone: json['meetingTone'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => TopicAnalysisModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      keyDecisions: (json['keyDecisions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) =>
                  ActionItemAnalysisModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'executiveSummary': executiveSummary,
      'meetingTone': meetingTone,
      'participants': participants,
      'topics': topics.map((e) => e.toJson()).toList(),
      'keyDecisions': keyDecisions,
      'actionItems': actionItems.map((e) => e.toJson()).toList(),
    };
  }

  MeetingMinutes toMeetingMinutes({required String meetingId}) {
    return MeetingMinutes(
      executiveSummary: executiveSummary,
      meetingTone: meetingTone,
      topics: topics.map((t) => t.toDomain()).toList(),
      keyDecisions: keyDecisions,
      actionItems: actionItems.map((a) => a.toDomain(meetingId: meetingId)).toList(),
    );
  }

  @override
  List<Object?> get props => [
        title,
        executiveSummary,
        meetingTone,
        participants,
        topics,
        keyDecisions,
        actionItems,
      ];
}
