import 'package:flutter/material.dart';
import 'package:vive_la_uca/views/splash_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            Navigator.pushNamed(context, "/splash");
          }, 
          child: const Text(' ir a otra pagina')
          ),
      )
    );
  }
}