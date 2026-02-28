import 'package:flutter/material.dart';
import 'package:ui_demo/features/auth/auth_service.dart';
import 'package:ui_demo/features/auth/presentation/components/auth_buttons.dart';
import 'package:ui_demo/features/auth/presentation/components/auth_textfields.dart';
import 'package:ui_demo/themes/app_colors.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onToggle;
  const SignUpForm({super.key, required this.onToggle});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool isLoading = false;
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cnfpasswordController = TextEditingController();
  void signUp() async {
    if (isLoading) return; // debounce guard
    setState(() {
      isLoading = true;
    });
    final email = emailController.text;
    final pwd = passwordController.text;
    final cnfpwd = cnfpasswordController.text;
    final overlay = Overlay.of(context);
    if (pwd != cnfpwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("password dont match"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      await authService.signUpWithEmailPassword(email, pwd);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        if (!mounted) return;
        showOverlayMessageWithOverlay(overlay, "Error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showOverlayMessageWithOverlay(
    OverlayState overlay,
    String message, {
    bool isError = true,
  }) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 20,
        left: 16,
        right: 16,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12),
          color: isError ? Colors.red : Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2)).then((_) => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Create\nan account",
                style: TextStyle(
                  fontFamily: "Jersey 10",
                  fontSize: 50,
                  color: Colors.white,
                  height: .6,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 12),
              AuthTextFields(
                enabled: !isLoading,
                controller: emailController,
                hintText: "Username",
                isPassword: false,
              ),
              const SizedBox(height: 12),

              AuthTextFields(
                enabled: !isLoading,
                controller: passwordController,
                hintText: "Password",
                isPassword: true,
              ),
              const SizedBox(height: 12),
              AuthTextFields(
                enabled: !isLoading,
                controller: cnfpasswordController,
                hintText: "Confirm password",
                isPassword: true,
              ),
              const SizedBox(height: 24),
              // ElevatedButton(onPressed: login, child: const Text("Sign In")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AuthButton(
                  isLoading: isLoading,
                  onTap: signUp,
                  text: "Sign Up",
                  color: AppColors.componentGreen,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: widget.onToggle,
                  child: Text(
                    "already have an account",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                      decorationColor: AppColors.componentShadow,
                      color: AppColors.componentShadow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
