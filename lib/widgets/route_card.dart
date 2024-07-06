import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String distance;
  final String redirect;
  final String uid;

  const RouteCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.distance,
    this.redirect = "/",
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navegar a la ruta '/route'
        GoRouter.of(context).push(redirect);
      },
      child: Container(
        color: Colors.white,
        width: 330, // Anchura fija para la tarjeta en un ListView horizontal
        child: Card(
          color: Colors.white,
          elevation: 5, // Ajusta este valor para controlar la profundidad de la sombra
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                imagePath,
                height: 150, // Altura fija para la imagen
                width: double.infinity, // La imagen ocupa todo el ancho de la tarjeta
                fit: BoxFit.cover, // La imagen se ajusta cubriendo completamente el espacio asignado
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                        Text(
                          distance,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
