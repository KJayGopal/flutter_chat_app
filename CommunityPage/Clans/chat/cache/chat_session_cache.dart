// lib/chat/cache/chat_session_cache.dart

import 'package:flutter_chat_types/flutter_chat_types.dart';

class ChatSessionCache {
  static final Map<String, List<TextMessage>> _cache = {};

  static List<TextMessage>? get(String chatId) {
    return _cache[chatId];
  }

  static void set(String chatId, List<TextMessage> messages) {
    _cache[chatId] = List.unmodifiable(messages);
  }

  static void clear(String chatId) {
    _cache.remove(chatId);
  }

  static void clearAll() {
    _cache.clear();
  }
}
