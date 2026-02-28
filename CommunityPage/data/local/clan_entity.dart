import 'package:hive/hive.dart';

part 'clan_entity.g.dart';

@HiveType(typeId: 2)
class ClanEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? avatarUrl;

  @HiveField(3)
  final String? lastMessage;

  @HiveField(4)
  final DateTime? lastMessageAt;

  ClanEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ClanEntity.fromMap(Map<String, dynamic> map) {
    return ClanEntity(
      id: map['id'] as String,
      name: map['name'] ?? 'Unknowndfdsfa',
      avatarUrl: map['avatar_url'] as String?,
      lastMessage: map['last_message'] as String?,
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'last_message': lastMessage,
    'last_message_at': lastMessageAt?.toIso8601String(),
  };
}
