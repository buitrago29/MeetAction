import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/minutes_ai/data/models/meeting_analysis_model.dart';

void main() {
  final tJsonMap = {
    'title': 'Reunión de Planificación Q3',
    'executiveSummary': 'Se discutieron los objetivos estratégicos y presupuestarios.',
    'meetingTone': 'constructive',
    'participants': ['Alice Smith', 'Bob Johnson', 'Carlos Gomez'],
    'topics': [
      {
        'title': 'Presupuesto Marketing',
        'keyPoints': 'Aprobado incremento del 15% para Q3.',
      },
      {
        'title': 'Lanzamiento MVP',
        'keyPoints': 'Fecha tentativa de lanzamiento fijada para noviembre.',
      }
    ],
    'keyDecisions': [
      'Aprobar presupuesto de marketing',
      'Fijar lanzamiento para noviembre',
    ],
    'actionItems': [
      {
        'assigneeName': 'Carlos Gomez',
        'description': 'Enviar propuesta comercial detallada',
        'suggestedDueDate': '2026-08-25T17:00:00.000Z',
        'priority': 'high',
      },
      {
        'assigneeName': 'Alice Smith',
        'description': 'Revisar métricas de analytics',
        'suggestedDueDate': null,
        'priority': 'medium',
      }
    ]
  };

  test('should parse from valid Gemini JSON map correctly', () {
    // act
    final model = MeetingAnalysisModel.fromJson(tJsonMap);

    // assert
    expect(model.title, 'Reunión de Planificación Q3');
    expect(model.executiveSummary, 'Se discutieron los objetivos estratégicos y presupuestarios.');
    expect(model.meetingTone, 'constructive');
    expect(model.participants, ['Alice Smith', 'Bob Johnson', 'Carlos Gomez']);
    expect(model.topics.length, 2);
    expect(model.topics.first.title, 'Presupuesto Marketing');
    expect(model.topics.first.keyPoints, 'Aprobado incremento del 15% para Q3.');
    expect(model.keyDecisions, ['Aprobar presupuesto de marketing', 'Fijar lanzamiento para noviembre']);
    expect(model.actionItems.length, 2);
    expect(model.actionItems.first.assigneeName, 'Carlos Gomez');
    expect(model.actionItems.first.description, 'Enviar propuesta comercial detallada');
    expect(model.actionItems.first.suggestedDueDate, DateTime.parse('2026-08-25T17:00:00.000Z'));
    expect(model.actionItems.first.priority, PriorityLevel.high);
    expect(model.actionItems[1].priority, PriorityLevel.medium);
    expect(model.actionItems[1].suggestedDueDate, isNull);
  });

  test('should serialize to JSON map correctly', () {
    // arrange
    final model = MeetingAnalysisModel.fromJson(tJsonMap);

    // act
    final jsonResult = model.toJson();

    // assert
    expect(jsonResult['title'], tJsonMap['title']);
    expect(jsonResult['executiveSummary'], tJsonMap['executiveSummary']);
    expect(jsonResult['meetingTone'], tJsonMap['meetingTone']);
    expect(jsonResult['participants'], tJsonMap['participants']);
    expect(jsonResult['keyDecisions'], tJsonMap['keyDecisions']);
    expect((jsonResult['topics'] as List).length, 2);
    expect((jsonResult['actionItems'] as List).length, 2);
  });

  test('should convert to domain MeetingMinutes entity and ActionItems', () {
    // arrange
    final model = MeetingAnalysisModel.fromJson(tJsonMap);
    const meetingId = 'meeting-123';

    // act
    final minutes = model.toMeetingMinutes(meetingId: meetingId);

    // assert
    expect(minutes.executiveSummary, model.executiveSummary);
    expect(minutes.meetingTone, 'constructive');
    expect(minutes.topics.length, 2);
    expect(minutes.keyDecisions.length, 2);
    expect(minutes.actionItems.length, 2);
    expect(minutes.actionItems.first.meetingId, meetingId);
    expect(minutes.actionItems.first.assigneeName, 'Carlos Gomez');
    expect(minutes.actionItems.first.priority, PriorityLevel.high);
    expect(minutes.actionItems.first.status, ActionItemStatus.pending);
    expect(minutes.actionItems.first.reminderScheduled, isFalse);
    expect(minutes.actionItems.first.id, isNotEmpty);
  });
}
