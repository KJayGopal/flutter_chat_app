// import 'package:flutter/material.dart';
// import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_demo/features/auth/auth_service.dart';

class ClanService {
  // ClanService._();
  final authService = AuthService();
  final SupabaseClient _supabase;
  // static final ClanService _instance = ClanService._internal();
  // factory ClanService() => _instance;
  // ClanService._internal();
  ClanService(this._supabase);

  // Fetch groups currect user is the part of
  Future<List<Map<String, dynamic>>> fetchUserGroups(String userId) async {
    final res = await _supabase
        .from('group_memberships')
        .select('groups(*)')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(res.map((e) => ['groups']));
  }

  // create a new group/clan

  Future<void> createGroup({
    required String name,
    String? description,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser!;
    final group = await _supabase
        .from('groups')
        .insert({
          'name': name,
          'description': description,
          'avatar_url': avatarUrl,
          'admin_id': user.id,
        })
        .select()
        .single();

    await _supabase.from('group_memberships').insert({
      'group_id': group['id'],
      'user_id': user.id,
      'role': 'admin',
    });
  }

  ////////////////////////  Fetch User Clans  ////////////////////////////
  Future<List<Map<String, dynamic>>> fetchUserClans(String userId) async {
    final res = await _supabase
        .from('groups')
        .select('id, name, avatar_url, last_message, last_message_at')
        .order('last_message_at', ascending: false)
        .limit(50);
    // final res = await _supabase
    //   .from('group_memberships')
    //   .select('groups(*)')
    //   .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(res);
  }

  //// Fetch group data //////

  Future<List<Map<String, dynamic>>> fetchClans() async {
    // final _supabase = Supabase.instance.client;
    // final userId = _supabase.auth.currentUser!.id;

    final res = await _supabase
        .from('groups')
        .select('''
      id,
      name,
      avatar_url,
      group_posts (
        content,
        created_at
      ),
      group_read_cursors (
        last_read_at
      )
    ''')
        .order('created_at', referencedTable: 'group_posts', ascending: false);
    print(res);
    final List<Map<String, dynamic>> clans = [];

    for (final g in res as List<dynamic>) {
      final posts = g['group_posts'] as List<dynamic>;
      final lastPost = posts.isNotEmpty ? posts.first : null;
      final lastMessage = lastPost?['content'];
      final lastMessageAt = lastPost?['created_at'];

      // Compute unread count
      final cursor = (g['group_read_cursors'] as List?)?.isNotEmpty == true
          ? g['group_read_cursors'][0]['last_read_at']
          : null;

      int unreadCount = 0;
      if (lastMessageAt != null && cursor != null) {
        if (DateTime.parse(lastMessageAt).isAfter(DateTime.parse(cursor))) {
          unreadCount = 1;
        }
      }

      clans.add({
        'id': g['id'],
        'name': g['name'],
        'avatar_url': g['avatar_url'],
        'last_message': lastMessage,
        'last_message_at': lastMessageAt,
        'unread_count': unreadCount,
      });
    }

    return clans;
  }

  //////////////////////////// Fetch Latest Messages //////////////////////////

  Future<List<Map<String, dynamic>>> fetchMessagesBefore(
    String groupId, {
    required DateTime before,
    int limit = 30,
  }) async {
    final res = await _supabase
        .from('group_posts')
        .select()
        .eq('group_id', groupId)
        .lt('created_at', before.toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit);

    // reverse so UI order is correct (old -> new)
    return List<Map<String, dynamic>>.from(res).reversed.toList();
  }

  Future<List<Map<String, dynamic>>> fetchLatestMessages(
    String groupId, {
    int limit = 50,
  }) async {
    final res = await _supabase
        .from('group_posts')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(res).reversed.toList();
  }

  /////////////  Stream service //////////////
  /// Realtime stream of messages for a group

  Stream<List<Map<String, dynamic>>> messageStream(String groupId) {
    return _supabase
        .from('group_posts')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: false);
  }

  // Send text msg
  // Future<void> sendTextMessage({
  //   required String groudId,
  //   required String content,
  //   //  String? created_at,
  //   // required String username,
  //   String? tag,
  // }) async {
  //   final user = _supabase.auth.currentUser!;
  //   await _supabase.from('group_posts').insert({
  //     'group_id': groudId,
  //     'user_id': user.id,
  //     'content': content,
  //     // 'created_at': created_at,
  //     // 'username': username,
  //     'tag': tag,
  //   });
  //   // print("$created_at created at");
  // }

  //Send media message
  Future<void> sendMediaMessage({
    required String groupId,
    required String mediaUrl,
    required String tag,
  }) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('group_posts').insert({
      'group_id': groupId,
      'user_id': user.id,
      'media_url': mediaUrl,
      'tag': tag,
    });
  }

  Future<void> markGroupRead(String groupId) async {
    final user = _supabase.auth.currentUser!;

    await _supabase.from('group_read_cursors').upsert({
      'group_id': groupId,
      'user_id': user.id,
      'last_read_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'group_id,user_id');
  }

  /// Count unread messages in a group
  Future<int> unreadCount(String groupId) async {
    final user = _supabase.auth.currentUser!;
    final res = await _supabase.rpc(
      'count_unread_messages',
      params: {'p_group_id': groupId, 'p_user_id': user.id},
    );

    return res as int;
  }

  /* -------------------------------------------------------------------------- */
  /*                               REACTIONS                                    */
  /* -------------------------------------------------------------------------- */

  Future<void> addReaction({
    required String postId,
    required String reaction,
  }) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('post_reactions').insert({
      'post_id': postId,
      'user_id': user.id,
      'reaction_type': reaction,
    });
  }

  Future<void> removeReaction(String postId) async {
    final user = _supabase.auth.currentUser!;
    await _supabase
        .from('post_reactions')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);
  }

  /// Resolve user info for chat UI
  Future<Map<String, dynamic>> resolveUser(String userId) async {
    final data = await _supabase
        .from('users_data')
        .select('username, avatar_url')
        .eq('id', userId)
        .single();

    return data;
  }

  /// Is user in a group -> i have not applied this yet.
  Future<bool> isUserInGroup(String groupId) async {
    final user = _supabase.auth.currentUser!;
    final res = await _supabase
        .from('group_memberships')
        .select('id')
        .eq('group_id', groupId)
        .eq('user_id', user.id)
        .maybeSingle();

    return res != null;
  }
}
