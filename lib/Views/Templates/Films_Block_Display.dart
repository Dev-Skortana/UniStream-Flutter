import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';
import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Classes_Implementation/Parameters_Get_Link_Watchs_Movie.dart';
import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Service_BoxDialog_WatchsResults.dart';

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
  ValueNotifier parametersGetLinkWatch = ValueNotifier(null);

  bool isActiveButtonSeeMovie = true;
  bool isVisibleCircularProgress = false;

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

  void buttonSeeFilmOnPressed() async {
    if (this.isVideosDipslayNotEmpty()) {
      if (this.isVisibleCircularProgress == false) {
        this.isVisibleCircularProgress = true;
        ParametersGetLinkWatchsMovie parameters = ParametersGetLinkWatchsMovie(
            super.widget.viewmodelFilmBase.video["Video"].titre);
        parameters.preparedParameters();
        this.parametersGetLinkWatch.value = parameters;
        final List<Map<String, String>> mapsWatchResult = await super
            .widget
            .viewmodelFilmBase
            .getManyResultLinkWatchOfVideo(
                {"titre_video": parameters.titre_video});
        showDialog(
            context: context,
            builder: (context) {
              return ServiceBoxdialogWatchsresults(
                  categorie: "Video_Film", mapsWatchResult: mapsWatchResult);
            });
        this.isVisibleCircularProgress = false;
        this.parametersGetLinkWatch.value = "";
      }
    }
  }

  bool isVideosDipslayNotEmpty() =>
      super.widget.viewmodelFilmBase.TotalCount > 0;

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
                    if (this.isVideosDipslayNotEmpty() == false) {
                      return Container();
                    }
                    return Container();
                  }),
            ],
          ),
          ValueListenableBuilder(
              valueListenable: this.parametersGetLinkWatch!,
              builder: (context, value, child) {
                if (this.isVideosDipslayNotEmpty()) {
                  return Column(
                    children: [
                      ElevatedButton(
                          key: this.controlButtonSeeMovie,
                          onPressed: this.isVisibleCircularProgress == false
                              ? () {
                                  this.buttonSeeFilmOnPressed();
                                }
                              : null,
                          child: Text("Voir le Film.")),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (this.isVisibleCircularProgress)
                            CircularProgressIndicator(
                                key: this.controlLoadSearchLinksWatch,
                                strokeWidth: 2)
                        ],
                      )
                    ],
                  );
                }
                return Container();
              }),
        ],
      ),
    );
  }
}
