import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';
import 'package:meet_action/features/minutes_ai/domain/repositories/minutes_ai_repository.dart';
import 'package:meet_action/features/minutes_ai/domain/usecases/process_meeting_audio.dart';

class MockMinutesAIRepository extends Mock implements MinutesAIRepository {}

void main() {
  late ProcessMeetingAudio useCase;
  late MockMinutesAIRepository mockRepository;

  setUp(() {
    mockRepository = MockMinutesAIRepository();
    useCase = ProcessMeetingAudio(mockRepository);
  });

  const tMeetingId = 'meeting-123';
  const tAudioPath = '/storage/audio/meeting_123.m4a';

  final tMinutes = MeetingMinutes(
    executiveSummary: 'Resumen de la reunión procesada por Gemini.',
    meetingTone: 'constructive',
    topics: const [
      TopicDiscussed(title: 'Objetivos Q3', keyPoints: 'Puntos clave tratados.')
    ],
    keyDecisions: const ['Decisión 1'],
    actionItems: [
      ActionItem(
        id: 'action-1',
        meetingId: tMeetingId,
        assigneeName: 'Carlos Gomez',
        description: 'Preparar informe',
        priority: PriorityLevel.high,
      )
    ],
  );

  test('should process meeting audio and return MeetingMinutes on success', () async {
    // arrange
    when(() => mockRepository.processAudio(
          audioPath: tAudioPath,
          meetingId: tMeetingId,
        )).thenAnswer((_) async => Right(tMinutes));

    // act
    final result = await useCase(
      const ProcessMeetingAudioParams(
        audioPath: tAudioPath,
        meetingId: tMeetingId,
      ),
    );

    // assert
    expect(result, Right(tMinutes));
    verify(() => mockRepository.processAudio(
          audioPath: tAudioPath,
          meetingId: tMeetingId,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when processing audio fails', () async {
    // arrange
    const tFailure = ServerFailure('Gemini API Error');
    when(() => mockRepository.processAudio(
          audioPath: tAudioPath,
          meetingId: tMeetingId,
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(
      const ProcessMeetingAudioParams(
        audioPath: tAudioPath,
        meetingId: tMeetingId,
      ),
    );

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.processAudio(
          audioPath: tAudioPath,
          meetingId: tMeetingId,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
