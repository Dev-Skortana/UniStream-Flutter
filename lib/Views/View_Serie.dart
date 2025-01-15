import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Series_Block_Display.dart';
import 'package:unistream/Views/Templates/Pagination_Display.dart';

class ViewSerie extends StatefulWidget {
  const ViewSerie({super.key});

  @override
  State<ViewSerie> createState() => ViewSerieState();
}

class ViewSerieState extends State<ViewSerie> {
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
                SeriesBlockDisplay(),
                PaginationDisplay(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
