import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trelltech/provider/language_provider.dart';
import 'package:trelltech/views/discover_app/discover_app_view.dart';
import 'package:trelltech/views/home/home_view.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/views/profile/profile_view.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<LanguageProvider>(context);
    return MaterialApp(
      title: 'TrellTech',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: languageProvider.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeView(),
        '/discover': (context) => const DiscoverAppView(),
        '/dashboard': (context) => const DashboardView(),
        '/profile': (context) => ProfileView(),
      },
    );
  }
}
