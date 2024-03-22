import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/widgets/menu_widget.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/repositories/api.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? userName;
  String? userEmail;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final apiKey = dotenv.env['TRELLO_API_KEY'];
    final accessToken = await getAccessToken();

    if (accessToken != null) {
      final clientId = await getClientID();

      if (clientId != null) {
        final userInfo = await getMember(apiKey!, accessToken, clientId);

        setState(() {
          userName = userInfo['fullName'];
          userEmail = userInfo['email']; // Assurez-vous que l'API renvoie bien l'email
          userPhotoUrl = userInfo['avatarUrl'];
        });
      }
    }
  }

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
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  userPhotoUrl != null ? "$userPhotoUrl/50.png" : 'https://placehold.co/50.png'
              ),
            ),
            SizedBox(height: 20),
            Text(
              userName ?? "Nom de l'utilisateur",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              userEmail ?? "Email de l'utilisateur",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Changer de langue');
              },
              child: Text('Changer de langue'),
            ),
            ElevatedButton(
              onPressed: () {
                disconnect(context);
              },
              child: Text('Se déconnecter'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuWidget(),
    );
  }
}
