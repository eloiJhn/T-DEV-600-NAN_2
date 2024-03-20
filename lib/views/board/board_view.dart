import 'dart:ffi';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_card.dart';
import 'package:trelltech/models/trello_list.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/widgets/card_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trelltech/widgets/empty_widget.dart';
import 'package:trelltech/widgets/menu_widget.dart';

class BoardView extends StatefulWidget {
  final Board board;

  const BoardView({super.key, required this.board});

  @override
  BoardViewState createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> {
  late CarouselController carouselController;
  bool _editList = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    carouselController = CarouselController();
  }

  Future<void> _initialize() async {
    setState(() {});
  }

  Future<List<TrelloList>> _getLists() async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var lists =
        await getLists(apiKey!, await getAccessToken(), widget.board.id!);
    List<TrelloList> listList =
        lists.map((item) => TrelloList.fromJson(item)).toList();
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
      url: widget.board.url,
      shortUrl: widget.board.shortUrl,
    );
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    await updateBoard(apiKey!, await getAccessToken(), widget.board.id, board);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextFormField(
              onChanged: (String value) {
                setState(() {
                  _updateBoard(value);
                });
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              initialValue: widget.board.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ))),
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
                  itemType: 'Listes',
                  message:
                      "Vous n'avez actuellement aucune liste dans ce tableau",
                  iconData: Icons.list,
                  witheColor: true,
                  onTap: () {
                    print('Tableau clicked');
                  },
                  isMasculine: false,
                );
              } else {
                return CarouselSlider.builder(
                    itemCount: snapshot.data?.length,
                    options: CarouselOptions(
                        autoPlay: false,
                        enlargeCenterPage: false,
                        height: MediaQuery.of(context).size.height),
                    itemBuilder:
                        (BuildContext context, int item, int pageViewIndex) {
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
                                                    snapshot.data![item].id);
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
                                            snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else {
                                        return ListView.builder(
                                            itemCount: snapshot.data?.length,
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
                                                            title: Text(snapshot
                                                                .data![index]
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
                                                                          card:
                                                                              snapshot.data![index]);
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
                                                              onPressed: () => {
                                                                // _deleteCard(snapshot.data![index].id),
                                                                setState(
                                                                    () async {
                                                                  deleteCard(
                                                                      dotenv.env[
                                                                          'TRELLO_API_KEY']!,
                                                                      await getAccessToken(),
                                                                      snapshot
                                                                          .data![
                                                                              index]
                                                                          .id);
                                                                  _editList =
                                                                      false;
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
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                decoration:
                                                    InputDecoration.collapsed(
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .addCard,
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
