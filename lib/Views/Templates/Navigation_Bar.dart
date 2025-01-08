import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  int _currentindex = 0;

  void setCurrentIndex(int index) {
    setState(() {
      this._currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: this._currentindex,
        onTap: (index) => this.setCurrentIndex(index),
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.white70,
        iconSize: 32,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: "Acceuill"),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_stream), label: "Animer"),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_stream), label: "Darama"),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_stream), label: "Serie"),
          BottomNavigationBarItem(icon: Icon(Icons.view_stream), label: "Film"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Enregistrements"),
          BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts), label: "Sites enregistrements")
        ]);
  }
}
