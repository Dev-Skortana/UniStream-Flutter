import 'package:flutter/material.dart';

class ViewEnregistrement extends StatefulWidget {
  const ViewEnregistrement({super.key});

  @override
  State<ViewEnregistrement> createState() => ViewEnregistrementState();
}

class ViewEnregistrementState extends State<ViewEnregistrement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        spacing: 100,
        children: [
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownMenu(
                width: 160,
                key: GlobalKey(),
                label: Text("Site :"),
                dropdownMenuEntries: <DropdownMenuEntry>[],
                onSelected: (value) {},
              ),
              DropdownMenu(
                width: 160,
                key: GlobalKey(),
                label: Text("Catégorie:"),
                dropdownMenuEntries: <DropdownMenuEntry>[],
                onSelected: (value) {},
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [
              DropdownMenu(
                width: 160,
                key: GlobalKey(),
                label: Text("Page N :"),
                dropdownMenuEntries: <DropdownMenuEntry>[],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  child: ElevatedButton(
                      key: GlobalKey(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      onPressed: () {},
                      child: Text("Lancer l'enregistrement"))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(key: GlobalKey(), "Enregistrement en cours..."),
            ],
          )
        ],
      ),
    );
  }
}
