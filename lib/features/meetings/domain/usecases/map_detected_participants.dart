import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';

class MapDetectedParticipants {
  List<ActionItem> call({
    required List<ActionItem> actionItems,
    required Map<String, Participant> nameMapping,
  }) {
    return actionItems.map((item) {
      final mapped = nameMapping[item.assigneeName];
      if (mapped != null) {
        return item.copyWith(
          assigneeName: mapped.name,
          assigneeEmail: mapped.email,
        );
      }
      return item;
    }).toList();
  }
}
