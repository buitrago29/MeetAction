import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/notifications/notification_service.dart';
import 'package:meet_action/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:meet_action/features/reminders/domain/entities/reminder_notification.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late ReminderRepositoryImpl repository;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 8, 25));
  });

  setUp(() {
    mockNotificationService = MockNotificationService();
    repository = ReminderRepositoryImpl(notificationService: mockNotificationService);
  });

  final tReminder = ReminderNotification(
    id: 'reminder-1',
    actionItemId: 'item-101',
    title: '🔔 Recordatorio de Compromiso (24h)',
    body: 'Recuerda tu compromiso: Entregar reporte',
    triggerDateTime: DateTime(2026, 8, 24, 17, 0),
  );

  group('scheduleReminder', () {
    test('should call notificationService.scheduleNotification and return Right(unit) on success',
        () async {
      // arrange
      when(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
          )).thenAnswer((_) async => {});

      // act
      final result = await repository.scheduleReminder(tReminder);

      // assert
      expect(result, const Right(unit));
      verify(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: tReminder.title,
            body: tReminder.body,
            scheduledDate: tReminder.triggerDateTime,
          )).called(1);
    });

    test('should return NotificationFailure when service throws an exception',
        () async {
      // arrange
      when(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
          )).thenThrow(Exception('Native notification scheduler failed'));

      // act
      final result = await repository.scheduleReminder(tReminder);

      // assert
      expect(result, isA<Left<Failure, Unit>>());
      verify(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: tReminder.title,
            body: tReminder.body,
            scheduledDate: tReminder.triggerDateTime,
          )).called(1);
    });
  });

  group('cancelReminder', () {
    test('should call notificationService.cancelNotification and return Right(unit)',
        () async {
      // arrange
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.cancelReminder('12345');

      // assert
      expect(result, const Right(unit));
      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });
  });
}
