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
    await TokenStorage.removeToken();  // Asegurándose de que se complete la eliminación del token
    Restart.restartApp();  // Redirigir a la página de inicio de sesión
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SimpleText(text: 'Cerrar sesión', fontSize: 20,color: Theme.of(context).primaryColor , textAlign: TextAlign.left,),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cerrar el diálogo
              },
              child: SimpleText(text: 'Cancelar', fontSize: 14,color: Theme.of(context).primaryColor ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cerrar el diálogo antes de cerrar sesión
                _logout();
              },
              child:  SimpleText(text: 'Cerrar sesion', fontSize: 14,color: Theme.of(context).primaryColor ,),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _showLogoutConfirmationDialog,  // Llama al diálogo de confirmación
      child: const SimpleText(text: 'Cerrar sesión', fontSize: 16, color: Colors.red,),
    );
  }
}
