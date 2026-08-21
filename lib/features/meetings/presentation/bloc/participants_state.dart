import 'package:equatable/equatable.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';

abstract class ParticipantsState extends Equatable {
  const ParticipantsState();

  @override
  List<Object?> get props => [];
}

class ParticipantsInitial extends ParticipantsState {}

class ParticipantsLoading extends ParticipantsState {}

class ParticipantsLoaded extends ParticipantsState {
  final List<Participant> participants;
  final String? joinCode;
  final Meeting? joinedMeeting;

  const ParticipantsLoaded({
    this.participants = const [],
    this.joinCode,
    this.joinedMeeting,
  });

  ParticipantsLoaded copyWith({
    List<Participant>? participants,
    String? joinCode,
    Meeting? joinedMeeting,
  }) {
    return ParticipantsLoaded(
      participants: participants ?? this.participants,
      joinCode: joinCode ?? this.joinCode,
      joinedMeeting: joinedMeeting ?? this.joinedMeeting,
    );
  }

  @override
  List<Object?> get props => [participants, joinCode, joinedMeeting];
}

class ParticipantsFailure extends ParticipantsState {
  final String message;

  const ParticipantsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
