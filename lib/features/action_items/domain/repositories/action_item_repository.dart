import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';

abstract class ActionItemRepository {
  Future<Either<Failure, List<ActionItem>>> getActionItems({String? meetingId});
  Future<Either<Failure, ActionItem>> updateStatus(String actionItemId, ActionItemStatus status);
  Future<Either<Failure, ActionItem>> saveActionItem(ActionItem item);
  Future<Either<Failure, void>> deleteActionItem(String actionItemId);
}
