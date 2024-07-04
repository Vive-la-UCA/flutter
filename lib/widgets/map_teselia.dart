import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:vive_la_uca/widgets/custom_location_marker.dart';

class MapTeselia extends StatelessWidget {
  final MapController mapController;
  final LatLng? currentLocation;
  final List<LatLng> routePoints;
  final List<Map<String, dynamic>> locations;

  const MapTeselia({
    Key? key,
    required this.mapController,
    required this.currentLocation,
    required this.routePoints,
    required this.locations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: currentLocation,
        zoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'http://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: 6.0,
              color: Colors.blue.shade100,
              borderColor: Colors.blue.shade300,
              borderStrokeWidth: 5,
              isDotted: false,
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: 10.0,
              color: const Color.fromARGB(255, 61, 122, 228),
              borderColor: const Color.fromARGB(255, 51, 101, 187),
              borderStrokeWidth: 2,
              isDotted: true,
            ),
          ],
        ),
        MarkerLayer(
          markers: locations.map((location) {
            return Marker(
              point: location['coordinates'],
              width: 100,
              height: 100,
              child: CustomLocationMarker(
                locationName: location['name'],
                imageUrl: location['imageUrl'],
              ),
            );
          }).toList(),
        ),
        CurrentLocationLayer(
          style: const LocationMarkerStyle(
            marker: DefaultLocationMarker(
              color: Colors.black,
              child: Image(image: AssetImage('lib/assets/images/owlIcon.png')),
            ),
            headingSectorColor: Colors.black,
            headingSectorRadius: 50,
            markerSize: Size(40, 40),
            markerDirection: MarkerDirection.heading,
            accuracyCircleColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
