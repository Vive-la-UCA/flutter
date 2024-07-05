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

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];

  Set<String> visitedLocations = {}; // Conjunto para rastrear ubicaciones visitadas
  Position? _previousPosition;
  final List<LatLng> _locationHistory = [];
  static const int historyLength = 5; // Número de puntos para suavizar
  static const double minDistance = 1.0; // Umbral mínimo de distancia en metros
  String? _currentAlertLocation; // Variable para rastrear la ubicación actual de alerta

  // Define una lista de coordenadas personalizadas para la ruta
  List<LatLng> routeCoordinates = [];

  List<Map<String, dynamic>> routeLocations = []; // Lista de ubicaciones de la ruta

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
        });
        _checkProximity();
      }
    });
  }

  void _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      final routeService =
          RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');

      // Aquí obtienes la ruta por ID y sus ubicaciones
      final routeId =
          '66822e32e6528f703bb47ffa'; // Reemplaza con el ID de la ruta que necesitas
      final routeResponse = await routeService.getOneRoute(token, routeId);
      final locationsFromRoute = routeResponse['locations'];

      // Extrae las coordenadas de las ubicaciones y las guarda en routeCoordinates
      setState(() {
        routeCoordinates = locationsFromRoute.map<LatLng>((location) {
          return LatLng(location['latitude'], location['longitude']);
        }).toList();

        // Guarda las ubicaciones de la ruta para proximidad
        routeLocations = locationsFromRoute.map<Map<String, dynamic>>((location) {
          return {
            '_id': location['_id'], // Asegúrate de incluir el ID en cada ubicación
            'name': location['name'],
            'description': location['description'],
            'coordinates': LatLng(location['latitude'], location['longitude']),
            'imageUrl': 'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                location['image'], // Actualiza la URL base según sea necesario
          };
        }).toList();
      });

      // El resto del código para obtener todas las ubicaciones
      final locationResponse = await LocationService(
              baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
          .getAllLocations(token);
      if (locationResponse != null) {
         print('Location Response: ${locationResponse.length} locations'); // Añadir esta línea
        setState(() {
          locations = locationResponse.map<Map<String, dynamic>>((location) {
            return {
              '_id': location['_id'],
              'name': location['name'],
              'description': location['description'],
              'coordinates': LatLng(location['latitude'], location['longitude']),
              'imageUrl': 'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                  location['image'], // Actualiza la URL base según sea necesario
            };
          }).toList();
          _calculateRoute(); // Calcular la ruta después de obtener las ubicaciones
        });
      }
    } else {
      setState(() {
        // Manejo del error
        print('Error al obtener el token');
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

      if (distance <= 10.0 && !visitedLocations.contains(location['_id'])) {
        _showProximityAlert(location['name']); // O cambiar a '_id' si prefieres usar el ID
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

    // Crear una lista de coordenadas para la URL
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
                // Capa de fondo de la línea
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 6.0, // Grosor del fondo de la línea
                      color: Colors.blue.shade100,
                      borderColor: Colors.blue.shade300,
                      borderStrokeWidth: 5, // Color del fondo de la línea
                      isDotted: false,
                    ),
                  ],
                ),
                // Capa de la línea punteada
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 10.0, // Grosor de la línea punteada
                      color: const Color.fromARGB(255, 61, 122, 228),
                      borderColor: const Color.fromARGB(255, 51, 101, 187),
                      borderStrokeWidth: 2, // Color de la línea punteada
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
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.orange,
                                size: 50,
                              ),
                              Positioned(
                                top: 8,
                                child: ClipOval(
                                  child: Image.network(
                                    location['imageUrl'],
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 24,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                CurrentLocationLayer(
                  style: const LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: Colors.black,
                      child: Image(
                          image: AssetImage('lib/assets/images/owlIcon.png')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 6.0,
        shape: CircleBorder(),
        child: Icon(
          Icons.my_location,
          size: 24.0, // Tamaño del icono más pequeño
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
