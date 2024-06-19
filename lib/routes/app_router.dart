// app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/views/home_page.dart';
import 'package:vive_la_uca/views/login_page.dart';
import 'package:vive_la_uca/views/register_page.dart';
import 'package:vive_la_uca/views/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final isLoggedIn = await TokenStorage.getToken() != null;
      final goingToLogin = state.subloc == '/login';

      if (!isLoggedIn && !goingToLogin) return '/login';
      if (isLoggedIn && goingToLogin) return '/home';

      return null; // Si no hay necesidad de redireccionar, devuelve null
    },
  );
}