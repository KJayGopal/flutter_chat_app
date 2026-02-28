import 'package:flutter/material.dart';
import 'package:ui_demo/themes/app_colors.dart';

class AuthTextFields extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool enabled;
  const AuthTextFields({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    required this.enabled,
  });

  @override
  State<AuthTextFields> createState() => _AuthTextFieldsState();
}

class _AuthTextFieldsState extends State<AuthTextFields> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: AppColors.componentShadow),

        suffixIcon: widget.isPassword
            ? IconButton(
                splashRadius: 18,
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.componentShadow),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textWhite),
        ),
        // hintText: hinttext,
        //         hintStyle: TextStyle(color: AppColors.componentShadow),
        //         fillColor: AppColors.textWhite,
      ),
    );
  }
}
