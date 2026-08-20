import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';

class ActionItemCard extends StatelessWidget {
  final ActionItem actionItem;
  final ValueChanged<ActionItemStatus> onStatusChanged;

  const ActionItemCard({
    super.key,
    required this.actionItem,
    required this.onStatusChanged,
  });

  String _getPriorityLabel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return 'Baja';
      case PriorityLevel.medium:
        return 'Media';
      case PriorityLevel.high:
        return 'Alta';
      case PriorityLevel.urgent:
        return 'Urgente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = MeetActionTheme.getPriorityColor(actionItem.priority);
    final isCompleted = actionItem.status == ActionItemStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isCompleted,
              activeColor: MeetActionTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (val) {
                if (val != null) {
                  onStatusChanged(
                    val
                        ? ActionItemStatus.completed
                        : ActionItemStatus.pending,
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actionItem.description,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? const Color(0xFF64748B)
                          : const Color(0xFFF1F5F9),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            actionItem.assigneeName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFCBD5E1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: priorityColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          _getPriorityLabel(actionItem.priority),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      if (actionItem.dueDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(actionItem.dueDate!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
