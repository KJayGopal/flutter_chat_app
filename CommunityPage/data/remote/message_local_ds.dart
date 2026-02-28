import 'dart:async';

// import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:ui_demo/CommunityPage/data/local/hive_service.dart';
import 'package:ui_demo/CommunityPage/data/local/message_entity.dart';
import 'package:ui_demo/CommunityPage/data/remote/remote_message.dart';

// import 'package:hive/hive.dart';
// import 'message_entity.dart';

int _lastSortIndex = 0;

int _nextSortIndex() {
  final now = DateTime.now().microsecondsSinceEpoch;
  if (now <= _lastSortIndex) {
    _lastSortIndex++;
  } else {
    _lastSortIndex = now;
  }
  return _lastSortIndex;
}

class MessageLocalDataSource {
  // final HiveService _hiveService;
  final Box<MessageEntity> _box;

  MessageLocalDataSource(this._box);

  /// Read once
  List<MessageEntity> loadMessages(String groupId) {
    return _box.values.where((m) => m.groupId == groupId).toList()
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
  }

  Stream<List<MessageEntity>> watchMessages(String groupId) async* {
    yield _sortedForGroup(groupId);

    await for (final _ in _box.watch()) {
      yield _sortedForGroup(groupId);
    }
  }

  Future<void> saveRemoteMessages(List<RemoteMessage> incoming) async {
    for (final msg in incoming) {
      final existing = _box.get(msg.id);

      final entity = existing == null
          ? MessageEntity(
              id: msg.id,
              groupId: msg.groupId,
              authorId: msg.authorId,
              content: msg.content,
              createdAt: msg.createdAt,
              tag: msg.tag,
              sortIndex: _nextSortIndex(), // 🔒 assigned ONCE
            )
          : MessageEntity(
              id: msg.id,
              groupId: msg.groupId,
              authorId: msg.authorId,
              content: msg.content,
              createdAt: msg.createdAt,
              tag: msg.tag,
              sortIndex: existing.sortIndex, // 🔒 preserved
            );

      await _box.put(entity.id, entity);
    }
  }

  Future<void> saveRemoteMessage(RemoteMessage msg) async {
    final existing = _box.get(msg.id);

    final entity = existing == null
        ? MessageEntity(
            id: msg.id,
            groupId: msg.groupId,
            authorId: msg.authorId,
            content: msg.content,
            createdAt: msg.createdAt,
            tag: msg.tag,
            sortIndex: _nextSortIndex(), // 🔒 assigned once
          )
        : MessageEntity(
            id: msg.id,
            groupId: msg.groupId,
            authorId: msg.authorId,
            content: msg.content,
            createdAt: msg.createdAt,
            tag: msg.tag,
            sortIndex: existing.sortIndex, // 🔒 preserved
          );

    await _box.put(entity.id, entity);
  }

  // Stream<List<MessageEntity>> watchMessages(String groupId) async* {
  //   // 🔑 1️⃣ Emit cached messages immediately
  //   final initial = _box.values.where((m) => m.groupId == groupId).toList();

  //   yield initial;

  //   // 🔑 2️⃣ Then emit on every change
  //   await for (final _ in _box.watch()) {
  //     final updated = _box.values.where((m) => m.groupId == groupId).toList();

  //     yield updated;
  //   }
  // }

  // Stream<List<MessageEntity>> watchMessages(String groupId) {
  //   return _box.watch().map((_) {
  //     final messages = _box.values.where((m) => m.groupId == groupId).toList()
  //       ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

  //     return messages;
  //   });
  // }

  // Stream<List<MessageEntity>> watchMessages(String groupId) {
  //   // Emit initial state ONCE
  //   final controller = StreamController<List<MessageEntity>>();

  //   void emit() {
  //     final msgs = loadMessages(groupId)
  //       ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

  //     debugPrint('🟢 HIVE EMIT (${msgs.length} msgs)');
  //     for (final m in msgs) {
  //       debugPrint('id=${m.id} authorId=${m.authorId}');
  //     }

  //     controller.add(msgs);
  //   }

  //   // Initial emit
  //   emit();

  //   // Listen to Hive changes
  //   final sub = _box.watch().listen((_) {
  //     emit();
  //   });

  //   // Cleanup
  //   controller.onCancel = () async {
  //     await sub.cancel();
  //   };

  //   return controller.stream;
  // }

  Future<void> saveMessages(List<MessageEntity> incoming) async {
    for (final msg in incoming) {
      final existing = _box.get(msg.id);

      final entity = existing == null
          ? msg
          : msg.copyWith(
              sortIndex: existing.sortIndex, // 🔒 NEVER CHANGE ORDER
            );

      await _box.put(entity.id, entity);
    }
  }

  // Future<void> saveMessage(MessageEntity message) async {
  //   debugPrint(
  //     '💾 SAVING MESSAGE → id=${message.id} '
  //     'authorId=${message.authorId} ',
  //   );

  //   await _box.put(message.id, message);
  // }
  // Future<void> saveMessage(MessageEntity incoming) async {
  //   final existing = _box.get(incoming.id);

  //   final entity = existing == null
  //       ? incoming.copyWith(sortIndex: DateTime.now().microsecondsSinceEpoch)
  //       : incoming.copyWith(
  //           sortIndex: existing.sortIndex, // 🔒 NEVER CHANGE
  //         );

  //   await _box.put(entity.id, entity);
  // }

  List<MessageEntity> _sortedForGroup(String groupId) {
    final list = _box.values.where((m) => m.groupId == groupId).toList();
    list.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return list;
  }

  Future<void> saveMessage(MessageEntity incoming) async {
    final existing = _box.get(incoming.id);

    final entity = existing == null
        ? incoming.copyWith(sortIndex: _nextSortIndex())
        : incoming.copyWith(sortIndex: existing.sortIndex);

    await _box.put(entity.id, entity);
  }

  Future<int?> getLastSortIndex(String groupId) async {
    final messages = _box.values.where((m) => m.groupId == groupId).toList();

    if (messages.isEmpty) return null;

    return messages
        .map((m) => m.sortIndex)
        .whereType<int>()
        .reduce((max, current) => current > max ? current : max);
  }

  Future<void> save123Message(MessageEntity incoming) async {
    final existing = _box.get(incoming.id);

    if (existing != null) {
      // update content only
      await _box.put(
        incoming.id,
        existing.copyWith(content: incoming.content, tag: incoming.tag),
      );
    } else {
      // first time ever → assign stable index
      final entity = MessageEntity(
        id: incoming.id,
        groupId: incoming.groupId,
        authorId: incoming.authorId,
        content: incoming.content,
        createdAt: incoming.createdAt,
        tag: incoming.tag,
        sortIndex: existing?.sortIndex ?? DateTime.now().microsecondsSinceEpoch,
      );

      await _box.put(entity.id, entity);
    }
  }

  Future<void> clearGroup(String groupId) async {
    final keys = _box.keys.where((k) => _box.get(k)?.groupId == groupId);
    await _box.deleteAll(keys);
  }
}
