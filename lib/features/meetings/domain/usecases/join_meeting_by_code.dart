import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';
import 'package:meet_action/features/meetings/domain/repositories/meeting_repository.dart';

class JoinMeetingByCode {
  final MeetingRepository repository;

  const JoinMeetingByCode(this.repository);

  Future<Either<Failure, Meeting>> call({
    required String code,
    required Participant participant,
  }) {
    return repository.joinMeetingByCode(
      code: code,
      participant: participant,
    );
  }
}
