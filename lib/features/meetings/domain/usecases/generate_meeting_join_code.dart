import 'dart:math';

class GenerateMeetingJoinCode {
  String call({String? meetingId}) {
    final random = Random();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final pin = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return 'MEET-$pin';
  }
}
