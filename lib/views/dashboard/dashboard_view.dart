import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/board/workspace_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  DashboardViewState createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> {
  List? workspaces;
  String? accessToken;
  String? clientId;
  String apiKey = dotenv.env['TRELLO_API_KEY']!;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await getAccessToken();
      clientId = await getClientID();
      await getWorkspaces();
    });
  }

  Future<void> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');
    print(accessToken);
    navigateIfNoToken();
  }

  void navigateIfNoToken() {
    if (accessToken == null) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> getWorkspaces() async {
    workspaces = await getWorkspace(apiKey, accessToken, clientId);
    setState(() {});
  }

  Widget buildUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C39A1),
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.dashboard),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2, // Nombre de colonnes
          children: workspaces != null
              ? workspaces!.map<Widget>((workspace) {
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () async {
                        var boards = await getBoards(
                            apiKey, accessToken!, workspace['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkspaceView(
                                workspaceName: workspace['displayName'],
                                boards: boards),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          workspace['displayName'],
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList()
              : [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAccessToken(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return buildUI(context);
        }
      },
    );
  }
}
