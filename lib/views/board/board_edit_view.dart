import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_organization.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trelltech/repositories/authentification.dart';
import 'package:trelltech/views/board/workspace_view.dart';

class EditBoardScreen extends StatefulWidget {
  final String boardId;

  const EditBoardScreen({super.key, required this.boardId});

  @override
  _EditBoardScreenState createState() => _EditBoardScreenState();
}

class _EditBoardScreenState extends State<EditBoardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _fetchBoardDetails();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  Future<void> _fetchBoardDetails() async {
    setState(() {
      _isLoading = true;
    });

    final board = await getBoard(dotenv.env['TRELLO_API_KEY']!,
        await getAccessToken(), widget.boardId);

    _nameController.text = board.name;
    _descriptionController.text = board.desc!;

    setState(() {
      _isLoading = false;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final board = Board(
        id: widget.boardId,
        name: _nameController.text,
        desc: _descriptionController.text,
        closed: false,
      );

      final success = await updateBoard(dotenv.env['TRELLO_API_KEY']!,
          await getAccessToken(), widget.boardId, board);

      if (success) {
        Navigator.pop(context, board);
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.boardUpdated,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );


      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.boardUpdateFailed,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editBoard),
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
                  labelText:
                  AppLocalizations.of(context)!.boardName,
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
                  labelText: AppLocalizations.of(context)!
                      .organizationDescription,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF1C39A1), // text color
                ),
                child: Text(
                  AppLocalizations.of(context)!.updateBoard,
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
