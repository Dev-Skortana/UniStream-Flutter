import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Views/Helpers/Theme_Provider.dart';

class TopAppBar extends StatefulWidget {
  late String name_of_appli;
  late Map<String, int> objectIndex;
  TopAppBar(
      {super.key,
      required String name_of_appli,
      required Map<String, int> object_index}) {
    this.objectIndex = object_index;
    this.name_of_appli = name_of_appli;
  }

  @override
  State<TopAppBar> createState() => TopAppBarState();
}

class TopAppBarState extends State<TopAppBar> {
  void setCurrentTheme() {
    setState(() {
      Provider.of<ThemeProvider>(context, listen: false).toogleTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: SafeArea(
          child: IndexedStack(
        index: this.widget.objectIndex["Index"]!,
        children: [
          Row(spacing: 15, children: [
            Text(widget.name_of_appli),
            Text("Acceuille", style: TextStyle(fontSize: 20))
          ]),
          Row(spacing: 15, children: [
            Text(widget.name_of_appli),
            Text("Animer", style: TextStyle(fontSize: 20))
          ]),
          Row(spacing: 15, children: [
            Text(widget.name_of_appli),
            Text("Drama", style: TextStyle(fontSize: 20))
          ]),
          Row(spacing: 15, children: [
            Text(widget.name_of_appli),
            Text("Serie", style: TextStyle(fontSize: 20))
          ]),
          Row(spacing: 15, children: [
            Text(widget.name_of_appli),
            Text("Film", style: TextStyle(fontSize: 20))
          ]),
          Row(spacing: 15, children: [
            Text(widget.name_of_appli),
            Text("Enregistrements", style: TextStyle(fontSize: 20))
          ]),
          Row(spacing: 15, children: [
            Text(widget.name_of_appli),
            Text("Sites enregistrements", style: TextStyle(fontSize: 16))
          ])
        ],
      )),
      leading: Icon(Icons.bed),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.accessibility),
          style:
              ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
          onPressed: () {
            this.setCurrentTheme();
          },
        )
      ],
    );
  }
}
