import 'package:equatable/equatable.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';

abstract class ParticipantsEvent extends Equatable {
  const ParticipantsEvent();

  @override
  List<Object?> get props => [];
}

class AddParticipantByEmailEvent extends ParticipantsEvent {
  final String email;
  final String? name;

  const AddParticipantByEmailEvent({
    required this.email,
    this.name,
  });

  @override
  List<Object?> get props => [email, name];
}

class RemoveParticipantEvent extends ParticipantsEvent {
  final String email;

  const RemoveParticipantEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class GenerateJoinPinEvent extends ParticipantsEvent {
  final String? meetingId;

  const GenerateJoinPinEvent({this.meetingId});

  @override
  List<Object?> get props => [meetingId];
}

class JoinMeetingByPinEvent extends ParticipantsEvent {
  final String code;
  final Participant participant;

  const JoinMeetingByPinEvent({
    required this.code,
    required this.participant,
  });

  @override
  List<Object?> get props => [code, participant];
}

class ResetParticipantsEvent extends ParticipantsEvent {
  const ResetParticipantsEvent();
}
