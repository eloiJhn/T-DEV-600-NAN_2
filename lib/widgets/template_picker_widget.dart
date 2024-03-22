import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/models/trello_board_template.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';

void showTemplatePicker(
    BuildContext context, Function(TrelloBoardTemplate) onSelect) async {
  final templates = await getBoardTemplates(
      dotenv.env['TRELLO_API_KEY']!, await getAccessToken());

  String filter = '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext bc) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Rechercher",
                        hintText: "Rechercher",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        return templates[index].name.contains(filter)
                            ? Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    templates[index].backgroundImage != null
                                        ? Ink.image(
                                            image: NetworkImage(templates[index]
                                                .backgroundImage!),
                                            fit: BoxFit.cover,
                                            height: 240,
                                            child: InkWell(
                                              onTap: () {
                                                onSelect(templates[index]);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          )
                                        : Container(
                                            color: Color(int.parse(
                                                'FF${templates[index].backgroundColor?.replaceAll('#', '') ?? ''}',
                                                radix: 16)),
                                            height: 240,
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            templates[index].name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.remove_red_eye,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                '${templates[index].viewCount}',
                                                style: const TextStyle(
                                                  wordSpacing: 2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 16.0),
                                              const Icon(
                                                Icons.copy,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                '${templates[index].copyCount}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
