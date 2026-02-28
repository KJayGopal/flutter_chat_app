import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final Color color;
  final bool isLoading;
  const AuthButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        // padding: const EdgeInsets.all(15),
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        // width: 40.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              )
            : Center(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
      ),
    );
  }
}
