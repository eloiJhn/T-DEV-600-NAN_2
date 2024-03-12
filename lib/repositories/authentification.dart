// auth_functions.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


/// Authenticate the user with Trello.
///
/// This function initiates the authentication process with Trello, obtaining
/// the user's access token upon successful authentication.
///
/// @param context The context of the application.
/// @return The access token if the user is authenticated, null otherwise.
Future<String?> authenticateWithTrello(BuildContext context) async {
  // Get the Trello API key from the environment
  final trelloAPIKey = dotenv.env['TRELLO_API_KEY'];
  final trelloAPPName = dotenv.env['TRELLO_APP_NAME'];

  final prefs = await SharedPreferences.getInstance();
  final url = Uri.https('trello.com', '/1/authorize', {
    'expiration': 'never',
    'name': trelloAPPName,
    'scope': 'read,write,account',
    'response_type': 'token',
    'key': trelloAPIKey,
    'return_url': 'trelltech://',
    'callback_method': 'fragment',
  });

  // Verify that the Trello API key is present
  if(trelloAPIKey == null || trelloAPPName == null) {
    if (kDebugMode) {
      print('TRELLO_API_KEY or TRELLO_APP_NAME not found in the .env file');
    }
    FToast().showToast(
      child: const Text('Une erreur est survenue lors de l\'authentification. Veuillez contacter le support avec le code d\'erreur ATH_NT_FND'),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
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

      final clientID = await getTrelloClientID(trelloAPIKey, accessToken);

      // Store the client ID in the app's preferences
      await prefs.setString('clientID', clientID);

      // Redirect the user to the dashboard page once authenticated (and remove the possibility to go back)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => DashboardView()),
            (Route<dynamic> route) => false,
      );
      return accessToken;
    }
  } catch (e) {
    print('Error during authentication: $e');
    return null;
  }
}

/// Disconnect the user from the application.
///
/// This function removes the user's access token from the app's preferences,
/// effectively disconnecting the user.
///
/// @param context The context of the application.
Future<void> disconnect(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
  Navigator.pushReplacementNamed(context, '/');
}

/// Check if the user is connected to the application.
///
/// @return True if the user is connected, false otherwise.
Future<bool> isConnected() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('accessToken') && prefs.getString('accessToken') != null;
}

/// Get the access token of the user.
///
/// @return The access token of the user.
Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

/// Get the client ID of the user.
///
/// @return The client ID of the user.
Future<String?> getClientID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('clientID');
}