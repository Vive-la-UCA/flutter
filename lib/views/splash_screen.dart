import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 21, 38, 68), Color.fromARGB(255, 21, 38, 100)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft
          ),
          
        ),
        child: const Column(
          mainAxisAlignment : MainAxisAlignment.center,
          children: [
          Text(
            '¡Descubre todos los lugares de la UCA!',
            textAlign: TextAlign.center, 
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
            fontSize: 32,
  
            

          )
          ,)
          ],
        ),
        ),
    );
  }
}