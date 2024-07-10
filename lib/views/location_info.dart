import 'package:flutter/material.dart';
import 'package:vive_la_uca/services/location_service.dart';
import 'package:vive_la_uca/services/token_service.dart';

class LocationInfo extends StatefulWidget {
  final String uid;
  const LocationInfo({super.key, required this.uid});

  @override
  State<LocationInfo> createState() => _LocationInfoState();
}

class _LocationInfoState extends State<LocationInfo> {
  bool _isLoading = true;
  Map<String, dynamic>? _routeData;

  @override
  void initState() {
    super.initState();
    _loadLocationInfo();
  }

  void _loadLocationInfo() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      try {
        final locationService =
            LocationService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
        _routeData = await locationService.getOneLocation(token, widget.uid);
      } catch (e) {
        print('Error loading route data: $e');
      }
      setState(() {
        _isLoading = false;
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
    final imageUrl =
        'https://vivelauca.uca.edu.sv/admin-back/uploads/${_routeData?['image'] ?? 'https://via.placeholder.com/400x300'}';
    final name = _routeData?['name'] ?? 'Ruta desconocida';
    final description =
        _routeData?['description'] ?? 'No hay descripción disponible.';

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
                height:
                    350, // Make sure the overlay covers the entire image area
                color: Colors.black
                    .withOpacity(0.3), // Black color with 80% opacity
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(description,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void startRoute() {
    print('Iniciar ruta: ${_routeData?['name']}');
  }
}
