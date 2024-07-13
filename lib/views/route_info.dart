import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/views/map_page.dart';
import 'package:vive_la_uca/widgets/place_card_list.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RouteInfo extends StatefulWidget {
  final String uid;
  final bool? hasBadge;

  RouteInfo({Key? key, required this.uid, this.hasBadge}) : super(key: key);

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
        final currentLocation = await _getCurrentLocation();
        if (currentLocation != null) {
          final routeCoordinates = _routeData!['locations']
              .map<LatLng>((location) =>
                  LatLng(location['latitude'], location['longitude']))
              .toList();
          await _calculateDistanceAndTime(currentLocation, routeCoordinates);
        }
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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
        'https://dei.uca.edu.sv/routing/route/v1/foot/$coordinates?geometries=geojson';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var route = json['routes'][0];
      setState(() {
        _distanceToLastLocation =
            route['distance'] / 1000; // Convertir a kilómetros
        _timeToLastLocation = route['duration'] / 60; // Convertir a minutos
      });
    } else {
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
          ? Skeletonizer(child: _buildRouteSkeleton())
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildRouteContent(),
            ),
    );
  }

  Widget _buildRouteSkeleton() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
            child: Container(
              width: double.infinity,
              height: 350,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 30,
                  width: 150,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

    final bool hasBadge = widget.hasBadge ?? false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Skeletonizer(
                    child: Container(
                      width: double.infinity,
                      height: 350,
                      color: Colors.grey[300],
                    ),
                  ),
                  fadeInDuration: const Duration(milliseconds: 500),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Skeletonizer(
                        child: Container(
                          width: double.infinity,
                          height: 400,
                          color: Colors.grey[300],
                        ),
                      ),
                      fadeInDuration: const Duration(milliseconds: 500),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    Container(
                      width: double.infinity,
                      height: 400,
                      color: Colors.black.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SvgPicture.asset(
                                  'lib/assets/images/has_badge.svg',
                                  width: 25,
                                  height: 25,
                                  colorFilter: ColorFilter.mode(
                                    hasBadge
                                        ? Colors.orange
                                        : const Color(0xFFB9C0C9),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: startRoute,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.only(
                                        left: 8, bottom: 7, top: 7, right: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Transform.rotate(
                                            angle: 45 * 3.1415927 / 180,
                                            child: const Icon(
                                              Icons.navigation_rounded,
                                              color: Colors.orange,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        ' Empezar ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                if (_distanceToLastLocation != null &&
                                    _timeToLastLocation != null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_timeToLastLocation!.toStringAsFixed(0)} min',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '(${_distanceToLastLocation!.toStringAsFixed(1)} km)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Lugares de esta ruta',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          PlaceCardList(
            places: locations
                .map<Map<String, String>>((location) => {
                      'title': location['name'] as String,
                      'imageUrl':
                          'https://vivelauca.uca.edu.sv/admin-back/uploads/${location['image'] as String}',
                      'description': location['description'] as String
                    })
                .toList(),
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
