import 'package:flutter/material.dart';

class Dotbadge extends StatelessWidget {
  final Widget child;
  final bool show;
  final double size;
  final Color color;
  const Dotbadge({
    super.key,
    required this.child,
    required this.show,
    required this.size,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned(
            top: 1,
            right: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
