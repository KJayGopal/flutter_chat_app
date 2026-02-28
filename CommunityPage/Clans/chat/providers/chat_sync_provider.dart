import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_demo/CommunityPage/provider/chat_provider.dart';

final chatSyncProvider = Provider.family<void, String>((ref, groupId) async {
  ref.keepAlive(); // now this actually works

  debugPrint('🟢 chatSyncProvider START for $groupId');

  final repo = ref.read(chatRepositoryProvider);

  // 1️⃣ History fetch
  try {
    final remoteMessages = await repo.remote.fetchMessages(groupId);
    debugPrint('📥 fetched ${remoteMessages.length} messages');

    if (remoteMessages.isNotEmpty) {
      await repo.local.saveRemoteMessages(remoteMessages);
    }
  } catch (e) {
    debugPrint('⚠️ history fetch failed: $e');
  }

  // 2️⃣ Realtime
  final sub = repo.remote
      .subscribe(groupId)
      .listen(
        (remoteMsg) async {
          debugPrint('🔥 REALTIME EVENT: ${remoteMsg.id}');
          await repo.local.saveRemoteMessage(remoteMsg);
        },
        onError: (e) {
          debugPrint('❌ realtime error: $e');
        },
      );

  ref.onDispose(() {
    debugPrint('🧹 chatSyncProvider DISPOSE for $groupId');
    sub.cancel();
  });
});
