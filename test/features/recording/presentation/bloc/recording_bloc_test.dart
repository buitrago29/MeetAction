import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/recording/domain/usecases/pause_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/resume_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/start_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/stop_recording.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_event.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_state.dart';

class MockStartRecording extends Mock implements StartRecording {}

class MockPauseRecording extends Mock implements PauseRecording {}

class MockResumeRecording extends Mock implements ResumeRecording {}

class MockStopRecording extends Mock implements StopRecording {}

void main() {
  late RecordingBloc bloc;
  late MockStartRecording mockStartRecording;
  late MockPauseRecording mockPauseRecording;
  late MockResumeRecording mockResumeRecording;
  late MockStopRecording mockStopRecording;

  setUpAll(() {
    registerFallbackValue(const StartRecordingParams(path: 'dummy'));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockStartRecording = MockStartRecording();
    mockPauseRecording = MockPauseRecording();
    mockResumeRecording = MockResumeRecording();
    mockStopRecording = MockStopRecording();

    bloc = RecordingBloc(
      startRecording: mockStartRecording,
      pauseRecording: mockPauseRecording,
      resumeRecording: mockResumeRecording,
      stopRecording: mockStopRecording,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tPath = '/path/to/record.m4a';

  test('initial state should be RecordingInitial', () {
    expect(bloc.state, const RecordingInitial());
  });

  group('StartRecordingEvent', () {
    blocTest<RecordingBloc, RecordingState>(
      'should emit [RecordingInProgress] when start recording succeeds',
      build: () {
        when(() => mockStartRecording(any()))
            .thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (b) => b.add(const StartRecordingEvent(path: tPath)),
      expect: () => [
        const RecordingInProgress(duration: Duration.zero, path: tPath),
      ],
      verify: (_) {
        verify(() => mockStartRecording(const StartRecordingParams(path: tPath)))
            .called(1);
      },
    );

    blocTest<RecordingBloc, RecordingState>(
      'should emit [RecordingFailure] when start recording fails',
      build: () {
        when(() => mockStartRecording(any()))
            .thenAnswer((_) async => const Left(AudioRecorderFailure('Permiso denegado')));
        return bloc;
      },
      act: (b) => b.add(const StartRecordingEvent(path: tPath)),
      expect: () => [
        const RecordingFailure('Permiso denegado'),
      ],
    );
  });

  group('RecordingDurationTickEvent', () {
    blocTest<RecordingBloc, RecordingState>(
      'should increment duration when in progress',
      seed: () => const RecordingInProgress(
        duration: Duration(seconds: 5),
        path: tPath,
      ),
      build: () => bloc,
      act: (b) => b.add(const RecordingDurationTickEvent(Duration(seconds: 6))),
      expect: () => [
        const RecordingInProgress(
          duration: Duration(seconds: 6),
          path: tPath,
        ),
      ],
    );
  });

  group('PauseRecordingEvent', () {
    blocTest<RecordingBloc, RecordingState>(
      'should emit [RecordingPaused] when in progress and pause succeeds',
      seed: () => const RecordingInProgress(
        duration: Duration(seconds: 15),
        path: tPath,
      ),
      build: () {
        when(() => mockPauseRecording(any()))
            .thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (b) => b.add(const PauseRecordingEvent()),
      expect: () => [
        const RecordingPaused(
          duration: Duration(seconds: 15),
          path: tPath,
        ),
      ],
      verify: (_) {
        verify(() => mockPauseRecording(const NoParams())).called(1);
      },
    );
  });

  group('ResumeRecordingEvent', () {
    blocTest<RecordingBloc, RecordingState>(
      'should emit [RecordingInProgress] when paused and resume succeeds',
      seed: () => const RecordingPaused(
        duration: Duration(seconds: 15),
        path: tPath,
      ),
      build: () {
        when(() => mockResumeRecording(any()))
            .thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (b) => b.add(const ResumeRecordingEvent()),
      expect: () => [
        const RecordingInProgress(
          duration: Duration(seconds: 15),
          path: tPath,
        ),
      ],
      verify: (_) {
        verify(() => mockResumeRecording(const NoParams())).called(1);
      },
    );
  });

  group('StopRecordingEvent', () {
    blocTest<RecordingBloc, RecordingState>(
      'should emit [RecordingStopped] when recording stops successfully',
      seed: () => const RecordingInProgress(
        duration: Duration(minutes: 1, seconds: 30),
        path: tPath,
      ),
      build: () {
        when(() => mockStopRecording(any()))
            .thenAnswer((_) async => const Right(tPath));
        return bloc;
      },
      act: (b) => b.add(const StopRecordingEvent()),
      expect: () => [
        const RecordingStopped(
          audioPath: tPath,
          duration: Duration(minutes: 1, seconds: 30),
        ),
      ],
      verify: (_) {
        verify(() => mockStopRecording(const NoParams())).called(1);
      },
    );

    blocTest<RecordingBloc, RecordingState>(
      'should emit [RecordingFailure] when stop fails',
      seed: () => const RecordingInProgress(
        duration: Duration(seconds: 10),
        path: tPath,
      ),
      build: () {
        when(() => mockStopRecording(any()))
            .thenAnswer((_) async => const Left(AudioRecorderFailure('Error al detener')));
        return bloc;
      },
      act: (b) => b.add(const StopRecordingEvent()),
      expect: () => [
        const RecordingFailure('Error al detener'),
      ],
    );
  });
}
