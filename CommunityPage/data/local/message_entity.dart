import 'package:hive/hive.dart';

// part 'message_entity.g.dart';
part 'message_entity.g.dart';

@HiveType(typeId: 1)
class MessageEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String groupId;

  @HiveField(2)
  final String authorId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? tag;

  @HiveField(6)
  final int sortIndex; // stable ordering key

  MessageEntity({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.sortIndex,
    this.tag,
  });

  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(map['created_at']);

    return MessageEntity(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      authorId: map['user_id'] as String,
      content: map['content'] ?? '',
      createdAt: createdAt,
      sortIndex: createdAt.microsecondsSinceEpoch, // fallback for remote
      tag: map['tag'] as String?,
    );
  }

  MessageEntity copyWith({
    String? id,
    String? groupId,
    String? authorId,
    String? content,
    DateTime? createdAt,
    String? tag,
    int? sortIndex,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      tag: tag ?? this.tag,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }
}
