// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_core/flutter_chat_core.dart';
// import 'package:ui_demo/CommunityPage/data/remote/message_local_ds.dart';
// import 'package:ui_demo/CommunityPage/data/remote/message_remote_ds.dart';
// import '../mappers/message_mapper.dart';

// class ChatRepository {
//   final MessageLocalDataSource local;
//   final MessageRemoteDataSource remote;

//   ChatRepository({required this.local, required this.remote});

//   /// Offline-first: emits cached messages first, then remote updates
//   Stream<List<Message>> watchMessages(String groupId) async* {
//     // FETCH HISTORY ONCE
//     final remoteMessages = await remote.fetchMessages(groupId);
//     await local.saveMessages(remoteMessages);

//     //  START REALTIME → HIVE
//     final sub = remote.subscribe(groupId).listen((entity) async {
//       await local.saveMessage(entity);
//     });

//     //  UI ONLY LISTENS TO HIVE
//     yield* local
//         .watchMessages(groupId)
//         .map((list) => list.map(MessageMapper.toUi).toList());

//     //  CLEANUP (VERY IMPORTANT)
//     await sub.cancel();
//   }

//   /// Send a message (offline-first)
//   Future<void> sendMessage(String groupId, Message msg) async {
//     final entity = MessageMapper.toEntity(
//       msg,
//       groupId,
//     ); //  convert to Hive entity
//     await local.saveMessage(entity); // save locally immediately

//     try {
//       await remote.sendMessage(
//         entity,
//       ); // only if your remote datasource supports it
//     } catch (e, st) {
//       debugPrint('SEND MESSAGE FAILED: $e');
//       debugPrintStack(stackTrace: st);
//       rethrow;
//       // fail silently; will sync later when online
//     }
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
// import 'package:ui_demo/CommunityPage/data/local/message_entity.dart';
import 'package:ui_demo/CommunityPage/data/remote/message_local_ds.dart';
import 'package:ui_demo/CommunityPage/data/remote/remote_message.dart';

// import '../local/message_local_ds.dart';
import '../remote/message_remote_ds.dart';
import '../mappers/message_mapper.dart';

import 'package:flutter/widgets.dart';

class ChatRepository {
  final MessageLocalDataSource local;
  final MessageRemoteDataSource remote;

  ChatRepository({required this.local, required this.remote});

  Stream<List<Message>> watchMessages(String groupId) {
    _startRemoteSyncAfterFirstFrame(groupId);

    return local
        .watchMessages(groupId)
        .map(
          (entities) =>
              entities.map(MessageMapper.toUi).toList(growable: false),
        );
  }

  // void _startRemoteSyncAfterFirstFrame(String groupId) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     // 1 Fetch history AFTER UI frame
  //     final remoteMessages = await remote.fetchMessages(groupId);
  //     await local.saveMessages(remoteMessages);

  //     //  Start realtime subscription AFTER history
  //     remote.subscribe(groupId).listen((entity) async {
  //       await local.saveMessage(entity);
  //     });
  //   });
  // }

  void _startRemoteSyncAfterFirstFrame(String groupId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1️⃣ History
      try {
        final remoteMessages = await remote.fetchMessages(groupId);

        if (remoteMessages.isNotEmpty) {
          remoteMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          await local.saveRemoteMessages(remoteMessages);
        }
      } catch (e) {
        debugPrint('Offline: skipping history fetch');
      }

      // 2️⃣ Realtime
      try {
        remote
            .subscribe(groupId)
            .listen(
              (remoteMsg) async {
                await local.saveRemoteMessage(remoteMsg);
              },
              onError: (e) {
                debugPrint('Realtime error: $e');
              },
            );
      } catch (e) {
        debugPrint('Realtime subscription failed: $e');
      }
    });
  }

  // void _startRemoteSyncAfterFirstFrame(String groupId) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     // 1 Fetch history safely
  //     List<RemoteMessage> remoteMessages = [];
  //     try {
  //       remoteMessages = await remote.fetchMessages(groupId);
  //     } catch (e) {
  //       debugPrint('Offline: skipping history fetch');
  //     }

  //     if (remoteMessages.isNotEmpty) {
  //       // 🔑 SORT ONCE — oldest → newest
  //       remoteMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

  //       // 🔑 ATOMIC SAVE — single Hive emit
  //       await local.saveRemoteMessages(remoteMessages);
  //     }

  //     //  Start realtime AFTER history
  //     try {
  //       remote
  //           .subscribe(groupId)
  //           .listen(
  //             (remoteMsg) async {
  //               await local.saveRemoteMessage(remoteMsg);
  //             },
  //             onError: (e) {
  //               debugPrint('Realtime error: $e');
  //             },
  //           );
  //     } catch (e) {
  //       debugPrint('Realtime subscription failed: $e');
  //     }
  //   });
  // }

  Future<TextMessage> sendTextMessage({
    required String groupId,
    required String content,
    required String authorId,
  }) async {
    final now = DateTime.now().toUtc();

    // Send and get REAL data from server
    final realEntity = await remote.sendMessage(
      RemoteMessage(
        id: '',
        groupId: groupId,
        authorId: authorId,
        content: content,
        createdAt: now,
        // sortIndex: 0, // not needed here
        tag: null,
      ),
    );

    return TextMessage(
      id: realEntity.id, // REAL Supabase ID
      authorId: realEntity.authorId,
      text: realEntity.content,
      createdAt: realEntity.createdAt,
    );
  }
  // Future<TextMessage> sendTextMessage({
  //   required String groupId,
  //   required String content,
  //   required String authorId,
  // }) async {
  //   final now = DateTime.now().toUtc();

  //   final lastSortIndex = await local.getLastSortIndex(groupId) ?? 0;
  //   final tempSortIndex = lastSortIndex + 1;

  //   final optimistic = TextMessage(
  //     id: 'temp_${now.microsecondsSinceEpoch}_$tempSortIndex',
  //     authorId: authorId,
  //     text: content,
  //     createdAt: now,
  //   );

  //   // NO local.saveMessage(optimisticEntity)

  //   unawaited(
  //     remote
  //         .sendMessage(
  //           MessageEntity(
  //             id: '',
  //             groupId: groupId,
  //             authorId: authorId,
  //             content: content,
  //             createdAt: now,
  //             sortIndex: tempSortIndex,
  //           ),
  //         )
  //         .catchError((e) => debugPrint('Send failed: $e')),
  //   );

  //   return optimistic;
  // }

  // Future<TextMessage> sendTextMessage({
  //   required String groupId,
  //   required String content,
  //   required String authorId,
  // }) async {
  //   final now = DateTime.now().toUtc();

  //   final msg = TextMessage(
  //     id: now.microsecondsSinceEpoch.toString(),
  //     authorId: authorId,
  //     text: content,
  //     createdAt: now,
  //   );

  //   final entity = MessageMapper.toEntity(msg, groupId);

  //   //  Optimistic local save
  //   await local.saveMessage(entity);

  //   // Best-effort remote send
  //   try {
  //     await remote.sendMessage(entity);
  //   } catch (e, st) {
  //     debugPrint('SEND FAILED (will retry later): $e');
  //     debugPrintStack(stackTrace: st);
  //     // DO NOT rethrow — offline-safe
  //   }

  //   return msg;
  // }
}
