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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Naviguer vers la vue correspondante en fonction de l'index
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardView()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileView()));
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

