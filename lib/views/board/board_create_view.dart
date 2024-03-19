import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_board_template.dart';
import 'package:trelltech/models/trello_organization.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trelltech/repositories/authentification.dart';

class CreateBoardScreen extends StatefulWidget {
  String organizationId;
  CreateBoardScreen({super.key, required this.organizationId});

  @override
  _CreateBoardScreenState createState() => _CreateBoardScreenState();
}

class _CreateBoardScreenState extends State<CreateBoardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isLoading = false;
  String _selectedOption = 'tableau_vierge';
  TrelloBoardTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? apiKey = dotenv.env['TRELLO_API_KEY'];
      String? accessToken = await getAccessToken();

      if (apiKey == null || accessToken == null) {
        Fluttertoast.showToast(
          msg: "API key or access token is null",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        await createBoard(
            apiKey,
            accessToken,
            _nameController.text,
            _descriptionController.text,
            widget.organizationId,
            _selectedTemplate?.id);

        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.boardCreated,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context, 'boardCreated');
      } catch (e) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.boardCreationFailed,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTemplatePicker() async {
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
                        decoration: InputDecoration(
                          labelText: "Rechercher",
                          hintText: "Rechercher",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
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
                                              image: NetworkImage(
                                                  templates[index]
                                                      .backgroundImage!),
                                              fit: BoxFit.cover,
                                              height: 240,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedTemplate =
                                                        templates[index];
                                                  });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.boardCreated),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.boardName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.boardDescription,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOption = 'tableau_vierge';
                                _selectedTemplate = null;
                              });
                            },
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: _selectedOption == 'tableau_vierge'
                                        ? Colors.blue
                                        : Colors.grey,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.insert_chart,
                                        size: 50.0,
                                      ),
                                      Text('Tableau vierge'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _selectedTemplate != null
                            ? Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedOption = 'template';
                                    });
                                    _showTemplatePicker();
                                  },
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        side: BorderSide(
                                          color: _selectedOption == 'template'
                                              ? Colors.blue
                                              : Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Image.network(
                                              _selectedTemplate!
                                                  .backgroundImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 5.0, sigmaY: 5.0),
                                              child: Container(
                                                color:
                                                    Colors.black.withOpacity(0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Image.network(
                                                    _selectedTemplate!
                                                        .backgroundImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              _selectedTemplate!.name,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedOption = 'template';
                                      _selectedTemplate = null;
                                    });
                                    _showTemplatePicker();
                                  },
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        side: BorderSide(
                                          color: _selectedOption == 'template'
                                              ? Colors.blue
                                              : Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.dashboard_customize,
                                              size: 50.0,
                                            ),
                                            Text(
                                              'Basé sur un template',
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF1C39A1),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.boardCreated,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
