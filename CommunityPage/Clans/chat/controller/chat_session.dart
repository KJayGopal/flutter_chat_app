// lib/chat/controller/chat_session.dart

import 'package:ui_demo/CommunityPage/data/repositories/chat_repository.dart';

import '../cache/chat_session_cache.dart';
// import '../data/chat_repository.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class ChatSession {
  final String groupId;
  final ChatRepository repo;

  ChatSession({required this.groupId, required this.repo});

  /// Load messages in WhatsApp order:
  /// memory → hive
  Future<List<Message>> loadInitialMessages() async {
    // 1️⃣ Memory
    final cached = ChatSessionCache.get(groupId);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 2️⃣ Hive
    final entities = repo.local.loadMessages(groupId);

    final messages = entities.map((e) {
      return TextMessage(
        id: e.id,
        author: User(id: e.authorId),
        text: e.content,
        createdAt: e.createdAt.millisecondsSinceEpoch,
      );
    }).toList();

    //  Warm memory
    ChatSessionCache.set(groupId, messages);

    return messages;
  }

  /// Add new messages + keep memory in sync
  void appendMessages(List<TextMessage> messages) {
    final existing = ChatSessionCache.get(groupId) ?? [];
    final updated = [...messages, ...existing];

    ChatSessionCache.set(groupId, updated);
  }
}
