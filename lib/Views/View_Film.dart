import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/ViewModel_Film.dart';
import 'package:unistream/Views/Templates/Films_Block_Display.dart';
import 'package:unistream/Views/Templates/Pagination_Display.dart';

class ViewFilm extends StatefulWidget {
  const ViewFilm({super.key});

  @override
  State<ViewFilm> createState() => ViewFilmState();
}

class ViewFilmState extends State<ViewFilm> {
  ValueNotifier? videoNotifier;
  ViewmodelFilm? viewmodel;
  late FutureBuilder data;

  FutureBuilder getData() => FutureBuilder(
      future: ViewmodelFilm.create(),
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
                    FilmsBlockDisplay(
                      viewmodel: this.viewmodel!,
                      video_notifier: this.videoNotifier!,
                    ),
                    PaginationDisplay(
                        viewmodel_Video: this.viewmodel!,
                        video_notifier: this.videoNotifier!),
                  ],
                ),
              )
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
