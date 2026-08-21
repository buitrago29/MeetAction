import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';
import 'package:meet_action/features/meetings/domain/usecases/map_detected_participants.dart';

void main() {
  late MapDetectedParticipants usecase;

  setUp(() {
    usecase = MapDetectedParticipants();
  });

  final tActionItems = [
    ActionItem(
      id: 'task-1',
      meetingId: 'meet-1',
      assigneeName: 'Carlos',
      assigneeEmail: null,
      description: 'Crear los mockups',
      dueDate: DateTime.parse('2026-08-25T17:00:00.000Z'),
      priority: PriorityLevel.high,
      status: ActionItemStatus.pending,
      reminderScheduled: false,
    ),
    ActionItem(
      id: 'task-2',
      meetingId: 'meet-1',
      assigneeName: 'Laura',
      assigneeEmail: null,
      description: 'Revisar contrato',
      dueDate: DateTime.parse('2026-08-26T17:00:00.000Z'),
      priority: PriorityLevel.medium,
      status: ActionItemStatus.pending,
      reminderScheduled: false,
    ),
    ActionItem(
      id: 'task-3',
      meetingId: 'meet-1',
      assigneeName: 'Carlos',
      assigneeEmail: null,
      description: 'Preparar presentación',
      dueDate: DateTime.parse('2026-08-25T17:00:00.000Z'),
      priority: PriorityLevel.urgent,
      status: ActionItemStatus.pending,
      reminderScheduled: false,
    ),
  ];

  final tMapping = {
    'Carlos': Participant(
      id: 'user-carlos',
      name: 'Carlos Mendoza',
      email: 'carlos@empresa.com',
      fcmToken: 'token_carlos',
    ),
    'Laura': Participant(
      id: 'user-laura',
      name: 'Laura Gómez',
      email: 'laura@empresa.com',
      fcmToken: 'token_laura',
    ),
  };

  test('should map detected names to full participant names and emails across all action items', () {
    final result = usecase(
      actionItems: tActionItems,
      nameMapping: tMapping,
    );

    expect(result.length, 3);
    
    expect(result[0].assigneeName, 'Carlos Mendoza');
    expect(result[0].assigneeEmail, 'carlos@empresa.com');

    expect(result[1].assigneeName, 'Laura Gómez');
    expect(result[1].assigneeEmail, 'laura@empresa.com');

    expect(result[2].assigneeName, 'Carlos Mendoza');
    expect(result[2].assigneeEmail, 'carlos@empresa.com');
  });

  test('should preserve original action item if name is not in the mapping', () {
    final result = usecase(
      actionItems: tActionItems,
      nameMapping: {
        'Carlos': Participant(
          id: 'user-carlos',
          name: 'Carlos Mendoza',
          email: 'carlos@empresa.com',
        ),
      },
    );

    expect(result[0].assigneeEmail, 'carlos@empresa.com');
    expect(result[1].assigneeName, 'Laura');
    expect(result[1].assigneeEmail, isNull);
  });
}
