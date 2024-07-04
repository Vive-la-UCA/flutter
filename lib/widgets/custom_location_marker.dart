import 'package:flutter/material.dart';

class CustomLocationMarker extends StatelessWidget {
  final String locationName;
  final String imageUrl;

  const CustomLocationMarker({
    Key? key,
    required this.locationName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            locationName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
            Positioned(
              top: 5,
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 20,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
