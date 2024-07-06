import 'package:flutter/material.dart';

class RouteInfo extends StatelessWidget {
  const RouteInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack para colocar el texto y los botones sobre la imagen
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                // Imagen Principal
                Image.network(
                  'https://via.placeholder.com/400x300',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                // Contenedor para el título y el botón, con un gradiente de fondo
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7), // Más opacidad en la parte inferior
                        Colors.transparent // Transparente hacia la parte superior
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ruta Romero',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white, // Texto blanco para contraste
                          fontFamily: 'MontserratBold',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: startRoute, 
                      //color de fondo
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white),
                          Text(' Empezar ', style: TextStyle(color: Colors.white)),
                          
                        ],
                      ),),
                      
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
                style: TextStyle(fontSize: 16,),
                textAlign: TextAlign.justify,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child:  Text(
              'Lugares de esta ruta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
             // padding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            ),
           
            const SizedBox(height: 5),
            // Lista de lugares
            Container(
              height: 400,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  _buildPlaceCard('Centro Monseñor Romero', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                  _buildPlaceCard('Mural Rostro de Mártires', 'https://via.placeholder.com/100'),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(String title, String imageUrl) {
    return Container(
      width: 250,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startRoute() {
    print('Iniciar ruta');
  }
}
