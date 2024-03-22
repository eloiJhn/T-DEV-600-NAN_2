import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trelltech/models/trello_list.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';

import '../models/trello_card.dart';

class CardWidget extends StatefulWidget {
  final TrelloCard card;
  final AsyncSnapshot<List<TrelloList>> lists;

  const CardWidget({super.key, required this.card, required this.lists});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  String? selectedItem;
  String? selectedList;
  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (mounted) {
      await _getMembersBoard();
      selectedList = widget.card.idList;
      setState(() {});
    }
  }

  Future<void> _getMembersBoard() async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var members = await getMembersFromBoard(
        apiKey!, await getAccessToken(), widget.card.idBoard);
    if (mounted) {
      setState(() {
        members.forEach((member) {
          membersList.add({"id": member['id'], "username": member['username']});
        });
      });
    }
  }

  bool isUserInCard(String memberId) {
    return widget.card.idMembers.contains(memberId);
  }

  Future<dynamic> _getMembers(String cardId) async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    var members =
        await getMembersFromCard(apiKey!, await getAccessToken(), cardId);
    return members;
  }

  Future<void> _addMember(String memberId) async {
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    await addMemberToCard(
        apiKey!, await getAccessToken(), widget.card.id, memberId);
  }

  Future<void> _updateCard(
      String name, String desc, String? due, String? idList) async {
    TrelloCard card = TrelloCard(
      id: widget.card.id,
      name: name,
      desc: desc,
      due: due ?? widget.card.due,
      idBoard: widget.card.idBoard,
      idList: idList ?? widget.card.idList,
      idMembers: widget.card.idMembers,
    );
    var apiKey = dotenv.env['TRELLO_API_KEY'];
    await updateCard(apiKey!, await getAccessToken(), widget.card.id, card);
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
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                              onChanged: (String value) {
                                _updateCard(value, widget.card.desc,
                                    widget.card.due, selectedList);
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              initialValue: widget.card.name,
                              style: const TextStyle(
                                color: Color(0xFF1C39A1),
                                fontSize: 20,
                              )),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "List",
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFF1C39A1)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButton<String>(
                      value: selectedList,
                      items: widget.lists.data!.map((TrelloList list) {
                        return DropdownMenuItem<String>(
                          value: list.id,
                          child: Text(list.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedList = newValue;
                          _updateCard(widget.card.name, widget.card.desc,
                              widget.card.due, newValue);
                        });
                      },
                      hint: const Text('Select a list'),
                    ),
                  ),
                  // add a color to the text
                  const SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      onChanged: (String value) {
                        _updateCard(widget.card.name, value, widget.card.due,
                            selectedList);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle:
                            TextStyle(color: Color(0xFF1C39A1), fontSize: 20),
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
                      height: 100,
                      child: FutureBuilder(
                        future: _getMembers(widget.card.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
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
                                            itemCount: snapshot.data != null
                                                ? snapshot.data.length
                                                : 0,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    snapshot.data[index]
                                                                ['avatarUrl'] !=
                                                            null
                                                        ? snapshot.data[index]
                                                                ['avatarUrl'] +
                                                            '/50.png'
                                                        : 'https://placehold.co/50.png'),
                                              );
                                            }),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        child: TextButton(
                                          child: const Icon(Icons.add,
                                              size: 25,
                                              color: Color(0xFF1C39A1)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Add Member'),
                                                      content: membersList
                                                              .where((member) =>
                                                                  !isUserInCard(
                                                                      member[
                                                                          "id"]))
                                                              .isEmpty
                                                          ? const Text(
                                                              "Il n'y a pas de membres à ajouter")
                                                          : DropdownButton<
                                                              String>(
                                                              value:
                                                                  selectedItem,
                                                              items: membersList
                                                                  .where((member) =>
                                                                      !isUserInCard(
                                                                          member[
                                                                              "id"]))
                                                                  .map((Map<
                                                                          String,
                                                                          dynamic>
                                                                      member) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: member[
                                                                      "id"],
                                                                  child: Text(
                                                                      member[
                                                                          "username"]),
                                                                );
                                                              }).toList(),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                setState(
                                                                    () async {
                                                                  widget.card
                                                                      .idMembers
                                                                      .add(
                                                                          newValue!);
                                                                  addMemberToCard(
                                                                      dotenv.env[
                                                                          'TRELLO_API_KEY']!,
                                                                      await getAccessToken(),
                                                                      widget
                                                                          .card
                                                                          .id,
                                                                      newValue!);
                                                                });
                                                              },
                                                            ),
                                                    );
                                                  },
                                                );
                                              },
                                            ).then(
                                                (value) => // refresh the page
                                                    _initialize());
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 20, color: Color(0xFF1C39A1)),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2015, 8),
                                          lastDate: DateTime(2101),
                                        );
                                        if (picked != null &&
                                            picked.toIso8601String() !=
                                                widget.card.due) {
                                          setState(() {
                                            widget.card.due =
                                                picked.toIso8601String();
                                          });
                                        }
                                      },
                                      child: Text(
                                        widget.card.due != null
                                            ? DateFormat('yyyy-MM-dd – kk:mm')
                                                .format(DateTime.parse(
                                                    widget.card.due!))
                                            : "No due date",
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      child: Icon(Icons.delete,
                                          size: 25, color: Color(0xFF1C39A1)),
                                      onPressed: () {},
                                    ),
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
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFF1C39A1)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
