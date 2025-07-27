import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_VideoBase.dart';

class PaginationDisplay extends StatefulWidget {
  late ViewmodelVideobase viewmodelVideo;
  late ValueNotifier videoNotifier;

  PaginationDisplay(
      {Key? key,
      required ViewmodelVideobase viewmodel_Video,
      required ValueNotifier video_notifier})
      : super(key: key) {
    this.viewmodelVideo = viewmodel_Video;
    this.videoNotifier = video_notifier;
  }

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

  Widget getTextCurrentPositionPagination() {
    int current_position = 0;
    if (widget.viewmodelVideo.TotalCount > 0) {
      current_position = (widget.viewmodelVideo.index + 1);
    }
    return Text(key: this.controlNumberFiche, current_position.toString());
  }

  Widget getTextTotalPagination() => Text(
      key: this.controlTotalFiche, widget.viewmodelVideo.TotalCount.toString());

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ValueListenableBuilder(
          valueListenable: widget.videoNotifier,
          builder: (context, value, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Fiche : "),
                this.getTextCurrentPositionPagination(),
                Text("/"),
                this.getTextTotalPagination()
              ],
            );
          }),
    );
  }
}
