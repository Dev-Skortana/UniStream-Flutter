import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';
import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Classes_Implementation/Parameters_Get_Link_Watchs_Series.dart';
import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Service_BoxDialog_WatchsResults.dart';

class SeriesBlockDisplay extends StatefulWidget {
  late ValueNotifier videoNotifier;
  late ViewmodelSeriebase viewmodelseriebase;
  SeriesBlockDisplay(
      {Key? key,
      required ViewmodelSeriebase viewmodel,
      required ValueNotifier video_notifier})
      : super(key: key) {
    this.viewmodelseriebase = viewmodel;
    this.videoNotifier = video_notifier;
  }

  @override
  State createState() => SeriesBlockDisplayState();
}

class SeriesBlockDisplayState extends State<SeriesBlockDisplay> {
  ValueNotifier parametersGetLinkWatch = ValueNotifier(null);

  int valueSaison = 0;
  int valueEpisode = 0;

  bool isVisibleCircularProgress = false;

  late GlobalKey ControlSaison;
  late GlobalKey ControlEpisode;
  late GlobalKey ControlButtonSeeSerie;
  late GlobalKey ControlLoadSearchLinksWatch;

  SeriesBlockDisplayState() {}

  @override
  void initState() {
    super.initState();
    this.initializeControlsSerie();
  }

  void initializeControlsSerie() {
    this.ControlSaison = GlobalKey();
    this.ControlEpisode = GlobalKey();
    this.ControlButtonSeeSerie = GlobalKey();
    this.ControlLoadSearchLinksWatch = GlobalKey();
  }

  List<int> getSaisonWithoutDoublons({required String titre}) {
    List<int> values = [];
    for (var detail in super
            .widget
            .viewmodelseriebase
            .GetGenerator_DetailSerieOfVideoSerie(titre) ??
        []) {
      values.add(detail.saison);
    }
    return values.toSet().toList();
  }

  List<int> getEpisodesOfSaison(
      {required String titre, int currentSaison = 0}) {
    List<int> values = [];
    if (currentSaison > 0) {
      for (var detail in super
              .widget
              .viewmodelseriebase
              .GetGenerator_DetailSerieOfVideoSerie(titre) ??
          []) {
        if (int.parse(detail.saison.toString()) == currentSaison) {
          values.add(int.parse(detail.episode.toString()));
        }
      }
    }
    return values;
  }

  void buttonSeeSerieOnPressed() async {
    if (this.isVideosDipslayNotEmpty()) {
      if (this.isVisibleCircularProgress == false) {
        this.isVisibleCircularProgress = true;

        ParametersGetLinkWatchsSeries parameters =
            ParametersGetLinkWatchsSeries(
                titreVideo:
                    super.widget.viewmodelseriebase.video["Video"].titre,
                saison: this.valueSaison.toString(),
                episode: this.valueEpisode.toString());
        parameters.preparedParameters();
        this.parametersGetLinkWatch.value = parameters;
        final List<Map<String, String>> mapsWatchResult = await super
            .widget
            .viewmodelseriebase
            .getManyResultLinkWatchOfVideo({
          "titre_video": parameters.titreVideo,
          "saison": parameters.saison.toString(),
          "episode": parameters.episode.toString()
        });
        showDialog(
            context: context,
            builder: (context) {
              return ServiceBoxdialogWatchsresults(
                  categorie: "Video_Serie",
                  mapsWatchResult: mapsWatchResult,
                  episode_into_caracteres: parameters.episode.toString());
            });
        this.isVisibleCircularProgress = false;
        this.parametersGetLinkWatch.value = "";
      }
    }
  }

  bool isVideosDipslayNotEmpty() =>
      super.widget.viewmodelseriebase.TotalCount > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          VideoBlockDisplay(
              viewmodel: widget.viewmodelseriebase,
              video_notifier: widget.videoNotifier),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  spacing: 20,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: widget.videoNotifier,
                        builder: (context, value, child) {
                          if (this.isVideosDipslayNotEmpty() == false) {
                            return Container();
                          }
                          final List<int> saisons =
                              this.getSaisonWithoutDoublons(titre: value.titre);
                          final List<int> episodes = this.getEpisodesOfSaison(
                              titre: super
                                  .widget
                                  .viewmodelseriebase
                                  .video["Video"]
                                  .titre,
                              currentSaison: this.valueSaison);

                          final DropdownMenu dropdownsaisons = DropdownMenu(
                            key: this.ControlSaison,
                            label: Text("Saison"),
                            hintText: "Choisissez la saison.",
                            dropdownMenuEntries: <DropdownMenuEntry>[
                              for (var saison in saisons)
                                DropdownMenuEntry(
                                    value: saison, label: saison.toString())
                            ],
                            menuHeight: 100,
                            width: 200,
                            onSelected: (value) {
                              setState(() {
                                this.valueSaison = int.parse(value.toString());
                              });
                            },
                          );

                          final DropdownMenu dropdownepisodes = DropdownMenu(
                            key: this.ControlEpisode,
                            label: Text("Episode"),
                            dropdownMenuEntries: [
                              for (var episode in episodes)
                                DropdownMenuEntry(
                                    value: episode, label: episode.toString())
                            ],
                            menuHeight: 100,
                            width: 200,
                            onSelected: (value) {
                              setState(() {
                                this.valueEpisode = int.parse(value.toString());
                              });
                            },
                          );

                          return Column(
                            spacing: 5,
                            children: [dropdownsaisons, dropdownepisodes],
                          );
                        }),
                    ValueListenableBuilder(
                        valueListenable: this.parametersGetLinkWatch,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              ElevatedButton(
                                  key: this.ControlButtonSeeSerie,
                                  onPressed:
                                      this.isVisibleCircularProgress == false
                                          ? () {
                                              this.buttonSeeSerieOnPressed();
                                            }
                                          : null,
                                  child:
                                      Text("Voir cette épisode de la série.")),
                              Container(
                                margin: EdgeInsets.fromLTRB(115, 0, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (this.isVisibleCircularProgress)
                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(0, 0, 110, 0),
                                        child: CircularProgressIndicator(
                                            key: this
                                                .ControlLoadSearchLinksWatch,
                                            strokeWidth: 2),
                                      )
                                  ],
                                ),
                              )
                            ],
                          );
                        }),
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
