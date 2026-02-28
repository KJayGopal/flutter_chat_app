// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:ui_demo/CommunityPage/Clans/clan_service.dart';
// import '../data/local/message_entity.dart';
// import '../data/remote/message_local_ds.dart';
// import '../data/remote/message_remote_ds.dart';
// import '../data/repositories/chat_repository.dart';
// import 'package:flutter_chat_core/flutter_chat_core.dart';

// final supabaseProvider = Provider<SupabaseClient>(
//   (ref) => Supabase.instance.client,
// );

// final clanServiceProvider = Provider<ClanService>((ref) {
//   return ClanService(ref.read(supabaseProvider));
// });

// final hiveBoxProvider = Provider<Box<MessageEntity>>((ref) {
//   return Hive.box<MessageEntity>('messages');
// });

// final messageLocalDataSourceProvider = Provider<MessageLocalDataSource>((ref) {
//   return MessageLocalDataSource(ref.read(hiveBoxProvider));
// });

// final messageRemoteDataSourceProvider = Provider<MessageRemoteDataSource>((
//   ref,
// ) {
//   return MessageRemoteDataSource(ref.read(supabaseProvider));
// });

// final chatRepositoryProvider = Provider<ChatRepository>((ref) {
//   return ChatRepository(
//     local: ref.read(messageLocalDataSourceProvider),
//     remote: ref.read(messageRemoteDataSourceProvider),
//   );
// });

// final chatMessagesProvider = StreamProvider.family<List<Message>, String>((
//   ref,
//   groupId,
// ) {
//   final repo = ref.watch(chatRepositoryProvider);
//   return repo.watchMessages(groupId);
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

import 'package:ui_demo/CommunityPage/Clans/clan_service.dart';
import 'package:ui_demo/CommunityPage/data/local/users_entity.dart';
import 'package:ui_demo/CommunityPage/data/remote/message_local_ds.dart';
import 'package:ui_demo/CommunityPage/data/remote/users_local_ds.dart';
import 'package:ui_demo/features/auth/auth_service.dart';
import '../data/local/message_entity.dart';
// import '../data/local/message_local_ds.dart';
import '../data/remote/message_remote_ds.dart';
import '../data/repositories/chat_repository.dart';

/// ----------------------------
/// Core Providers
/// ----------------------------

/// AuthService provider

final authServiceProvider = Provider<AuthService>((ref) {
  // final supabase = ref.read(supabaseProvider);
  return AuthService();
});

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final clanServiceProvider = Provider<ClanService>((ref) {
  return ClanService(ref.read(supabaseProvider));
});

final hiveBoxProvider = Provider<Box<MessageEntity>>((ref) {
  return Hive.box<MessageEntity>('messages');
});
// user box provider
final usersBoxProvider = Provider<Box<UserEntity>>((ref) {
  return Hive.box<UserEntity>('users');
});

/// ----------------------------
/// Data Sources
/// ----------------------------

final messageLocalDataSourceProvider = Provider<MessageLocalDataSource>((ref) {
  return MessageLocalDataSource(ref.read(hiveBoxProvider));
});

final messageRemoteDataSourceProvider = Provider<MessageRemoteDataSource>((
  ref,
) {
  return MessageRemoteDataSource(ref.read(supabaseProvider));
});

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return UserLocalDataSource(ref.read(usersBoxProvider));
});

/// ----------------------------
/// Repository
/// ----------------------------

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    local: ref.read(messageLocalDataSourceProvider),
    remote: ref.read(messageRemoteDataSourceProvider),
  );
});

/// ----------------------------
/// READ: Messages Stream
/// ----------------------------

final chatMessagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  groupId,
) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(groupId);
});

/// ----------------------------
/// WRITE: Chat Actions
/// ----------------------------

final chatActionsProvider = Provider<ChatActions>((ref) {
  return ChatActions(
    ref.read(chatRepositoryProvider),
    ref.read(supabaseProvider),
    ref.read(userLocalDataSourceProvider),
  );
});

class ChatActions {
  final ChatRepository _repo;
  final SupabaseClient _supabase;
  final UserLocalDataSource _userLocal;
  ChatActions(this._repo, this._supabase, this._userLocal);

  ///  THIS is where "send message" lives
  Future<Message> sendText(String groupId, String text) async {
    if (text.trim().isEmpty) {
      throw Exception('Cannot send empty message');
    }

    final userId = _supabase.auth.currentUser!.id;

    final response = await _repo.sendTextMessage(
      groupId: groupId,
      content: text,
      authorId: userId,
    );
    return TextMessage(
      id: response.id,
      authorId: response.authorId,
      text: response.text,
      createdAt: response.createdAt,
    );
  }

  Future<void> preloadUsersFromMessages(List<Message> messages) async {
    final userIds = messages.map((m) => m.authorId).toSet();

    final missing = userIds
        .where((id) => _userLocal.getUser(id) == null)
        .toList();

    if (missing.isEmpty) return;

    try {
      final res = await _supabase
          .from('users_data')
          .select('id, username')
          .inFilter('id', missing);

      final users = res.map<UserEntity>((row) {
        return UserEntity(id: row['id'], name: row['username'] ?? 'Unknown');
      }).toList();

      await _userLocal.saveUsers(users);
    } catch (_) {
      // offline-safe
    }
  }
}
