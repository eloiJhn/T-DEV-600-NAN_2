import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/board/workspace_view.dart';
import 'package:trelltech/widgets/menu_widget.dart';


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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isProcessing = false;


  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await getAccessToken();
      clientId = await getClientID();
      await getUserWorkspaces();
    });
  }

  Future<void> refreshData() async {
    await getUserWorkspaces();
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

  Future<void> getUserWorkspaces() async {
    workspaces = await getWorkspaces(apiKey, accessToken, clientId);
    setState(() {});
  }

  Widget buildUI(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFF1C39A1),
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.dashboard),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          children: workspaces != null
              ? workspaces!.map<Widget>((workspace) {
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: _isProcessing ? null : () async { // Add this line
                        setState(() {
                          _isProcessing = true; // Add this line
                        });
                        var boards = await getBoards(
                            apiKey, accessToken!, workspace['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkspaceView(
                                workspaceId: workspace['id'],
                                boards: boards),
                          ),
                        );
                        setState(() {
                          _isProcessing = false; // Add this line
                        });
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
      bottomNavigationBar: MenuWidget(),
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
          return RefreshIndicator(
            onRefresh: refreshData,
            child: buildUI(context),
          );
        }
      },
    );
  }
}
