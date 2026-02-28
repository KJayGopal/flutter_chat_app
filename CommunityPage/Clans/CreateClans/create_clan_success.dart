import 'package:flutter/material.dart';

class CreateClanSuccess extends StatelessWidget {
  const CreateClanSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(50),
          child: Text(
            'Clan created ! ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white, //  explicit
            ),
          ),
        ),
      ),
    );
  }
}
