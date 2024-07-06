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

  
}
