import 'package:meet_action/features/meetings/domain/entities/meeting.dart';

abstract class MeetingRemoteDataSource {
  Future<List<Meeting>> getMeetings();
  Future<Meeting> getMeetingById(String id);
  Future<Meeting> createMeeting(Meeting meeting);
  Future<Meeting> updateMeeting(Meeting meeting);
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
      throw Exception('Meeting with id $id not found');
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
}
