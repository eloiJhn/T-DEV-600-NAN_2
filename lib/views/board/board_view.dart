import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/repositories/api.dart';

import '../../models/trello_list.dart';

class BoardView extends StatefulWidget {
  final Board board;

  const BoardView({super.key, required this.board});

  @override
  BoardViewState createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> {
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getAccessToken();
    setState(() {});
  }

  Future<void> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');
  }

  Future<void> getAccessToken() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.board.name)),
        body: Center(
          child: FutureBuilder(
              future: _getLists(),
              builder: (context, AsyncSnapshot<List<TrelloList>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return CarouselSlider.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int item,
                            int pageViewIndex) =>
                        Text(snapshot.data![item].name),
                    options: CarouselOptions(
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      aspectRatio: 2.0,
                      initialPage: 2,
                    ),
                  );
                }
              }),
        ));
  }
}
