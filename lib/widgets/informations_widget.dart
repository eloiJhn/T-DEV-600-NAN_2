import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InformationsBottomSheet extends StatelessWidget {
  final String name;
  final String? desc;

  InformationsBottomSheet({required this.name, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${name}',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 10),
          Text(
            '${desc == '' ? 'Aucune description' : desc}',
            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
