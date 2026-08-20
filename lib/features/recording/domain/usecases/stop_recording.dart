import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/recording/domain/repositories/audio_recorder_repository.dart';

class StopRecording implements UseCase<String, NoParams> {
  final AudioRecorderRepository repository;

  StopRecording(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.stopRecording();
  }
}
