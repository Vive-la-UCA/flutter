// ignore_for_file: prefer_interpolation_to_compose_strings
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
import 'package:go_router/go_router.dart'; // Importa go_router
import 'package:vive_la_uca/widgets/dialog_route.dart'; // Importa CustomDialogRoute
import 'package:vive_la_uca/services/badge_service.dart';
import 'package:vive_la_uca/services/auth_service.dart';
import 'package:vive_la_uca/services/user_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MapPage extends StatefulWidget {
  final String? routeId;
  final String? routeName;
  final String? routeImage;
  double? distanceToLastLocation;
  double? timeToLastLocation;

  MapPage({
    Key? key,
    this.routeId,
    this.routeName,
    this.routeImage,
    this.distanceToLastLocation,
    this.timeToLastLocation,
  }) : super(key: key);

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
  String? _token;
  String? _userId;
  String? _badgeId;
  String? _badgeName;
  String? _badgeImageUrl;
  bool _isLoadingRoute = true;
  bool _hasConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  List<LatLng> routeCoordinates = [];
  List<Map<String, dynamic>> routeLocations = [];
  List<Map<String, dynamic>> locations = [];
  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _initialize();
  }

  Future<void> _initialize() async {
    _routeId = widget.routeId;
    await Future.wait([
      _checkPermissions(),
      _loadToken(),
      _loadVisitedLocations(),
    ]);

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      if (_shouldUpdatePosition(position)) {
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
          _updateDistanceAndTime();
        }
      }
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  String _distanceString = '';
  String _timeString = '';

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _hasConnection = result != ConnectivityResult.none;
      if (_hasConnection) {
        _loadToken();
      }
    });
  }

  Future<void> _saveDataToCache(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  Future<String?> _loadDataFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _updateDistanceAndTime() {
    if (currentLocation != null && routeCoordinates.isNotEmpty) {
      // Calcular la distancia desde la ubicación actual hasta el último punto de la ruta
      double distance =
          _calculateDistance(currentLocation!, routeCoordinates.last);

      // Calcular el tiempo estimado basado en la distancia
      double time = _calculateTime(distance);

      // Convertir la distancia a la unidad adecuada
      String distanceString;
      if (distance >= 1000) {
        distanceString = (distance / 1000).toStringAsFixed(2) + ' km';
      } else {
        distanceString = distance.toStringAsFixed(2) + ' m';
      }

      // Convertir el tiempo a la unidad adecuada
      String timeString;
      if (time >= 60) {
        int hours = (time / 60).floor();
        int minutes = (time % 60).round();
        timeString = '$hours h $minutes min';
      } else {
        timeString = time.toStringAsFixed(0) + ' min';
      }

      // Actualizar el estado con la nueva distancia y tiempo
      setState(() {
        widget.distanceToLastLocation = distance;
        widget.timeToLastLocation = time;
        _distanceString = distanceString;
        _timeString = timeString;
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

  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  double _calculateTime(double distance) {
    // Supongamos que la velocidad promedio es 5 km/h (5000 m/h)
    const double averageSpeed = 5000 / 3600; // en m/s
    return distance / averageSpeed / 60; // en minutos
  }

  Future<void> _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      final authService = AuthService(
          baseUrl: 'https://vivelauca.uca.edu.sv/admin-back/api/auth');
      try {
        final userData = await authService.checkToken(token);
        setState(() {
          _token = token;
          _userId = userData[
              'uid']; // Asumiendo que el ID del usuario está en el campo 'id'
        });
      } catch (e) {
        // Cargar datos desde el caché si no hay conexión
        final cachedUserData = await _loadDataFromCache('userData');
        if (cachedUserData != null) {
          final userData = jsonDecode(cachedUserData);
          setState(() {
            _token = token;
            _userId = userData['uid'];
          });
        } else {
          print('Failed to fetch user data: $e');
        }
      }

      if (_routeId != null) {
        final badgeService =
            BadgeService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
        try {
          final badge = await badgeService.getBadgeByRouteId(token, _routeId!);
          setState(() {
            _badgeId = badge['uid'];
            _badgeName = badge['name'];
            _badgeImageUrl =
                'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                    badge['image']; // Formar la URL completa
          });
        } catch (e) {
          // Cargar datos desde el caché si no hay conexión
          final cachedBadgeData =
              await _loadDataFromCache('badgeData_$_routeId');
          if (cachedBadgeData != null) {
            final badge = jsonDecode(cachedBadgeData);
            setState(() {
              _badgeId = badge['uid'];
              _badgeName = badge['name'];
              _badgeImageUrl =
                  'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                      badge['image'];
            });
          } else {
            print('Failed to get badge ID: $e');
          }
        }
      }

      final routeService =
          RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');

      if (_routeId != null) {
        try {
          final routeResponse =
              await routeService.getOneRoute(token, _routeId!);
          await _saveDataToCache(
              'routeResponse_$_routeId', jsonEncode(routeResponse));
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
                  'imageUrl':
                      'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                          location['image'],
                };
              }).toList();
              _showRoute = true;
              _isLoadingRoute = false;
            });

            // Verificar si todas las localidades de la ruta ya han sido visitadas
            _checkIfRouteCompleted(initialCheck: true);
          }
        } catch (e) {
          // Cargar datos desde el caché si no hay conexión
          final cachedRouteResponse =
              await _loadDataFromCache('routeResponse_$_routeId');
          if (cachedRouteResponse != null) {
            final routeResponse = jsonDecode(cachedRouteResponse);
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
                    'imageUrl':
                        'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                            location['image'],
                  };
                }).toList();
                _showRoute = true;
                _isLoadingRoute = false;
              });

              // Verificar si todas las localidades de la ruta ya han sido visitadas
              _checkIfRouteCompleted(initialCheck: true);
            }
          } else {
            print('Failed to get route data: $e');
          }
        }
      }

      try {
        final locationResponse = await LocationService(
                baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
            .getAllLocations(token);
        await _saveDataToCache(
            'locationResponse', jsonEncode(locationResponse));
        if (locationResponse != null) {
          print('Location Response: ${locationResponse.length} locations');
          if (mounted) {
            setState(() {
              locations =
                  locationResponse.map<Map<String, dynamic>>((location) {
                return {
                  '_id': location['_id'],
                  'name': location['name'],
                  'description': location['description'],
                  'coordinates':
                      LatLng(location['latitude'], location['longitude']),
                  'imageUrl':
                      'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
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
      } catch (e) {
        // Cargar datos desde el caché si no hay conexión
        final cachedLocationResponse =
            await _loadDataFromCache('locationResponse');
        if (cachedLocationResponse != null) {
          final locationResponse = jsonDecode(cachedLocationResponse);
          if (locationResponse != null) {
            print('Location Response: ${locationResponse.length} locations');
            if (mounted) {
              setState(() {
                locations =
                    locationResponse.map<Map<String, dynamic>>((location) {
                  return {
                    '_id': location['_id'],
                    'name': location['name'],
                    'description': location['description'],
                    'coordinates':
                        LatLng(location['latitude'], location['longitude']),
                    'imageUrl':
                        'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
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
          print('Failed to get location data: $e');
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

  bool _shouldUpdatePosition(Position position) {
    return _previousPosition == null ||
        Geolocator.distanceBetween(
              _previousPosition!.latitude,
              _previousPosition!.longitude,
              position.latitude,
              position.longitude,
            ) >
            minDistance;
  }

  void _sortRouteLocationsByDistance() {
    if (currentLocation != null) {
      List<Map<String, dynamic>> locationWithDistance = [];

      for (var location in routeLocations) {
        final distance = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          location['coordinates'].latitude,
          location['coordinates'].longitude,
        );
        locationWithDistance.add({...location, 'distance': distance});
      }

      locationWithDistance.sort((a, b) {
        return a['distance'].compareTo(b['distance']);
      });

      routeLocations = locationWithDistance.map((location) {
        return {
          '_id': location['_id'],
          'name': location['name'],
          'description': location['description'],
          'coordinates': location['coordinates'],
          'imageUrl': location['imageUrl']
        };
      }).toList();

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

    // Verificar proximidad para ubicaciones de la ruta
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
        _checkIfRouteCompleted();
        break;
      }
    }

    // Verificar proximidad para todas las ubicaciones
    for (var location in locations) {
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
        break; // Puedes eliminar este break si deseas mostrar múltiples alertas de proximidad
      }
    }

    if (nearest != _nearestLocation) {
      setState(() {
        _nearestLocation = nearest;
      });
    }
  }

  void _checkIfRouteCompleted({bool initialCheck = false}) {
    final routeLocationNames =
        routeLocations.map((location) => location['name']).toSet();
    if (visitedLocations.containsAll(routeLocationNames)) {
      if (initialCheck) {
        _showRouteCompletedDialog();
      } else {
        showCustomDialogRoute();
      }
    }
  }

  // Dentro de la clase _MapPageState
  void _navigateToHome() {
    context.go('/home');
  }

  Future<void> showCustomDialogRoute() async {
    print('BadgeName: $_badgeName');
    print('BadgeImageUrl: _badgeImageUrl');
    print('RouteName: ${widget.routeName}');
    print('RouteImage: ${widget.routeImage}');

    // Mostrar el dialogo
    if (_badgeName != null &&
        _badgeImageUrl != null &&
        widget.routeName != null &&
        widget.routeImage != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogRoute(
            locationName: "última ubicación",
            badgeName: _badgeName!,
            badgeImageUrl: _badgeImageUrl!,
            routeName: widget.routeName!,
            routeImage: widget.routeImage!,
            onConfirm: _navigateToHome, // Pasa la función de navegación
          );
        },
      );
      // Agregar la badge al usuario
      if (_token != null && _userId != null && _badgeId != null) {
        print('Pase hasta aqui');
        final userService =
            UserService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
        try {
          await userService.addBadgeToUser(_token!, _userId!,
              _badgeId!); // Usar el userId y badgeId obtenidos
        } catch (e) {
          print('Failed to add badge to user: $e');
        }
      }
    } else {
      print(
          'Error: BadgeName, BadgeImageUrl, RouteName, or RouteImage is null');
    }
  }

  void _showRouteCompletedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ruta completada'),
          content: const Text(
              'Ya has finalizado la ruta, ¿deseas volver a hacerla?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _clearRouteVisitedLocations();
                  _saveVisitedLocations();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _clearRouteVisitedLocations() {
    final routeLocationNames =
        routeLocations.map((location) => location['name']).toSet();
    visitedLocations
        .removeWhere((location) => routeLocationNames.contains(location));
  }

  void _showProximityAlert(Map<String, dynamic> location) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialogLocation(
        location: location,
        onMoreInfo: () {
          Navigator.of(context).pop();
          _showLocationDetails(location);
        },
      );
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
                    child: _isLoadingRoute
                        ? Skeletonizer(
                            child: Container(
                              height: 150,
                              color: Colors.grey[300],
                            ),
                          )
                        : RouteInfoWidget(
                            routeName: widget.routeName ?? 'Ruta desconocida',
                            locations: routeLocations
                                .map((loc) => loc['name'] as String)
                                .toList(),
                            imageUrl: routeLocations.isNotEmpty
                                ? routeLocations[0]['imageUrl'] as String
                                : 'https://via.placeholder.com/150',
                            onCancel: _toggleRouteVisibility,
                            distanceString: _distanceString,
                            nearestLocation: _nearestLocation?['name'],
                            imageRoute: widget.routeImage,
                            timeString: _timeString,
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
