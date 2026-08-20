import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/recording/domain/repositories/audio_recorder_repository.dart';
import 'package:meet_action/features/recording/domain/usecases/stop_recording.dart';

class MockAudioRecorderRepository extends Mock
    implements AudioRecorderRepository {}

void main() {
  late StopRecording useCase;
  late MockAudioRecorderRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRecorderRepository();
    useCase = StopRecording(mockRepository);
  });

  const tRecordedPath = '/data/recordings/meeting_recording.m4a';

  test('should call repository.stopRecording and return recorded file path',
      () async {
    // arrange
    when(() => mockRepository.stopRecording())
        .thenAnswer((_) async => const Right(tRecordedPath));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, const Right(tRecordedPath));
    verify(() => mockRepository.stopRecording()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return AudioRecorderFailure when stopRecording fails', () async {
    // arrange
    const tFailure = AudioRecorderFailure('Failed to stop recording');
    when(() => mockRepository.stopRecording())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.stopRecording()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
