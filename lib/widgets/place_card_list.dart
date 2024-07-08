import 'package:flutter/material.dart';
import 'build_place_card.dart';

class PlaceCardList extends StatelessWidget {
  final List<Map<String, String>> places;

  const PlaceCardList({Key? key, required this.places}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Stack(
        children: [
          // Dibujar la línea vertical
          Positioned(
            top: 8,
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.5 -
                2, // Ajustar el centrado
            child: Container(
              width: 4,
              color: Theme.of(context)
                  .primaryColor, // Ajustar el color según sea necesario
            ),
          ),
          // Añadir un círculo pequeño al principio de la línea
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width * 0.5 -
                10, // Ajustar el centrado
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Añadir un círculo pequeño al final de la línea
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.5 -
                10, // Ajustar el centrado
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0,
                bottom:
                    20.0), // Agregar espacio suficiente en la parte superior
            child: Column(
              children: places.map((place) {
                return Align(
                  alignment: Alignment.center,
                  child: PlaceCard(
                    title: place['title']!,
                    imageUrl: place['imageUrl']!,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
