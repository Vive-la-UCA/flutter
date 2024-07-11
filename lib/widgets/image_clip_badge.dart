import 'package:flutter/material.dart';

class BadgeShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;
    double radius = width * 0.15;

    path.moveTo(width / 2, 0);
    path.lineTo(width - radius, radius);
    path.lineTo(width, height / 2);
    path.lineTo(width - radius, height - radius);
    path.lineTo(width / 2, height);
    path.lineTo(radius, height - radius);
    path.lineTo(0, height / 2);
    path.lineTo(radius, radius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
