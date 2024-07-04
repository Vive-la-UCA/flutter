import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vive_la_uca/widgets/dialog_route.dart';
import 'package:vive_la_uca/widgets/map_teselia.dart';
import 'package:vive_la_uca/widgets/current_location_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  Set<String> visitedLocations = {};
  Position? _previousPosition;
  final List<LatLng> _locationHistory = [];
  static const int historyLength = 5;
  static const double minDistance = 1.0;

  final List<LatLng> customCoordinates = [
    const LatLng(13.6799237, -89.2362585),
    const LatLng(13.6807665, -89.2357817),
    const LatLng(13.678844850811696, -89.23629600872326)
  ];

  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Veterinaria LOVET',
      'coordinates': const LatLng(13.687647111828923, -89.2711526401394),
      'imageUrl':
          'https://lh5.googleusercontent.com/p/AF1QipOaJTAczEMQP-iabIc4yxaiy9AOg2lLNs-3MqWU=w408-h544-k-no',
    },
    {
      'name': 'Queen Beauty Salon',
      'coordinates': const LatLng(13.688026289568239, -89.27140677944354),
      'imageUrl':
          'https://i.pinimg.com/236x/e2/91/62/e29162cb17247e676d3e3a2ca2c93783.jpg',
    },
    {
      'name': 'Ciber cafe Internet',
      'coordinates': const LatLng(13.688018471476012, -89.2717252917641),
      'imageUrl':
          'https://i.pinimg.com/236x/e2/91/62/e29162cb17247e676d3e3a2ca2c93783.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      if (await Permission.location.request().isGranted) {
        _determinePosition();
      } else {
        openAppSettings();
      }
    } else {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(
            currentLocation!, 18.0); // Mueve el mapa a la ubicación actual
      });
      _calculateRoute();
      _checkProximity();
    } catch (e) {
      // Handle exception
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      if (_previousPosition == null ||
          Geolocator.distanceBetween(
                  _previousPosition!.latitude,
                  _previousPosition!.longitude,
                  position.latitude,
                  position.longitude) >
              minDistance) {
        LatLng smoothedLocation =
            _getSmoothedLocation(LatLng(position.latitude, position.longitude));
        setState(() {
          currentLocation = smoothedLocation;
          _previousPosition = position;
        });
        _checkProximity();
        // Elimina o comenta esta línea
        // _mapController.move(currentLocation!, 18.0); // Mueve el mapa a la ubicación actual
      }
    });
  }

  LatLng _getSmoothedLocation(LatLng newLocation) {
    _locationHistory.add(newLocation);
    if (_locationHistory.length > historyLength) {
      _locationHistory.removeAt(0);
    }
    double avgLat = 0;
    double avgLng = 0;
    for (var loc in _locationHistory) {
      avgLat += loc.latitude;
      avgLng += loc.longitude;
    }
    avgLat /= _locationHistory.length;
    avgLng /= _locationHistory.length;
    return LatLng(avgLat, avgLng);
  }

  void _checkProximity() {
    if (currentLocation == null) return;
    for (var location in locations) {
      double distance = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          location['coordinates'].latitude,
          location['coordinates'].longitude);
      if (distance <= 5.0) {
        _showProximityAlert(location['name']);
      }
    }
  }

  void _showProximityAlert(String locationName) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(locationName: locationName);
        });
  }

  void _calculateRoute() async {
    if (currentLocation == null) return;
    List<LatLng> waypoints = [currentLocation!, ...customCoordinates];
    String coordinates = waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');
    String url =
        'https://dei.uca.edu.sv/routing/route/v1/foot/$coordinates?geometries=geojson';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var coordinates = json['routes'][0]['geometry']['coordinates'] as List;
      setState(() {
        _routePoints =
            coordinates.map((point) => LatLng(point[1], point[0])).toList();
      });
    } else {
      print('Failed to load route');
    }
  }

  void _moveToCurrentLocation() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 18.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapTeselia(
                  mapController: _mapController,
                  currentLocation: currentLocation,
                  routePoints: _routePoints,
                  locations: locations,
                ),
              ],
            ),
      floatingActionButton: CurrentLocationButton(
        onPressed: _moveToCurrentLocation,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
