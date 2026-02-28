import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/data/local/users_entity.dart';
import 'package:ui_demo/CommunityPage/widgets/clanmates_tile.dart';
import 'package:ui_demo/themes/app_colors.dart';

enum _MemberAction { makeAdmin, restrict, remove }

class MembersList extends StatefulWidget {
  final List<UserEntity> members;

  const MembersList({super.key, required this.members});

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  static const int initialCount = 6;
  bool _expanded = false;
  PopupMenuItem<_MemberAction> _menuItem({
    required _MemberAction value,
    required String label,
    Color? color,
    bool showDivider = true,
  }) {
    return PopupMenuItem(
      value: value,
      padding: EdgeInsets.zero, // we control layout manually
      child: SizedBox(
        width: 160, // menu width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            // Centered text
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Custom divider
            if (showDivider)
              Center(
                child: Container(
                  width: 80, // divider width
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),

            // const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.members.length;
    final visibleCount = _expanded ? total : total.clamp(0, initialCount);

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCount,
          itemBuilder: (context, index) {
            final user = widget.members[index];
            // final menuKey = GlobalKey();
            return ClanmatesTile(
              user: user,
              trailing: PopupMenuButton<_MemberAction>(
                offset: const Offset(-40, 8),
                color: AppColors.componentShadow,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.composerBackground,
                ),
                itemBuilder: (context) => [
                  _menuItem(
                    value: _MemberAction.makeAdmin,
                    label: 'make admin',
                  ),
                  _menuItem(value: _MemberAction.restrict, label: 'restrict'),
                  _menuItem(
                    value: _MemberAction.remove,
                    label: 'remove',
                    color: Colors.red.shade800,
                    showDivider: false, // last item → no line
                  ),
                ],
              ),
            );
          },
        ),

        if (total > initialCount)
          TextButton(
            onPressed: () {
              setState(() => _expanded = !_expanded);
            },
            child: Text(_expanded ? 'See less' : 'See more'),
          ),
      ],
    );
  }
}
