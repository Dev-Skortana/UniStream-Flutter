import 'package:flutter/material.dart';

class ViewEnregistrement extends StatefulWidget {
  const ViewEnregistrement({super.key});

  @override
  State<ViewEnregistrement> createState() => ViewEnregistrementState();
}

class ViewEnregistrementState extends State<ViewEnregistrement> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          spacing: 50,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu(
                  key: GlobalKey(),
                  label: Text("Site :"),
                  dropdownMenuEntries: <DropdownMenuEntry>[],
                  onSelected: (value) {},
                ),
                DropdownMenu(
                  key: GlobalKey(),
                  label: Text("Catégorie Video :"),
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
      ),
    );
  }
}
