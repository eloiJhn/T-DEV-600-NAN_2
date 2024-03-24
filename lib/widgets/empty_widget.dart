import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EmptyBoardWidget extends StatelessWidget {
  final String itemType;
  final String message;
  final IconData iconData;
  final VoidCallback onTap;
  final bool isMasculine;
  final bool witheColor;

  const EmptyBoardWidget({
    Key? key,
    required this.itemType,
    required this.message,
    required this.iconData,
    required this.onTap,
    required this.isMasculine,
    this.witheColor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: DottedBorder(
          color: witheColor ? Colors.white : Colors.grey,
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    iconData,
                    color: witheColor ? Colors.white : Colors.grey,
                    size: 100,
                  ),
                  Text(
                    "${isMasculine ? AppLocalizations.of(context)!.no : AppLocalizations.of(context)!.nof} $itemType",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: witheColor ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: witheColor ? Colors.white : Colors.black,
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
