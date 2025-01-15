import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

class FilmsBlockDisplay extends StatefulWidget {
  @override
  State createState() => FilmsBlockDisplayState();
}

class FilmsBlockDisplayState extends State<FilmsBlockDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          VideoBlockDisplay(),
          /* Video display */
          Row(
            children: [],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [],
            mainAxisAlignment: MainAxisAlignment.center,
          )
        ],
      ),
    );
  }
}
