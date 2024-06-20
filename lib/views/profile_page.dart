import 'package:flutter/material.dart';
import 'package:vive_la_uca/services/auth_service.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/widgets/logout_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName; // To hold the user's name

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _loadToken() async {
    final token = await TokenStorage.getToken();

    if (token != null) {
      
      // final authService = AuthService(
      //     baseUrl: 'https://vivelauca.uca.edu.sv/admin-back/api/auth');

      final authService = AuthService(baseUrl: 'https://vivelauca.uca.edu.sv/admin-back/api/auth');

      try {
        final userData = await authService.checkToken(token);
        setState(() {
          _userName = userData['name']; // Extracting the name from userData
        });
      } catch (e) {
        _showErrorDialog('Failed to fetch user data: $e');
      }
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
        title: const Text('Vive la UCA'),
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
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Placeholder image
            ),
            const SizedBox(height: 30),
            Text(
              _userName ??
                  'Loading...', // Display the user's name or loading state
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mis Insignias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                children: List.generate(5, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Image.network(
                            'https://via.placeholder.com/50', // Placeholder image URL
                            width: double.infinity,
                            height: 80, // Adjusted height for the image
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Insignia Monsenor',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                    
                  );
                }),
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
