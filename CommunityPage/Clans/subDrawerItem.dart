import 'package:flutter/material.dart';

class SubDrawerItem extends StatelessWidget {
  final String label;
  final bool showActive;
  final bool showTimer;
  final bool showVolume;

  const SubDrawerItem({
    super.key,
    required this.label,
    this.showActive = false,
    this.showTimer = false,
    this.showVolume = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 8, bottom: 0),
      child: Row(
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14, // smaller
              height: .5,
            ),
          ),
          SizedBox(width: 5),
          if (showActive)
            Container(
              width: 10,
              height: 10,
              // margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          Spacer(),
          // Icon(Icons.timer),
          SizedBox(
            width: 28,
            height: 28, // THIS WAS MISSING
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (showTimer)
                  const Icon(Icons.timer, size: 20, color: Colors.white70),
              ],
            ),
          ),

          SizedBox(
            width: 28,
            height: 28, // THIS WAS MISSING
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (showVolume)
                  const Icon(Icons.volume_up, size: 20, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _GreenDot extends StatelessWidget {
//   const _GreenDot();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 6,
//       height: 6,
//       decoration: const BoxDecoration(
//         color: Colors.green,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }
