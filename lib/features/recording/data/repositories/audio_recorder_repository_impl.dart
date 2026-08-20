import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/recording/data/datasources/audio_recorder_local_datasource.dart';
import 'package:meet_action/features/recording/domain/repositories/audio_recorder_repository.dart';

class AudioRecorderRepositoryImpl implements AudioRecorderRepository {
  final AudioRecorderLocalDataSource localDataSource;

  AudioRecorderRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Unit>> startRecording({required String path}) async {
    try {
      await localDataSource.startRecording(path: path);
      return const Right(unit);
    } catch (e) {
      return Left(AudioRecorderFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> pauseRecording() async {
    try {
      await localDataSource.pauseRecording();
      return const Right(unit);
    } catch (e) {
      return Left(AudioRecorderFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resumeRecording() async {
    try {
      await localDataSource.resumeRecording();
      return const Right(unit);
    } catch (e) {
      return Left(AudioRecorderFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> stopRecording() async {
    try {
      final path = await localDataSource.stopRecording();
      if (path == null || path.isEmpty) {
        return const Left(AudioRecorderFailure('No recording path returned'));
      }
      return Right(path);
    } catch (e) {
      return Left(AudioRecorderFailure(e.toString()));
    }
  }

  @override
  Future<bool> isRecording() async {
    return await localDataSource.isRecording();
  }

  @override
  Future<bool> isPaused() async {
    return await localDataSource.isPaused();
  }

  @override
  Future<bool> hasPermission() async {
    return await localDataSource.hasPermission();
  }
}
