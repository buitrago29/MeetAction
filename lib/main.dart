import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meet_action/core/notifications/notification_service.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
import 'package:meet_action/features/meetings/data/datasources/meeting_remote_datasource.dart';
import 'package:meet_action/features/meetings/data/repositories/meeting_repository_impl.dart';
import 'package:meet_action/features/meetings/domain/usecases/generate_meeting_join_code.dart';
import 'package:meet_action/features/meetings/domain/usecases/join_meeting_by_code.dart';
import 'package:meet_action/features/meetings/presentation/bloc/participants_bloc.dart';
import 'package:meet_action/features/meetings/presentation/pages/meetings_home_screen.dart';
import 'package:meet_action/features/recording/data/datasources/audio_recorder_local_datasource.dart';
import 'package:meet_action/features/recording/data/repositories/audio_recorder_repository_impl.dart';
import 'package:meet_action/features/recording/domain/usecases/pause_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/resume_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/start_recording.dart';
import 'package:meet_action/features/recording/domain/usecases/stop_recording.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:meet_action/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:meet_action/features/reminders/domain/usecases/calculate_reminder_times.dart';
import 'package:meet_action/features/reminders/domain/usecases/schedule_action_item_reminders.dart';
import 'package:meet_action/features/reminders/presentation/bloc/reminder_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  final notificationService = NotificationServiceImpl();
  try {
    await notificationService.initialize();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  // Audio Recording feature dependencies
  final audioLocalDataSource = AudioRecorderLocalDataSourceImpl();
  final audioRepository =
      AudioRecorderRepositoryImpl(localDataSource: audioLocalDataSource);
  final startRecording = StartRecording(audioRepository);
  final pauseRecording = PauseRecording(audioRepository);
  final resumeRecording = ResumeRecording(audioRepository);
  final stopRecording = StopRecording(audioRepository);

  // Reminders feature dependencies
  final reminderRepository =
      ReminderRepositoryImpl(notificationService: notificationService);
  final calculateReminderTimes = CalculateReminderTimes();
  final scheduleActionItemReminders = ScheduleActionItemReminders(
    reminderRepository: reminderRepository,
    calculateReminderTimes: calculateReminderTimes,
  );

  // Participants & Join feature dependencies
  final meetingDataSource = InMemoryMeetingRemoteDataSource();
  final meetingRepository = MeetingRepositoryImpl(remoteDataSource: meetingDataSource);
  final generateMeetingJoinCode = GenerateMeetingJoinCode();
  final joinMeetingByCode = JoinMeetingByCode(meetingRepository);

  runApp(
    MeetActionApp(
      recordingBloc: RecordingBloc(
        startRecording: startRecording,
        pauseRecording: pauseRecording,
        resumeRecording: resumeRecording,
        stopRecording: stopRecording,
      ),
      reminderBloc: ReminderBloc(
        scheduleActionItemReminders: scheduleActionItemReminders,
      ),
      participantsBloc: ParticipantsBloc(
        generateMeetingJoinCode: generateMeetingJoinCode,
        joinMeetingByCode: joinMeetingByCode,
      ),
    ),
  );
}

class MeetActionApp extends StatelessWidget {
  final RecordingBloc recordingBloc;
  final ReminderBloc reminderBloc;
  final ParticipantsBloc participantsBloc;

  const MeetActionApp({
    super.key,
    required this.recordingBloc,
    required this.reminderBloc,
    required this.participantsBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecordingBloc>.value(value: recordingBloc),
        BlocProvider<ReminderBloc>.value(value: reminderBloc),
        BlocProvider<ParticipantsBloc>.value(value: participantsBloc),
      ],
      child: MaterialApp(
        title: 'MeetAction',
        debugShowCheckedModeBanner: false,
        theme: MeetActionTheme.darkTheme,
        home: const MeetingsHomeScreen(),
      ),
    );
  }
}
