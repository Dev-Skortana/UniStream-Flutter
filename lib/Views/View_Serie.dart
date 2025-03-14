import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/ViewModel_Serie.dart';
import 'package:unistream/Views/Templates/Series_Block_Display.dart';
import 'package:unistream/Views/Templates/Pagination_Display.dart';

class ViewSerie extends StatefulWidget {
  const ViewSerie({super.key});

  @override
  State<ViewSerie> createState() => ViewSerieState();
}

class ViewSerieState extends State<ViewSerie> {
  ValueNotifier? videoNotifier;
  ViewmodelSerie? viewmodel;
  late FutureBuilder data;

  FutureBuilder getData() => FutureBuilder(
      future: ViewmodelSerie.create(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          this.viewmodel = snapshot.data;
          this.videoNotifier = ValueNotifier(this.viewmodel!.video["Video"]);
          return Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    SeriesBlockDisplay(
                      viewmodel: this.viewmodel!,
                      video_notifier: this.videoNotifier!,
                    )
                  ],
                ),
              ),
              PaginationDisplay(
                  viewmodel_Video: this.viewmodel!,
                  video_notifier: this.videoNotifier!)
            ],
          );
        }
      });

  @override
  void initState() {
    super.initState();
    this.data = this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: this.data);
  }
}
