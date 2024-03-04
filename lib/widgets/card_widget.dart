import 'package:flutter/material.dart';

import '../models/trello_card.dart';

class CardWidget extends StatelessWidget {
  final TrelloCard card;

  const CardWidget({
    super.key,
    required this.card
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(card.name),
      content: Text(card.name),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}