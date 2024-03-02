import 'package:flutter/material.dart';
import 'package:trelltech/views/auth/login_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trelltech/views/discover_app/discover_app_view.dart';
import 'package:trelltech/views/home/home_view.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrellTech',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeView(),
        '/login': (context) => const LoginView(),
        '/discover': (context) => const DiscoverAppView(),
        '/dashboard': (context) => const DashboardView(),
      },
    );
  }
}