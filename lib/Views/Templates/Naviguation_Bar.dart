import 'package:flutter/material.dart';

class bottomNaviguationBar extends StatefulWidget {
  late Map<String, int> objectIndex;

  bottomNaviguationBar(
      {super.key,
      required Map<String, int> object_index,
      required Function setstate_mainwrapper}) {
    this.objectIndex = object_index;
  }

  @override
  State<bottomNaviguationBar> createState() => bottomNaviguationBarState();
}

class bottomNaviguationBarState extends State<bottomNaviguationBar> {
  void setCurrentIndex(int index) {
    setState(() {
      widget.objectIndex = {"Index": index};
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
        selectedIndex: this.widget.objectIndex["Index"]!,
        elevation: 10,
        onDestinationSelected: (index) {
          this.setCurrentIndex(index);
        },
        destinations: const [
          NavigationDestination(
              selectedIcon: Icon(Icons.house),
              icon: Icon(Icons.house_outlined),
              label: "Acceuille"),
          NavigationDestination(
              selectedIcon: Icon(Icons.view_stream),
              icon: Icon(Icons.view_stream_outlined),
              label: "Animer"),
          NavigationDestination(
              selectedIcon: Icon(Icons.view_stream),
              icon: Icon(Icons.view_stream_outlined),
              label: "Drama"),
          NavigationDestination(
              selectedIcon: Icon(Icons.view_stream),
              icon: Icon(Icons.view_stream_outlined),
              label: "Serie"),
          NavigationDestination(
              selectedIcon: Icon(Icons.view_stream),
              icon: Icon(Icons.view_stream_outlined),
              label: "Film"),
          NavigationDestination(
              selectedIcon: Icon(Icons.search),
              icon: Icon(Icons.search_outlined),
              label: "Enregistrements"),
          NavigationDestination(
              selectedIcon: Icon(Icons.import_contacts),
              icon: Icon(Icons.import_contacts_outlined),
              label: "Sites enregistrements"),
        ]);
  }
}
