import 'package:flutter/material.dart';
import 'package:trelltech/views/discoverAppPage/discoverAppPage_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C39A1),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Pour centrer verticalement
          children: [
          Row(
          mainAxisSize: MainAxisSize.min, // Pour centrer horizontalement
          children: [
            Image.asset('assets/logo.png',
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 5),
            const Text(
              'TrellTech',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Espace entre le titre et le bouton
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DiscoverAppPage()),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white), // Couleur de fond
            foregroundColor: MaterialStateProperty.all(Color(0xFF1C39A1)), // Couleur du texte
          ),
          child: const Text('Découvrir l\'application'),
        ),
      ],
    ),)
    ,
    );
  }
}