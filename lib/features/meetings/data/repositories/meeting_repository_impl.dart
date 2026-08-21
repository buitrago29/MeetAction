import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/exceptions.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/meetings/data/datasources/meeting_remote_datasource.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';
import 'package:meet_action/features/meetings/domain/repositories/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteDataSource remoteDataSource;

  MeetingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Meeting>>> getMeetings() async {
    try {
      final meetings = await remoteDataSource.getMeetings();
      return Right(meetings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meeting>> getMeetingById(String id) async {
    try {
      final meeting = await remoteDataSource.getMeetingById(id);
      return Right(meeting);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meeting>> createMeeting(Meeting meeting) async {
    try {
      final created = await remoteDataSource.createMeeting(meeting);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meeting>> updateMeeting(Meeting meeting) async {
    try {
      final updated = await remoteDataSource.updateMeeting(meeting);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meeting>> joinMeetingByCode({
    required String code,
    required Participant participant,
  }) async {
    try {
      final meeting = await remoteDataSource.joinMeetingByCode(
        code: code,
        participant: participant,
      );
      return Right(meeting);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
