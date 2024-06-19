import 'package:flutter/material.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:restart_app/restart_app.dart';
import 'package:vive_la_uca/widgets/simple_text.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  void _logout() async {
    await TokenStorage.removeToken();// Asegurándose de que se complete la eliminación del token
    Restart.restartApp(); // Redirigir a la página de inicio de sesión
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _logout,
      child: const SimpleText(text: 'Cerrar sesión', fontSize: 16, color: Colors.red,),
    );
  }
}
