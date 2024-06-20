import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vive_la_uca/views/home_page.dart';
import 'package:vive_la_uca/views/login_page.dart';
import 'package:vive_la_uca/views/register_page.dart';
import 'package:vive_la_uca/views/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, initialize them before using them
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _routes = {
    '/': (context) => const SplashScreen(),
    '/home': (context) => const HomePage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF012255),
        ),
        initialRoute: '/',
        routes: _routes,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const HomePage());
        });
  }
}
