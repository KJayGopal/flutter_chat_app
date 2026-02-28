import 'package:flutter/material.dart';
import 'package:ui_demo/features/auth/auth_service.dart';
import 'package:ui_demo/features/auth/presentation/components/auth_buttons.dart';
import 'package:ui_demo/features/auth/presentation/components/auth_textfields.dart';
import 'package:ui_demo/themes/app_colors.dart';
import 'package:ui_demo/utils/size_configs.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback onToggle;
  const SignInForm({super.key, required this.onToggle});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  // final VoidCallback onToggle;
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  void signIn() async {
    if (isLoading) return; // debounce guard
    setState(() {
      isLoading = true;
    });
    final email = emailController.text;
    final pwd = passwordController.text;
    final overlay = Overlay.of(context);
    try {
      await authService.signInWithEmailPassword(email, pwd);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showOverlayMessageWithOverlay(overlay, "Error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void SignInWithGoogle() async {
    final overlay = Overlay.of(context);
    try {
      await authService.signInWithGoogle();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showOverlayMessageWithOverlay(overlay, "Error: $e");
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
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome\nback",
                style: TextStyle(
                  fontFamily: "Jersey 10",
                  fontSize: 50,
                  color: Colors.white,
                  height: .7,
                ),
                softWrap: true,
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AuthTextFields(
                  enabled: !isLoading,
                  controller: emailController,
                  hintText: "Username",
                  isPassword: false,
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AuthTextFields(
                  enabled: !isLoading,
                  controller: passwordController,
                  hintText: "Password",
                  isPassword: true,
                ),
              ),
              const SizedBox(height: 24),
              // ElevatedButton(onPressed: login, child: const Text("Sign In")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AuthButton(
                  isLoading: isLoading,
                  onTap: signIn,
                  text: "Sign In",
                  color: AppColors.componentGreen,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: widget.onToggle,
                  child: Text(
                    "New User! Create an account",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                      decorationColor: AppColors.componentShadow,
                      color: AppColors.componentShadow,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationThickness: 2,
                    decorationColor: AppColors.componentShadow,
                    color: AppColors.componentShadow,
                  ),
                ),
              ),
              SizedBox(height: 22),
              Center(
                child: Center(
                  child: GestureDetector(
                    onTap: SignInWithGoogle,
                    child: Container(
                      width: 180.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/google.png",
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Sign In with Google",
                            style: TextStyle(color: Colors.black),
                          ),
                          // Icon(Icons.apple)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      print("apple sign in");
                    },
                    child: Container(
                      width: 180.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.apple, size: 35, color: Colors.black),
                          SizedBox(width: 3),
                          Text(
                            "Sign In with Apple  ",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
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
