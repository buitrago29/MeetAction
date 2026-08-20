import 'package:equatable/equatable.dart';

abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class StartRecordingEvent extends RecordingEvent {
  final String path;

  const StartRecordingEvent({required this.path});

  @override
  List<Object?> get props => [path];
}

class PauseRecordingEvent extends RecordingEvent {
  const PauseRecordingEvent();
}

class ResumeRecordingEvent extends RecordingEvent {
  const ResumeRecordingEvent();
}

class StopRecordingEvent extends RecordingEvent {
  const StopRecordingEvent();
}

class RecordingDurationTickEvent extends RecordingEvent {
  final Duration duration;

  const RecordingDurationTickEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}
