import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vive_la_uca/services/token_service.dart';

class LogoutButton extends StatefulWidget {
const LogoutButton({ super.key });

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
void _logout (){
  TokenStorage.removeToken();
   GoRouter.of(context).replace('/');
   
}

  @override
  Widget build(BuildContext context){
    return ElevatedButton(onPressed: _logout, child: const Text( 'cerrar sesión'),);
  }
}