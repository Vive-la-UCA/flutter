import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vive_la_uca/services/location_service.dart';
import 'package:vive_la_uca/widgets/dialog_location.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/widgets/location_details_bottomsheet.dart';
import 'package:vive_la_uca/widgets/location_marker.dart';
import 'package:vive_la_uca/widgets/bottom_info_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';  // Importa go_router

class MapPage extends StatefulWidget {
  final String? routeId;
  final String? routeName;
  final String? routeImage;

  const MapPage({Key? key, this.routeId, this.routeName, this.routeImage})
      : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _showRoute = false;
  StreamSubscription<Position>? positionStream;
  Map<String, dynamic>? _nearestLocation;
  Set<String> visitedLocations = {};
  Position? _previousPosition;
  final List<LatLng> _locationHistory = [];
  static const int historyLength = 5;
  static const double minDistance = 1.0;
  String? _routeId;

  // Variables para tiempo y distancia
  double? _distanceToLastLocation;
  double? _timeToLastLocation;

  List<LatLng> routeCoordinates = [];
  List<Map<String, dynamic>> routeLocations = [];
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    _routeId = widget.routeId;
    _checkPermissions();
    _loadToken();
    _loadVisitedLocations();

    positionStream = Geolocator.getPositionStream(
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
        if (mounted) {
          setState(() {
            currentLocation = smoothedLocation;
            _previousPosition = position;
          });
          _checkProximity();
          _saveVisitedLocations();
        }
      }
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _calculateDistanceAndTime() async {
    if (currentLocation == null || routeCoordinates.isEmpty) return;

    LatLng lastLocation = routeCoordinates.last;
    String coordinates =
        '${currentLocation!.longitude},${currentLocation!.latitude};${lastLocation.longitude},${lastLocation.latitude}';

    String url =
        'https://router.project-osrm.org/route/v1/walking/$coordinates?overview=false&geometries=geojson&steps=true';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var route = json['routes'][0];
      setState(() {
        _distanceToLastLocation = route['distance'] / 100;
        _timeToLastLocation = route['duration'] / 60;
      });
    } else {
      setState(() {
        _distanceToLastLocation = null;
        _timeToLastLocation = null;
      });
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _determinePosition();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
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

      if (_routeId != null) {
        final routeResponse = await routeService.getOneRoute(token, _routeId!);
        final locationsFromRoute = routeResponse['locations'];

        if (mounted) {
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
                'coordinates':
                    LatLng(location['latitude'], location['longitude']),
                'imageUrl': 'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                    location['image'],
              };
            }).toList();
          });
        }
      }

      final locationResponse = await LocationService(
              baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
          .getAllLocations(token);
      if (locationResponse != null) {
        print('Location Response: ${locationResponse.length} locations');
        if (mounted) {
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
            _sortRouteLocationsByDistance();
            if (_routeId != null) {
              _calculateRoute();
            }
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          // Manejo de error
        });
      }
    }
  }

  Future<void> _saveVisitedLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('visitedLocations', visitedLocations.toList());
  }

  Future<void> _loadVisitedLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedLocations = prefs.getStringList('visitedLocations');
    if (savedLocations != null) {
      setState(() {
        visitedLocations = savedLocations.toSet();
      });
    }
  }

  void _sortRouteLocationsByDistance() {
    if (currentLocation != null) {
      routeLocations.sort((a, b) {
        final aDistance = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          a['coordinates'].latitude,
          a['coordinates'].longitude,
        );
        final bDistance = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          b['coordinates'].latitude,
          b['coordinates'].longitude,
        );
        return aDistance.compareTo(bDistance);
      });

      routeCoordinates = routeLocations.map((location) {
        return location['coordinates'] as LatLng;
      }).toList();
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
      if (_routeId != null) {
        _calculateRoute();
      }
      _checkProximity();
    } catch (e) {
      // Excepcion
    }
  }

  void _checkProximity() {
    if (currentLocation == null) return;

    Map<String, dynamic>? nearest;
    double? minDistance;

    for (var location in routeLocations) {
      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        location['coordinates'].latitude,
        location['coordinates'].longitude,
      );

      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }

      if (distance <= 20.0 && !visitedLocations.contains(location['name'])) {
        _showProximityAlert(location);
        setState(() {
          visitedLocations.add(location['name']);
        });
        _saveVisitedLocations();
        break;
      }
    }

    if (nearest != _nearestLocation) {
      setState(() {
        _nearestLocation = nearest;
      });
    }
  }

  void _showProximityAlert(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogLocation(location: location);
      },
    );
  }

  void _calculateRoute() async {
    if (currentLocation == null) return;

    List<LatLng> waypoints = [currentLocation!, ...routeCoordinates];

    if (waypoints.length <= 1) {
      return;
    }

    String coordinates = waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');

    String url =
        'https://dei.uca.edu.sv/routing/route/v1/foot/$coordinates?geometries=geojson';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var coordinates = json['routes'][0]['geometry']['coordinates'] as List;
      if (mounted) {
        setState(() {
          _routePoints =
              coordinates.map((point) => LatLng(point[1], point[0])).toList();
          _showRoute = true;
        });
      }
      _calculateDistanceAndTime();
    } else {
      // Exception
    }
  }

  void _moveToCurrentLocation() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 18.0);
    }
  }

  void _toggleRouteVisibility() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
            '¿Estás seguro de finalizar la ruta? Tu progreso no se guardará.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
               // Navega a la ruta /home usando GoRouter
            },
          ),
          TextButton(
            child: const Text('Finalizar'),
            onPressed: () {
              setState(() {
                _showRoute = false;
                _routePoints.clear();
                routeCoordinates.clear();
                routeLocations.clear();
                _routeId = null;
              });
              Navigator.of(context).pop();
              context.go('/home');
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLocation!,
                    initialZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'http://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.vive_la_uca',
                      tileProvider:
                          const FMTCStore('mapStore').getTileProvider(),
                    ),
                    if (_showRoute)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 6.0,
                            color: Colors.blue.shade100,
                            borderColor: Colors.blue.shade300,
                            borderStrokeWidth: 5,
                            isDotted: false,
                          ),
                        ],
                      ),
                    if (_showRoute)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 10.0,
                            color: const Color.fromARGB(255, 61, 122, 228),
                            borderColor:
                                const Color.fromARGB(255, 51, 101, 187),
                            borderStrokeWidth: 2,
                            isDotted: true,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: LocationMarkers.buildMarkers(
                          locations, visitedLocations, _showLocationDetails),
                    ),
                    CurrentLocationLayer(
                      style: const LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          color: Colors.black,
                          child: Image(
                              image:
                                  AssetImage('lib/assets/images/owlIcon.png')),
                        ),
                        headingSectorColor: Colors.black,
                        headingSectorRadius: 50,
                        markerSize: Size(40, 40),
                        markerDirection: MarkerDirection.heading,
                        accuracyCircleColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                if (_showRoute)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RouteInfoWidget(
                      routeName: widget.routeName ?? 'Ruta desconocida',
                      locations: routeLocations
                          .map((loc) => loc['name'] as String)
                          .toList(),
                      imageUrl: routeLocations.isNotEmpty
                          ? routeLocations[0]['imageUrl'] as String
                          : 'https://via.placeholder.com/150',
                      onCancel: _toggleRouteVisibility,
                      distance: _distanceToLastLocation,
                      time: _timeToLastLocation,
                      nearestLocation: _nearestLocation?['name'],
                      imageRoute: widget.routeImage,
                    ),
                  ),
                Positioned(
                  bottom: _showRoute ? 240 : 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
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
                ),
              ],
            ),
    );
  }
}
