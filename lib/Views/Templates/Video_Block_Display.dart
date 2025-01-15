import 'package:flutter/material.dart';

class VideoBlockDisplay extends StatefulWidget {
  @override
  State createState() => VideoBlockDisplayState();
}

class VideoBlockDisplayState extends State<VideoBlockDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                child: Row(
                  children: [],
                ),
              )
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("#"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Titre :"), Text("#")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Description :"), Text("#")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Durée :"), Text("#")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Date de parution :"), Text("#")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Studio de réalisation :"), Text("#")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Genre :"), Text("#")],
            ),
            Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Infos Additionnel : (en dessous !)")]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Réalisateurs :"), Text("#")]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Pays :"), Text("#")],
                ),
              ],
            ),
            Column(
              spacing: 15,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text("<<"),
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      child: Text("<"),
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      child: Text(">"),
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      child: Text(">>"),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            )
          ],
        ));
  }
}
