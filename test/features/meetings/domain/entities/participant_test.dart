import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';

void main() {
  final tDateTime = DateTime.parse('2026-08-20T10:00:00.000Z');
  final tParticipant = Participant(
    id: 'user-1',
    name: 'Carlos Mendoza',
    email: 'carlos@empresa.com',
    avatarUrl: 'https://example.com/carlos.png',
    isHost: false,
    fcmToken: 'fcm_token_123',
    joinedAt: tDateTime,
  );

  test('should be a subclass of Equatable and support value equality', () {
    final tParticipant2 = Participant(
      id: 'user-1',
      name: 'Carlos Mendoza',
      email: 'carlos@empresa.com',
      avatarUrl: 'https://example.com/carlos.png',
      isHost: false,
      fcmToken: 'fcm_token_123',
      joinedAt: tDateTime,
    );

    expect(tParticipant, equals(tParticipant2));
  });

  test('copyWith should return a modified copy of participant', () {
    final modified = tParticipant.copyWith(
      name: 'Carlos Updated',
      isHost: true,
    );

    expect(modified.name, 'Carlos Updated');
    expect(modified.isHost, true);
    expect(modified.email, 'carlos@empresa.com');
    expect(modified.id, 'user-1');
  });
}
