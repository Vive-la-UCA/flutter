import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vive_la_uca/services/auth_service.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/services/badge_service.dart';
import 'package:vive_la_uca/widgets/logout_button.dart';
import 'package:vive_la_uca/widgets/simple_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vive_la_uca/widgets/badge_detail_sheet.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool _isLoading = true; // Indicator for loading badges

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
    if (await _requestPermissions()) {
      print('Permissions granted');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageUrl', pickedFile.path);
        setState(() {
          _profileImageUrl = pickedFile.path;
        });
      } else {
        print('No image selected');
      }
    } else {
      print('Permissions not granted');
    }
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.storage,
    ].request();

    bool storageGranted = statuses[Permission.storage]?.isGranted ?? false;

    print('Storage permission: $storageGranted');

    return storageGranted;
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
        _isLoading = false; // Set loading to false when done
      });
    } catch (e) {
      _showErrorDialog('Failed to fetch badges: $e');
      setState(() {
        _isLoading = false; // Set loading to false even on error
      });
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

  void _showBadgeDetailSheet(
      BuildContext context, Map<String, dynamic> badge) async {
    final imageUrl = badge['image'] ?? '';
    final badgeName = badge['name'] ?? 'Unnamed Badge';
    final routeId = badge['route']['_id'] ?? '';

    final token = await TokenStorage.getToken();
    final routeService =
        RouteService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back');
    try {
      final routeData = await routeService.getOneRoute(token!, routeId);
      final routeName = routeData['name'] ?? 'unknown';
      final routeImage = routeData['image'] ?? '';

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return BadgeDetailSheet(
            imageUrl:
                'https://vivelauca.uca.edu.sv/admin-back/uploads/' + imageUrl,
            badgeName: badgeName,
            routeName: routeName,
            routeImageUrl:
                'https://vivelauca.uca.edu.sv/admin-back/uploads/' + routeImage,
          );
        },
      );
    } catch (e) {
      _showErrorDialog('Failed to fetch route data: $e');
    }
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
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Theme.of(context).primaryColor, // Color del borde
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
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _badges.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'lib/assets/images/has_badge.svg',
                                width: 50,
                                height: 50,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFB9C0C9), // Gris
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Consigue insignias completando las rutas',
                                textAlign: TextAlign.center, // Centrar el texto
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(top: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _badges.length,
                          itemBuilder: (context, index) {
                            final badge = _badges[index];
                            return GestureDetector(
                              onTap: () => _showBadgeDetailSheet(context, badge),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        'https://vivelauca.uca.edu.sv/admin-back/uploads/' +
                                            badge['image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      badge['name'] ?? 'Unnamed Badge',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
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
