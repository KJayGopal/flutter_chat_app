import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/Clans/clan_drawerItem.dart';

class DrawerSection extends StatelessWidget {
  final DrawerItem header;
  final List<Widget> children;

  const DrawerSection({
    super.key,
    required this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, ...children, const SizedBox(height: 12)],
    );
  }
}
