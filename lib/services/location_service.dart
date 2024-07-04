import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  final  baseUrl;

  LocationService({required this.baseUrl});

  Future<List<dynamic>> getLocations(tokenKey) async {
    final url = Uri.parse('$baseUrl/api/location');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $tokenKey'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['locations']; 
    } else {
      throw Exception('Failed to load locations');
    }
  }
}
