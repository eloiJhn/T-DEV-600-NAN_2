import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_organization.dart';
import 'package:trelltech/repositories/api.dart';
import 'package:trelltech/repositories/authentification.dart';

class EditOrganizationScreen extends StatefulWidget {
  final String organisationId;
  final List<Board> boards;

  const EditOrganizationScreen(
      {Key? key, required this.organisationId, required this.boards})
      : super(key: key);

  @override
  _EditOrganizationScreenState createState() => _EditOrganizationScreenState();
}

class _EditOrganizationScreenState extends State<EditOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _fetchOrganizationDetails();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  Future<void> _fetchOrganizationDetails() async {
    setState(() {
      _isLoading = true;
    });

    final organization = await getWorkspace(dotenv.env['TRELLO_API_KEY']!,
        await getAccessToken(), widget.organisationId);

    _nameController.text = organization.displayName;
    _descriptionController.text = organization.description;

    setState(() {
      _isLoading = false;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final organization = TrelloOrganization(
        id: widget.organisationId,
        displayName: _nameController.text,
        description: _descriptionController.text,
      );

      final success = await updateWorkspace(dotenv.env['TRELLO_API_KEY']!,
          await getAccessToken(), widget.organisationId, organization);

      if (success) {
        Navigator.pop(context, organization);
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.organization_updated,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.organization_updateFailed,
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
        title: Text(AppLocalizations.of(context)!.organization_edit),
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
                            AppLocalizations.of(context)!.organization_name,
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
                            .organization_description,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF1C39A1), // text color
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.organization_update,
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
