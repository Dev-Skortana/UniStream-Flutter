import 'package:flutter/material.dart';

class ViewAnimer extends StatefulWidget {
  const ViewAnimer({super.key});

  @override
  State<ViewAnimer> createState() => ViewAnimerState();
}

class ViewAnimerState extends State<ViewAnimer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(
      children: [Text("Page des animées !")],
    )));
  }
}
