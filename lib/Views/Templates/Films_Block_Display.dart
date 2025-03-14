import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

class FilmsBlockDisplay extends StatefulWidget {
  late ValueNotifier videoNotifier;
  late ViewmodelFilmbase viewmodelFilmBase;

  FilmsBlockDisplay(
      {Key? key,
      required ViewmodelFilmbase viewmodel,
      required ValueNotifier video_notifier})
      : super(key: key) {
    this.viewmodelFilmBase = viewmodel;
    this.videoNotifier = video_notifier;
  }

  @override
  State createState() => FilmsBlockDisplayState();
}

class FilmsBlockDisplayState extends State<FilmsBlockDisplay> {
  late VideoBlockDisplay videoBlockDisplay;

  late GlobalKey controlButtonSeeMovie;
  late GlobalKey controlLoadSearchLinksWatch;

  FilmsBlockDisplayState() {}

  @override
  void initState() {
    super.initState();

    this.initializeControlsFilm();
  }

  void initializeControlsFilm() {
    this.controlButtonSeeMovie = GlobalKey();
    this.controlLoadSearchLinksWatch = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          VideoBlockDisplay(
            viewmodel: widget.viewmodelFilmBase,
            video_notifier: widget.videoNotifier,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                  valueListenable: widget.videoNotifier,
                  builder: (context, value, child) {
                    return Container();
                  }),
              ElevatedButton(
                  key: this.controlButtonSeeMovie,
                  onPressed: () {},
                  child: Text("Voir le Film."))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  key: this.controlLoadSearchLinksWatch, strokeWidth: 2)
            ],
          )
        ],
      ),
    );
  }
}
