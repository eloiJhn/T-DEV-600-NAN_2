import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_list.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/board/board_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../repositories/api.dart';

class WorkspaceView extends StatefulWidget {
  final List<Board> boards;

  const WorkspaceView({Key? key, required this.boards}) : super(key: key);

  @override
  WorkspaceViewState createState() => WorkspaceViewState();
}

class WorkspaceViewState extends State<WorkspaceView> {
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    accessToken = await getAccessToken();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ddd")
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                    itemCount: widget.boards.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(children: [
                        Text(widget.boards[index].name),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BoardView(
                                    board: widget.boards[index]
                                )
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.openBoard),
                        ),
                      ]);
                    }
                ),
              ),
              ElevatedButton(
                onPressed: () => disconnect(context),
                child: Text(AppLocalizations.of(context)!.logout),
              ),
            ],
          ),
        ),
    );
  }
}
