import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/Clans/chatLoadUI/chat_skeleton_ui.dart';

class Chatloadingscreen extends StatelessWidget {
  const Chatloadingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: const [Expanded(child: ChatSkeletonList())]);
  }
}
