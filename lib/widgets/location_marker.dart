import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LocationMarkers {
  static List<Marker> buildMarkers(
      List<Map<String, dynamic>> locations,
      Set<String> visitedLocations,
      Function(Map<String, dynamic>) showLocationDetails) {
    return locations.map((location) {
      final bool isVisited = visitedLocations.contains(location['name']);
      return Marker(
        point: location['coordinates'],
        width: 100,
        height: 100,
        child: GestureDetector(
          onTap: () => showLocationDetails(location),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isVisited ? const Color(0xFF704FCE) : Colors.white,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: location['imageUrl'],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
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
