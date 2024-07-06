import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:vive_la_uca/services/location_service.dart';
import 'package:vive_la_uca/widgets/dialog_route.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/widgets/location_details_bottomsheet.dart';
import 'package:vive_la_uca/widgets/location_marker.dart';

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
  String? _currentAlertLocation;
  final List<LatLng> _traveledRoutePoints = [];
  List<LatLng> _remainingRoutePoints = [];

  List<LatLng> routeCoordinates = [];
  List<Map<String, dynamic>> routeLocations = [];
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadToken();

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
                position.longitude,
              ) >
              minDistance) {
        LatLng smoothedLocation = _getSmoothedLocation(
          LatLng(position.latitude, position.longitude),
        );
        setState(() {
          currentLocation = smoothedLocation;
          _previousPosition = position;
          _updateRouteProgress(); // Asegúrate de que esto esté aquí
        });
        _checkProximity();
      }
    });
  }

  void _updateRouteProgress() {
    if (currentLocation == null || _remainingRoutePoints.isEmpty) return;

    setState(() {
      while (_remainingRoutePoints.isNotEmpty &&
          Geolocator.distanceBetween(
                currentLocation!.latitude,
                currentLocation!.longitude,
                _remainingRoutePoints[0].latitude,
                _remainingRoutePoints[0].longitude,
              ) <
              minDistance) {
        _traveledRoutePoints.add(_remainingRoutePoints.removeAt(0));
      }
    });
  }

  void _showLocationDetails(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LocationDetailsBottomSheet(location: location);
      },
    );
  }

  void _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      final routeService =
          RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');

      const routeId = '6688bfe1a454b9cd7b34d11a';
      final routeResponse = await routeService.getOneRoute(token, routeId);
      final locationsFromRoute = routeResponse['locations'];

      setState(() {
        routeCoordinates = locationsFromRoute.map<LatLng>((location) {
          return LatLng(location['latitude'], location['longitude']);
        }).toList();

        routeLocations =
            locationsFromRoute.map<Map<String, dynamic>>((location) {
          return {
            '_id': location['_id'],
            'name': location['name'],
            'description': location['description'],
            'coordinates': LatLng(location['latitude'], location['longitude']),
            'imageUrl': 'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                location['image'],
          };
        }).toList();
      });

      final locationResponse = await LocationService(
              baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
          .getAllLocations(token);
      if (locationResponse != null) {
        print('Location Response: ${locationResponse.length} locations');
        setState(() {
          locations = locationResponse.map<Map<String, dynamic>>((location) {
            return {
              '_id': location['_id'],
              'name': location['name'],
              'description': location['description'],
              'coordinates':
                  LatLng(location['latitude'], location['longitude']),
              'imageUrl': 'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                  location['image'],
            };
          }).toList();
          _calculateRoute();
        });
      }
    } else {
      setState(() {
        //Exception
      });
    }
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

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      _calculateRoute();
      _checkProximity();
    } catch (e) {
      // Excepcion
    }
  }

  void _checkProximity() {
    if (currentLocation == null) return;

    for (var location in routeLocations) {
      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        location['coordinates'].latitude,
        location['coordinates'].longitude,
      );

      if (distance <= 20.0 && !visitedLocations.contains(location['name'])) {
        _showProximityAlert(location['name']);
        visitedLocations.add(location['_id']);
        break;
      }
    }
  }

  void _showProximityAlert(String locationName) {
    setState(() {
      _currentAlertLocation = locationName;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(locationName: locationName);
      },
    ).then((_) {
      setState(() {
        _currentAlertLocation = null;
      });
    });
  }

  void _calculateRoute() async {
    if (currentLocation == null) return;

    List<LatLng> waypoints = [currentLocation!, ...routeCoordinates];

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
        _remainingRoutePoints = List.from(_routePoints);
      });
    } else {
      //Exception
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
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLocation!,
                initialZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'http://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.vive_la_uca',
                  tileProvider: const FMTCStore('mapStore').getTileProvider(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _remainingRoutePoints,
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
                      points: _traveledRoutePoints,
                      strokeWidth: 6.0,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: LocationMarkers.buildMarkers(
                      locations, _showLocationDetails),
                ),
                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: const DefaultLocationMarker(
                      color: Colors.black,
                      child: Image(
                          image: AssetImage('lib/assets/images/owlIcon.png')),
                    ),
                    accuracyCircleColor: Colors.blue.withOpacity(0.1),
                    headingSectorColor: Colors.blue.withOpacity(0.5),
                    markerSize: const Size(40, 40),
                    markerDirection: MarkerDirection.heading,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.my_location,
          size: 24.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
