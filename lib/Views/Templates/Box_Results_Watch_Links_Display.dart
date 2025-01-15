import 'package:flutter/material.dart';

class BoxResultsWatchLinksDisplay extends StatefulWidget {
  @override
  State createState() => BoxResultsWatchLinksDisplayState();
}

class BoxResultsWatchLinksDisplayState
    extends State<BoxResultsWatchLinksDisplay> {
  void _closeBoxDialog() {}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Panel visionnage Vidéo."),
      content: Container(
        alignment: Alignment.center,
        child: Row(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /* */
            Text(
                "En cliquant sur l'un des boutons ci-dessus, le lien apparaîtra dans la zone de text en dessous :"),
            /* */
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Fermer"),
          onPressed: this._closeBoxDialog,
        )
      ],
    );
  }
}
