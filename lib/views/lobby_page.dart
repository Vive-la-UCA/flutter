import 'package:flutter/material.dart';
import 'package:vive_la_uca/widgets/route_card.dart';
import 'package:vive_la_uca/widgets/search_bar.dart';

class LobbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Vive la UCA',
                style: TextStyle(
                  fontFamily: 'MontserratBold',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sé búho: recorré nuestro campus, conocé de primera mano tu futura carrera universitaria.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 15),
              SearchingBar(),
              const SizedBox(height: 15),
              const Text(
                'Rutas populares',
                style: TextStyle(
                  fontFamily: 'MontserratBold',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              
              const RouteCard(
                imagePath: 'lib/assets/images/CMR.png',
                title: 'Ruta 1',
                description: 'Relata los detalles de los mártires durante el conflicto armado en El Salvador wnidnwi wdnwindiwn wndwnd dwnduwdu',
                distance: '1.5 km',
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Lugares populares',
                style: TextStyle(
                  fontFamily: 'MontserratBold',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ), 
              const SizedBox(height: 10),
              const RouteCard(
                imagePath: 'lib/assets/images/M7.jpg',
                title: 'Magna 7',
                description: 'Un recuerdo para toda la vida',
                distance: '1.5 km',
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
