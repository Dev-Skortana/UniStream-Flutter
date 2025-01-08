import 'package:flutter/material.dart';

class ViewDrama extends StatefulWidget {
  const ViewDrama({super.key});

  @override
  State<ViewDrama> createState() => ViewDramaState();
}

class ViewDramaState extends State<ViewDrama> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(
      children: [Text("Page des Dramas !")],
    )));
  }
}
