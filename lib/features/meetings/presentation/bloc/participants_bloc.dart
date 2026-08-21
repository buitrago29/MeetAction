import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';
import 'package:meet_action/features/meetings/domain/usecases/generate_meeting_join_code.dart';
import 'package:meet_action/features/meetings/domain/usecases/join_meeting_by_code.dart';
import 'package:meet_action/features/meetings/presentation/bloc/participants_event.dart';
import 'package:meet_action/features/meetings/presentation/bloc/participants_state.dart';

class ParticipantsBloc extends Bloc<ParticipantsEvent, ParticipantsState> {
  final GenerateMeetingJoinCode generateMeetingJoinCode;
  final JoinMeetingByCode joinMeetingByCode;
  final _uuid = const Uuid();

  ParticipantsBloc({
    required this.generateMeetingJoinCode,
    required this.joinMeetingByCode,
  }) : super(ParticipantsInitial()) {
    on<AddParticipantByEmailEvent>(_onAddParticipantByEmail);
    on<RemoveParticipantEvent>(_onRemoveParticipant);
    on<GenerateJoinPinEvent>(_onGenerateJoinPin);
    on<JoinMeetingByPinEvent>(_onJoinMeetingByPin);
    on<ResetParticipantsEvent>(_onResetParticipants);
  }

  void _onAddParticipantByEmail(
    AddParticipantByEmailEvent event,
    Emitter<ParticipantsState> emit,
  ) {
    final currentList = state is ParticipantsLoaded
        ? (state as ParticipantsLoaded).participants
        : <Participant>[];

    final currentCode = state is ParticipantsLoaded
        ? (state as ParticipantsLoaded).joinCode
        : null;

    final newParticipant = Participant(
      id: _uuid.v4(),
      name: event.name ?? event.email.split('@').first,
      email: event.email,
      joinedAt: DateTime.now(),
    );

    emit(ParticipantsLoaded(
      participants: [...currentList, newParticipant],
      joinCode: currentCode,
    ));
  }

  void _onRemoveParticipant(
    RemoveParticipantEvent event,
    Emitter<ParticipantsState> emit,
  ) {
    if (state is ParticipantsLoaded) {
      final loaded = state as ParticipantsLoaded;
      final updated = loaded.participants.where((p) => p.email != event.email).toList();
      emit(loaded.copyWith(participants: updated));
    }
  }

  void _onGenerateJoinPin(
    GenerateJoinPinEvent event,
    Emitter<ParticipantsState> emit,
  ) {
    final code = generateMeetingJoinCode(meetingId: event.meetingId);
    if (state is ParticipantsLoaded) {
      emit((state as ParticipantsLoaded).copyWith(joinCode: code));
    } else {
      emit(ParticipantsLoaded(joinCode: code));
    }
  }

  Future<void> _onJoinMeetingByPin(
    JoinMeetingByPinEvent event,
    Emitter<ParticipantsState> emit,
  ) async {
    emit(ParticipantsLoading());
    final result = await joinMeetingByCode(
      code: event.code,
      participant: event.participant,
    );

    result.fold(
      (failure) => emit(ParticipantsFailure(failure.message)),
      (meeting) => emit(ParticipantsLoaded(
        joinCode: meeting.joinCode ?? event.code,
        joinedMeeting: meeting,
      )),
    );
  }

  void _onResetParticipants(
    ResetParticipantsEvent event,
    Emitter<ParticipantsState> emit,
  ) {
    emit(ParticipantsInitial());
  }
}
