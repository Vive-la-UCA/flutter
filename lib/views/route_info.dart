import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/views/map_page.dart';
import 'package:vive_la_uca/widgets/place_card_list.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vive_la_uca/views/no_connection.dart';

double _calculateDistance(LatLng start, LatLng end) {
  return Geolocator.distanceBetween(
    start.latitude,
    start.longitude,
    end.latitude,
    end.longitude,
  );
}

double calculateTime(double distance) {
  const double averageSpeed = 5000 / 3600; // velocidad promedio en m/s
  return distance / averageSpeed / 60; // tiempo en minutos
}

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
  LatLng? currentLocation;

  double? _distanceToLastLocation;
  double? _timeToLastLocation;
  bool _hasConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _initialize();
  }

  Future<void> _initialize() async {
    await _determinePosition();
    if (_hasConnection) {
      await _loadRouteInfo();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _hasConnection = result != ConnectivityResult.none;
      if (_hasConnection) {
        _loadRouteInfo();
      }
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    LatLng latLng = LatLng(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        currentLocation = latLng;
      });
    }
  }

  Future<void> _loadRouteInfo() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      try {
        final routeService =
            RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
        _routeData = await routeService.getOneRoute(token, widget.uid);
        if (currentLocation != null) {
          final routeCoordinates = _routeData!['locations']
              .map<LatLng>((location) => LatLng(
                  double.parse(location['latitude'].toString()),
                  double.parse(location['longitude'].toString())))
              .toList();
          await _calculateDistanceAndTime(currentLocation!, routeCoordinates);
        }
      } catch (e) {
        print('Error loading route data: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _calculateDistanceAndTime(
      LatLng currentLocation, List<LatLng> routeCoordinates) async {
    if (routeCoordinates.isEmpty) return;

    LatLng lastLocation = routeCoordinates.last;
    double distance = _calculateDistance(currentLocation, lastLocation);
    double time = calculateTime(distance);

    if (mounted) {
      setState(() {
        _distanceToLastLocation = distance;
        _timeToLastLocation = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasConnection) {
      return NoConnectionScreen(onRetry: _loadRouteInfo);
    }

    return Scaffold(
      body: _isLoading
          ? Skeletonizer(child: _buildRouteSkeleton())
          : _buildRouteContent(),
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
                                        _timeToLastLocation! >= 60
                                            ? '${(_timeToLastLocation! / 60).floor()} h ${(_timeToLastLocation! % 60).round()} min'
                                            : '${_timeToLastLocation!.toStringAsFixed(0)} min',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _distanceToLastLocation! >= 1000
                                            ? '(${(_distanceToLastLocation! / 1000).toStringAsFixed(2)} km)'
                                            : '(${_distanceToLastLocation!.toStringAsFixed(2)} m)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_distanceToLastLocation == null ||
                                    _timeToLastLocation == null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        '--:--',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '--:--',
                                        style: TextStyle(
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
                Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 16),
                ),
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
                      'description': location['description'] as String,
                    })
                .toList(),
          ),
        ],
      ),
    );
  }

  void startRoute() async {
    if (_routeData != null) {
      if (currentLocation != null) {
        final routeCoordinates = _routeData!['locations']
            .map<LatLng>((location) => LatLng(
                double.parse(location['latitude'].toString()),
                double.parse(location['longitude'].toString())))
            .toList();

        await _calculateDistanceAndTime(currentLocation!, routeCoordinates);

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
