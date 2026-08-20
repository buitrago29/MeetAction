import 'package:equatable/equatable.dart';

abstract class RecordingState extends Equatable {
  const RecordingState();

  @override
  List<Object?> get props => [];
}

class RecordingInitial extends RecordingState {
  const RecordingInitial();
}

class RecordingInProgress extends RecordingState {
  final Duration duration;
  final String? path;

  const RecordingInProgress({
    required this.duration,
    this.path,
  });

  @override
  List<Object?> get props => [duration, path];
}

class RecordingPaused extends RecordingState {
  final Duration duration;
  final String? path;

  const RecordingPaused({
    required this.duration,
    this.path,
  });

  @override
  List<Object?> get props => [duration, path];
}

class RecordingStopped extends RecordingState {
  final String audioPath;
  final Duration duration;

  const RecordingStopped({
    required this.audioPath,
    required this.duration,
  });

  @override
  List<Object?> get props => [audioPath, duration];
}

class RecordingFailure extends RecordingState {
  final String message;

  const RecordingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
