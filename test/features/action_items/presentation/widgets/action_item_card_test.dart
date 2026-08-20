import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/action_items/presentation/widgets/action_item_card.dart';

void main() {
  final tActionItem = ActionItem(
    id: 'item-1',
    meetingId: 'meet-1',
    assigneeName: 'Carlos Gómez',
    description: 'Actualizar la documentación de la API',
    dueDate: DateTime(2026, 8, 25),
    priority: PriorityLevel.high,
    status: ActionItemStatus.pending,
  );

  Widget createWidgetUnderTest({
    required ActionItem item,
    required ValueChanged<ActionItemStatus> onStatusChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ActionItemCard(
          actionItem: item,
          onStatusChanged: onStatusChanged,
        ),
      ),
    );
  }

  testWidgets('should display assignee, description, priority badge, and status',
      (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(item: tActionItem, onStatusChanged: (_) {}),
    );

    expect(find.text('Actualizar la documentación de la API'), findsOneWidget);
    expect(find.text('Carlos Gómez'), findsOneWidget);
    expect(find.text('Alta'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('should call onStatusChanged when checkbox is clicked',
      (tester) async {
    ActionItemStatus? updatedStatus;
    await tester.pumpWidget(
      createWidgetUnderTest(
        item: tActionItem,
        onStatusChanged: (status) {
          updatedStatus = status;
        },
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(updatedStatus, ActionItemStatus.completed);
  });
}
