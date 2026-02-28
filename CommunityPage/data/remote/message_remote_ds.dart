import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_demo/CommunityPage/data/remote/remote_message.dart';
// import '../local/message_entity.dart';

// class MessageRemoteDataSource {
//   final SupabaseClient _client;

//   MessageRemoteDataSource(this._client);

//   /// One-time fetch
//   Future<List<MessageEntity>> fetchMessages(String groupId) async {
//     final res = await _client
//         .from('group_posts')
//         .select()
//         .eq('group_id', groupId)
//         .order('created_at');

//     return (res as List).map((e) => MessageEntity.fromMap(e)).toList();
//   }

//   /// Realtime
//   // Stream<MessageEntity> subscribe(String groupId) {
//   //   return _client
//   //       .from('group_posts')
//   //       .stream(primaryKey: ['id'])
//   //       .eq('group_id', groupId)
//   //       .map((rows) => MessageEntity.fromMap(rows.last));
//   // }

//   Stream<MessageEntity> subscribe(String groupId) {
//     return _client
//         .from('group_posts')
//         .stream(primaryKey: ['id'])
//         .eq('group_id', groupId)
//         .map((rows) {
//           if (rows.isEmpty) return null; // optional null check
//           return MessageEntity.fromMap(rows.last); // single item
//         })
//         .where((msg) => msg != null) // filter nulls
//         .cast<MessageEntity>(); // cast to correct type
//   }

//   /// Send a message online
//   Future<void> sendMessage(MessageEntity msg) async {
//     await _client.from('group_posts').insert({
//       // 'id': msg.id,
//       'group_id': msg.groupId,
//       'user_id': msg.authorId,
//       'content': msg.content,
//       'tag': msg.tag,
//     });
//   }
// }

class MessageRemoteDataSource {
  final SupabaseClient _client;

  MessageRemoteDataSource(this._client);

  // Future<List<MessageEntity>> fetchMessages(String groupId) async {
  //   final res = await _client
  //       .from('group_posts')
  //       .select()
  //       .eq('group_id', groupId)
  //       .order('created_at', ascending: true);
  //   final ms1 = <MessageEntity>[];
  //   for (final i in ms1) {
  //     print('sortindex: ${i.sortIndex} and index: ${i.id}');
  //   }

  //   return (res as List<dynamic>)
  //       .map((e) => MessageEntity.fromMap(e as Map<String, dynamic>))
  //       .toList();
  // }
  Future<List<RemoteMessage>> fetchMessages(String groupId) async {
    final res = await _client
        .from('group_posts')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: true);

    return (res as List).map((e) => RemoteMessage.fromMap(e)).toList();
  }

  // Stream<MessageEntity> subscribe(String groupId) {
  //   final controller = StreamController<MessageEntity>();

  //   final channel = _client.channel('group_posts_realtime')
  //     ..onPostgresChanges(
  //       event: PostgresChangeEvent.insert,
  //       schema: 'public',
  //       table: 'group_posts',
  //       callback: (payload) {
  //         final row = payload.newRecord;
  //         if (row == null) return;

  //         // 🔑 FILTER IN APP, NOT IN SUPABASE
  //         if (row['group_id'] != groupId) return;

  //         controller.add(MessageEntity.fromMap(row));
  //       },
  //     )
  //     ..subscribe();

  //   controller.onCancel = () {
  //     _client.removeChannel(channel);
  //   };

  //   return controller.stream;
  // }
  Stream<RemoteMessage> subscribe(String groupId) {
    final controller = StreamController<RemoteMessage>.broadcast();

    final channel = _client.channel('group_posts_realtime')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'group_posts',
        callback: (payload) {
          final row = payload.newRecord;
          if (row == null) return;

          // filter in app
          if (row['group_id'] != groupId) return;

          debugPrint('🔥 REALTIME EMIT ${row['id']}');
          controller.add(RemoteMessage.fromMap(row));
        },
      )
      ..subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }

  // Stream<MessageEntity> subscribe(String groupId) {
  //   return _client
  //       .from('group_posts')
  //       .stream(primaryKey: ['id'])
  //       .eq('group_id', groupId)
  //       .expand((rows) => rows.map((row) => MessageEntity.fromMap(row)));
  // }

  Future<RemoteMessage> sendMessage(RemoteMessage msg) async {
    final response = await _client
        .from('group_posts')
        .insert({
          'group_id': msg.groupId,
          'user_id': msg.authorId,
          'content': msg.content,
          'tag': msg.tag,
        })
        .select()
        .single(); // ← THIS IS CRITICAL

    return RemoteMessage.fromMap(response);
  }
}
