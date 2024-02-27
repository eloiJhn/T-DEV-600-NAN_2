import 'package:flutter/material.dart';
import 'package:trelltech/views/discover_app/discover_app_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C39A1),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('../assets/logo.png',
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DiscoverAppView()),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            foregroundColor: MaterialStateProperty.all(Color(0xFF1C39A1)),
          ),
          child: const Text('Découvrir l\'application'),
        ),
      ],
    ),)
    ,
    );
  }
}