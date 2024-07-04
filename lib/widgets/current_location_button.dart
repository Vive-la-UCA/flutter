import 'package:flutter/material.dart';

class CurrentLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CurrentLocationButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,  // Ancho del botón más pequeño
      height: 48, // Altura del botón más pequeño
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 6.0,
        shape: CircleBorder(),
        child: Icon(
          Icons.my_location,
          size: 24.0, // Tamaño del icono más pequeño
        ),
      ),
    );
  }
}
