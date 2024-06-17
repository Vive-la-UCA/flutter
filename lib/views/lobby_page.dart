import 'package:flutter/material.dart';
import 'package:vive_la_uca/widgets/route_card.dart';
import 'package:vive_la_uca/widgets/search_bar.dart';
import '../widgets/simple_text.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

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
               SimpleText(text:  'Vive la UCA', color: Theme.of(context).primaryColor, fontSize: 20, fontFamily: 'MontserratBold', fontWeight: FontWeight.bold,),
              const SizedBox(height: 10),
              const SimpleText(text: 'Sé búho: recorré nuestro campus, conocé de primera mano tu futura carrera universitaria.',  color: Colors.black, fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w500, textAlign: TextAlign.justify),
              const SizedBox(height: 15),
              const SearchingBar(),
              const SizedBox(height: 15),
              const SimpleText(text: 'Rutas populares', color: Colors.orange, fontFamily:  'MontserratBold',fontSize: 20,fontWeight: FontWeight.bold, ),
              const SizedBox(height: 10),
              
              const RouteCard(
                imagePath: 'lib/assets/images/CMR.png',
                title: 'Ruta 1',
                description: 'Relata los detalles de los mártires durante el conflicto armado en El Salvador wnidnwi wdnwindiwn wndwnd dwnduwdu',
                distance: '1.5 km',
              ),
              const SizedBox(height: 20),
              const SimpleText(text: 'Lugares populares', color: Colors.orange, fontFamily:  'MontserratBold',fontSize: 20,fontWeight: FontWeight.bold, ),
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
