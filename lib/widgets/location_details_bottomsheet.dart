import 'package:flutter/material.dart';

//*Constants
const maxLargeSheet = 0.9;

class LocationDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> location;

  const LocationDetailsBottomSheet({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            maxLargeSheet, // 80% del tamaño de la pantalla
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    location['imageUrl'],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 24,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 20,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 4.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                location['name'],
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Text(
                    location['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
