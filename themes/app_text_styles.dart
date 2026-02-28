import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:ui_demo/utils/size_configs.dart';

class AppTextStyles {
  static TextStyle get heading1 => TextStyle(
    fontSize: 24.w,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: "Jersey 10",
  );

  static TextStyle get heading2 => TextStyle(
    fontSize: 20.w,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: "Inter",
  );

  static TextStyle get body => TextStyle(
    fontSize: 16.w,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: "Inter",
  );

  static TextStyle get small => TextStyle(
    fontSize: 14.w,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
    fontFamily: "Inter",
  );
}
