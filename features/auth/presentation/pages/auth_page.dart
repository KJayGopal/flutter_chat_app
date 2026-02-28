import 'package:flutter/material.dart';
import 'package:ui_demo/features/auth/presentation/pages/SignInForm.dart';
import 'package:ui_demo/features/auth/presentation/pages/SignUpForm.dart';
import 'package:ui_demo/themes/app_colors.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  bool isLogin = false;
  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  void toggleAuth() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.72,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: isLogin
                  ? SignInForm(onToggle: toggleAuth)
                  : SignUpForm(onToggle: toggleAuth),
            ),
          ),
        );
      },
    );
  }
}
