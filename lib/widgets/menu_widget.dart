import 'package:flutter/material.dart';
import 'package:trelltech/views/board/board_view.dart';
import 'package:trelltech/views/board/workspace_view.dart';

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
    Widget bottomSheetContent;

    // Vérifiez le type de la vue actuelle
    if (context.findAncestorWidgetOfExactType<WorkspaceView>() != null) {
      // Si l'utilisateur est dans DashboardView
      bottomSheetContent = ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('Ajouter un board'),
        onTap: () {
          Navigator.pop(context);
          // Logique pour ajouter un board
        },
      );
    } else if (context.findAncestorWidgetOfExactType<BoardView>() != null) {
      // Si l'utilisateur est dans WorkspaceView
      bottomSheetContent = ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('Ajouter une organisation'),
        onTap: () {
          Navigator.pop(context);
          // Logique pour ajouter un board spécifique à WorkspaceView
        },
      );
    } else {
      // Contenu par défaut ou vide si aucune des vues n'est détectée
      bottomSheetContent = Container();
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [bottomSheetContent],
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
      selectedItemColor: Colors.grey,
      unselectedItemColor: Colors.grey,
    );
  }

}

