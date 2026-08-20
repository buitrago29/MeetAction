import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/recording/domain/repositories/audio_recorder_repository.dart';
import 'package:meet_action/features/recording/domain/usecases/start_recording.dart';

class MockAudioRecorderRepository extends Mock
    implements AudioRecorderRepository {}

void main() {
  late StartRecording useCase;
  late MockAudioRecorderRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRecorderRepository();
    useCase = StartRecording(mockRepository);
  });

  const tPath = '/path/to/meeting_recording.m4a';

  test('should call repository.startRecording and return Right(unit) on success',
      () async {
    // arrange
    when(() => mockRepository.startRecording(path: tPath))
        .thenAnswer((_) async => const Right(unit));

    // act
    final result = await useCase(const StartRecordingParams(path: tPath));

    // assert
    expect(result, const Right(unit));
    verify(() => mockRepository.startRecording(path: tPath)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return AudioRecorderFailure when startRecording fails', () async {
    // arrange
    const tFailure = AudioRecorderFailure('Failed to start recording');
    when(() => mockRepository.startRecording(path: tPath))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(const StartRecordingParams(path: tPath));

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.startRecording(path: tPath)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
