// lib/CommunityPage/data/mappers/message_mapper.dart

import 'package:flutter_chat_core/flutter_chat_core.dart';
import '../local/message_entity.dart';

class MessageMapper {
  /// Entity → UI
  static Message toUi(MessageEntity e) {
    return TextMessage(
      id: e.id,
      authorId: e.authorId,
      createdAt: e.createdAt,
      text: e.content,
      metadata: {
        if (e.tag != null) 'tag': e.tag,
        'sortIndex': e.sortIndex, // optional, for debugging
      },
    );
  }

  /// UI / Remote → Entity
  static MessageEntity toEntity(
    Message msg,
    String groupId, {
    MessageEntity? existing,
  }) {
    final textMsg = msg as TextMessage;

    // 🔒 Freeze ordering
    final sortIndex =
        existing?.sortIndex ??
        (msg.createdAt ?? DateTime.now()).microsecondsSinceEpoch;

    final createdAt = msg.createdAt ?? DateTime.now();

    return MessageEntity(
      id: msg.id,
      groupId: groupId,
      authorId: msg.authorId,
      content: textMsg.text,
      createdAt: createdAt,
      sortIndex: sortIndex,
      tag: msg.metadata?['tag'] as String?,
    );
  }
}
