import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:meet_action/features/meetings/domain/usecases/get_meetings.dart';

class MockMeetingRepository extends Mock implements MeetingRepository {}

void main() {
  late GetMeetings useCase;
  late MockMeetingRepository mockMeetingRepository;

  setUp(() {
    mockMeetingRepository = MockMeetingRepository();
    useCase = GetMeetings(mockMeetingRepository);
  });

  final tMeetingList = [
    Meeting(
      id: 'meeting-1',
      title: 'Planning Q3',
      createdAt: DateTime(2026, 8, 20, 10, 0),
      duration: const Duration(minutes: 45),
      audioUrl: 'https://storage.googleapis.com/audio/meeting-1.m4a',
      status: MeetingStatus.completed,
      participants: const ['Alice', 'Bob'],
      minutes: null,
    ),
  ];

  test('should get a list of meetings from the repository', () async {
    // arrange
    when(() => mockMeetingRepository.getMeetings())
        .thenAnswer((_) async => Right(tMeetingList));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, Right(tMeetingList));
    verify(() => mockMeetingRepository.getMeetings()).called(1);
    verifyNoMoreInteractions(mockMeetingRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // arrange
    const tFailure = ServerFailure('Error fetching meetings');
    when(() => mockMeetingRepository.getMeetings())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockMeetingRepository.getMeetings()).called(1);
    verifyNoMoreInteractions(mockMeetingRepository);
  });
}
