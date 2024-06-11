import 'package:flutter/material.dart';
import 'package:vive_la_uca/views/home_page.dart';
import 'package:vive_la_uca/views/login_page.dart';
import 'package:vive_la_uca/views/register_page.dart';
import 'package:vive_la_uca/views/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _routes = {
    '/': (context) => const SplashScreen(),
    '/home': (context) => const HomePage(),
    '/login': (context) => LoginPage(),
    '/register': (context) => const RegisterPage(),
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: _routes,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const HomePage());
        });
  }
}
