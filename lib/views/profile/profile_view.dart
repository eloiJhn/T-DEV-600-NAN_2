import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:trelltech/provider/language_provider.dart';
import 'package:trelltech/widgets/menu_widget.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          userEmail = userInfo['email'];
          userPhotoUrl = userInfo['avatarUrl'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userPhotoUrl != null
                  ? "$userPhotoUrl/50.png"
                  : 'https://placehold.co/50.png'),
            ),
            SizedBox(height: 20),
            Text(
              userName ?? AppLocalizations.of(context)!.userName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              userEmail ?? AppLocalizations.of(context)!.userEmail,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            LanguageDropdown(),
            ElevatedButton(
              onPressed: () {
                disconnect(context);
              },
              child: Text(AppLocalizations.of(context)!.disconnect),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuWidget(),
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<LanguageProvider>(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: languageProvider.locale,
        items: [
          DropdownMenuItem(
            value: Locale('en', 'US'),
            child: Row(
              children: <Widget>[
                Image.network('https://flagpedia.net/data/flags/mini/us.png',
                    width: 30),
                const SizedBox(width: 8),
                Text('English'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: Locale('fr', 'FR'),
            child: Row(
              children: <Widget>[
                Image.network('https://flagpedia.net/data/flags/mini/fr.png',
                    width: 30),
                const SizedBox(width: 8),
                Text('Français'),
              ],
            ),
          ),
        ],
        onChanged: (Locale? locale) {
          if (locale != null) {
            languageProvider.setLocale(locale);
          }
        },
      ),
    );
  }
}
