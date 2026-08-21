import 'package:meet_action/core/errors/exceptions.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';

abstract class MeetingRemoteDataSource {
  Future<List<Meeting>> getMeetings();
  Future<Meeting> getMeetingById(String id);
  Future<Meeting> createMeeting(Meeting meeting);
  Future<Meeting> updateMeeting(Meeting meeting);
  Future<Meeting> joinMeetingByCode({
    required String code,
    required Participant participant,
  });
}

class InMemoryMeetingRemoteDataSource implements MeetingRemoteDataSource {
  final Map<String, Meeting> _storage = {};

  @override
  Future<List<Meeting>> getMeetings() async {
    return _storage.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Meeting> getMeetingById(String id) async {
    final meeting = _storage[id];
    if (meeting == null) {
      throw ServerException('Meeting with id $id not found');
    }
    return meeting;
  }

  @override
  Future<Meeting> createMeeting(Meeting meeting) async {
    _storage[meeting.id] = meeting;
    return meeting;
  }

  @override
  Future<Meeting> updateMeeting(Meeting meeting) async {
    _storage[meeting.id] = meeting;
    return meeting;
  }

  @override
  Future<Meeting> joinMeetingByCode({
    required String code,
    required Participant participant,
  }) async {
    final meeting = _storage.values.cast<Meeting?>().firstWhere(
          (m) => m?.joinCode?.toUpperCase() == code.toUpperCase(),
          orElse: () => null,
        );

    if (meeting == null) {
      throw const ServerException('Código de reunión inválido o expirado');
    }

    final updatedParticipants = List<String>.from(meeting.participants);
    if (!updatedParticipants.contains(participant.name)) {
      updatedParticipants.add(participant.name);
    }

    final updatedMeeting = meeting.copyWith(participants: updatedParticipants);
    _storage[updatedMeeting.id] = updatedMeeting;
    return updatedMeeting;
  }
}
