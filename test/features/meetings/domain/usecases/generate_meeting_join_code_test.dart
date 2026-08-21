import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/meetings/domain/usecases/generate_meeting_join_code.dart';

void main() {
  late GenerateMeetingJoinCode usecase;

  setUp(() {
    usecase = GenerateMeetingJoinCode();
  });

  test('should generate a 6-character alphanumeric join code formatted as MEET-XXXX', () {
    final code = usecase(meetingId: 'meet-123');

    expect(code, startsWith('MEET-'));
    expect(code.length, 9); // 'MEET-' (5) + 4 alphanumeric (4) = 9
  });

  test('should generate unique codes for consecutive invocations', () {
    final code1 = usecase(meetingId: 'meet-1');
    final code2 = usecase(meetingId: 'meet-2');

    expect(code1, isNot(equals(code2)));
  });
}
