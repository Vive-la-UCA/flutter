import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/views/home_page.dart';
import 'package:vive_la_uca/views/login_page.dart';
import 'package:vive_la_uca/views/register_page.dart';
import 'package:vive_la_uca/views/splash_screen.dart';

void main() {
  runApp( MyApp());
  _loadToken();
}
bool isLoggedIn = false;
void _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      isLoggedIn=true;
    }

    
  }




class MyApp extends StatelessWidget {
  
   MyApp({super.key});
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF012255),
      ),
      routerConfig: _router,
    );
  }
}



final GoRouter _router = GoRouter(

  redirect:(context, state){
    if(isLoggedIn){
      return "/home";
    }
  },
  
  routes: [
    GoRoute(path: '/', builder: (context,state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context,state) => const HomePage()),
    GoRoute(path: '/login', builder: (context,state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context,state) => const RegisterPage()),
  ]

  
);

  