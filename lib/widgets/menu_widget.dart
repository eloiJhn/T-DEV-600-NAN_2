import 'package:flutter/material.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:trelltech/views/profile/profile_view.dart';

class MenuWidget extends StatefulWidget {
  final int initialIndex;
  MenuWidget({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _showAddElementBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Ajouter une organisation'),
                onTap: () {
                  // Ajoutez votre logique pour ajouter une organisation ici
                },
              ),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Ajouter un board'),
                onTap: () {
                  // Ajoutez votre logique pour ajouter un board ici
                },
              ),
            ],
          ),
        );
      },
    );
  }

    void _onItemTapped(int index) {
      setState(() {
        _currentIndex = index;
      });

      String? currentRoute = ModalRoute.of(context)?.settings.name;
      String newRoute = index == 0 ? '/dashboard' : '/profile';

    if(currentRoute == newRoute) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        // affiche une bottom sheet pour ajouter un élément (organisation, board, etc.
        _showAddElementBottomSheet(context);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building with _currentIndex: $_currentIndex');
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.grey, // Rendre la couleur de l'item sélectionné transparente
      unselectedItemColor: Colors.grey, // Vous pouvez définir la couleur des autres items ici
    );
  }

}

