import 'package:flutter/material.dart';
import 'package:ui_demo/themes/app_colors.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class CustomChatComposer extends StatefulWidget {
  final void Function(String) onSend;
  final ValueChanged<double>? onHeightChanged;
  final List<String> users;
  final List<String> tags;
  final VoidCallback onToggleAttachments;
  final bool showAttachments;
  const CustomChatComposer({
    super.key,
    required this.onSend,
    required this.users,
    required this.tags,
    required this.onToggleAttachments,
    required this.showAttachments,
    this.onHeightChanged,
  });

  @override
  State<CustomChatComposer> createState() => _CustomChatComposerState();
}

class _CustomChatComposerState extends State<CustomChatComposer>
    with SingleTickerProviderStateMixin {
  final _containerKey = GlobalKey();
  final _controller = TextEditingController();
  bool _canSend = false;
  bool _showEmoji = false;
  final ScrollController _textScrollController = ScrollController();
  static const double _lineHeight = 22.0;
  static const int _maxLines = 6;
  String _lastText = '';
  bool _attachmentsOpen = false;

  // void _handleMentions(String text) {
  //   // Logic to handle mentions of users
  // }

  void _onTextChanged() {
    final text = _controller.text;

    // only when deleting
    if (text.length < _lastText.length) {
      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(0);
      }
    }

    _lastText = text;

    // Height can now shrink
    _notifyHeight();
  }

  double _lastHeight = 0;
  void _notifyHeight() {
    final context = _containerKey.currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final height = box.size.height.roundToDouble();

    if (height == _lastHeight) return;
    _lastHeight = height;

    // Defer notification to the NEXT frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onHeightChanged?.call(height);
    });
  }

  // void _showTags() {
  //   // Logic to show tags selection
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) {
  //       return ListView(
  //         children: widget.tags.map((tag) {
  //           return ListTile(
  //             title: Text('#$tag'),
  //             onTap: () {
  //               _controller.text += ' #$tag ';
  //               Navigator.pop(context);
  //             },
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyHeight(); // baseline measurement
    });
  }

  OverlayEntry? _attachmentOverlay;

  void _showAttachmentOverlay(BuildContext context) {
    if (_attachmentOverlay != null) return;

    _attachmentOverlay = OverlayEntry(
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideAttachmentOverlay,
              ),
            ),
            Positioned(
              left: 10,
              bottom: 62 + bottomInset,
              child: _AttachmentTray(),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_attachmentOverlay!);
  }

  // void _hideAttachmentOverlay() {
  //   _attachmentOverlay?.remove();
  //   _attachmentOverlay = null;
  // }
  void _hideAttachmentOverlay() {
    _attachmentOverlay?.remove();
    _attachmentOverlay = null;

    if (mounted) {
      setState(() {
        _attachmentsOpen = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textScrollController.dispose();
    // _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _notifyHeight();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        key: _containerKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.componentGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  // onTap: () {
                  //   _showAttachmentOverlay(context);
                  //   _notifyHeight();
                  // },
                  onTap: () {
                    setState(() {
                      _attachmentsOpen = !_attachmentsOpen;
                    });

                    if (_attachmentsOpen) {
                      _showAttachmentOverlay(context);
                    } else {
                      _hideAttachmentOverlay();
                    }

                    _notifyHeight();
                  },

                  child: Center(
                    child: AnimatedRotation(
                      turns: _attachmentsOpen ? 0.125 : 0.0,
                      duration: const Duration(
                        milliseconds: 500,
                      ), //  slow & smooth
                      curve: Curves.easeInOutCubic, // VERY important
                      child: Icon(
                        Icons.add, // symmetric, rotation is visible
                        size: 30,
                        color: AppColors.componentBlack,
                        weight: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: _lineHeight * _maxLines),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.composerBackground,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Scrollbar(
                        controller: _textScrollController,
                        thumbVisibility:
                            true, // set false if you want auto-hide
                        radius: const Radius.circular(8),
                        child: TextField(
                          controller: _controller,
                          scrollController: _textScrollController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          minLines: 1,
                          maxLines: _maxLines,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.componentGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    widget.onSend(text);
                    _controller.clear();
                    _notifyHeight();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: const Center(
                      child: Icon(Icons.send, size: 22, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentTray extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.componentBlack,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_document, color: AppColors.textWhite),
                  SizedBox(width: 5),
                  Text(
                    "document",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textFadeWhite,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                width: w * .55,
                height: 1,
                color: AppColors.textSecondary,
              ),
              Row(
                children: [
                  Icon(Icons.link, color: AppColors.textWhite),
                  SizedBox(width: 5),
                  Text(
                    "link",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textFadeWhite,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                width: w * .65,
                height: 1,
                color: AppColors.textSecondary,
              ),
              Row(
                children: [
                  Icon(Icons.mic, color: AppColors.textWhite),
                  SizedBox(width: 5),
                  Text(
                    "audio",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textFadeWhite,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                width: w * .65,
                height: 1,
                color: AppColors.textSecondary,
              ),

              Row(
                children: [
                  Icon(Icons.image, color: AppColors.textWhite),
                  SizedBox(width: 5),
                  Text(
                    "image/video",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textFadeWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
