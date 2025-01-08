import 'package:flutter/material.dart';

class ViewSerie extends StatefulWidget {
  const ViewSerie({super.key});

  @override
  State<ViewSerie> createState() => ViewSerieState();
}

class ViewSerieState extends State<ViewSerie> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(
      children: [Text("Page des Séries !")],
    )));
  }
}
