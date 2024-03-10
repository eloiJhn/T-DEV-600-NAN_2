import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class EmptyBoardWidget extends StatelessWidget {
  final String itemType;
  final String message;
  final IconData iconData;
  final VoidCallback onTap;
  final bool isMasculine;

  const EmptyBoardWidget({
    Key? key,
    required this.itemType,
    required this.message,
    required this.iconData,
    required this.onTap,
    required this.isMasculine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    iconData,
                    color: Colors.grey,
                    size: 100,
                  ),
                  Text(
                    "${isMasculine ? 'Aucun' : 'Aucune'} $itemType",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}