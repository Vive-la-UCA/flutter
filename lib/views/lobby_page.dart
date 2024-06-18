import 'package:flutter/material.dart';
import 'package:vive_la_uca/widgets/route_card.dart';
import 'package:vive_la_uca/widgets/search_bar.dart';
import 'package:vive_la_uca/widgets/simple_text.dart';
import 'package:vive_la_uca/services/token_service.dart';
import 'package:vive_la_uca/services/route_service.dart';
import 'package:vive_la_uca/services/location_service.dart'; 

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late Future<List<dynamic>> futureRoutes = Future.value([]);
  late Future<List<dynamic>> futureLocations = Future.value([]);
  bool _isLoading = true;  // Estado adicional para controlar la carga

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      setState(() {
        futureRoutes = RouteService(baseUrl: 'http://10.0.2.2:5050').getRoutes(token);
        futureLocations = LocationService(baseUrl: 'http://10.0.2.2:5050').getRoutes(token);
        print(futureLocations);
        _isLoading = false;  // Actualizar estado de carga
      });
    } else {
      setState(() {
        _isLoading = false;  // Actualizar estado de carga, manejo del error
      });
    }
  }

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
              SimpleText(text: 'Vive la UCA', color: Theme.of(context).primaryColor, fontSize: 20, fontFamily: 'MontserratBold', fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              const SimpleText(text: 'Sé búho: recorré nuestro campus, conocé de primera mano tu futura carrera universitaria.', color: Colors.black, fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w500, textAlign: TextAlign.justify),
              const SizedBox(height: 15),
              const SearchingBar(),
              const SizedBox(height: 15),
              const SimpleText(text: 'Rutas populares', color: Colors.orange, fontFamily: 'MontserratBold', fontSize: 20, fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<dynamic>>(
                      future: futureRoutes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Container(
                            
                            height: 260, // Ajusta la altura según el contenido de la tarjeta
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var route = snapshot.data![index];
                                return RouteCard(
                                  imagePath: 'http://10.0.2.2:5050/uploads/' + route['image'], // Asegura que la URL es correcta
                                  title: route['name'],
                                  description: 'Descripción de la rutaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                                  distance: '5 km',
                                );
                              },
                            ),
                          );
                        } else {
                          return const Text('No hay rutas disponibles');
                        }
                      },
                    ),
              const SizedBox(height: 30),

              const SimpleText(text: 'Lugares populares', color: Colors.orange, fontFamily: 'MontserratBold', fontSize: 20, fontWeight: FontWeight.bold),
              const SizedBox(height: 15),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<dynamic>>(
                      future: futureLocations,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Container(
                            
                            height: 260, // Ajusta la altura según el contenido de la tarjeta
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var location = snapshot.data![index];
                                return RouteCard(
                                  imagePath: 'http://10.0.2.2:5050/uploads/' + location['image'], // Asegura que la URL es correcta
                                  title: location['name'],
                                  description: location['description'] ,
                                  distance: '5 km',
                                );
                              },
                            ),
                          );
                        } else {
                          return const Text('No hay rutas disponibles');
                        }
                      },
                    ),
                    const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
