import 'package:flutter/material.dart';

class ViewFilm extends StatefulWidget {
  const ViewFilm({super.key});

  @override
  State<ViewFilm> createState() => ViewFilmState();
}

class ViewFilmState extends State<ViewFilm> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(
      children: [Text("Page des Films !")],
    )));
  }
}
