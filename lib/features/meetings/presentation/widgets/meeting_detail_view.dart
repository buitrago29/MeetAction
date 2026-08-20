import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/action_items/presentation/widgets/action_item_card.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

class MeetingDetailView extends StatelessWidget {
  final Meeting meeting;
  final MeetingMinutes? minutes;
  final List<ActionItem> actionItems;
  final void Function(ActionItem item, ActionItemStatus newStatus)?
      onActionItemStatusChanged;

  const MeetingDetailView({
    super.key,
    required this.meeting,
    this.minutes,
    required this.actionItems,
    this.onActionItemStatusChanged,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes min ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMMM yyyy, HH:mm', 'es').format(meeting.createdAt);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(meeting.duration),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Executive Summary Section
          if (minutes != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: MeetActionTheme.primaryLight, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Resumen Ejecutivo de IA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MeetActionTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                minutes!.executiveSummary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ),

            // Topics Discussed Section
            if (minutes!.topics.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Temas Tratados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              ...minutes!.topics.map(
                (topic) => Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: MeetActionTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        topic.keyPoints,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFCBD5E1),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],

          // Action Items Section
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Compromisos y Tareas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MeetActionTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${actionItems.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: MeetActionTheme.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (actionItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No hay compromisos registrados en esta reunión.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...actionItems.map(
              (item) => ActionItemCard(
                actionItem: item,
                onStatusChanged: (newStatus) {
                  onActionItemStatusChanged?.call(item, newStatus);
                },
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
