// import 'dart:math';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ui_demo/CommunityPage/Clans/CreateClans/create_clan_success.dart';
import 'package:ui_demo/CommunityPage/Clans/clan_service.dart';
import 'package:ui_demo/assets/components/customToggle.dart';
import 'package:ui_demo/themes/app_colors.dart';

class CreateClanPage extends StatefulWidget {
  const CreateClanPage({super.key});

  @override
  State<CreateClanPage> createState() => _CreateClanPageState();
}

class _CreateClanPageState extends State<CreateClanPage> {
  bool isOn = true;
  bool disableConversations = true;
  bool disableInvites = true;
  bool approveMembers = true;
  bool disappearingMessages = true;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _clanController = TextEditingController();
  final double _lineHeight = 1.4 * 16;
  static const double _fontSize = 16;
  static const double _lineSpacing = 1.4;
  final ScrollController _scrollController = ScrollController();
  late final ClanService _clanService;
  late final supabase.SupabaseClient _supabase;

  static const int _maxLines = 4;

  late final double _baselineOffset;

  bool isLoading = false;
  void onCreate() async {
    if (isLoading) return; // debounce guard
    setState(() {
      isLoading = true;
    });
    // print("hii");
    final clanName = _clanController.text;
    final clanDescripton = _controller.text;
    // final overlay = Overlay.of(context);
    try {
      await _clanService.createGroup(
        name: clanName,
        description: clanDescripton,
      );
      showPaymentSuccess(context);
    } catch (e) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> showPaymentSuccess(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const CreateClanSuccess(),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.of(context).pop(); // close overlay
    }
    // Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final painter = TextPainter(
      text: const TextSpan(
        text: 'A',
        style: TextStyle(fontSize: _fontSize, height: _lineSpacing),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _baselineOffset = painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
  }

  @override
  void initState() {
    super.initState();
    _supabase = supabase.Supabase.instance.client;
    _clanService = ClanService(_supabase);
  }

  @override
  void dispose() {
    _controller.dispose();
    _clanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Clan",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontFamily: "Jersey 10",
                  fontSize: 40,
                ),
              ),

              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.componentShadow,
                    child: Center(child: Icon(Icons.edit, size: 30)),
                  ),
                  SizedBox(width: 10),
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: Center(
                        child: TextField(
                          controller: _clanController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            // fillColor:,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.componentShadow,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 50),

              Center(
                child: Container(
                  width: size.width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.componentShadow,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Description:",
                          style: TextStyle(color: AppColors.textFadeWhite),
                        ),
                      ),
                      const SizedBox(height: 8),

                      //  FIXED HEIGHT INPUT AREA (NO MediaQuery math here)
                      SizedBox(
                        height: _lineHeight * _maxLines + 16,
                        child: Stack(
                          children: [
                            //  lines that MOVE with text scroll
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _scrollController,
                                _controller,
                              ]),
                              builder: (_, _) {
                                return CustomPaint(
                                  size: Size.infinite,
                                  painter: _ScrollingLinePainter(
                                    lineHeight: _lineHeight,
                                    text: _controller.text,
                                    scrollOffset: _scrollController.hasClients
                                        ? _scrollController.offset
                                        : 0,
                                    paddingTop: 8,
                                    baselineOffset: _baselineOffset,
                                    minLines: _maxLines,
                                  ),
                                );
                              },
                            ),

                            //  the ONLY scrollable
                            TextField(
                              controller: _controller,
                              scrollController: _scrollController,
                              keyboardType: TextInputType.multiline,
                              minLines: _maxLines,
                              maxLines: _maxLines, // stops height growth
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: _fontSize,
                                height: _lineSpacing,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Center(
                child: Container(
                  width: w * .85,
                  height: h * .3,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.componentShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Clan configuration",
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textFadeWhite,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.comments_disabled_rounded,
                              color: AppColors.textWhite,
                            ),
                            SizedBox(width: 7),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Disable converstaions",
                                  style: TextStyle(
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                                Text(
                                  disableConversations ? "on" : "off",
                                  style: TextStyle(
                                    height: .5,
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Customtoggle(
                              isOn: isOn,
                              onChanged: (v) =>
                                  setState(() => disableConversations = v),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card_off,
                              color: AppColors.textWhite,
                            ),
                            SizedBox(width: 7),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Disable Invitations",
                                  style: TextStyle(
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                                Text(
                                  disableInvites ? "on" : "off",
                                  style: TextStyle(
                                    height: .5,
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Customtoggle(
                              isOn: isOn,
                              onChanged: (v) =>
                                  setState(() => disableInvites = v),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_clock_sharp,
                              color: AppColors.textWhite,
                            ),
                            SizedBox(width: 7),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Approve new members",
                                  style: TextStyle(
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                                Text(
                                  approveMembers ? "on" : "off",
                                  style: TextStyle(
                                    height: .5,
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Customtoggle(
                              isOn: isOn,
                              onChanged: (v) =>
                                  setState(() => approveMembers = v),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.message, color: AppColors.textWhite),
                            SizedBox(width: 7),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Disappearing messages",
                                  style: TextStyle(
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                                Text(
                                  disappearingMessages ? "on" : "off",
                                  style: TextStyle(
                                    height: .5,
                                    color: AppColors.textFadeWhite,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Customtoggle(
                              isOn: isOn,
                              onChanged: (v) =>
                                  setState(() => disappearingMessages = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: GestureDetector(
                  onTap: () => onCreate(),
                  child: Container(
                    width: .35 * w,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.componentGreen,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              "Create",
                              style: TextStyle(
                                fontFamily: "Jersey 10",
                                fontSize: 25,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollingLinePainter extends CustomPainter {
  final double lineHeight;
  final String text;
  final double scrollOffset;
  final double paddingTop;
  final double baselineOffset;
  final int minLines;

  _ScrollingLinePainter({
    required this.lineHeight,
    required this.text,
    required this.scrollOffset,
    required this.paddingTop,
    required this.baselineOffset,
    required this.minLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    final textLines = '\n'.allMatches(text).length + 1;
    final lineCount = max(textLines, minLines);

    for (int i = 1; i <= lineCount; i++) {
      final y =
          paddingTop + baselineOffset + (lineHeight * (i - 1)) - scrollOffset;

      if (y < 0 || y > size.height) continue;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScrollingLinePainter old) {
    return old.text != text || old.scrollOffset != scrollOffset;
  }
}
