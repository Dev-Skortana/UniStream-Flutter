import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';
import 'package:unistream/Views/Templates/Video_Block_Display.dart';

class SeriesBlockDisplay extends StatefulWidget {
  Function? valueChangedOfTopView;
  late ViewmodelSeriebase viewmodelseriebase;
  SeriesBlockDisplay(
      {Key? key,
      required ViewmodelSeriebase viewmodel,
      required Function value_changed_topview})
      : super(key: key) {
    this.viewmodelseriebase = viewmodel;
    this.valueChangedOfTopView = value_changed_topview;
  }

  @override
  State createState() => SeriesBlockDisplayState();
}

class SeriesBlockDisplayState extends State<SeriesBlockDisplay> {
  Function? valueChangedOfThisBlock;
  late GlobalKey ControlSaison;
  late GlobalKey ControlEpisode;
  late GlobalKey ControlButtonSeeSerie;
  late GlobalKey ControlLoadSearchLinksWatch;

  late int valueCurrentSaison;

  SeriesBlockDisplayState() {
    this.valueChangedOfThisBlock = () {
      setState(() {});
    };
  }

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

  List<int> getEpisodesOfSaison() {
    List<int> values = [];
    for (var detail in super
            .widget
            .viewmodelseriebase
            .GetGenerator_DetailSerieOfVideoSerie(
                super.widget.viewmodelseriebase.video["Video"].titre) ??
        []) {
      if (int.parse(detail.saison.toString()) == this.valueCurrentSaison) {
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
              value_changed_of_view_specialized: widget.valueChangedOfTopView!,
              value_changed_of_block: this.valueChangedOfThisBlock!),
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
                      onSelected: (value) {
                        setState(() {
                          this.valueCurrentSaison = int.parse(value.toString());
                        });
                      },
                    ),
                    DropdownMenu(
                      key: this.ControlEpisode,
                      label: Text("Episode"),
                      hintText: "Choisissez l'épisode.",
                      dropdownMenuEntries: <DropdownMenuEntry>[
                        for (var episode in this.getEpisodesOfSaison())
                          DropdownMenuEntry(
                              value: episode, label: episode.toString())
                      ],
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
