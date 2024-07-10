import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadToken();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profileImageUrl') ??
          'https://i0.wp.com/digitalhealthskills.com/wp-content/uploads/2022/11/3da39-no-user-image-icon-27.png?fit=500%2C500&ssl=1';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', pickedFile.path);
      setState(() {
        _profileImageUrl = pickedFile.path;
      });
    }
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
        title: Column(
          children: [
            const SizedBox(height: 30),
            SimpleText(
              text: 'Vive la UCA',
              color: Theme.of(context).primaryColor,
              fontSize: 25,
              fontFamily: 'MontserratBold',
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor, // Color del borde
                      width: 5.0, // Ancho del borde
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImageUrl != null
                        ? _profileImageUrl!.startsWith('http')
                            ? NetworkImage(_profileImageUrl!)
                            : FileImage(File(_profileImageUrl!))
                                as ImageProvider
                        : const NetworkImage(
                            'https://i0.wp.com/digitalhealthskills.com/wp-content/uploads/2022/11/3da39-no-user-image-icon-27.png?fit=500%2C500&ssl=1',
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                ),
              ],
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
                          color: Colors.white,
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
