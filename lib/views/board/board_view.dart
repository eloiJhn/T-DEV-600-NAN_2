import 'package:flutter/material.dart';
import 'package:trelltech/models/board.dart';

class BoardView extends StatefulWidget {
  final Board board;

  const BoardView({super.key, required this.board});

  @override
  BoardViewState createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.board.name)),
      body: Center(
        child: Text(
          'Board',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}