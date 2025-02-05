import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

class FilmsBlockDisplay extends StatefulWidget {
  late ViewmodelFilmbase viewmodelFilmBase;

  FilmsBlockDisplay({Key? key, required ViewmodelFilmbase viewmodel})
      : super(key: key) {}
  @override
  State createState() => FilmsBlockDisplayState();
}

class FilmsBlockDisplayState extends State<FilmsBlockDisplay> {
  late VideoBlockDisplay videoBlockDisplay;

  late GlobalKey controlButtonSeeMovie;
  late GlobalKey controlLoadSearchLinksWatch;

  @override
  void initState() {
    super.initState();
    this.videoBlockDisplay =
        VideoBlockDisplay(viewmodel: super.widget.viewmodelFilmBase);
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
          this.videoBlockDisplay,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
