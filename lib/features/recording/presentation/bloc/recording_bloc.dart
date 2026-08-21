import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/recording/domain/usecases/pause_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/resume_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/start_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/stop_recording.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_event.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecording startRecording;
  final PauseRecording pauseRecording;
  final ResumeRecording resumeRecording;
  final StopRecording stopRecording;
  Timer? _timer;
  int _secondsElapsed = 0;

  RecordingBloc({
    required this.startRecording,
    required this.pauseRecording,
    required this.resumeRecording,
    required this.stopRecording,
  }) : super(const RecordingInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<RecordingDurationTickEvent>(_onDurationTick);
    on<PauseRecordingEvent>(_onPauseRecording);
    on<ResumeRecordingEvent>(_onResumeRecording);
    on<StopRecordingEvent>(_onStopRecording);
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await startRecording(StartRecordingParams(path: event.path));
    result.fold(
      (failure) => emit(RecordingFailure(failure.message)),
      (_) {
        _secondsElapsed = 0;
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          _secondsElapsed++;
          add(RecordingDurationTickEvent(Duration(seconds: _secondsElapsed)));
        });
        emit(RecordingInProgress(duration: Duration.zero, path: event.path));
      },
    );
  }

  void _onDurationTick(
    RecordingDurationTickEvent event,
    Emitter<RecordingState> emit,
  ) {
    if (state is RecordingInProgress) {
      final current = state as RecordingInProgress;
      emit(RecordingInProgress(duration: event.duration, path: current.path));
    }
  }

  Future<void> _onPauseRecording(
    PauseRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    if (state is RecordingInProgress) {
      final current = state as RecordingInProgress;
      final result = await pauseRecording(const NoParams());
      result.fold(
        (failure) => emit(RecordingFailure(failure.message)),
        (_) {
          _timer?.cancel();
          emit(RecordingPaused(duration: current.duration, path: current.path));
        },
      );
    }
  }

  Future<void> _onResumeRecording(
    ResumeRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    if (state is RecordingPaused) {
      final current = state as RecordingPaused;
      final result = await resumeRecording(const NoParams());
      result.fold(
        (failure) => emit(RecordingFailure(failure.message)),
        (_) {
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            _secondsElapsed++;
            add(RecordingDurationTickEvent(Duration(seconds: _secondsElapsed)));
          });
          emit(RecordingInProgress(duration: current.duration, path: current.path));
        },
      );
    }
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<RecordingState> emit,
  ) async {
    _timer?.cancel();
    Duration duration = Duration.zero;
    if (state is RecordingInProgress) {
      duration = (state as RecordingInProgress).duration;
    } else if (state is RecordingPaused) {
      duration = (state as RecordingPaused).duration;
    }

    final result = await stopRecording(const NoParams());
    result.fold(
      (failure) => emit(RecordingFailure(failure.message)),
      (audioPath) {
        _secondsElapsed = 0;
        emit(RecordingStopped(audioPath: audioPath, duration: duration));
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
