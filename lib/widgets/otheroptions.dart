import 'package:flutter/material.dart';

class Otheroptions extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback function;
  const Otheroptions({
    super.key,
    required this.text1,
    required this.text2,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text1,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap:function,
            child: Text(
              text2,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
