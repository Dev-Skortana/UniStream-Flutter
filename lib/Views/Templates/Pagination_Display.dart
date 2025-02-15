import 'dart:ffi';

import 'package:flutter/material.dart';

class PaginationDisplay extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PaginationDisplayState();
}

class PaginationDisplayState extends State<PaginationDisplay> {
  late GlobalKey controlNumberFiche;
  late GlobalKey controlTotalFiche;

  PaginationDisplayState() {
    this.initializationControlsPagination();
  }

  void initializationControlsPagination() {
    this.controlNumberFiche = GlobalKey();
    this.controlTotalFiche = GlobalKey();
  }

  void valueChanged({required int indexvideo, required int index}) {
    /* */
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Fiche : "),
          Text(key: this.controlNumberFiche, ""),
          Text("/"),
          Text(key: this.controlTotalFiche, "Total")
        ],
      ),
    );
  }
}
