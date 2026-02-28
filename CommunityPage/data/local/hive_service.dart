// ignore: depend_on_referenced_packages
import 'package:hive/hive.dart';
import 'message_entity.dart';

class HiveService {
  static const _messagesBoxName = 'messages_box';
  static const _groupIndexBoxName = 'group_index_box';

  // ---- Boxes ----

  Future<LazyBox<MessageEntity>> _messagesBox() async {
    return Hive.openLazyBox<MessageEntity>(_messagesBoxName);
  }

  Future<Box<List<String>>> _groupIndexBox() async {
    return Hive.openBox<List<String>>(_groupIndexBoxName);
  }

  // ---- Read messages for a group ----

  Future<List<MessageEntity>> getMessages(String groupId) async {
    final messagesBox = await _messagesBox();
    final indexBox = await _groupIndexBox();

    final msgIds = indexBox.get(groupId) ?? [];

    final messages = <MessageEntity>[];
    for (final id in msgIds) {
      final msg = await messagesBox.get(id);
      if (msg != null) messages.add(msg);
    }

    // Stable ordering for animated lists
    messages.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    return messages;
  }

  // ---- Insert / Update messages ----

  Future<void> upsertMessages(List<MessageEntity> messages) async {
    final messagesBox = await _messagesBox();
    final indexBox = await _groupIndexBox();

    for (final m in messages) {
      // store message
      await messagesBox.put(m.id, m);

      // update group index
      final ids = indexBox.get(m.groupId) ?? [];
      if (!ids.contains(m.id)) {
        ids.add(m.id);
        await indexBox.put(m.groupId, ids);
      }
    }
  }

  // ---- Clear messages for one group ----

  Future<void> clearGroup(String groupId) async {
    final messagesBox = await _messagesBox();
    final indexBox = await _groupIndexBox();

    final ids = indexBox.get(groupId) ?? [];

    for (final id in ids) {
      await messagesBox.delete(id);
    }

    await indexBox.delete(groupId);
  }
}
