import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

class SeriesBlockDisplay extends StatefulWidget {
  @override
  State createState() => SeriesBlockDisplayState();
}

class SeriesBlockDisplayState extends State<SeriesBlockDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          VideoBlockDisplay(),
          /*Video display */
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  spacing: 20,
                  children: [
                    /* */
                    /* */
                    /* */
                    Container(
                      margin: EdgeInsets.fromLTRB(115, 0, 0, 0),
                      child: Row(
                        children: [
                          /* */
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
