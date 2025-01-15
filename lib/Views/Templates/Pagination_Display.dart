import 'dart:ffi';

import 'package:flutter/material.dart';

class PaginationDisplay extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PaginationDisplayState();
}

class PaginationDisplayState extends State<PaginationDisplay> {
  void initializationControlsPagination() {}

  void valueChanged() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("Fiche : "), Text("nb"), Text("/"), Text("Total")],
      ),
    );
  }
}
