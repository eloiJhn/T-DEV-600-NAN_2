import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/repositories/api.dart';

import '../models/trello_card.dart';

class CardWidget extends StatefulWidget {
  final TrelloCard card;

  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  String? accessToken;
  String? selectedItem;
  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getAccessToken();
    if (mounted) { // Check if widget is mounted before calling setState
      await _getMembersBoard();
      setState(() {});
    }
  }

  Future<void> _getMembersBoard() async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var members = await getMembersFromBoard(apiKey!, accessToken!, widget.card.idBoard);
    if (mounted) {
      setState(() {
        members.forEach((member) {
          membersList.add({"id": member['id'], "username": member['username']});
        });
      });
    }
  }

  Future<void> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');
  }

  Future<dynamic> _getMembers(String cardId) async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var members = await getMembersFromCard(apiKey!, accessToken!, cardId);
    return members;
  }

  Future<void> _addMember(String memberId) async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    await addMemberToCard(apiKey!, accessToken!, widget.card.id, memberId);
  }

  Future<void> _updateCard(String name, String desc) async {

    TrelloCard card = TrelloCard(
      id: widget.card.id,
      name: name,
      desc: desc,
      due: widget.card.due,
      idBoard: widget.card.idBoard,
      idMembers: widget.card.idMembers,
    );
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    await updateCard(apiKey!, accessToken!, widget.card.id, card);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: FutureBuilder(
        future: _getMembers(widget.card.id),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Container(); // Error handling widget
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          onChanged: (String value) {
                            _updateCard(value, widget.card.desc);
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          initialValue: widget.card.name,
                          style: const TextStyle(
                            color: Color(0xFF1C39A1),
                            fontSize: 20,
                          )
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                          color: Color(0xFF1C39A1),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // add a color to the text
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    onChanged: (String value) {
                      _updateCard(widget.card.name, value);
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF1C39A1),
                          width: 2.0,
                        ),
                      ),
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Color(0xFF1C39A1), fontSize: 20),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.card.desc,
                    maxLines: 5,
                  ),
                ),
                Container(
                  height: 1,
                  color: const Color(0xFF1C39A1),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 50,
                    child: FutureBuilder(
                      future: _getMembers(widget.card.id),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasError) {
                          return Container();
                        } else {
                          return Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Color(0xFF1C39A1),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data != null ? snapshot.data.length : 0,
                                        itemBuilder: (BuildContext context, int index) {
                                          return CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              snapshot.data[index]['avatarUrl'] != null ? snapshot.data[index]['avatarUrl'] + '/50.png' : 'https://placehold.co/50.png'
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 25, color: Color(0xFF1C39A1)),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  title: const Text('Add Member'),
                                                  content: DropdownButton<String>(
                                                    value: selectedItem,
                                                    items: membersList.map((Map<String, dynamic> member) {
                                                      return DropdownMenuItem<String>(
                                                        value: member["id"],
                                                        child: Text(member["username"]),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        selectedItem = newValue;
                                                      });
                                                    },
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('Add'),
                                                      onPressed: () {
                                                        if (selectedItem != null) {
                                                          _addMember(selectedItem!);
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
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20, color: Color(0xFF1C39A1)),
                                  const SizedBox(width: 10),
                                  Text(widget.card.due ?? "No due date"),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: const Color(0xFF1C39A1),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "ACTIVITIES",
                      style: TextStyle(fontSize: 20, color: Color(0xFF1C39A1)),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
