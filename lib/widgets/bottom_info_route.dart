import 'package:flutter/material.dart';

class RouteInfoWidget extends StatelessWidget {
  final String routeName;
  final List<String> locations;
  final String imageUrl;
  final VoidCallback onCancel;
  final double? distance;
  final double? time;
  final String? nearestLocation;
  final String? imageRoute; // Añadir esta línea

  RouteInfoWidget({
    required this.routeName,
    required this.locations,
    required this.imageUrl,
    required this.onCancel,
    this.distance,
    this.time,
    this.nearestLocation,
    this.imageRoute, // Añadir esta línea
  });

  @override
  Widget build(BuildContext context) {
    print(nearestLocation);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color(0xFF704FCE),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF704FCE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        distance != null
                            ? '${distance!.toStringAsFixed(2)} m'
                            : 'N/A',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Text(
                        'Distancia',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time != null
                            ? '${time!.toStringAsFixed(0)} min'
                            : 'N/A',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Text(
                        'Tiempo',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF704FCE),
                    ),
                  ),
                ],
              ),
            ),
            // White part with image and locations
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding:
                        const EdgeInsets.all(4.0), // Padding for purple border
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageRoute ?? imageUrl, // Mostrar la imagen de la ruta
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF704FCE),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...locations.map((location) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 8, color: Color(0xFF704FCE)),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: location == nearestLocation
                                          ? Color(0xFF704FCE)
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}