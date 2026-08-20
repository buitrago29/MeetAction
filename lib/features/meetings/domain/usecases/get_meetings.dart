import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/repositories/meeting_repository.dart';

class GetMeetings implements UseCase<List<Meeting>, NoParams> {
  final MeetingRepository repository;

  GetMeetings(this.repository);

  @override
  Future<Either<Failure, List<Meeting>>> call(NoParams params) async {
    return await repository.getMeetings();
  }
}
