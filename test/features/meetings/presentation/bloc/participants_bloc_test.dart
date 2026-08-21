import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';
import 'package:meet_action/features/meetings/domain/usecases/generate_meeting_join_code.dart';
import 'package:meet_action/features/meetings/domain/usecases/join_meeting_by_code.dart';
import 'package:meet_action/features/meetings/presentation/bloc/participants_bloc.dart';
import 'package:meet_action/features/meetings/presentation/bloc/participants_event.dart';
import 'package:meet_action/features/meetings/presentation/bloc/participants_state.dart';

class MockGenerateMeetingJoinCode extends Mock implements GenerateMeetingJoinCode {}
class MockJoinMeetingByCode extends Mock implements JoinMeetingByCode {}

void main() {
  late ParticipantsBloc bloc;
  late MockGenerateMeetingJoinCode mockGenerateCode;
  late MockJoinMeetingByCode mockJoinMeeting;

  setUp(() {
    mockGenerateCode = MockGenerateMeetingJoinCode();
    mockJoinMeeting = MockJoinMeetingByCode();
    bloc = ParticipantsBloc(
      generateMeetingJoinCode: mockGenerateCode,
      joinMeetingByCode: mockJoinMeeting,
    );
  });

  final tParticipant = Participant(
    id: 'user-1',
    name: 'Carlos Mendoza',
    email: 'carlos@empresa.com',
    joinedAt: DateTime.parse('2026-08-20T10:00:00.000Z'),
  );

  test('initial state should be ParticipantsInitial', () {
    expect(bloc.state, isA<ParticipantsInitial>());
  });

  blocTest<ParticipantsBloc, ParticipantsState>(
    'should add participant by email and emit ParticipantsLoaded',
    build: () => bloc,
    act: (bloc) => bloc.add(const AddParticipantByEmailEvent(
      email: 'carlos@empresa.com',
      name: 'Carlos Mendoza',
    )),
    expect: () => [
      predicate<ParticipantsLoaded>((state) =>
          state.participants.length == 1 &&
          state.participants.first.email == 'carlos@empresa.com' &&
          state.participants.first.name == 'Carlos Mendoza'),
    ],
  );

  blocTest<ParticipantsBloc, ParticipantsState>(
    'should generate join code and emit ParticipantsLoaded with joinCode',
    setUp: () {
      when(() => mockGenerateCode(meetingId: any(named: 'meetingId')))
          .thenReturn('MEET-9921');
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const GenerateJoinPinEvent(meetingId: 'meet-100')),
    expect: () => [
      predicate<ParticipantsLoaded>((state) =>
          state.joinCode == 'MEET-9921'),
    ],
  );

  blocTest<ParticipantsBloc, ParticipantsState>(
    'should join meeting by code successfully and emit ParticipantsLoaded',
    setUp: () {
      when(() => mockJoinMeeting(
            code: 'MEET-8822',
            participant: tParticipant,
          )).thenAnswer((_) async => Right(Meeting(
            id: 'meet-1',
            title: 'Daily Meeting',
            createdAt: DateTime.parse('2026-08-20T10:00:00.000Z'),
            duration: Duration.zero,
            audioUrl: '',
            status: MeetingStatus.recording,
            participants: const ['Carlos Mendoza'],
            joinCode: 'MEET-8822',
          )));
    },
    build: () => bloc,
    act: (bloc) => bloc.add(JoinMeetingByPinEvent(
      code: 'MEET-8822',
      participant: tParticipant,
    )),
    expect: () => [
      isA<ParticipantsLoading>(),
      predicate<ParticipantsLoaded>((state) =>
          state.joinedMeeting?.id == 'meet-1' &&
          state.joinCode == 'MEET-8822'),
    ],
  );

  blocTest<ParticipantsBloc, ParticipantsState>(
    'should emit ParticipantsFailure when join meeting fails',
    setUp: () {
      when(() => mockJoinMeeting(
            code: 'INVALID-CODE',
            participant: tParticipant,
          )).thenAnswer((_) async => const Left(ServerFailure('Código no encontrado')));
    },
    build: () => bloc,
    act: (bloc) => bloc.add(JoinMeetingByPinEvent(
      code: 'INVALID-CODE',
      participant: tParticipant,
    )),
    expect: () => [
      isA<ParticipantsLoading>(),
      const ParticipantsFailure('Código no encontrado'),
    ],
  );
}
