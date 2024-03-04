import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/models/board.dart';

import '../../repositories/api.dart';
import '../board/board_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  DashboardViewState createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> {
  String? accessToken;

  @override
  void initState() {
    super.initState();
    getAccessToken();
  }

  Future<void> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');
    navigateIfNoToken();
  }

  void navigateIfNoToken() {
    if (accessToken == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<List<Board>> _getBoards() async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var boards = await getBoards(apiKey!, accessToken!);
    List<Board> boardList = boards.map((item) => Board.fromJson(item)).toList();
    return boardList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAccessToken(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            appBar:
                AppBar(title: Text(AppLocalizations.of(context)!.dashboard)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: FutureBuilder(
                        future: _getBoards(),
                        builder:
                            (context, AsyncSnapshot<List<Board>> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data?.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(children: [
                                    Text(snapshot.data![index].name),
                                    ElevatedButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => BoardView(
                                                  board:
                                                      snapshot.data![index]))),
                                      child: Text(AppLocalizations.of(context)!
                                          .openBoard),
                                    ),
                                  ]);
                                });
                          }
                        }),
                  ),
                  ElevatedButton(
                    onPressed: () => app_disconnect(context),
                    child: Text(AppLocalizations.of(context)!.logout),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
