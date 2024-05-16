import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String distance;

  const RouteCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.distance, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Esto asegura que cualquier contenido visual no sobrepase los bordes del card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados para el card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          Padding(
            
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  distance,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                  ),
                ),
                  ],
                ),
                
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Añade "..." si el texto sobrepasa el límite de líneas
                ),
                const SizedBox(height: 10),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
