import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';
import 'package:meet_action/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:meet_action/features/meetings/domain/usecases/join_meeting_by_code.dart';

class MockMeetingRepository extends Mock implements MeetingRepository {}

void main() {
  late JoinMeetingByCode usecase;
  late MockMeetingRepository mockRepository;

  setUp(() {
    mockRepository = MockMeetingRepository();
    usecase = JoinMeetingByCode(mockRepository);
  });

  final tParticipant = Participant(
    id: 'user-2',
    name: 'Carlos Mendoza',
    email: 'carlos@empresa.com',
    joinedAt: DateTime.parse('2026-08-20T10:00:00.000Z'),
  );

  final tMeeting = Meeting(
    id: 'meet-1',
    title: 'Reunión de Estrategia',
    createdAt: DateTime.parse('2026-08-20T10:00:00.000Z'),
    duration: const Duration(minutes: 30),
    audioUrl: 'https://storage.googleapis.com/audio/meet-1.m4a',
    status: MeetingStatus.recording,
    participants: const ['Ana (Host)', 'Carlos Mendoza'],
    joinCode: 'MEET-8492',
  );

  test('should return Meeting when join code is valid and participant is added', () async {
    when(() => mockRepository.joinMeetingByCode(
          code: 'MEET-8492',
          participant: tParticipant,
        )).thenAnswer((_) async => Right(tMeeting));

    final result = await usecase(
      code: 'MEET-8492',
      participant: tParticipant,
    );

    expect(result, Right(tMeeting));
    verify(() => mockRepository.joinMeetingByCode(
          code: 'MEET-8492',
          participant: tParticipant,
        )).called(1);
  });

  test('should return ServerFailure when join code is not found or expired', () async {
    when(() => mockRepository.joinMeetingByCode(
          code: 'INVALID-PIN',
          participant: tParticipant,
        )).thenAnswer((_) async => const Left(ServerFailure('Código de reunión inválido o expirado')));

    final result = await usecase(
      code: 'INVALID-PIN',
      participant: tParticipant,
    );

    expect(result, const Left(ServerFailure('Código de reunión inválido o expirado')));
    verify(() => mockRepository.joinMeetingByCode(
          code: 'INVALID-PIN',
          participant: tParticipant,
        )).called(1);
  });
}
