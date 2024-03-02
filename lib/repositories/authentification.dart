// auth_functions.dart

import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


/**
 * Authenticate the user with Trello
 * @param context The context of the application
 * @return The access token if the user is authenticated, null otherwise
 */
Future<String?> app_authenticateWithTrello(BuildContext context) async {
  // Get the Trello API key from the .env file
  final trelloAPIKey = dotenv.env['TRELLO_API_KEY'];

  final prefs = await SharedPreferences.getInstance();
  final url = Uri.https('trello.com', '/1/authorize', {
    'expiration': 'never',
    'name': 'TrellTech',
    'scope': 'read',
    'response_type': 'token',
    'key': trelloAPIKey,
    'return_url': 'trelltech://',
    'callback_method': 'fragment',
  });

  // Verify that the Trello API key is present
  if(trelloAPIKey == null) {
    print('La clé API Trello n\'a pas été trouvée');
    return null;
  }

  // Authenticate the user with Trello
  try {
    final result = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: 'trelltech',
    );

    // Parse the result
    final parsedResult = Uri.parse(result);
    final fragment = parsedResult.fragment;
    final accessToken = Uri.splitQueryString(fragment)['token'];
    final error = Uri.splitQueryString(fragment)['error'];

    if (error != null) {
      // Handle the error here
      print('Error during authentication: $error');
      return null;
    } else {
      // Store the access token in the app's preferences
      await prefs.setString('accessToken', accessToken!);

      // Redirect the user to the dashboard page once authenticated (and remove the possibility to go back)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => DashboardView()),
            (Route<dynamic> route) => false,
      );
      return accessToken;
    }
  } catch (e) {
    print('Erreur d\'authentification avec Trello: $e');
    return null;
  }
}

/**
 * Disconnect the user from the application
 * @param context The context of the application
 */
Future<void> app_disconnect(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
  Navigator.pushReplacementNamed(context, '/');
}

/**
 * Check if the user is connected to the application
 * @return True if the user is connected, false otherwise
 */
Future<bool> app_isConnected() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('accessToken') && prefs.getString('accessToken') != null;
}