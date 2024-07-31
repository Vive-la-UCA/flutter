import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

Future<Map<String, dynamic>> register(
  String name, String email, String password) async {
  final url = Uri.parse('$baseUrl/register');

  try {
    final response = await http.post(
      url,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  } catch (error) {
    // Captura y maneja cualquier error que ocurra durante la solicitud HTTP
    throw Exception('Failed to register: $error');
  }
}


  Future<Map<String, dynamic>> checkToken(String token) async {
    final url = Uri.parse('$baseUrl/check-token');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else {
      throw Exception('Failed to check token');
    }
  }
}
