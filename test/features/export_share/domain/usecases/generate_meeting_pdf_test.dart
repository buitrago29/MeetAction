import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/export_share/domain/usecases/generate_meeting_pdf.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

void main() {
  late GenerateMeetingPdf useCase;

  setUp(() {
    useCase = GenerateMeetingPdf();
  });

  final tMeeting = Meeting(
    id: 'meet-1',
    title: 'Reunión de Lanzamiento v1.0',
    createdAt: DateTime(2026, 8, 20, 11, 0),
    duration: const Duration(minutes: 50),
    status: MeetingStatus.completed,
    audioUrl: '/audio/launch.m4a',
    participants: const ['Carlos Gomez', 'Ana Ruiz'],
  );

  const tMinutes = MeetingMinutes(
    executiveSummary: 'Lanzamiento oficial de MeetAction para plataformas móviles.',
    topics: [
      TopicDiscussed(title: 'Roadmap', keyPoints: 'Hitos alcanzados de Fase 1 a 6'),
    ],
    keyDecisions: ['Aprobación de la versión para producción'],
    actionItems: [],
  );

  final tActionItems = [
    ActionItem(
      id: 'ai-1',
      meetingId: 'meet-1',
      assigneeName: 'Carlos Gomez',
      description: 'Generar binarios de release',
      dueDate: DateTime(2026, 8, 26),
      priority: PriorityLevel.high,
      status: ActionItemStatus.pending,
    ),
  ];

  test('should generate valid non-empty Uint8List containing PDF document', () async {
    // act
    final result = await useCase(
      GenerateMeetingPdfParams(
        meeting: tMeeting,
        minutes: tMinutes,
        actionItems: tActionItems,
      ),
    );

    // assert
    expect(result.isRight(), isTrue);
    final pdfBytes = result.getOrElse((_) => Uint8List(0));
    expect(pdfBytes.isNotEmpty, isTrue);
    // PDF Magic bytes check: %PDF (0x25, 0x50, 0x44, 0x46)
    expect(pdfBytes.take(4).toList(), [0x25, 0x50, 0x44, 0x46]);
  });
}
