class RemoteMessage {
  final String id;
  final String groupId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final String? tag;

  RemoteMessage({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.tag,
  });

  factory RemoteMessage.fromMap(Map<String, dynamic> map) {
    return RemoteMessage(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      authorId: map['user_id'] as String,
      content: map['content'] as String,
      tag: map['tag'] as String?,
      createdAt: map['created_at'] is String
          ? DateTime.parse(map['created_at'])
          : map['created_at'] as DateTime,
    );
  }
}
