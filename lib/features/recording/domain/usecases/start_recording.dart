import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/recording/domain/repositories/audio_recorder_repository.dart';

class StartRecordingParams extends Equatable {
  final String path;

  const StartRecordingParams({required this.path});

  @override
  List<Object?> get props => [path];
}

class StartRecording implements UseCase<Unit, StartRecordingParams> {
  final AudioRecorderRepository repository;

  StartRecording(this.repository);

  @override
  Future<Either<Failure, Unit>> call(StartRecordingParams params) async {
    return await repository.startRecording(path: params.path);
  }
}
