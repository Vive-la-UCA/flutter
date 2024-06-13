import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de localización están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Servicios de localización no habilitados.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permisos de localización denegados.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permisos de localización denegados permanentemente.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Obtener la ubicación actual del dispositivo.
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation!,
                initialZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                CurrentLocationLayer(
                  style: const LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: Colors.black,
                      child: Image(
                          image: AssetImage(
                              'lib/assets/images/owlIcon.png')), //Icono
                    ),
                    headingSectorColor: Colors.black, // Color de la direccion
                    headingSectorRadius: 50,
                    markerSize: Size(40, 40),
                    markerDirection: MarkerDirection.heading,
                    accuracyCircleColor:
                        Colors.transparent, // Elimina el borde azul
                  ),
                ),
              ],
            ),
    );
  }
}
