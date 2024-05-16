import 'package:flutter/material.dart';

class SearchingBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  SearchingBar({this.hintText = 'Search', this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo del contenedor
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2), // cambios de posición de la sombra
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: Colors.grey), // Icono de lupa
          border: InputBorder.none, // Eliminar borde
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding interior
        ),
      ),
    );
  }
}
