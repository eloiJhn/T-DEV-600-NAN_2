import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_organization.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/board/board_create_view.dart';
import 'package:trelltech/views/board/board_view.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:trelltech/views/organizations/organization_edit_view.dart';
import 'package:trelltech/widgets/empty_widget.dart';
import 'package:trelltech/widgets/informations_widget.dart';
import 'package:trelltech/widgets/menu_widget.dart';

class WorkspaceView extends StatefulWidget {
  final String workspaceId;

  const WorkspaceView({
    super.key,
    required this.workspaceId,
  });

  @override
  WorkspaceViewState createState() => WorkspaceViewState();
}

class WorkspaceViewState extends State<WorkspaceView> {
  late TrelloOrganization? organization = null;
  late Future<Color> bgColorFuture;
  late List<Board> boards = [];

  WorkspaceViewState() {
    bgColorFuture = Future.value(Colors.grey);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    boards = await getBoards(dotenv.env['TRELLO_API_KEY']!,
        await getAccessToken(), widget.workspaceId);
    try {
      organization = await getWorkspace(
        dotenv.env['TRELLO_API_KEY']!,
        await getAccessToken(),
        widget.workspaceId,
      );
    } catch (e) {
      print(
          'Erreur lors de la récupération des détails de l\'organisation: $e');
    }

    if (boards.isNotEmpty) {
      bgColorFuture = _getBgColor(
        boards[0].bgColor,
        boards[0].bgImage,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool get isOrganizationInitialized => organization != null;

  Future<PaletteGenerator> _generatePalette(String imageUrl) async {
    if (imageUrl.isEmpty) {
      throw ArgumentError('Image URL cannot be null or empty');
    }
    return await compute(_generatePaletteInBackground, imageUrl);
  }

  Future<PaletteGenerator> _generatePaletteInBackground(String imageUrl) async {
    final provider = CachedNetworkImageProvider(imageUrl);
    return await PaletteGenerator.fromImageProvider(provider);
  }

  Future<void> _addNewBoard() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateBoardScreen(organizationId: widget.workspaceId)),
    );

    if (result == 'boardCreated') {
      await _initialize();
    }
  }

  Future<Color> _getBgColor(String? color, String? imageUrl) async {
    if (color != null) {
      String colorHex = color.split('#')[1];
      int colorInt = int.parse(colorHex, radix: 16);
      int colorBinary = 0xFF000000 + colorInt;
      return Color(colorBinary);
    } else {
      try {
        PaletteGenerator paletteGenerator = await _generatePalette(imageUrl!);
        return paletteGenerator.dominantColor!.color;
      } catch (e) {
        print('Failed to load image: $e');
        return Colors.grey;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color>(
      future: bgColorFuture,
      builder: (BuildContext context, AsyncSnapshot<Color> snapshot) {
        return RefreshIndicator(
            onRefresh: _initialize,
            child: _buildWorkspaceView(snapshot.data ?? Colors.grey));
      },
    );
  }

  Widget _buildWorkspaceView(Color bgColor) {
    return Scaffold(
      appBar: AppBar(
        title: Text(organization?.displayName ?? 'Loading...'),
        actions: <Widget>[
          CustomPopupMenuButton(
              organisationId: widget.workspaceId, boards: boards, state: this),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: boards.isEmpty
                  ? EmptyBoardWidget(
                      itemType: AppLocalizations.of(context)!.board_title,
                      message:
                          AppLocalizations.of(context)!.board_empty_message,
                      iconData: Icons.dashboard,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBoardScreen(
                                organizationId: widget.workspaceId),
                          ),
                        );
                      },
                      isMasculine: true,
                    )
                  : _buildBoardList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _addNewBoard();
        },
        backgroundColor: const Color(0xFF0D1B50),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBoardList() {
    return ListView.builder(
      itemCount: boards.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return InformationsBottomSheet(
                  name: boards[index].name,
                  desc: boards[index].desc,
                );
              },
            );
          },
          child: CustomListItem(
            board: boards[index],
            bgColorFuture: _getBgColor(
              boards[index].bgColor,
              boards[index].bgImage,
            ),
            refresh: _initialize,
          ),
        );
      },
    );
  }
}

class CustomListItem extends StatelessWidget {
  final Board board;
  final Future<Color> bgColorFuture;
  final void Function() refresh;

  const CustomListItem({
    Key? key,
    required this.board,
    required this.bgColorFuture,
    required this.refresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color>(
      future: bgColorFuture,
      builder: (BuildContext context, AsyncSnapshot<Color> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        } else {
          Color bgColor = snapshot.data!;
          return GestureDetector(
            onTap: () {
              if (board.closed) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.board_closed,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BoardView(board: board),
                  ),
                ).then((value) => refresh());
              }
            },
            child: Opacity(
              opacity: board.closed ? 0.5 : 1,
              child: SizedBox(
                height: 100,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: CustomCardContent(bgColor: bgColor, board: board),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class CustomCardContent extends StatelessWidget {
  final Color bgColor;
  final Board board;

  const CustomCardContent({
    Key? key,
    required this.bgColor,
    required this.board,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: board.bgColor == null &&
                board.bgImage != null &&
                board.bgImage!.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(board.bgImage!),
                fit: BoxFit.cover,
              )
            : null,
        color: board.bgColor != null
            ? Color(int.parse(board.bgColor!.split('#')[1], radix: 16))
                .withOpacity(1)
            : (board.bgImage != null && board.bgImage!.isNotEmpty
                ? null
                : bgColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              board.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeData.estimateBrightnessForColor(bgColor) ==
                        Brightness.light
                    ? Colors.white
                    : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPopupMenuButton extends StatelessWidget {
  final String organisationId;
  final List<Board> boards;
  final WorkspaceViewState state;

  const CustomPopupMenuButton({
    Key? key,
    required this.organisationId,
    required this.boards,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(AppLocalizations.of(context)!
                              .organization_update),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditOrganizationScreen(
                                    organisationId: organisationId,
                                    boards: boards),
                              ),
                            ).then((value) => state._initialize());
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(AppLocalizations.of(context)!
                              .organization_delete),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!
                                        .organization_delete),
                                    content: Text(AppLocalizations.of(context)!
                                        .organization_delete_message),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          deleteWorkspace(
                                                  dotenv.env['TRELLO_API_KEY']!,
                                                  (await getAccessToken())!,
                                                  organisationId)
                                              .then((value) {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DashboardView()),
                                              (Route<dynamic> route) => false,
                                            );
                                          });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .organization_delete),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
