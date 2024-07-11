import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class RouteCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String distance;
  final String redirect;
  final String uid;
  final bool? hasBadge; // Hacer hasBadge opcional

  const RouteCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.distance,
    this.redirect = "/",
    required this.uid,
    this.hasBadge, // Hacer hasBadge opcional
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).push(redirect);
      },
      child: Container(
        color: Colors.white,
        width: 330, // Anchura fija para la tarjeta en un ListView horizontal
        child: Card(
          color: Colors.white,
          elevation:
              2, // Ajusta este valor para controlar la profundidad de la sombra
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    imagePath,
                    height: 150, // Altura fija para la imagen
                    width: double
                        .infinity, // La imagen ocupa todo el ancho de la tarjeta
                    fit: BoxFit
                        .cover, // La imagen se ajusta cubriendo completamente el espacio asignado
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasBadge != null) // Solo mostrar si hasBadge no es nulo
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD9D9D9)
                          .withOpacity(0.71), // Color de fondo del círculo
                    ),
                    padding:
                        const EdgeInsets.all(5.0), // Padding dentro del círculo
                    child: SvgPicture.asset(
                      'lib/assets/images/has_badge.svg',
                      width: 25,
                      height: 25,
                      colorFilter: ColorFilter.mode(
                        hasBadge! ? Colors.orange : Color(0xFF515151),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
