import 'package:flutter/material.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/services/token_service.dart';

class RouteInfo extends StatefulWidget {
  final String uid;
  RouteInfo({Key? key, required this.uid}) : super(key: key);

  @override
  State<RouteInfo> createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo> {
  bool _isLoading = true;
  Map<String, dynamic>? _routeData;

  @override
  void initState() {
    super.initState();
    _loadRouteInfo();
  }

  void _loadRouteInfo() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      try {
        final routeService = RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
        _routeData = await routeService.getOneRoute(token, widget.uid);
      } catch (e) {
        print('Error loading route data: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildRouteContent(),
    );
  }

  Widget _buildRouteContent() {
    final imageUrl = 'https://vivelauca.uca.edu.sv/admin-back/uploads/' + (_routeData?['image'] ?? 'https://via.placeholder.com/400x300');
    final name = _routeData?['name'] ?? 'Ruta desconocida';
    final description = _routeData?['description'] ?? 'No hay descripción disponible.';
    final locations = List<Map<String, dynamic>>.from(_routeData?['locations'] ?? []);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.network(imageUrl, width: double.infinity, height: 350, fit: BoxFit.cover),
              Container(
                width: double.infinity,
                height: 350, // Make sure the overlay covers the entire image area
                color: Colors.black.withOpacity(0.3), // Black color with 80% opacity
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: startRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white),
                          Text(' Empezar ', style: TextStyle(color: Colors.white)),
                          
                        ],
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(description, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Lugares de esta ruta:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...locations.map((location) => _buildPlaceCard(location['name'], 'https://vivelauca.uca.edu.sv/admin-back/uploads/' + location['image'])).toList(),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(String title, String imageUrl) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
          ),
        ],
      ),
    );
  }

  void startRoute() {
    print('Iniciar ruta: ${_routeData?['name']}');
  }
}
