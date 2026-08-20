import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_event.dart';
import 'package:meet_action/features/recording/presentation/bloc/recording_state.dart';
import 'package:meet_action/features/recording/presentation/widgets/waveform_visualizer.dart';

class RecordMeetingScreen extends StatelessWidget {
  const RecordMeetingScreen({super.key});

  String _formatTimer(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabar Reunión'),
        centerTitle: true,
      ),
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is RecordingStopped) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎙️ Audio guardado: ${state.audioPath}'),
                backgroundColor: MeetActionTheme.statusCompleted,
              ),
            );
            Navigator.of(context).pop(state.audioPath);
          } else if (state is RecordingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.message}'),
                backgroundColor: MeetActionTheme.accentColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final isRecording = state is RecordingInProgress;
          final isPaused = state is RecordingPaused;
          final isInitial = state is RecordingInitial;
          final currentDuration = (state is RecordingInProgress)
              ? state.duration
              : (state is RecordingPaused)
                  ? state.duration
                  : (state is RecordingStopped)
                      ? state.duration
                      : Duration.zero;

          return SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isRecording
                        ? MeetActionTheme.accentColor.withValues(alpha: 0.15)
                        : (isPaused
                            ? MeetActionTheme.statusPending.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isRecording
                          ? MeetActionTheme.accentColor
                          : (isPaused
                              ? MeetActionTheme.statusPending
                              : Colors.white24),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording
                              ? MeetActionTheme.accentColor
                              : (isPaused
                                  ? MeetActionTheme.statusPending
                                  : Colors.white38),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRecording
                            ? 'GRABANDO EN VIVO'
                            : (isPaused ? 'PAUSADO' : 'LISTO PARA GRABAR'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: isRecording
                              ? MeetActionTheme.accentColor
                              : (isPaused
                                  ? MeetActionTheme.statusPending
                                  : Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Timer Display
                Text(
                  _formatTimer(currentDuration),
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Waveform Visualizer
                WaveformVisualizer(
                  isRecording: isRecording,
                  barCount: 28,
                  height: 120,
                ),

                const Spacer(),

                // Controls Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause / Resume Button
                      if (!isInitial)
                        IconButton.filledTonal(
                          iconSize: 32,
                          icon: Icon(
                            isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          onPressed: () {
                            if (isPaused) {
                              context
                                  .read<RecordingBloc>()
                                  .add(const ResumeRecordingEvent());
                            } else {
                              context
                                  .read<RecordingBloc>()
                                  .add(const PauseRecordingEvent());
                            }
                          },
                        ),

                      // Main Record / Stop Action Button
                      GestureDetector(
                        onTap: () {
                          if (isInitial) {
                            final now = DateTime.now().millisecondsSinceEpoch;
                            context
                                .read<RecordingBloc>()
                                .add(StartRecordingEvent(
                                    path: 'meeting_recording_$now.m4a'));
                          } else {
                            context
                                .read<RecordingBloc>()
                                .add(const StopRecordingEvent());
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isInitial
                                  ? [
                                      MeetActionTheme.primaryColor,
                                      MeetActionTheme.secondaryColor
                                    ]
                                  : [
                                      MeetActionTheme.accentColor,
                                      Colors.redAccent
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isInitial
                                        ? MeetActionTheme.primaryColor
                                        : MeetActionTheme.accentColor)
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isInitial
                                ? Icons.mic_rounded
                                : Icons.stop_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Placeholder for symmetry
                      if (!isInitial)
                        const SizedBox(width: 48)
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
