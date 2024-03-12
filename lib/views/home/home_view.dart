import 'package:flutter/material.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/discover_app/discover_app_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    isConnected().then((isConnected) {
      if (isConnected) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

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
            Image.asset('assets/images/logo.png',
              width: 30,
              height: 30,
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
          key: const Key('discover_button'),
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