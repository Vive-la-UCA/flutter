import 'package:flutter/material.dart';
import 'package:vive_la_uca/services/auth_service.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/services/badge_service.dart';
import 'package:vive_la_uca/widgets/logout_button.dart';
import 'package:vive_la_uca/widgets/simple_text.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName; // To hold the user's name
  List<String> _badgeIds = []; // To hold badge IDs
  List<Map<String, dynamic>> _badges = []; // To hold detailed badge data

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _loadToken() async {
    final token = await TokenStorage.getToken();

    if (token != null) {
      final authService = AuthService(
          baseUrl: 'https://vivelauca.uca.edu.sv/admin-back/api/auth');

      try {
        final userData = await authService.checkToken(token);
        setState(() {
          _userName = userData['name'];
          _badgeIds = List<String>.from(userData['badges'] ?? []);
        });
        _fetchBadges(token);
      } catch (e) {
        _showErrorDialog('Failed to fetch user data: $e');
      }
    }
  }

  void _fetchBadges(String token) async {
    final badgeService =
        BadgeService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');

    try {
      final badges = await Future.wait(
        _badgeIds.map((id) async {
          final badge = await badgeService.getBadgeById(token, id);
          return badge;
        }),
      );
      setState(() {
        _badges = badges.toList();
      });
    } catch (e) {
      _showErrorDialog('Failed to fetch badges: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SimpleText(
          text: 'Vive la UCA',
          color: Theme.of(context).primaryColor,
          fontSize: 20,
          fontFamily: 'MontserratBold',
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  'https://cdn-icons-png.freepik.com/512/1144/1144760.png'),
            ),
            const SizedBox(height: 15),
            Text(
              _userName ?? 'Loading...',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mis Insignias',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _badges.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _badges.length,
                      itemBuilder: (context, index) {
                        final badge = _badges[index];
                        return Card(
                          child: ListTile(
                            leading: Image.network(
                              'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                                  badge['image'],
                              width: 50,
                              height: 50,
                            ),
                            title: Text(badge['name'] ?? 'Unnamed Badge'),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 15),
            const LogoutButton(),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
