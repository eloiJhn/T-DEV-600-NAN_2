import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/board/workspace_view.dart';
import 'package:trelltech/views/organizations/organization_create_view.dart';
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
    _loadData();
  }

  Future<void> _loadData() async {
    accessToken = await getAccessToken();
    clientId = await getClientID();
    await _getUserWorkspaces();
  }

  Future<void> _getUserWorkspaces() async {
    setState(() {
      _isProcessing = true;
    });
    workspaces = await getWorkspaces(apiKey, accessToken, clientId);
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _refreshData() async {
    await _getUserWorkspaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFF1C39A1),
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.dashboard),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: GridView.count(
          crossAxisCount: 2,
          children: workspaces != null
              ? workspaces!.map<Widget>((workspace) {
            return Card(
              margin: EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () async {
                  setState(() {
                    _isProcessing = true;
                  });
                  var boards = await getBoards(
                      apiKey, accessToken!, workspace['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkspaceView(
                              workspaceId: workspace['id'], boards: boards),
                    ),
                  );
                  setState(() {
                    _isProcessing = false;
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewOrganization,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _addNewOrganization() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateOrganizationScreen()),
    );

    if (result == 'organizationCreated') {
      await _refreshData();

      if (workspaces != null && workspaces!.isNotEmpty) {
        setState(() {
          var newOrganization = workspaces!.removeAt(0); // Supposer que la nouvelle org est en première position
          workspaces!.add(newOrganization); // Ajouter la nouvelle organisation à la fin de la liste
        });
      }
    }
  }
}

