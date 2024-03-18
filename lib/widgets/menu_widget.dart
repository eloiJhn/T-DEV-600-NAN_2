import 'package:flutter/material.dart';
import 'package:trelltech/views/board/board_view.dart';
import 'package:trelltech/views/board/workspace_view.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:trelltech/views/profile/profile_view.dart';
import 'package:trelltech/views/organizations/organization_create_view.dart';


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

    if (context.findAncestorWidgetOfExactType<WorkspaceView>() != null) {
      bottomSheetContent = ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Ajouter un board'),
        onTap: () {
          Navigator.pop(context);
        },
      );
    } else if (context.findAncestorWidgetOfExactType<DashboardView>() != null) {
      bottomSheetContent = ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('Ajouter une organisation'),
        onTap: () {
          Navigator.pop(context); // Ferme le BottomSheet
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateOrganizationScreen()), // Navigue vers OrganizationCreateView
          );
        },
      );
    } else {
      bottomSheetContent = Container();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Permet au BottomSheet de prendre plus de hauteur
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            child: Wrap(
              children: [bottomSheetContent],
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Naviguer vers la vue correspondante
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building with _currentIndex: $_currentIndex');


    List<BottomNavigationBarItem> navBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    ];

    navBarItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: 'Profile',
      ),
    );

    return BottomNavigationBar(
      items: navBarItems,
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.grey,
      unselectedItemColor: Colors.grey,
    );
  }
}

