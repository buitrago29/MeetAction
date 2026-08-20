import 'dart:convert';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/exceptions.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/minutes_ai/data/datasources/gemini_remote_datasource.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';
import 'package:meet_action/features/minutes_ai/domain/repositories/minutes_ai_repository.dart';

class MinutesAIRepositoryImpl implements MinutesAIRepository {
  final GeminiRemoteDataSource remoteDataSource;

  MinutesAIRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MeetingMinutes>> processAudio({
    required String audioPath,
    required String meetingId,
  }) async {
    try {
      final file = File(audioPath);
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);

      String mimeType = 'audio/mp4';
      if (audioPath.endsWith('.aac')) {
        mimeType = 'audio/aac';
      } else if (audioPath.endsWith('.mp3')) {
        mimeType = 'audio/mp3';
      } else if (audioPath.endsWith('.wav')) {
        mimeType = 'audio/wav';
      }

      final analysisModel = await remoteDataSource.analyzeAudioContent(
        audioBase64: base64Audio,
        mimeType: mimeType,
      );

      final minutes = analysisModel.toMeetingMinutes(meetingId: meetingId);
      return Right(minutes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
