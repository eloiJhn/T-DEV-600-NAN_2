import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_card.dart';
import 'package:trelltech/models/trello_list.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/board/workspace_view.dart';
import 'package:trelltech/widgets/card_widget.dart';
import 'package:trelltech/widgets/empty_widget.dart';
import 'package:trelltech/widgets/menu_widget.dart';

import '../dashboard/dashboard_view.dart';
import 'board_edit_view.dart';

class BoardView extends StatefulWidget {
  final Board board;

  const BoardView({super.key, required this.board});

  @override
  BoardViewState createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> {
  late CarouselController carouselController;
  bool _editList = false;
  late Board board;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
    carouselController = CarouselController();
    _nameController.text = widget.board.name;
  }

  Future<void> _initialize() async {
    try {
      board = await getBoard(
        dotenv.env['TRELLO_API_KEY']!,
        await getAccessToken(),
        widget.board.id,
      );
    } catch (e) {
      print('Erreur lors de la récupération des détails du tableau: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<List<TrelloList>> _getLists() async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var lists =
        await getLists(apiKey!, await getAccessToken(), widget.board.id!);
    List<TrelloList> listList =
        lists.map((item) => TrelloList.fromJson(item)).toList();
    if (listList.isNotEmpty) listList.add(TrelloList(id: 'plus', name: ''));
    return listList;
  }

  Future<List<TrelloCard>> _getCardsByList(String trelloListId) async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var cards = await getCards(apiKey!, await getAccessToken(), trelloListId);
    List<TrelloCard> listCard =
        cards.map((item) => TrelloCard.fromJson(item)).toList();
    return listCard;
  }

  Future<void> _updateList(String name, String listId) async {
    TrelloList list = TrelloList(
      id: listId,
      name: name,
    );
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    await updateList(apiKey!, await getAccessToken(), listId, list);
    setState(() {});
  }

  Future<void> _updateBoard(String name) async {
    Board board = Board(
      id: widget.board.id,
      name: name,
      idOrganization: widget.board.idOrganization,
      closed: widget.board.closed,
      pinned: widget.board.pinned,
      desc: widget.board.desc,
      url: widget.board.url,
      shortUrl: widget.board.shortUrl,
    );
    _nameController.text = name;

    var apiKey = dotenv.env['TRELLO_API_KEY'];
    await updateBoard(apiKey!, await getAccessToken(), widget.board.id, board);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _nameController,
          onChanged: (String value) {
            _updateBoard(value);
          },
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          CustomPopupMenuButton(
            boardId: widget.board.id,
            organizationId: widget.board.idOrganization,
            onBoardUpdated: (updatedBoard) {
              setState(() {
                _nameController.text = updatedBoard.name;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: widget.board.bgImage != null
              ? DecorationImage(
                  image: NetworkImage(widget.board.bgImage!),
                  fit: BoxFit.cover,
                )
              : null,
          color: widget.board.bgColor != null
              ? Color(int.parse('0xff${widget.board.bgColor!.split('#')[1]}'))
              : null,
        ),
        child: FutureBuilder(
            future: _getLists(),
            builder: (context, AsyncSnapshot<List<TrelloList>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.data!.isEmpty) {
                return EmptyBoardWidget(
                  itemType: AppLocalizations.of(context)!.lists_title,
                  message: AppLocalizations.of(context)!.lists_empty_message,
                  iconData: Icons.list,
                  witheColor: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final _formKey = GlobalKey<FormState>();
                        return AlertDialog(
                          title: Text('Ajouter une liste'),
                          content: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'Nom de la liste'),
                                    validator: (input) => input!.trim().isEmpty
                                        ? 'Veuillez entrer un nom de liste'
                                        : null,
                                    onSaved: (input) async => {
                                      if (input!.isNotEmpty)
                                        {
                                          createList(
                                              dotenv.env['TRELLO_API_KEY']!,
                                              await getAccessToken(),
                                              input,
                                              "bottom",
                                              widget.board.id),
                                          Fluttertoast.showToast(
                                            msg: AppLocalizations.of(context)!
                                                .list_created,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          ),
                                          _initialize()
                                        }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Annuler'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Ajouter'),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState?.save();
                                  // Ici, vous pouvez ajouter la logique pour sauvegarder la nouvelle liste
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  isMasculine: false,
                );
              } else {
                return CarouselSlider.builder(
                    itemCount: snapshot.data?.length,
                    options: CarouselOptions(
                        autoPlay: false,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: false,
                        height: MediaQuery.of(context).size.height),
                    itemBuilder:
                        (BuildContext context, int item, int pageViewIndex) {
                      if (item == snapshot.data!.length - 1) {
                        return GestureDetector(
                          child: Card(
                            margin: const EdgeInsets.fromLTRB(15, 30, 15, 30),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                        color: Color(0xff162B62)),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .list_create,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .list_create_message,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final _formKey = GlobalKey<FormState>();
                                return AlertDialog(
                                  title: Text(AppLocalizations.of(context)!
                                      .list_create),
                                  content: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                labelText: AppLocalizations.of(
                                                        context)!
                                                    .list_name),
                                            validator: (input) => input!
                                                    .trim()
                                                    .isEmpty
                                                ? 'Veuillez entrer un nom de liste'
                                                : null,
                                            onSaved: (input) async => {
                                              if (input!.isNotEmpty)
                                                {
                                                  createList(
                                                      dotenv.env[
                                                          'TRELLO_API_KEY']!,
                                                      await getAccessToken(),
                                                      input,
                                                      "bottom",
                                                      widget.board.id),
                                                  Fluttertoast.showToast(
                                                    msg: AppLocalizations.of(
                                                            context)!
                                                        .list_created,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0,
                                                  ),
                                                  _initialize()
                                                }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                          AppLocalizations.of(context)!.cancel),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(AppLocalizations.of(context)!
                                          .list_create),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState?.save();
                                          // Ici, vous pouvez ajouter la logique pour sauvegarder la nouvelle liste
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }
                      return Card(
                          margin: const EdgeInsets.fromLTRB(15, 30, 15, 30),
                          child: Column(children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                    color: Color(0xff162B62)),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      right: 20, left: 20),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                              onChanged: (String value) {
                                                _updateList(value,
                                                        snapshot.data![item].id)
                                                    .then((value) =>
                                                        _initialize());
                                              },
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              initialValue: snapshot
                                                  .data![item].name
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              )),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: Colors.white,
                                          onPressed: () => {
                                            setState(() {
                                              _editList = !_editList;
                                            })
                                          },
                                        )
                                      ]),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 8,
                                child: FutureBuilder(
                                    future: _getCardsByList(
                                        snapshot.data![item].id),
                                    builder: (context,
                                        AsyncSnapshot<List<TrelloCard>>
                                            snapshotCard) {
                                      if (!snapshotCard.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else {
                                        return ListView.builder(
                                            itemCount:
                                                snapshotCard.data?.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    flex: 7,
                                                    child: Card(
                                                        margin: const EdgeInsets
                                                            .all(10),
                                                        color: Colors.grey[200],
                                                        child: ListTile(
                                                            title: Text(
                                                                snapshotCard
                                                                    .data![
                                                                        index]
                                                                    .name),
                                                            onTap: () =>
                                                                showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return CardWidget(
                                                                        card: snapshotCard
                                                                            .data![index],
                                                                        lists:
                                                                            snapshot,
                                                                      );
                                                                    }).whenComplete(() {
                                                                  setState(() {
                                                                    _getCardsByList(
                                                                        snapshot
                                                                            .data![index]
                                                                            .id);
                                                                  });
                                                                }))),
                                                  ),
                                                  _editList
                                                      ? Expanded(
                                                          flex: 3,
                                                          child: Card(
                                                            color: Colors
                                                                .redAccent,
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed:
                                                                  () async => {
                                                                deleteCard(
                                                                        dotenv.env[
                                                                            'TRELLO_API_KEY']!,
                                                                        await getAccessToken(),
                                                                        snapshot
                                                                            .data![
                                                                                index]
                                                                            .id!)
                                                                    .then(
                                                                        (value) {
                                                                  Fluttertoast.showToast(
                                                                      msg: AppLocalizations.of(
                                                                              context)!
                                                                          .card_deleted,
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT,
                                                                      gravity: ToastGravity
                                                                          .BOTTOM,
                                                                      timeInSecForIosWeb:
                                                                          1,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      fontSize:
                                                                          16.0);
                                                                  setState(() {
                                                                    _getCardsByList(
                                                                        snapshot
                                                                            .data![index]
                                                                            .id);
                                                                  });
                                                                })
                                                              },
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox()
                                                ],
                                              );
                                            });
                                      }
                                    })),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Color(0xff162B62)),
                                    child: Center(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: TextField(
                                                onSubmitted: (String value) {
                                                  setState(() async {
                                                    createCard(
                                                        dotenv.env[
                                                            'TRELLO_API_KEY']!,
                                                        await getAccessToken(),
                                                        snapshot.data![item].id,
                                                        value);
                                                    _initialize();
                                                  });
                                                },
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                decoration:
                                                    InputDecoration.collapsed(
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .card_add,
                                                  hintStyle: const TextStyle(
                                                      color: Colors.white70),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )))
                          ]));
                    });
              }
            }),
      ),
      bottomNavigationBar: MenuWidget(), // Here is where you add the MenuWidget
    );
  }
}

class CustomPopupMenuButton extends StatelessWidget {
  final String boardId;
  final String? organizationId;
  final Function(Board) onBoardUpdated;

  const CustomPopupMenuButton({
    super.key,
    required this.boardId,
    required this.organizationId,
    required this.onBoardUpdated,
  });

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
                          title: Text(AppLocalizations.of(context)!.board_edit),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditBoardScreen(boardId: boardId),
                              ),
                            );

                            if (result != null) {
                              final updatedBoard = result as Board;
                              onBoardUpdated(updatedBoard);
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title:
                              Text(AppLocalizations.of(context)!.board_delete),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!
                                        .board_delete),
                                    content: Text(AppLocalizations.of(context)!
                                        .board_delete_message),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .cancel),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          deleteBoard(
                                                  dotenv.env['TRELLO_API_KEY']!,
                                                  (await getAccessToken())!,
                                                  boardId)
                                              .then((value) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WorkspaceView(
                                                            workspaceId:
                                                                organizationId!)));
                                          }).then((value) => {
                                                    Fluttertoast.showToast(
                                                      msg: AppLocalizations.of(
                                                              context)!
                                                          .board_deleted,
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0,
                                                    )
                                                  });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .board_delete),
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
