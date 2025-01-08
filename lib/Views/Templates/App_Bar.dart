import 'package:flutter/material.dart';

class TopAppBar extends StatefulWidget {
  const TopAppBar({super.key});

  @override
  State<TopAppBar> createState() => TopAppBarState();
}

class TopAppBarState extends State<TopAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("UniStream"),
      leading: Icon(Icons.bed),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.home),
            selectedIcon: Icon(Icons.light_mode),
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue)),
            onPressed: () {})
      ],
    );
  }
}
