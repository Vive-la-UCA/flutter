import 'package:flutter/material.dart';
import 'package:vive_la_uca/widgets/route_card.dart';
import 'package:vive_la_uca/widgets/simple_text.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/services/location_service.dart';
import 'package:vive_la_uca/services/badge_service.dart';
import 'package:vive_la_uca/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  Map<String, bool> _badgeStatus = {};

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
        if (!mounted) return;
        setState(() {
          _token = token;
          _badgeIds = List<String>.from(userData['badges'] ?? []);
          futureRoutes =
              RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
                  .getAllRoutes(token);
          futureLocations = LocationService(
                  baseUrl: 'https://vivelauca.uca.edu.sv/admin-back')
              .getAllLocations(token);
        });

        final routes = await futureRoutes;
        final badgeService =
            BadgeService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');

        for (var route in routes) {
          final badge =
              await badgeService.getBadgeByRouteId(_token!, route['uid']);
          if (!mounted) return;
          setState(() {
            _badgeStatus[route['uid']] =
                badge != null && _badgeIds.contains(badge['uid']);
          });
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Failed to fetch user data: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  ? Container(
                      height: 270,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) =>
                            buildRouteCardSkeleton(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                      ),
                    )
                  : FutureBuilder<List<dynamic>>(
                      future: futureRoutes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 270,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (context, index) =>
                                  buildRouteCardSkeleton(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 10),
                            ),
                          );
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
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: RouteCard(
                                    key: ValueKey(route['uid']),
                                    imagePath:
                                        'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                                            route['image'],
                                    title: route['name'],
                                    description: route['description'],
                                    distance: '',
                                    redirect: '/route/${route['uid']}',
                                    uid: route['uid'],
                                    hasBadge: _badgeStatus[route['uid']],
                                  ),
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
                  ? Container(
                      height: 270,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) =>
                            buildRouteCardSkeleton(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                      ),
                    )
                  : FutureBuilder<List<dynamic>>(
                      future: futureLocations,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 270,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (context, index) =>
                                  buildRouteCardSkeleton(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 10),
                            ),
                          );
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
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: RouteCard(
                                    key: ValueKey(location['uid']),
                                    imagePath:
                                        'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                                            location['image'],
                                    title: location['name'],
                                    description: location['description'],
                                    distance: '',
                                    redirect: '/location/${location['uid']}',
                                    uid: location['uid'],
                                  ),
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

  Widget buildRouteCardSkeleton() {
    return Container(
      width: 330,
      child: Card(
        color: Colors.white,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeletonizer(
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeletonizer(
                    child: Container(
                      height: 20,
                      width: 200,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Skeletonizer(
                    child: Container(
                      height: 16,
                      width: 100,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Skeletonizer(
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
