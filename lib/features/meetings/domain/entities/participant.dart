import 'package:equatable/equatable.dart';

class Participant extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isHost;
  final String? fcmToken;
  final DateTime? joinedAt;

  const Participant({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isHost = false,
    this.fcmToken,
    this.joinedAt,
  });

  Participant copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isHost,
    String? fcmToken,
    DateTime? joinedAt,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isHost: isHost ?? this.isHost,
      fcmToken: fcmToken ?? this.fcmToken,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        isHost,
        fcmToken,
        joinedAt,
      ];
}
