import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class LocationMarkers {
  static List<Marker> buildMarkers(List<Map<String, dynamic>> locations,
      Function(Map<String, dynamic>) showLocationDetails) {
    return locations.map((location) {
      return Marker(
        point: location['coordinates'],
        width: 100,
        height: 100,
        child: GestureDetector(
          onTap: () => showLocationDetails(location),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  location['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(location['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
