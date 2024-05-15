import 'package:flutter/material.dart';
import 'map_page.dart';
import 'lobby_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;


   final List<Widget> _pages = [
    LobbyPage(),
    ProfilePage(),
    MapPage(),
  ];

 void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
           
            InkWell(
              onTap: () => _onItemTapped(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.home, color: _selectedIndex == 0 ? Colors.orange : Colors.grey),
                  Text('Inicio', style: TextStyle(fontFamily: 'Montserrat', color: _selectedIndex == 0 ? Colors.orange : Colors.grey), )
                ],
              ),
            ),
            SizedBox(width: 48),
            
            InkWell(
              onTap: () => _onItemTapped(1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.person, color: _selectedIndex == 1 ? Colors.orange : Colors.grey),
                  Text('Perfil', style: TextStyle(fontFamily: 'Montserrat',color: _selectedIndex == 1 ? Colors.orange : Colors.grey))
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: _selectedIndex == 2 ? Colors.orange : const Color.fromARGB(1000, 1, 34, 85),
        child: const Icon(Icons.map_sharp, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
