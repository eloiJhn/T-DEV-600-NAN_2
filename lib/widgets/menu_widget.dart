import 'package:flutter/material.dart';
import 'package:trelltech/views/board/board_view.dart';
import 'package:trelltech/views/board/workspace_view.dart';
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
    Widget bottomSheetContent;

    if (context.findAncestorWidgetOfExactType<WorkspaceView>() != null) {
      bottomSheetContent = ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('Ajouter un board'),
        onTap: () {
          Navigator.pop(context);
        },
      );
    } else if (context.findAncestorWidgetOfExactType<DashboardView>() != null) {
      bottomSheetContent = ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('Ajouter une organisation'),
        onTap: () {
          Navigator.pop(context);
        },
      );
    } else {
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

    bool isOnBoardView = context.findAncestorWidgetOfExactType<BoardView>() != null;
    bool isOnProfileView = context.findAncestorWidgetOfExactType<ProfileView>() != null;

    // Ajustement de l'index si l'icône "Ajouter" est cachée
    if ((isOnBoardView || isOnProfileView) && index >= 1) {
      index += 1;
    }

    // Naviguer vers la vue correspondante
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        if (!isOnBoardView && !isOnProfileView) {
          _showAddElementBottomSheet(context);
        }
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building with _currentIndex: $_currentIndex');
    bool isOnBoardView = context.findAncestorWidgetOfExactType<BoardView>() != null;
    bool isOnProfileView = context.findAncestorWidgetOfExactType<ProfileView>() != null;

    bool hideAddIcon = isOnBoardView || isOnProfileView;


    List<BottomNavigationBarItem> navBarItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    ];

    if (!hideAddIcon) {
      navBarItems.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Add',
        ),
      );
    }

    navBarItems.add(
      BottomNavigationBarItem(
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
