import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_VideoBase.dart';

class VideoBlockDisplay extends StatefulWidget {
  late Function valueTopViewChanged;
  late Function valueBlockChanged;
  late ViewmodelVideobase viewmodelVideobase;
  VideoBlockDisplay(
      {Key? key,
      required ViewmodelVideobase viewmodel,
      required Function value_changed_of_view_specialized,
      required Function value_changed_of_block})
      : super(key: key) {
    this.viewmodelVideobase = viewmodel;
    this.valueBlockChanged = value_changed_of_block;
    this.valueTopViewChanged = value_changed_of_view_specialized;
  }

  @override
  State createState() => VideoBlockDisplayState();
}

class VideoBlockDisplayState extends State<VideoBlockDisplay> {
  late Map<String, dynamic> videosToDisplay;
  late bool isComponentSearchSecondaryVisible;
  late bool hasAttributeStudio;

  late int index;

  late GlobalKey controlStudio;

  late GlobalKey controlDropdownFieldSearch;
  late GlobalKey controlContainerComposantsSearch;
  late GlobalKey controlContainerComposantsFilter;
  late GlobalKey controlLienAffiche;
  late GlobalKey controlTitre;
  late GlobalKey controlDescription;
  late GlobalKey controlDuree;
  late GlobalKey controlDateParution;
  late GlobalKey controlGenres;
  late GlobalKey controlRealisateurs;
  late GlobalKey controlPays;

  late GlobalKey controlButtonFirst;
  late GlobalKey controlButtonPrevious;
  late GlobalKey controlPagination;
  late GlobalKey controlButtonLast;
  late GlobalKey controlButtonNext;

  @override
  void initState() {
    super.initState();
    this.videosToDisplay = super.widget.viewmodelVideobase.video;
    this.isComponentSearchSecondaryVisible = false;
    this.hasAttributeStudio = false;
    this.initializeControlsVideo();
  }

  void initializeControlsVideo() {
    this.controlDropdownFieldSearch = GlobalKey();

    this.controlContainerComposantsSearch = GlobalKey();
    this.controlContainerComposantsFilter = GlobalKey();

    this.controlLienAffiche = GlobalKey();
    this.controlTitre = GlobalKey();
    this.controlDescription = GlobalKey();
    this.controlDuree = GlobalKey();
    this.controlDateParution = GlobalKey();
    this.controlGenres = GlobalKey();
    this.controlRealisateurs = GlobalKey();
    this.controlPays = GlobalKey();

    this.controlButtonFirst = GlobalKey();
    this.controlButtonPrevious = GlobalKey();
    this.controlPagination = GlobalKey();
    this.controlButtonLast = GlobalKey();
    this.controlButtonNext = GlobalKey();
  }

  _value_Changed(VoidCallback callback_naviguation) {
    setState(() {
      callback_naviguation();
      widget.valueBlockChanged();
      widget.valueTopViewChanged();
    });
  }

  bool isVideosDipslayNotEmpty() =>
      super.widget.viewmodelVideobase.TotalCount > 0;

  String _Unsplit(List? words) {
    String chaine = "";
    if (words != null) {
      for (int iteration = 0; iteration < words.length; iteration++) {
        String separateur = (iteration + 1) < words.length ? "," : "";
        chaine += "${words[iteration]} ${separateur}";
      }
    }
    return chaine;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                child: Row(
                  children: [
                    DropdownMenu(
                      key: this.controlDropdownFieldSearch,
                      dropdownMenuEntries: <DropdownMenuEntry>[],
                      width: 110,
                    ),
                    Container(
                      key: this.controlContainerComposantsSearch,
                      child: Column(),
                    ),
                    Container(
                      key: this.controlContainerComposantsFilter,
                      child: Row(),
                    ),
                  ],
                ),
              )
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                    key: this.controlLienAffiche,
                    (super.widget.viewmodelVideobase.video["Video"] as Video)
                        .lienAffiche,
                    width: 200,
                    height: 150),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Titre :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: this.controlTitre,
                    decoration: InputDecoration(
                        constraints: BoxConstraints(),
                        hintText: (super
                                .widget
                                .viewmodelVideobase
                                .video["Video"] as Video)
                            .titre,
                        border: InputBorder.none),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Description :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: this.controlDescription,
                    readOnly: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                        constraints: BoxConstraints(),
                        hintText: (super
                                .widget
                                .viewmodelVideobase
                                .video["Video"] as Video)
                            .description,
                        border: InputBorder.none),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Durée :"),
                Text(
                    key: this.controlDuree,
                    super
                        .widget
                        .viewmodelVideobase
                        .video["Video"]
                        .duree
                        .toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Date de parution :"),
                Text(
                    key: this.controlDateParution,
                    super
                        .widget
                        .viewmodelVideobase
                        .video["Video"]
                        .dateParution
                        .toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: this.hasAttributeStudio
                  ? [
                      Text("Studio de réalisation :"),
                      Text(
                          key: this.controlStudio,
                          super.widget.viewmodelVideobase.video["Video"].studio)
                    ]
                  : [],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Genre :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: this.controlGenres,
                    readOnly: true,
                    decoration: InputDecoration(
                        constraints: BoxConstraints(),
                        hintText: this._Unsplit([
                          for (var item in super
                                  .widget
                                  .viewmodelVideobase
                                  .video["Video"]
                                  .genres ??
                              [])
                            item.nom
                        ]),
                        border: InputBorder.none),
                    expands: false,
                  ),
                )
              ],
            ),
            Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Infos Additionnel : (en dessous !)")]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Réalisateurs :"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: this.controlRealisateurs,
                      readOnly: true,
                      decoration: InputDecoration(
                          constraints: BoxConstraints(),
                          hintText: this._Unsplit([
                            for (var item in super
                                    .widget
                                    .viewmodelVideobase
                                    .video["Video"]
                                    .realisateurs ??
                                [])
                              item.nom
                          ]),
                          border: InputBorder.none),
                      expands: false,
                    ),
                  )
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Pays :"),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        key: this.controlPays,
                        readOnly: true,
                        decoration: InputDecoration(
                            constraints: BoxConstraints(),
                            hintText: this._Unsplit([
                              for (var item in super
                                      .widget
                                      .viewmodelVideobase
                                      .video["Video"]
                                      .pays ??
                                  [])
                                item.nom
                            ]),
                            border: InputBorder.none),
                        expands: false,
                      ),
                    )
                  ],
                ),
              ],
            ),
            Column(
              spacing: 15,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text("<<"),
                      onPressed: () {
                        this._value_Changed(
                            super.widget.viewmodelVideobase.GetVideoFirst);
                      },
                    ),
                    ElevatedButton(
                      child: Text("<"),
                      onPressed: () {
                        this._value_Changed(
                            super.widget.viewmodelVideobase.GetVideoPrevious);
                      },
                    ),
                    ElevatedButton(
                      child: Text(">"),
                      onPressed: () {
                        this._value_Changed(
                            super.widget.viewmodelVideobase.GetVideoNext);
                      },
                    ),
                    ElevatedButton(
                      child: Text(">>"),
                      onPressed: () {
                        this._value_Changed(
                            super.widget.viewmodelVideobase.GetVideoLast);
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ));
  }
}
