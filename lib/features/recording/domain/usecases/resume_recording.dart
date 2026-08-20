import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/recording/domain/repositories/audio_recorder_repository.dart';

class ResumeRecording implements UseCase<Unit, NoParams> {
  final AudioRecorderRepository repository;

  ResumeRecording(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.resumeRecording();
  }
}
