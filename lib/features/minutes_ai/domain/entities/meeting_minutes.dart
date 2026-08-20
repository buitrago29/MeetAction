import 'package:equatable/equatable.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';

class TopicDiscussed extends Equatable {
  final String title;
  final String keyPoints;

  const TopicDiscussed({
    required this.title,
    required this.keyPoints,
  });

  @override
  List<Object?> get props => [title, keyPoints];
}

class MeetingMinutes extends Equatable {
  final String executiveSummary;
  final List<TopicDiscussed> topics;
  final List<String> keyDecisions;
  final List<ActionItem> actionItems;
  final String? meetingTone;

  const MeetingMinutes({
    required this.executiveSummary,
    required this.topics,
    required this.keyDecisions,
    required this.actionItems,
    this.meetingTone,
  });

  @override
  List<Object?> get props => [
        executiveSummary,
        topics,
        keyDecisions,
        actionItems,
        meetingTone,
      ];
}
