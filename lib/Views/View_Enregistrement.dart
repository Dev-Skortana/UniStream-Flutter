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
        child: Center(
            child: Column(
      children: [Text("Page d'enregistrements des données vidéos d'un site !")],
    )));
  }
}
