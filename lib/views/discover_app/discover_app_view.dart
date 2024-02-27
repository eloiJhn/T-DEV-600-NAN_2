import 'package:flutter/material.dart';

class DiscoverAppView extends StatelessWidget {
  const DiscoverAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Découvrir l\'application'),
        backgroundColor: Color(0xFF1C39A1),
      ),
      body: const Center(
        child: Text('Contenu de la page Découvrir l\'application'),
      ),
    );
  }
}
