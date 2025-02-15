import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

class FilmsBlockDisplay extends StatefulWidget {
  Function? value_changed_of_topview;
  late ViewmodelFilmbase viewmodelFilmBase;

  FilmsBlockDisplay(
      {Key? key,
      required ViewmodelFilmbase viewmodel,
      required Function value_changed_of_topview})
      : super(key: key) {
    this.viewmodelFilmBase = viewmodel;
    this.value_changed_of_topview = value_changed_of_topview;
  }

  @override
  State createState() => FilmsBlockDisplayState();
}

class FilmsBlockDisplayState extends State<FilmsBlockDisplay> {
  Function? valueChangedOfThis;
  late VideoBlockDisplay videoBlockDisplay;

  late GlobalKey controlButtonSeeMovie;
  late GlobalKey controlLoadSearchLinksWatch;

  FilmsBlockDisplayState() {
    this.valueChangedOfThis = () {
      setState(() {});
    };
  }

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
              value_changed_of_view_specialized:
                  widget.value_changed_of_topview!,
              value_changed_of_block: this.valueChangedOfThis!),
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
