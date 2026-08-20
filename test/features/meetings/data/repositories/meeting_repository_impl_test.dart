import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/exceptions.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/meetings/data/datasources/meeting_remote_datasource.dart';
import 'package:meet_action/features/meetings/data/repositories/meeting_repository_impl.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';

class MockMeetingRemoteDataSource extends Mock
    implements MeetingRemoteDataSource {}

void main() {
  late MeetingRepositoryImpl repository;
  late MockMeetingRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockMeetingRemoteDataSource();
    repository = MeetingRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final tMeeting = Meeting(
    id: 'meeting-1',
    title: 'Planificación Q3',
    createdAt: DateTime(2026, 8, 20, 10, 0),
    duration: const Duration(minutes: 30),
    audioUrl: 'https://storage.googleapis.com/audio/meeting-1.m4a',
    status: MeetingStatus.completed,
    participants: const ['Alice', 'Bob'],
  );

  group('getMeetings', () {
    test('should return list of meetings when remote data source call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getMeetings())
          .thenAnswer((_) async => [tMeeting]);

      // act
      final result = await repository.getMeetings();

      // assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => []), [tMeeting]);
      verify(() => mockRemoteDataSource.getMeetings()).called(1);
    });

    test('should return ServerFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getMeetings())
          .thenThrow(const ServerException('Error fetching meetings'));

      // act
      final result = await repository.getMeetings();

      // assert
      expect(result, const Left(ServerFailure('Error fetching meetings')));
      verify(() => mockRemoteDataSource.getMeetings()).called(1);
    });
  });

  group('createMeeting', () {
    test('should save meeting and return saved meeting on success', () async {
      // arrange
      when(() => mockRemoteDataSource.createMeeting(tMeeting))
          .thenAnswer((_) async => tMeeting);

      // act
      final result = await repository.createMeeting(tMeeting);

      // assert
      expect(result, Right(tMeeting));
      verify(() => mockRemoteDataSource.createMeeting(tMeeting)).called(1);
    });

    test('should return ServerFailure when remote data source fails to create meeting',
        () async {
      // arrange
      when(() => mockRemoteDataSource.createMeeting(tMeeting))
          .thenThrow(const ServerException('Error creating meeting'));

      // act
      final result = await repository.createMeeting(tMeeting);

      // assert
      expect(result, const Left(ServerFailure('Error creating meeting')));
      verify(() => mockRemoteDataSource.createMeeting(tMeeting)).called(1);
    });
  });
}
