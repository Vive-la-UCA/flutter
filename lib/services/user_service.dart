import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  // Add badge to user
  Future<void> addBadgeToUser(String token, String userId, String badgeId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/add-badge/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'badge': badgeId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Badge added successfully');
      } else {
        print('Failed to add badge: ${response.body}');
        throw Exception('Failed to add badge: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Failed to add badge due to an exception: $e');
    }
  }
}
