import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

abstract class MinutesAIRepository {
  Future<Either<Failure, MeetingMinutes>> processAudio({
    required String audioPath,
    required String meetingId,
  });
}
