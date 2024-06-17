import 'package:flutter/material.dart';

class RegisterQuestion extends StatelessWidget {
  final VoidCallback onRegisterPressed;  // Callback para la acción de registro

  const RegisterQuestion({
    super.key,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'No tienes cuenta?',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: onRegisterPressed,  // Usar el callback proporcionado
          child: const Text('Registrate aquí!',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: Colors.blue,
            )
          )
        )
      ],
    );
  }
}
