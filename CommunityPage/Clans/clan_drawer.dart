import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/Clans/clan_drawerItem.dart';
import 'package:ui_demo/CommunityPage/Clans/clan_drawersection.dart';
import 'package:ui_demo/CommunityPage/Clans/subDrawerItem.dart';
import 'package:ui_demo/themes/app_colors.dart';
import 'package:ui_demo/utils/size_configs.dart';

class ClanDrawer extends StatelessWidget {
  const ClanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 200.w,
      backgroundColor: AppColors.componentShadow,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 120, horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            DrawerSection(
              header: DrawerItem(label: '#tags'),
              children: [
                SubDrawerItem(label: '#daily_life'),
                SubDrawerItem(label: '#music', showActive: true),
                SubDrawerItem(label: '#progress'),
                SubDrawerItem(label: '#comeback'),
              ],
            ),

            DrawerSection(
              header: DrawerItem(label: '/squads'),
              children: [
                SubDrawerItem(label: '/hangout', showVolume: true),
                SubDrawerItem(label: '/smoke_', showActive: true),
                SubDrawerItem(label: '/coding', showTimer: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
