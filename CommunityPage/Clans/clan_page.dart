// lib/clan_chat_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ui_demo/CommunityPage/Clans/chat/date_header.dart';
import 'package:ui_demo/CommunityPage/Clans/chat/providers/chat_controller_provider.dart';
import 'package:ui_demo/CommunityPage/Clans/chat/providers/chat_sync_provider.dart';
import 'package:ui_demo/CommunityPage/Clans/clanOption/clan_option_page.dart';
// import 'package:ui_demo/CommunityPage/Clans/chatLoadUI/chatLoadingScreen.dart';
import 'package:ui_demo/CommunityPage/Clans/clan_drawer.dart';
import 'package:ui_demo/CommunityPage/Clans/custom_chatcomposer.dart';
import 'package:ui_demo/CommunityPage/data/local/users_entity.dart';
import 'package:ui_demo/CommunityPage/provider/chat_provider.dart';
import 'package:ui_demo/CommunityPage/widgets/dotBadge.dart';
import 'package:ui_demo/assets/components/customToggle.dart';
import 'package:ui_demo/themes/app_colors.dart';
import 'package:ui_demo/utils/size_configs.dart';

enum ChatLoadState { coldStart, hydrated, live }

class ClanChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String username;
  const ClanChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.username,
  });

  @override
  ConsumerState<ClanChatScreen> createState() => _ClanChatScreenState();
}

class _ClanChatScreenState extends ConsumerState<ClanChatScreen> {
  bool _composerInitialized = false;
  double composerHeight = 0;
  // bool _initialMessagesSet = false;
  // bool _usersPreloaded = false;
  // int _lastMessageCount = 0;
  // late final ChatController chatController;
  bool muteNotifications = false;
  bool disappearingMessages = false;
  final ScrollController _scrollController = ScrollController();
  bool isCollapsed = false;
  bool isOn = false;
  bool _showAttachments = false;
  // bool _listenerAttached = false;
  final _drawerkey = GlobalKey<ScaffoldState>();
  late final ChatTheme chatTheme;
  late final supabase.SupabaseClient _supabase;
  late final _currentUserId;
  late final _currentUsername;

  final ThemeData baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.componentShadow,
      surface: Colors.transparent,
      error: AppColors.primary,
    ),
  );

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = _dayOnly(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = _dayOnly(date);

    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';

    return DateFormat('EEE, d MMM').format(date); // Mon, 12 Jan
  }

  @override
  void initState() {
    super.initState();

    // chatController = InMemoryChatController();
    _supabase = supabase.Supabase.instance.client;
    final auth = ref.read(authServiceProvider);

    _currentUserId = auth.userId;
    _currentUsername = auth.userName;
    chatTheme = ChatTheme.fromThemeData(baseTheme).copyWith(
      colors: ChatTheme.fromThemeData(
        baseTheme,
      ).colors.copyWith(primary: AppColors.componentShadow),
    );
  }

  // void _syncMessages(List<Message> messages) {
  //   if (!mounted) return;

  //   // FIRST LOAD
  //   if (!_initialMessagesSet) {
  //     _chatController.setMessages(messages);
  //     _initialMessagesSet = true;
  //     return;
  //   }

  //   // INCREMENTAL ONLY
  //   final existingIds = _chatController.messages.map((m) => m.id).toSet();

  //   for (final msg in messages) {
  //     if (!existingIds.contains(msg.id)) {
  //       _chatController.insertMessage(msg);
  //     }
  //   }
  // }

  void _onScroll() {
    // Optional: implement loading older messages if needed
  }

  Future<User> _resolveUser(String userId) async {
    final user = ref.read(userLocalDataSourceProvider).getUser(userId);

    if (user != null) {
      return User(id: userId, name: user.name);
    }

    return User(id: userId, name: 'Loading…');
  }

  Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.componentShadow,
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSendPressed(String text) async {
    if (text.trim().isEmpty) return;

    final controller = ref.read(chatControllerProvider(widget.groupId));
    final currentUserId = ref.read(supabaseProvider).auth.currentUser!.id;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = TextMessage(
      id: tempId,
      authorId: currentUserId,
      text: text,
      createdAt: DateTime.now().toUtc(),
    );

    print('OPTIMISTIC INSERT: $tempId');
    await controller.insertMessage(optimisticMessage);

    try {
      final realMessage = await ref
          .read(chatActionsProvider)
          .sendText(widget.groupId, text);

      print('REAL FROM SERVER: ${realMessage.id}');

      // UPDATE in place — NO remove, NO insert → zero visual change!
      await controller.updateMessage(optimisticMessage, realMessage);

      print('SEAMLESS UPDATE: temp → real (no flash)');
    } catch (e) {
      print('SEND FAILED: $e');
      // Optional: mark as failed or remove
      await controller.removeMessage(optimisticMessage);
    }
  }

  // bool _isSending = false;
  // Future<void> _onSendPressed(String text) async {
  //   if (text.trim().isEmpty) return;
  //   // _isSending = true;
  //   final controller = ref.read(chatControllerProvider(widget.groupId));
  //   final currentUserId = ref.read(supabaseProvider).auth.currentUser!.id;

  //   final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
  //   final optimisticMessage = TextMessage(
  //     id: tempId,
  //     authorId: currentUserId,
  //     text: text,
  //     createdAt: DateTime.now(),
  //   );

  //   print('OPTIMISTIC INSERT: $tempId');
  //   await controller.insertMessage(optimisticMessage);

  //   try {
  //     final realMessage = await ref
  //         .read(chatActionsProvider)
  //         .sendText(widget.groupId, text);

  //     if (realMessage != null) {
  //       print(
  //         'REAL MESSAGE RECEIVED FROM SEND: ${realMessage.id} | text: "${(realMessage as TextMessage).text}"',
  //       );

  //       await controller.removeMessage(optimisticMessage);
  //       print('REMOVED OPTIMISTIC: $tempId');

  //       final alreadyExists = controller.messages.any(
  //         (m) => m.id == realMessage.id,
  //       );
  //       if (!alreadyExists) {
  //         await controller.insertMessage(realMessage);
  //         print('INSERTED REAL FROM SEND: ${realMessage.id}');
  //       } else {
  //         print('SKIPPED INSERT (already exists): ${realMessage.id}');
  //       }
  //     }
  //   } catch (e) {
  //     print('SEND FAILED: $e');
  //     await controller.removeMessage(optimisticMessage);
  //   }
  // }

  // Future<void> _onSendPressed(String text) async {
  //   if (text.trim().isEmpty) return;

  //   final controller = ref.read(
  //     chatControllerProvider(widget.groupId),
  //   ); // ← here
  //   final currentUserId = ref.read(supabaseProvider).auth.currentUser!.id;

  //   final tempId = DateTime.now().millisecondsSinceEpoch.toString();
  //   final optimisticMessage = TextMessage(
  //     id: tempId,
  //     authorId: currentUserId,
  //     text: text,
  //     createdAt: DateTime.now(),
  //   );

  //   await controller.insertMessage(optimisticMessage);

  //   try {
  //     final realMessage = await ref
  //         .read(chatActionsProvider)
  //         .sendText(widget.groupId, text);

  //     if (realMessage != null) {
  //       // Always remove optimistic first
  //       await controller.removeMessage(optimisticMessage);
  //       // Then insert real one (only if not already there — safety)
  //       if (!controller.messages.any((m) => m.id == realMessage.id)) {
  //         await controller.insertMessage(realMessage);
  //       }
  //     }
  //   } catch (e) {
  //     print('removing....');
  //     await controller.removeMessage(optimisticMessage);
  //     // optional: re-insert as failed
  //   }
  // }

  @override
  void dispose() {
    // _chatController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  User getUserSync(String userId) {
    // ME → auth
    if (userId == _currentUserId) {
      return User(id: userId, name: _currentUsername);
    }

    // OTHERS → Hive
    final entity = Hive.box<UserEntity>('users').get(userId);

    if (entity != null) {
      return User(id: entity.id, name: entity.name);
    }

    return User(id: userId, name: 'Unknown');
  }

  // This was the recent one...
  // User getUserSync(String userId) {
  //   final usersBox = Hive.box<UserEntity>('users');
  //   final entity = usersBox.get(userId);

  //   if (entity != null) {
  //     return User(id: entity.id, name: entity.name);
  //   }

  //   return User(id: userId, name: 'Unknown');
  // }

  // bool _hasLoadedInitial = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   if (!_hasLoadedInitial) {
  //     _hasLoadedInitial = true;
  //     print(' Loading initial messages for ${widget.groupId}');
  //     final messagesAsync = ref.read(chatMessagesProvider(widget.groupId));
  //     messagesAsync.whenData((messages) {
  //       final controller = ref.read(chatControllerProvider(widget.groupId));
  //       if (messages.isNotEmpty) {
  //         controller.setMessages(messages);
  //         setState(() {});
  //       }
  //     });
  //   }
  // }
  bool _initialHydrated = false;

  @override
  Widget build(BuildContext context) {
    final chatController = ref.watch(chatControllerProvider(widget.groupId));
    ref.watch(chatSyncProvider(widget.groupId));
    ref.listen<AsyncValue<List<Message>>>(
      chatMessagesProvider(widget.groupId),
      (prev, next) {
        next.whenData((messages) {
          if (messages.isEmpty) return;

          // 🔑 PHASE 1 — bulk hydrate ONCE
          if (!_initialHydrated) {
            chatController.setMessages(messages);
            _initialHydrated = true;
            debugPrint('✅ INITIAL BULK HYDRATE: ${messages.length}');
            return;
          }

          // 🔑 PHASE 2 — incremental only
          final existingIds = chatController.messages.map((m) => m.id).toSet();

          for (final msg in messages) {
            if (!existingIds.contains(msg.id)) {
              chatController.insertMessage(msg);
              debugPrint('➕ REALTIME INSERT: ${msg.id}');

              ref.read(chatActionsProvider).preloadUsersFromMessages([msg]);
            }
          }
        });
      },
    );

    // ref.listen<AsyncValue<List<Message>>>(
    //   chatMessagesProvider(widget.groupId),
    //   (previous, next) {
    //     next.whenData((messages) {
    //       if (messages.isEmpty) return;

    //       // hydrate ONCE, then incremental only
    //       if (chatController.messages.isEmpty) {
    //         chatController.setMessages(messages);
    //         debugPrint(' Hydrated ${messages.length} messages');
    //       }
    //     });
    //   },
    // );
    // // preload users (safe & side-effecty)
    // messagesAsync.whenData((messages) {
    //   ref.read(chatActionsProvider).preloadUsersFromMessages(messages);
    // });
    final isLoading = chatController.messages.isEmpty;
    SizeConfig.init(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _drawerkey,
      endDrawer: ClanDrawer(),
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 30, 25, 0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 0),
                        reverseTransitionDuration: const Duration(
                          milliseconds: 0,
                        ),
                        pageBuilder: (_, _, _) =>
                            ClanOptionPage(groupName: widget.groupName),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              final slide = Tween<Offset>(
                                begin: const Offset(0.02, 0),
                                end: Offset.zero,
                              ).animate(animation);

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: slide,
                                  child: child,
                                ),
                              );
                            },
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.componentShadow,
                        ),
                        // child: CircleAvatar(
                        //   radius: 24, // size
                        //   backgroundColor: Colors.grey[200],
                        //   backgroundImage: authService.avatarUrl != null
                        //       ? NetworkImage(authService.avatarUrl!)
                        //       : null, // fallback if null
                        //   child: authService.avatarUrl == null
                        //       ? Icon(Icons.person, color: Colors.white)
                        //       : null,
                        // ),
                      ),
                      SizedBox(width: 7.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.groupName}",
                            style: TextStyle(
                              fontFamily: "Jersey 10",
                              fontSize: 30,
                              height: .75,
                              color: AppColors.textWhite,
                            ),
                          ),
                          Text(
                            "Designation",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Icon(
                    Icons.settings_outlined,
                    size: 28,
                    color: AppColors.componentShadow,
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () => _drawerkey.currentState?.openEndDrawer(),
                  child: Dotbadge(
                    show: true,
                    size: 10,

                    child: Icon(
                      Icons.view_sidebar_outlined,
                      size: 30,
                      color: AppColors.componentShadow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.h),
          AnimatedContainer(
            duration: isCollapsed
                ? const Duration(milliseconds: 10) // opening
                : const Duration(milliseconds: 250), // closing
            curve: Curves.easeOut,
            width: isCollapsed ? width : 0,
            height: isCollapsed ? 150 : 0,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.background,

              // border: Border.all(
              //   color: Color.fromARGB(255, 197, 195, 195),
              //   width: 1,
              // ),
            ),
            child: isCollapsed
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      // shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      // padding: const EdgeInsets.all(10),
                      children: [
                        Row(
                          // spacing: 10,
                          children: [
                            Center(
                              child: SvgPicture.asset(
                                'assets/progress-clock.svg',
                                width: 35,
                                height: 35,
                                colorFilter: ColorFilter.mode(
                                  Color(0xFFA3A2A2),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Disappearing Messages",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textWhite,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  disappearingMessages ? "on" : "off",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textWhite,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Customtoggle(
                              isOn: isOn,
                              onChanged: (v) {
                                setState(() => disappearingMessages = v);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Center(
                              child: Icon(
                                Icons.volume_off,
                                size: 35,
                                color: Color(0xFFA3A2A2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  " Mute Notifications",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textWhite,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  muteNotifications ? "on" : "off",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textWhite,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Customtoggle(
                              isOn: isOn,
                              onChanged: (v) {
                                setState(() => muteNotifications = v);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showConfirmationDialog(
                              context,
                              'Exit Clan',
                              'Are you sure you want to exit the clan?',
                            );

                            if (confirm == true) {
                              // User confirmed exit
                              // Implement exit logic here
                            }
                          },
                          child: Row(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.exit_to_app,
                                  size: 35,
                                  color: AppColors.colorRed,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                " Exit Clan",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.colorRed,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                color: Color(0xFF202020),
                child: Column(
                  children: [
                    Expanded(
                      child: Chat(
                        // listType: ChatListType.reversed,
                        currentUserId: ref
                            .read(supabaseProvider)
                            .auth
                            .currentUser!
                            .id,
                        chatController: chatController,
                        resolveUser: _resolveUser,
                        theme: chatTheme,
                        builders: Builders(
                          composerBuilder: (context) => const SizedBox.shrink(),
                          textMessageBuilder:
                              (
                                context,
                                message,
                                index, {
                                MessageGroupStatus? groupStatus,
                                required bool isSentByMe,
                              }) {
                                final user = getUserSync(message.authorId);
                                final username = user.name ?? "unknown";

                                final createdAt =
                                    message.createdAt?.toLocal() ??
                                    DateTime.now().toLocal();
                                final time = TimeOfDay.fromDateTime(
                                  createdAt,
                                ).format(context);

                                final showAvatar = groupStatus?.isFirst ?? true;
                                final showTime = true;
                                final allMessages = chatController.messages;

                                final current = message;
                                final previous = index > 0
                                    ? allMessages[index - 1]
                                    : null;

                                final currentDay = DateTime(
                                  current.createdAt!.year,
                                  current.createdAt!.month,
                                  current.createdAt!.day,
                                );

                                final previousDay = previous == null
                                    ? null
                                    : DateTime(
                                        previous.createdAt!.year,
                                        previous.createdAt!.month,
                                        previous.createdAt!.day,
                                      );

                                final showDateHeader =
                                    previousDay == null ||
                                    currentDay != previousDay;

                                return Column(
                                  children: [
                                    if (showDateHeader)
                                      DateHeader(
                                        formatDayLabel(
                                          current.createdAt!.toLocal(),
                                        ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: showAvatar ? 8 : 2,
                                        // bottom: showTime ? 2 : 0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment: isSentByMe
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          /// LEFT AVATAR (others)
                                          if (!isSentByMe)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              child: showAvatar
                                                  ? CircleAvatar(
                                                      radius: 14,
                                                      backgroundImage:
                                                          user.imageSource !=
                                                              null
                                                          ? NetworkImage(
                                                              user.imageSource!,
                                                            )
                                                          : null,
                                                      backgroundColor:
                                                          Colors.grey,
                                                    )
                                                  : const SizedBox(width: 28),
                                            ),
                                          Flexible(
                                            child: Align(
                                              alignment: isSentByMe
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.72,
                                                ),
                                                child: IntrinsicWidth(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isSentByMe
                                                          ? Colors.blue.shade700
                                                          : Colors
                                                                .grey
                                                                .shade300,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize
                                                          .min, // IMPORTANT
                                                      crossAxisAlignment:
                                                          isSentByMe
                                                          ? CrossAxisAlignment
                                                                .end
                                                          : CrossAxisAlignment
                                                                .start,
                                                      children: [
                                                        if (showAvatar)
                                                          Text(
                                                            username,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                          ),

                                                        Text(
                                                          message.text,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                            color: isSentByMe
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 2,
                                                        ),

                                                        Text(
                                                          time,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .black45,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          /// RIGHT AVATAR (me fuckeer)
                                          if (isSentByMe)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 6,
                                              ),
                                              child: showAvatar
                                                  ? CircleAvatar(
                                                      radius: 14,
                                                      backgroundImage:
                                                          user.imageSource !=
                                                              null
                                                          ? NetworkImage(
                                                              user.imageSource!,
                                                            )
                                                          : null,
                                                      backgroundColor:
                                                          Colors.grey,
                                                    )
                                                  : const SizedBox(width: 28),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CustomChatComposer(
                          users: [],
                          tags: [],
                          onSend: _onSendPressed,
                          onToggleAttachments: () {
                            setState(() {
                              _showAttachments = !_showAttachments;
                            });
                          },
                          showAttachments: _showAttachments,
                          onHeightChanged: (hi) {
                            if (!_composerInitialized) {
                              composerHeight = hi; // silent initial set
                              _composerInitialized = true;
                              return;
                            }

                            setState(() {
                              composerHeight = hi; // animate from now on
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
