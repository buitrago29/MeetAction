import 'package:flutter/material.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/presentation/pages/meeting_detail_screen.dart';
import 'package:meet_action/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';
import 'package:meet_action/features/recording/presentation/pages/record_meeting_screen.dart';

class MeetingsHomeScreen extends StatefulWidget {
  const MeetingsHomeScreen({super.key});

  @override
  State<MeetingsHomeScreen> createState() => _MeetingsHomeScreenState();
}

class _MeetingsHomeScreenState extends State<MeetingsHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Meeting> _meetings = [
    Meeting(
      id: 'meet-101',
      title: 'Planificación Sprint Q3 y Arquitectura',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      duration: const Duration(minutes: 40, seconds: 50),
      status: MeetingStatus.completed,
      audioUrl: '/recordings/sprint_q3.m4a',
      participants: const ['Carlos Gómez', 'Ana Ruiz', 'Luis Torres'],
    ),
    Meeting(
      id: 'meet-102',
      title: 'Alineación de Producto y Diseño UI',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(minutes: 30, seconds: 20),
      status: MeetingStatus.completed,
      audioUrl: '/recordings/product_sync.m4a',
      participants: const ['Ana Ruiz', 'Carlos Gómez'],
    ),
    Meeting(
      id: 'meet-103',
      title: 'Revisión Técnica con Stakeholders',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      duration: const Duration(minutes: 15, seconds: 50),
      status: MeetingStatus.recording,
      audioUrl: '/recordings/stakeholders_sync.m4a',
      participants: const ['Luis Torres'],
    ),
  ];

  final Map<String, MeetingMinutes> _minutesMap = {
    'meet-101': MeetingMinutes(
      executiveSummary:
          'Se establecieron los objetivos estratégicos para el tercer trimestre, priorizando la migración a Clean Architecture y la integración con Gemini API.',
      topics: const [
        TopicDiscussed(
          title: 'Arquitectura y BLoC',
          keyPoints: 'Definición de capas de dominio, datos y presentación con TDD.',
        ),
        TopicDiscussed(
          title: 'Notificaciones Preventivas',
          keyPoints: 'Configuración de alertas 24h antes y el día del vencimiento.',
        ),
      ],
      keyDecisions: const [
        'Adopción estricta de Clean Architecture',
        'Modelos inmutables con Equatable',
      ],
      actionItems: const [],
      meetingTone: 'Colaborativo y enfocado',
    ),
  };

  final Map<String, List<ActionItem>> _actionItemsMap = {
    'meet-101': [
      ActionItem(
        id: 'ai-1',
        meetingId: 'meet-101',
        assigneeName: 'Carlos Gómez',
        description: 'Implementar el cliente de API para Gemini 2.0 Flash',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: PriorityLevel.urgent,
        status: ActionItemStatus.pending,
      ),
      ActionItem(
        id: 'ai-2',
        meetingId: 'meet-101',
        assigneeName: 'Ana Ruiz',
        description: 'Diseñar el sistema de componentes en Flutter',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        priority: PriorityLevel.high,
        status: ActionItemStatus.completed,
      ),
      ActionItem(
        id: 'ai-3',
        meetingId: 'meet-101',
        assigneeName: 'Luis Torres',
        description: 'Escribir las pruebas unitarias y de integración',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        priority: PriorityLevel.medium,
        status: ActionItemStatus.pending,
      ),
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalActionItems = _actionItemsMap.values
        .expand((list) => list)
        .where((ai) => ai.status == ActionItemStatus.pending)
        .length;

    final filteredMeetings = _meetings.where((m) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final titleMatch = m.title.toLowerCase().contains(query);
      final participantMatch =
          m.participants.any((p) => p.toLowerCase().contains(query));
      return titleMatch || participantMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    MeetActionTheme.primaryColor,
                    MeetActionTheme.secondaryColor
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MeetAction',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Gestión Inteligente de Reuniones',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 12),

          // Metrics Hero Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E2468), Color(0xFF131B2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MeetActionTheme.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen General',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MeetActionTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      icon: Icons.forum_rounded,
                      value: '${_meetings.length}',
                      label: 'Reuniones',
                      color: MeetActionTheme.primaryLight,
                    ),
                    Container(
                        width: 1, height: 40, color: const Color(0xFF334155)),
                    _buildMetricItem(
                      icon: Icons.checklist_rounded,
                      value: '$totalActionItems',
                      label: 'Pendientes',
                      color: MeetActionTheme.priorityHigh,
                    ),
                    Container(
                        width: 1, height: 40, color: const Color(0xFF334155)),
                    _buildMetricItem(
                      icon: Icons.auto_awesome,
                      value: '${_minutesMap.length}',
                      label: 'Actas IA',
                      color: MeetActionTheme.priorityLow,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar reuniones o participantes...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: MeetActionTheme.primaryLight),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reuniones Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${filteredMeetings.length} encontrada${filteredMeetings.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Meetings List
          if (filteredMeetings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 48, color: Color(0xFF475569)),
                    SizedBox(height: 12),
                    Text(
                      'No se encontraron reuniones que coincidan.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredMeetings.map(
              (meeting) => MeetingCard(
                meeting: meeting,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MeetingDetailScreen(
                        meeting: meeting,
                        minutes: _minutesMap[meeting.id],
                        initialActionItems: _actionItemsMap[meeting.id] ?? [],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RecordMeetingScreen(),
            ),
          );
        },
        icon: const Icon(Icons.mic_rounded),
        label: const Text(
          'Nueva Grabación',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
