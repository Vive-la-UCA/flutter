import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  final  baseUrl;

  LocationService({required this.baseUrl});

  Future<List<dynamic>> getRoutes(tokenKey) async {
    final url = Uri.parse('$baseUrl/api/location');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $tokenKey'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['locations']; // Devuelve directamente la lista de rutas
    } else {
      throw Exception('Failed to load locations');
    }
  }
}
