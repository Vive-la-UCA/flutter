import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vive_la_uca/views/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Inicializa el AnimationController y la Animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Inicia la animación
    _animationController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      // Comienza a desvanecer la pantalla
      _animationController.reverse().then((value) => {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) =>  LoginPage()))
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 21, 38, 68), Color.fromARGB(255, 21, 38, 100)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: FadeTransition(
        opacity: _animation,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('lib/assets/images/logo.png')),
             SizedBox(height: 24), // Añade espacio entre el texto y el spinner
             Text(
              '¡Descubre todos los lugares de la UCA!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 32,
              ),
            ),
             SizedBox(height: 48), // Añade más espacio si es necesario
            CircularProgressIndicator( // Aquí añades el spinner
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Color del spinner
            ),
          ],
        ),
      ),
    ),
  );
}
}