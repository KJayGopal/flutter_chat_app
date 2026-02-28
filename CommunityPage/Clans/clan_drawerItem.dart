import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String label;

  const DrawerItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// LEFT TEXT
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontFamily: 'Jersey 10',
              ),
            ),
          ),
          // SizedBox(width: 3),

          // /// Green Active Dot
          // if (showActive)
          //   Container(
          //     width: 12,
          //     height: 12,
          //     margin: const EdgeInsets.only(right: 8),
          //     decoration: BoxDecoration(
          //       color: Colors.green,
          //       shape: BoxShape.circle,
          //     ),
          //   ),

          // /// RIGHT INDICATOR ZONE (FIXED WIDTH + HEIGHT )
          // SizedBox(
          //   width: 28,
          //   height: 28, // THIS WAS MISSING
          //   child: Stack(
          //     alignment: Alignment.center,
          //     clipBehavior: Clip.none,
          //     children: [
          //       if (showVolume)
          //         const Icon(Icons.volume_up, size: 20, color: Colors.white70),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
