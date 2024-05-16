import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vive_la_uca/widgets/route_card.dart';
import 'package:vive_la_uca/widgets/search_bar.dart';

class LobbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child:  SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
        const Text(
          'Vive La UCA',
           style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.orange,

           ) ,
           ),

           const SizedBox(height: 15,),

           SearchingBar(),
      ],
          )
          )
        ),
      
    );
  }
}
