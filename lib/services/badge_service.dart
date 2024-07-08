import 'dart:convert';
import 'package:http/http.dart' as http;

class BadgeService {
  final baseUrl;

  BadgeService({required this.baseUrl});

  Future<List<dynamic>> getBadges(tokenKey) async {
    final url = Uri.parse('$baseUrl/api/badge');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenKey'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['routes']; // Devuelve directamente la lista de rutas
    } else {
      throw Exception('Failed to load routes');
    }
  }

  Future<Map<String, dynamic>> getBadgeById(tokenKey, badgeId) async {
    final url = Uri.parse('$baseUrl/api/badge/$badgeId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenKey'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['badge']; // Devuelve directamente la lista de rutas
    } else {
      throw Exception('Failed to load routes');
    }
  }

  Future<Map<String, dynamic>> getBadgeByRouteId(tokenKey, routeId) async {
    final url = Uri.parse('$baseUrl/api/badge/route/$routeId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenKey'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['badge']; // Devuelve directamente la lista de rutas
    } else {
      throw Exception('Failed to load routes');
    }
  }
}
