import 'package:equatable/equatable.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

enum MeetingStatus {
  recording,
  uploading,
  processing,
  completed,
  failed,
}

class Meeting extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final Duration duration;
  final String audioUrl;
  final MeetingStatus status;
  final List<String> participants;
  final MeetingMinutes? minutes;

  const Meeting({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.duration,
    required this.audioUrl,
    required this.status,
    required this.participants,
    this.minutes,
  });

  Meeting copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    Duration? duration,
    String? audioUrl,
    MeetingStatus? status,
    List<String>? participants,
    MeetingMinutes? minutes,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      minutes: minutes ?? this.minutes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        createdAt,
        duration,
        audioUrl,
        status,
        participants,
        minutes,
      ];
}
