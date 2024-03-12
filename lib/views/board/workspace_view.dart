import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trelltech/models/board.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:trelltech/models/trello_organization.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trelltech/views/board/board_view.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:trelltech/views/organizations/organization_edit_view.dart';
import 'package:trelltech/widgets/empty_widget.dart';

class WorkspaceView extends StatefulWidget {
  final String workspaceId;
  final List<Board> boards;

  const WorkspaceView({
    Key? key,
    required this.boards,
    required this.workspaceId,
  }) : super(key: key);

  @override
  WorkspaceViewState createState() => WorkspaceViewState();
}

class WorkspaceViewState extends State<WorkspaceView> {
  late String accessToken;
  late TrelloOrganization? organization;
  late Future<Color> bgColorFuture;

  WorkspaceViewState() {
    // Initialise bgColorFuture ici
    bgColorFuture = Future.value(Colors.grey);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void refresh() {
    _initialize();
  }


  Future<void> _initialize() async {
    accessToken = (await getAccessToken())!;

    try {
      organization = await getWorkspace(
        dotenv.env['TRELLO_API_KEY']!,
        accessToken,
        widget.workspaceId,
      );
    } catch (e) {
      print('Erreur lors de la récupération des détails de l\'organisation: $e');
    }

    if (widget.boards.isNotEmpty) {
      bgColorFuture = _getBgColor(
        widget.boards[0].bgColor,
        widget.boards[0].bgImage,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool get isOrganizationInitialized => organization != null;

  Future<PaletteGenerator> _generatePalette(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      throw ArgumentError('Image URL cannot be null or empty');
    }
    return await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(imageUrl),
    );
  }

  Future<Color> _getBgColor(String? color, String? imageUrl) async {
    if (color != null) {
      return Color(int.parse(color.split('#')[1], radix: 16));
    } else {
      try {
        PaletteGenerator paletteGenerator =
        await compute(_generatePalette, imageUrl);
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
        if (!isOrganizationInitialized) {
          return const CircularProgressIndicator();
        }
        return _buildWorkspaceView(snapshot.data ?? Colors.grey);
      },
    );
  }

  Widget _buildWorkspaceView(Color bgColor) {
    return Scaffold(
      appBar: AppBar(
        title: Text(organization?.displayName ?? 'Loading...'),
        actions: <Widget>[
          CustomPopupMenuButton(organisationId: widget.workspaceId, boards: widget.boards, state: this),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: widget.boards.isEmpty
                  ? EmptyBoardWidget(
                itemType: 'Tableau',
                message:
                "Vous n'avez actuellement aucun tableau de créé pour cette organisation. Veuillez cliquer pour en ajouter un",
                iconData: Icons.dashboard,
                onTap: () {
                  print('Tableau clicked');
                },
                isMasculine: true,
              )
                  : _buildBoardList(),
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

  Widget _buildBoardList() {
    return ListView.builder(
      itemCount: widget.boards.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return CustomListItem(
          board: widget.boards[index],
          bgColorFuture: _getBgColor(
            widget.boards[index].bgColor,
            widget.boards[index].bgImage,
          ),
        );
      },
    );
  }
}

class CustomListItem extends StatelessWidget {
  final Board board;
  final Future<Color> bgColorFuture;

  const CustomListItem({
    Key? key,
    required this.board,
    required this.bgColorFuture,
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
                  msg: "Le tableau est fermé",
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
                );
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
        image: board.bgImage != null && board.bgImage!.isNotEmpty
            ? DecorationImage(
          image: CachedNetworkImageProvider(board.bgImage!),
          fit: BoxFit.cover,
        )
            : null,
        color:
        board.bgImage != null && board.bgImage!.isNotEmpty ? null : bgColor,
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
                          title: const Text('Modifier'),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditOrganizationScreen(organisationId: organisationId, boards: boards),
                              ),
                            ).then((value) => state.refresh());
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Supprimer'),
                          onTap: () {
                            showDialog(context: context, builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Supprimer l\'organisation'),
                                content: const Text('Êtes-vous sûr de vouloir supprimer cette organisation ?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      deleteWorkspace(dotenv.env['TRELLO_API_KEY']!, (await getAccessToken())!, organisationId).then((value) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context) => DashboardView()),
                                              (Route<dynamic> route) => false,
                                        );
                                      });
                                    },
                                    child: const Text('Supprimer'),
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
