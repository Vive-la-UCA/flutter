import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/views/map_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteInfo extends StatefulWidget {
  final String uid;
  RouteInfo({Key? key, required this.uid}) : super(key: key);

  @override
  State<RouteInfo> createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo> {
  bool _isLoading = true;
  Map<String, dynamic>? _routeData;

  // Variables que calculan la distancia y el tiempo de la ruta
  double? _distanceToLastLocation;
  double? _timeToLastLocation;

  @override
  void initState() {
    super.initState();
    _loadRouteInfo();
  }

  void _loadRouteInfo() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      try {
        final routeService =
            RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
        _routeData = await routeService.getOneRoute(token, widget.uid);
      } catch (e) {
        print('Error loading route data: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Los servicios de ubicación no están habilitados, no se puede proceder
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Los permisos de ubicación están denegados
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Los permisos están denegados para siempre, no se puede proceder
      return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _calculateDistanceAndTime(
      LatLng currentLocation, List<LatLng> routeCoordinates) async {
    if (routeCoordinates.isEmpty) return;

    LatLng lastLocation = routeCoordinates.last;
    String coordinates =
        '${currentLocation.longitude},${currentLocation.latitude};${lastLocation.longitude},${lastLocation.latitude}';

    String url =
        'https://router.project-osrm.org/route/v1/walking/$coordinates?overview=false&geometries=geojson&steps=true';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var route = json['routes'][0];
      setState(() {
        _distanceToLastLocation =
            route['distance'] / 100; // Convertir a kilómetros
        _timeToLastLocation = route['duration'] / 60; // Convertir a minutos
      });
    } else {
      // Manejo de error
      setState(() {
        _distanceToLastLocation = null;
        _timeToLastLocation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildRouteContent(),
    );
  }

  Widget _buildRouteContent() {
    final imageUrl = 'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
        (_routeData?['image'] ?? 'https://via.placeholder.com/400x300');
    final name = _routeData?['name'] ?? 'Ruta desconocida';
    final description =
        _routeData?['description'] ?? 'No hay descripción disponible.';
    final locations =
        List<Map<String, dynamic>>.from(_routeData?['locations'] ?? []);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.network(imageUrl,
                  width: double.infinity, height: 350, fit: BoxFit.cover),
              Container(
                width: double.infinity,
                height: 350,
                color: Colors.black.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: startRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(' Empezar ',
                                style: TextStyle(color: Colors.white)),
                            Icon(Icons.play_arrow, color: Colors.white),
                            if (_distanceToLastLocation != null &&
                                _timeToLastLocation != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_timeToLastLocation!.toStringAsFixed(0)} min',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      '(${_distanceToLastLocation!.toStringAsFixed(1)} km)',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(description,
                textAlign: TextAlign.justify, style: TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Lugares de esta ruta:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...locations
              .map((location) => _buildPlaceCard(
                  location['name'],
                  'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                      location['image']))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(String title, String imageUrl) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            child: Image.network(imageUrl,
                width: 100, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
            ),
          ),
        ],
      ),
    );
  }

  void startRoute() async {
    if (_routeData != null) {
      final currentLocation = await _getCurrentLocation();
      if (currentLocation != null) {
        final routeCoordinates = _routeData!['locations']
            .map<LatLng>((location) =>
                LatLng(location['latitude'], location['longitude']))
            .toList();

        await _calculateDistanceAndTime(currentLocation, routeCoordinates);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(
              routeId: widget.uid,
              routeName: _routeData?['name'] ?? 'Ruta desconocida',
              routeImage: 'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                  (_routeData?['image'] ??
                      'https://via.placeholder.com/400x300'),
              distanceToLastLocation: _distanceToLastLocation,
              timeToLastLocation: _timeToLastLocation,
            ),
          ),
        );
      } else {
        print('No current location available');
      }
    } else {
      print('No route data available to start route');
    }
  }
}
