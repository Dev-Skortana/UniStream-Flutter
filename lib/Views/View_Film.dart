import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Films_Block_Display.dart';
import 'package:unistream/Views/Templates/Pagination_Display.dart';

class ViewFilm extends StatefulWidget {
  const ViewFilm({super.key});

  @override
  State<ViewFilm> createState() => ViewFilmState();
}

class ViewFilmState extends State<ViewFilm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                FilmsBlockDisplay(),
                PaginationDisplay(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
