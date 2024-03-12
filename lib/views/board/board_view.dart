import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_card.dart';
import 'package:trelltech/models/trello_list.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/widgets/card_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BoardView extends StatefulWidget {
  final Board board;

  const BoardView({super.key, required this.board});

  @override
  BoardViewState createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> {
  String? accessToken;
  late CarouselController carouselController;

  @override
  void initState() {
    super.initState();
    _initialize();
    carouselController = CarouselController();
  }

  Future<void> _initialize() async {
    await _getAccessToken();
    setState(() {});
  }

  Future<void> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');
  }

  Future<List<TrelloList>> _getLists() async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var lists = await getLists(apiKey!, accessToken!, widget.board.id);
    List<TrelloList> listList =
        lists.map((item) => TrelloList.fromJson(item)).toList();
    return listList;
  }

  Future<List<TrelloCard>> _getCardsByList(String trelloListId) async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var cards = await getCards(apiKey!, accessToken!, trelloListId);
    List<TrelloCard> listCard =
        cards.map((item) => TrelloCard.fromJson(item)).toList();
    return listCard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.board.name)),
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
                                      color: Color(0xff162B62)),
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 20, left: 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            snapshot.data![item].name
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.more_horiz),
                                            color: Colors.white,
                                            onPressed: () => {},
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
                                              child:
                                                  CircularProgressIndicator());
                                        } else {
                                          return ListView.builder(
                                              itemCount: snapshot.data?.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return GestureDetector(
                                                  onTap: () => {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            CardWidget(
                                                                card: snapshot
                                                                        .data![
                                                                    index])),
                                                  },
                                                  child: Card(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    color: Colors.grey[200],
                                                    child: ListTile(
                                                      title: Text(snapshot
                                                          .data![index].name),
                                                    ),
                                                  ),
                                                );
                                              });
                                        }
                                      })),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                          color: Color(0xff162B62)),
                                      child: Center(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
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
                                                  style: const TextStyle(color: Colors.white),
                                                  decoration: InputDecoration.collapsed(
                                                    hintText: AppLocalizations.of(context)!.addCard,
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
        ));
  }
}
