import 'package:flutter/material.dart';

class Categorybtn extends StatelessWidget {
  final VoidCallback function;
  final String imagePath;
  final String title;
  const Categorybtn({
    super.key,
    required this.function,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border:
              Border.all(color: Color.fromRGBO(169, 61, 231, 0.91), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image instead of icon
            Image.asset(
              imagePath,
              height: 60,
              width: 60,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
