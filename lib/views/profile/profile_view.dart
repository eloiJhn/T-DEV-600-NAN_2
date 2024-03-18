import 'package:flutter/material.dart';
import 'package:trelltech/widgets/menu_widget.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  <Widget>[
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://via.placeholder.com/150"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Nom de l'utilisateur",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "user@example.com", // Exemple d'email
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Modifier le profil');
              },
              child: Text('Modifier le profil'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuWidget(),
    );
  }
}
