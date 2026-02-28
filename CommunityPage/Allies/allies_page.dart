import 'package:flutter/material.dart';
import 'package:ui_demo/themes/app_colors.dart';

class AlliesPage extends StatefulWidget {
  const AlliesPage({super.key});

  @override
  State<AlliesPage> createState() => _AlliesPageState();
}

class _AlliesPageState extends State<AlliesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(backgroundColor: AppColors.componentBlack));
  }
}
