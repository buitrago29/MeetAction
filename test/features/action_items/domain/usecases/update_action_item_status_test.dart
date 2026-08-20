import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/action_items/domain/repositories/action_item_repository.dart';
import 'package:meet_action/features/action_items/domain/usecases/update_action_item_status.dart';

class MockActionItemRepository extends Mock implements ActionItemRepository {}

void main() {
  late UpdateActionItemStatus useCase;
  late MockActionItemRepository mockRepository;

  setUp(() {
    mockRepository = MockActionItemRepository();
    useCase = UpdateActionItemStatus(mockRepository);
  });

  const tActionItemId = 'task-1';
  const tNewStatus = ActionItemStatus.completed;

  final tUpdatedActionItem = ActionItem(
    id: tActionItemId,
    meetingId: 'meeting-1',
    assigneeName: 'Carlos Gomez',
    description: 'Completar reporte de auditoría',
    dueDate: DateTime(2026, 8, 25),
    priority: PriorityLevel.high,
    status: tNewStatus,
    reminderScheduled: false,
  );

  test('should update action item status in repository and return updated item', () async {
    // arrange
    when(() => mockRepository.updateStatus(tActionItemId, tNewStatus))
        .thenAnswer((_) async => Right(tUpdatedActionItem));

    // act
    final result = await useCase(
      const UpdateActionItemStatusParams(
        actionItemId: tActionItemId,
        status: tNewStatus,
      ),
    );

    // assert
    expect(result, Right(tUpdatedActionItem));
    verify(() => mockRepository.updateStatus(tActionItemId, tNewStatus)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails to update status', () async {
    // arrange
    const tFailure = ServerFailure('Database update failed');
    when(() => mockRepository.updateStatus(tActionItemId, tNewStatus))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(
      const UpdateActionItemStatusParams(
        actionItemId: tActionItemId,
        status: tNewStatus,
      ),
    );

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.updateStatus(tActionItemId, tNewStatus)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
