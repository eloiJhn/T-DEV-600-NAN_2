import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_card.dart';
import 'package:trelltech/models/trello_list.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/widgets/card_widget.dart';
import 'package:trelltech/widgets/menu_widget.dart';


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
    return MenuWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.board.name),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: FutureBuilder(
          future: _getLists(),
          builder: (context, AsyncSnapshot<List<TrelloList>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: snapshot.data?.length,
                options: CarouselOptions(
                  autoPlay: false,
                  scrollDirection: Axis.vertical,
                  enlargeCenterPage: false,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                ),
                itemBuilder: (BuildContext context, int item,
                    int pageViewIndex) {
                  ScrollController listScrollController = ScrollController();
                  return Card(
                    child: Column(children: [
                      Text(
                        snapshot.data![item].name.toUpperCase(),
                        style: const TextStyle(fontSize: 30),
                      ),
                      Expanded(
                        child: FutureBuilder(
                          future: _getCardsByList(snapshot.data![item].id),
                          builder: (context,
                              AsyncSnapshot<List<TrelloCard>> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification is ScrollEndNotification &&
                                      listScrollController.position
                                          .extentAfter == 0) {
                                    carouselController.animateToPage(
                                      item + 1,
                                      duration: const Duration(
                                          milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  controller: listScrollController,
                                  itemCount: snapshot.data?.length,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return GestureDetector(
                                      onTap: () =>
                                      {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CardWidget(
                                                card: snapshot.data![index],
                                              ),
                                        ),
                                      },
                                      child: Card(
                                        color: Colors.grey[200],
                                        child: ListTile(
                                          title: Text(
                                              snapshot.data![index].name),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ]),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
  }