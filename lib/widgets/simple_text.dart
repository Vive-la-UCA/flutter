import 'package:flutter/material.dart';

class SimpleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color color;

  const SimpleText({
    super.key,
    required this.text,
    this.fontSize = 24.0,
    this.fontFamily = 'Montserrat',
    this.fontWeight = FontWeight.bold,
    this.color = Colors.white,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        color: color,
        
      ),
      textAlign: textAlign,
    );
  }
}
