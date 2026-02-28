import 'package:flutter/material.dart';
import 'package:ui_demo/CommunityPage/Allies/allies_page.dart';
import 'package:ui_demo/CommunityPage/clan_list.dart';
import 'package:ui_demo/features/auth/auth_service.dart';
import 'package:ui_demo/themes/app_colors.dart';
import 'package:ui_demo/utils/size_configs.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final authService = AuthService();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 25, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
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
                            "${authService.userName}",
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
                      // Icon(
                      //   Icons.search,
                      //   size: 25,
                      //   color: AppColors.componentShadow,
                      // ),
                      SizedBox(width: 10.w),
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: Icon(
                          Icons.menu,
                          size: 30,
                          color: AppColors.componentShadow,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SearchBar(
                    // controller: searchController,
                    hintText: "Search anything...",
                    // leading: const Icon(Icons.search),
                    trailing: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      ),
                    ],
                    backgroundColor: WidgetStateProperty.all(
                      AppColors.componentShadow,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: width,
                    // height: height * .75,
                    decoration: BoxDecoration(
                      color: AppColors.componentBlack,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          padding: EdgeInsets.symmetric(horizontal: 110),
                          controller: _tabController,
                          labelColor: Colors.white,
                          indicatorColor: Colors.white,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: "Clan"),
                            Tab(text: "Allies"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [ClanList(), AlliesPage()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
