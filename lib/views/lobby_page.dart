import 'package:flutter/material.dart';
import 'package:vive_la_uca/widgets/route_card.dart';
import 'package:vive_la_uca/widgets/simple_text.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/services/location_service.dart';
import 'package:vive_la_uca/services/badge_service.dart';
import 'package:vive_la_uca/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late Future<List<dynamic>> futureRoutes;
  late Future<List<dynamic>> futureLocations;
  List<String> _badgeIds = [];
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  void _loadTokenAndData() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      final authService = AuthService(
          baseUrl: 'https://vivelauca.uca.edu.sv/admin-back/api/auth');
      try {
        final userData = await authService.checkToken(token);
        setState(() {
          _token = token;
          _badgeIds = List<String>.from(userData['badges'] ?? []);
          futureRoutes =
              RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
                  .getAllRoutes(token);
          futureLocations = LocationService(
                  baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
              .getAllLocations(token);
          _isLoading = false;
        });
      } catch (e) {
        print('Failed to fetch user data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _hasBadgeForRoute(String routeId) async {
    final badgeService =
        BadgeService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
    try {
      if (_token != null) {
        final badge = await badgeService.getBadgeByRouteId(_token!, routeId);
        if (badge != null) {
          return _badgeIds.contains(badge['uid']);
        }
      }
      return false;
    } catch (e) {
      print('Failed to fetch badge for route: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              SimpleText(
                  text: 'Vive la UCA',
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                  fontFamily: 'MontserratBold',
                  fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              const SimpleText(
                  text:
                      'Sé búho: recorré nuestro campus, conocé de primera mano tu futura carrera universitaria.',
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.justify),
              const SizedBox(height: 15),
              const SimpleText(
                  text: 'Rutas populares',
                  color: Colors.orange,
                  fontFamily: 'MontserratBold',
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<dynamic>>(
                      future: futureRoutes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Container(
                            height: 270,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var route = snapshot.data![index];
                                return FutureBuilder<bool>(
                                  future: _hasBadgeForRoute(route['uid']),
                                  builder: (context, badgeSnapshot) {
                                    if (badgeSnapshot.connectionState ==
                                            ConnectionState.done &&
                                        !badgeSnapshot.hasError) {
                                      return RouteCard(
                                        imagePath:
                                            'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                                                route['image'],
                                        title: route['name'],
                                        description: route['description'],
                                        distance: '',
                                        redirect: '/route/${route['uid']}',
                                        uid: route['uid'],
                                        hasBadge: badgeSnapshot.data!,
                                      );
                                    } else {
                                      return RouteCard(
                                        imagePath:
                                            'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                                                route['image'],
                                        title: route['name'],
                                        description: route['description'],
                                        distance: '',
                                        redirect: '/route/${route['uid']}',
                                        uid: route['uid'],
                                        hasBadge: false,
                                      );
                                    }
                                  },
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 10),
                            ),
                          );
                        } else {
                          return const Text('No hay rutas disponibles');
                        }
                      },
                    ),
              const SizedBox(height: 20),
              const SimpleText(
                  text: 'Lugares populares',
                  color: Colors.orange,
                  fontFamily: 'MontserratBold',
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              const SizedBox(height: 15),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<dynamic>>(
                      future: futureLocations,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Container(
                            height: 270,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var location = snapshot.data![index];
                                return RouteCard(
                                  imagePath:
                                      'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                                          location['image'],
                                  title: location['name'],
                                  description: location['description'],
                                  distance: '',
                                  redirect: '/location/${location['uid']}',
                                  uid: location['uid'],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 10),
                            ),
                          );
                        } else {
                          return const Text('No hay lugares disponibles');
                        }
                      },
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
