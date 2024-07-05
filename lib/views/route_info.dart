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
            // Imagen Principal
            Image.network(
              'https://via.placeholder.com/400x300',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            // Título y Duración
            Container(
              padding: EdgeInsets.all(16.0),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ruta Romero',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.play_arrow, color: Colors.orange),
                      Text(' Empezar '),
                      Icon(Icons.access_time, color: Colors.grey),
                      Text('3 min (500 m)'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Lugares de esta ruta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Lista de lugares
            Container(
              height: 300,
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
                  _buildPlaceCard('M', 'https://via.placeholder.com/100'),
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
}
