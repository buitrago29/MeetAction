import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/action_items/domain/repositories/action_item_repository.dart';

class UpdateActionItemStatusParams extends Equatable {
  final String actionItemId;
  final ActionItemStatus status;

  const UpdateActionItemStatusParams({
    required this.actionItemId,
    required this.status,
  });

  @override
  List<Object?> get props => [actionItemId, status];
}

class UpdateActionItemStatus implements UseCase<ActionItem, UpdateActionItemStatusParams> {
  final ActionItemRepository repository;

  UpdateActionItemStatus(this.repository);

  @override
  Future<Either<Failure, ActionItem>> call(UpdateActionItemStatusParams params) async {
    return await repository.updateStatus(params.actionItemId, params.status);
  }
}
