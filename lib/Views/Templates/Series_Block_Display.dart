import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

class SeriesBlockDisplay extends StatefulWidget {
  late ViewmodelSeriebase viewmodelseriebase;
  SeriesBlockDisplay({Key? key, required ViewmodelSeriebase viewmodel})
      : super(key: key) {}
  @override
  State createState() => SeriesBlockDisplayState();
}

class SeriesBlockDisplayState extends State<SeriesBlockDisplay> {
  late VideoBlockDisplay videoBlockDisplay;

  late GlobalKey ControlSaison;
  late GlobalKey ControlEpisode;
  late GlobalKey ControlButtonSeeSerie;
  late GlobalKey ControlLoadSearchLinksWatch;

  @override
  void initState() {
    super.initState();
    this.videoBlockDisplay =
        VideoBlockDisplay(viewmodel: super.widget.viewmodelseriebase);
    this.initializeControlsSerie();
  }

  void initializeControlsSerie() {
    this.ControlSaison = GlobalKey();
    this.ControlEpisode = GlobalKey();
    this.ControlButtonSeeSerie = GlobalKey();
    this.ControlLoadSearchLinksWatch = GlobalKey();
  }

  List<int> getSaisonWithoutDoublons() {
    List<int> values = [];
    for (var detail in super
            .widget
            .viewmodelseriebase
            .GetGenerator_DetailSerieOfVideoSerie(
                super.widget.viewmodelseriebase.video["Video"].titre) ??
        []) {
      values.add(detail.saison);
    }
    return values.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          this.videoBlockDisplay,
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  spacing: 20,
                  children: [
                    DropdownMenu(
                      key: this.ControlSaison,
                      label: Text("Saison"),
                      hintText: "Choisissez la saison.",
                      dropdownMenuEntries: <DropdownMenuEntry>[
                        for (var saison in this.getSaisonWithoutDoublons())
                          DropdownMenuEntry(
                              value: saison, label: saison.toString())
                      ],
                      menuHeight: 100,
                      width: 200,
                      onSelected: (value) {},
                    ),
                    DropdownMenu(
                      key: this.ControlEpisode,
                      label: Text("Episode"),
                      hintText: "Choisissez l'épisode.",
                      dropdownMenuEntries: <DropdownMenuEntry>[],
                      menuHeight: 100,
                      width: 200,
                    ),
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
                    )
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
