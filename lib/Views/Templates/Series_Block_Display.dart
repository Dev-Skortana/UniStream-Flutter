import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

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
  late GlobalKey ControlSaison;
  late GlobalKey ControlEpisode;
  late GlobalKey ControlButtonSeeSerie;
  late GlobalKey ControlLoadSearchLinksWatch;

  late ValueNotifier<int> valueCurrentSaisonNotifier;

  SeriesBlockDisplayState() {}

  @override
  void initState() {
    super.initState();
    this.valueCurrentSaisonNotifier = ValueNotifier(0);
    this.initializeControlsSerie();
  }

  void initializeControlsSerie() {
    this.ControlSaison = GlobalKey();
    this.ControlEpisode = GlobalKey();
    this.ControlButtonSeeSerie = GlobalKey();
    this.ControlLoadSearchLinksWatch = GlobalKey();
  }

  void resetItemsInDropdows() {
    if (this.ControlSaison.currentWidget != null) {
      (this.ControlSaison.currentWidget as DropdownMenu)
          .dropdownMenuEntries
          .clear;
    }
    if (this.ControlEpisode.currentWidget != null) {
      (this.ControlEpisode.currentWidget as DropdownMenu)
          .dropdownMenuEntries
          .clear;
    }
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

  List<int> getEpisodesOfSaison({required String titre}) {
    List<int> values = [];
    for (var detail in super
            .widget
            .viewmodelseriebase
            .GetGenerator_DetailSerieOfVideoSerie(titre) ??
        []) {
      if (int.parse(detail.saison.toString()) ==
          this.valueCurrentSaisonNotifier!.value) {
        values.add(int.parse(detail.episode.toString()));
      }
    }
    return values;
  }

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
                          //resetItemsInDropdows();

                          return DropdownMenu(
                            key: this.ControlSaison,
                            label: Text("Saison"),
                            hintText: "Choisissez la saison.",
                            dropdownMenuEntries: <DropdownMenuEntry>[
                              for (var saison in this
                                  .getSaisonWithoutDoublons(titre: value.titre))
                                DropdownMenuEntry(
                                    value: saison, label: saison.toString())
                            ],
                            menuHeight: 100,
                            width: 200,
                            onSelected: (value) {
                              this.valueCurrentSaisonNotifier!.value =
                                  int.parse(value.toString());
                            },
                          );
                        }),
                    ValueListenableBuilder(
                        valueListenable: this.valueCurrentSaisonNotifier,
                        builder: (context, value, child) {
                          if (value > 0) {
                            return DropdownMenu(
                              key: this.ControlEpisode,
                              label: Text("Episode"),
                              hintText: "Choisissez l'épisode.",
                              dropdownMenuEntries: <DropdownMenuEntry>[
                                for (var episode
                                    in this.valueCurrentSaisonNotifier?.value !=
                                            null
                                        ? this.getEpisodesOfSaison(
                                            titre: super
                                                .widget
                                                .viewmodelseriebase
                                                .video["Video"]
                                                .titre)
                                        : [])
                                  DropdownMenuEntry(
                                      value: episode, label: episode.toString())
                              ],
                              menuHeight: 100,
                              width: 200,
                            );
                          } else {
                            return Container();
                          }
                        }),
                    ElevatedButton(
                        key: this.ControlButtonSeeSerie,
                        onPressed: () {},
                        child: Text("Voir cette épisode de la série.")),
                    Container(
                      margin: EdgeInsets.fromLTRB(115, 0, 0, 0),
                      child: Row(
                        children: [
                          CircularProgressIndicator(
                              key: this.ControlLoadSearchLinksWatch,
                              strokeWidth: 2)
                        ],
                      ),
                    ),
                    Text((widget.viewmodelseriebase.video["Video"] as Video)
                        .titre)
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
