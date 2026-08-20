import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/presentation/widgets/meeting_detail_view.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  final tMeeting = Meeting(
    id: 'meet-1',
    title: 'Reunión de Arquitectura',
    createdAt: DateTime(2026, 8, 20, 11, 0),
    duration: const Duration(minutes: 20),
    status: MeetingStatus.completed,
    audioUrl: '/audio/arch.m4a',
    participants: const ['Carlos Gomez'],
  );

  const tMinutes = MeetingMinutes(
    executiveSummary: 'Se definieron los lineamientos de Clean Architecture y la integración con Gemini API.',
    topics: [
      TopicDiscussed(
        title: 'Arquitectura Limpia',
        keyPoints: 'Uso de Domain, Data y Presentation layers.',
      ),
      TopicDiscussed(
        title: 'Notificaciones',
        keyPoints: 'Alertas locales con flutter_local_notifications.',
      ),
    ],
    keyDecisions: ['Adopción estricta de TDD'],
    actionItems: [],
  );

  final tActionItems = [
    const ActionItem(
      id: 'item-1',
      meetingId: 'meet-1',
      assigneeName: 'Ana Ruiz',
      description: 'Configurar variables de entorno',
      priority: PriorityLevel.urgent,
      status: ActionItemStatus.pending,
    ),
  ];

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MeetingDetailView(
          meeting: tMeeting,
          minutes: tMinutes,
          actionItems: tActionItems,
          onActionItemStatusChanged: (item, status) {},
        ),
      ),
    );
  }

  testWidgets('should render meeting title, executive summary, topics, and action items',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Reunión de Arquitectura'), findsOneWidget);
    expect(find.textContaining('Se definieron los lineamientos'), findsOneWidget);
    expect(find.text('Arquitectura Limpia'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Configurar variables de entorno'), findsOneWidget);
    expect(find.text('Ana Ruiz'), findsOneWidget);
  });
}
