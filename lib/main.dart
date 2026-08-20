import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meet_action/core/notifications/notification_service.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
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
    ),
  );
}

class MeetActionApp extends StatelessWidget {
  final RecordingBloc recordingBloc;
  final ReminderBloc reminderBloc;

  const MeetActionApp({
    super.key,
    required this.recordingBloc,
    required this.reminderBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecordingBloc>.value(value: recordingBloc),
        BlocProvider<ReminderBloc>.value(value: reminderBloc),
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
