import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';

abstract class AudioRecorderRepository {
  Future<Either<Failure, Unit>> startRecording({required String path});
  Future<Either<Failure, Unit>> pauseRecording();
  Future<Either<Failure, Unit>> resumeRecording();
  Future<Either<Failure, String>> stopRecording();
  Future<bool> isRecording();
  Future<bool> isPaused();
  Future<bool> hasPermission();
}
