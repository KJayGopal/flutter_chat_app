import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_demo/CommunityPage/Clans/clanOption/member_list.dart';
import 'package:ui_demo/CommunityPage/data/local/users_entity.dart';
import 'package:ui_demo/CommunityPage/provider/chat_provider.dart';
import 'package:ui_demo/themes/app_colors.dart';
import 'package:ui_demo/utils/size_configs.dart';

final clanMembersProvider = Provider.family<List<UserEntity>, String>((
  ref,
  groupId,
) {
  final usersBox = ref.watch(usersBoxProvider);

  // however you mark clan membership
  return usersBox.values.toList();
});

class ClanOptionPage extends ConsumerStatefulWidget {
  final String groupName;
  const ClanOptionPage({super.key, required this.groupName});

  @override
  ConsumerState<ClanOptionPage> createState() => _ClanOptionPageState();
}

class _ClanOptionPageState extends ConsumerState<ClanOptionPage> {
  @override
  Widget build(BuildContext context) {
    final members = ref.watch(clanMembersProvider(widget.groupName));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 30, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: Icon(
                    Icons.edit,
                    size: 28,
                    color: AppColors.componentShadow,
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () => {},
                  child: Icon(
                    Icons.share,
                    size: 30,
                    color: AppColors.componentShadow,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              "Clanmates: ",
              style: TextStyle(color: AppColors.componentShadow),
            ),
            MembersList(members: members),
          ],
        ),
      ),
    );
  }
}
