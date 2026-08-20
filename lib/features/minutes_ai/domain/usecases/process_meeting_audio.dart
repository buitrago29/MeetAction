import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';
import 'package:meet_action/features/minutes_ai/domain/repositories/minutes_ai_repository.dart';

class ProcessMeetingAudioParams extends Equatable {
  final String audioPath;
  final String meetingId;

  const ProcessMeetingAudioParams({
    required this.audioPath,
    required this.meetingId,
  });

  @override
  List<Object?> get props => [audioPath, meetingId];
}

class ProcessMeetingAudio implements UseCase<MeetingMinutes, ProcessMeetingAudioParams> {
  final MinutesAIRepository repository;

  ProcessMeetingAudio(this.repository);

  @override
  Future<Either<Failure, MeetingMinutes>> call(ProcessMeetingAudioParams params) async {
    return await repository.processAudio(
      audioPath: params.audioPath,
      meetingId: params.meetingId,
    );
  }
}
