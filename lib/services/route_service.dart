import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteService {
  final  baseUrl;

  RouteService({required this.baseUrl});

  Future<List<dynamic>> getRoutes(tokenKey) async {
    final url = Uri.parse('$baseUrl/api/route');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $tokenKey'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['routes']; // Devuelve directamente la lista de rutas
    } else {
      throw Exception('Failed to load routes');
    }
  }

<<<<<<< HEAD
  Future<Map<String, dynamic>> getOneRoute(String tokenKey, String uid) async {
  final url = Uri.parse('$baseUrl/api/route/$uid');
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $tokenKey'
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['route'];
  } else {
    throw Exception('Failed to load route');
  }
}

  
=======
  Future<Map<String, dynamic>> getOneRoute(String tokenKey, String routeId) async {
    final url = Uri.parse('$baseUrl/api/route/$routeId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['route']; // Devuelve directamente la ruta
    } else if (response.statusCode == 404) {
      throw Exception('Route not found');
    } else {
      throw Exception('Failed to load route: ${response.statusCode}');
    }
  }
>>>>>>> 04d16b0a6bff8af58c1b1a13e46646794ce68386
}
