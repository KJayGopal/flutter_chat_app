import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/Clans/chatLoadUI/chat_bubble_skeleton_UI.dart';

class ChatSkeletonList extends StatelessWidget {
  const ChatSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      itemCount: 15,
      itemBuilder: (_, i) {
        return ChatBubbleSkeletonUi(isMe: i.isEven);
      },
    );
  }
}
