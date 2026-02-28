// providers/chat_controller_provider.dart
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ui_demo/CommunityPage/provider/chat_provider.dart';

final chatControllerProvider = Provider.family<ChatController, String>((
  ref,
  groupId,
) {
  final controller = InMemoryChatController();
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
