import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/data/local/users_entity.dart';
import 'package:ui_demo/themes/app_colors.dart';

class ClanmatesTile extends StatelessWidget {
  final UserEntity user;
  final bool isAdmin;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ClanmatesTile({
    super.key,
    required this.user,
    this.isAdmin = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Avatar
            // CircleAvatar(
            //   radius: 22,
            //   backgroundColor: Colors.blueGrey.shade300,
            //   backgroundImage: user.avatarUrl != null
            //       ? NetworkImage(user.avatarUrl!)
            //       : null,
            //   child: user.avatarUrl == null
            //       ? Text(
            //           user.name.characters.first.toUpperCase(),
            //           style: const TextStyle(
            //             fontWeight: FontWeight.bold,
            //             color: Colors.white,
            //           ),
            //         )
            //       : null,
            // ),
            const SizedBox(width: 12),

            // Name + role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (isAdmin)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: AppColors.componentShadow,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                  child: Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.componentGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            // Optional trailing (menu, badge, etc.)
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
