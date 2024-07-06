import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/views/home_page.dart';
import 'package:vive_la_uca/views/login_page.dart';
import 'package:vive_la_uca/views/register_page.dart';
import 'package:vive_la_uca/views/route_info.dart';
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
  loadToken();
  runApp(const MyApp());
}

bool isLoggedIn = false;
void loadToken() async {
  final token = await TokenStorage.getToken();
  if (token != null) {
    isLoggedIn = true;
  } else {
    isLoggedIn = false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  redirect: (context, state) {
    final loggedIn = isLoggedIn;  // Check if the user is logged in
    final goingToLogin = state.subloc == '/login';

    if (loggedIn && goingToLogin) {
      // If logged in and trying to go to login, redirect to home
      return "/home";
    } else if (!loggedIn && state.subloc != '/login' && state.subloc != '/') {
      // If not logged in and trying to access a protected route, redirect to login
      return "/login";
    }
    // No redirection needed
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/route/:uid',  builder: (context, state) {
    final String uid = state.params['uid']!; // Recuperar el UID de los parámetros de la ruta
    return RouteInfo(uid: uid); // Pasar el UID al constructor de RouteInfo
  },),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
  ],
);