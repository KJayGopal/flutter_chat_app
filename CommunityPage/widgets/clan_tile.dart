import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/Clans/clan_page.dart';
import 'package:ui_demo/features/auth/auth_service.dart';

// import '../screens/clan_chat_screen.dart';
final authService = AuthService();

class GroupTile extends StatelessWidget {
  final String groupId;
  final String name;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const GroupTile({
    super.key,
    required this.groupId,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClanChatScreen(
              groupId: groupId,
              groupName: name,
              username: authService.userName ?? "You",
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _Avatar(avatarUrl: avatarUrl, name: name),
            const SizedBox(width: 12),
            Expanded(child: _Content(name, lastMessage)),
            _Trailing(unreadCount, lastMessageAt),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _Avatar({this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.blueGrey.shade200,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              name.characters.first.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}

class _Trailing extends StatelessWidget {
  final int unreadCount;
  final DateTime? lastMessageAt;

  const _Trailing(this.unreadCount, this.lastMessageAt);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTime(lastMessageAt),
          style: TextStyle(
            fontSize: 12,
            color: unreadCount > 0 ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        if (unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';

    final messageTime = dt.toUtc();
    final now = DateTime.now().toUtc();

    final diff = now.difference(messageTime);

    print("$messageTime input time");
    print("now $now");
    print("diff $diff");

    if (diff.inDays > 0) return '${dt.day}/${dt.month}/${dt.year}';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  // static String _formatTime(DateTime? dt) {
  //   if (dt == null) return '';

  //   final now = DateTime.now();
  //   final diff = dt.difference(now);
  //   print("${dt} input time");
  //   print("now $now");
  //   print("diff $diff");
  //   if (diff.inSeconds < 30) return 'now';
  //   if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  //   if (diff.inHours < 24) return '${diff.inHours}h';
  //   return '${diff.inDays}d';
  // }
}

class _Content extends StatelessWidget {
  final String name;
  final String? lastMessage;

  const _Content(this.name, this.lastMessage);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lastMessage ?? 'No messages yet!!!',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
