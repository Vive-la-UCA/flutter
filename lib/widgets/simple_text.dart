import 'package:flutter/material.dart';

class SimpleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const SimpleText({
    super.key,
    required this.text,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'Montserrat',
        color: color,
      ),
    );
  }
}
