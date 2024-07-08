import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  // Add badge to user
  Future<Map<String, dynamic>> addBadgeToUser(String tokenKey, String badgeId) async {
    final url = Uri.parse('$baseUrl/api/users/add-badge/$badgeId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['badge'];
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to add badge: ${errorData['message']}');
    }
  }
}
