import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const FormButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.black,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontWeight: fontWeight,
          fontFamily: 'Montserrat',
          fontSize: fontSize,
        ),
        foregroundColor: textColor, 
      ),
      child: Text(text),
    );
  }
}
