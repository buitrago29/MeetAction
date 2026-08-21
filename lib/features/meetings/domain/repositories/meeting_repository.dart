import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';

abstract class MeetingRepository {
  Future<Either<Failure, List<Meeting>>> getMeetings();
  Future<Either<Failure, Meeting>> getMeetingById(String id);
  Future<Either<Failure, Meeting>> createMeeting(Meeting meeting);
  Future<Either<Failure, Meeting>> updateMeeting(Meeting meeting);
  Future<Either<Failure, Meeting>> joinMeetingByCode({
    required String code,
    required Participant participant,
  });
}
