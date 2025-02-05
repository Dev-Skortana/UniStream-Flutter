import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_VideoBase.dart';

class VideoBlockDisplay extends StatefulWidget {
  late ViewmodelVideobase viewmodelVideobase;
  VideoBlockDisplay({Key? key, required ViewmodelVideobase viewmodel})
      : super(key: key) {
    this.viewmodelVideobase = viewmodel;
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

  void _Value_Changed() {
    setState(() {});
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
                    super.widget.viewmodelVideobase.video["Video"].lienAffiche,
                    width: 200,
                    height: 150),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Titre :"),
                TextField(
                  key: this.controlLienAffiche,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText:
                        super.widget.viewmodelVideobase.video["Video"].titre,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Description :"),
                TextField(
                  key: this.controlDescription,
                  readOnly: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: super
                        .widget
                        .viewmodelVideobase
                        .video["Video"]
                        .description,
                    border: InputBorder.none,
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
                    super.widget.viewmodelVideobase.video["Video"].duree),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Date de parution :"),
                Text(
                    key: this.controlDateParution,
                    super.widget.viewmodelVideobase.video["Video"].dateParution)
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
                TextField(
                  key: this.controlGenres,
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: this._Unsplit([
                        for (var item in super
                            .widget
                            .viewmodelVideobase
                            .video["Video"]
                            .genres)
                          item.nom
                      ]),
                      border: InputBorder.none),
                  expands: true,
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
                  TextField(
                    key: this.controlRealisateurs,
                    readOnly: true,
                    decoration: InputDecoration(
                        hintText: this._Unsplit([
                          for (var item in super
                              .widget
                              .viewmodelVideobase
                              .video["Video"]
                              .realisateurs)
                            item.nom
                        ]),
                        border: InputBorder.none),
                    expands: true,
                  )
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Pays :"),
                    TextField(
                      key: this.controlPays,
                      readOnly: true,
                      decoration: InputDecoration(
                          hintText: this._Unsplit([
                            for (var item in super
                                .widget
                                .viewmodelVideobase
                                .video["Video"]
                                .pays)
                              item.nom
                          ]),
                          border: InputBorder.none),
                      expands: true,
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
                        super.widget.viewmodelVideobase.GetVideoFirst();
                        this._Value_Changed();
                      },
                    ),
                    ElevatedButton(
                      child: Text("<"),
                      onPressed: () {
                        super.widget.viewmodelVideobase.GetVideoPrevious();
                        this._Value_Changed();
                      },
                    ),
                    ElevatedButton(
                      child: Text(">"),
                      onPressed: () {
                        super.widget.viewmodelVideobase.GetVideoNext();
                        this._Value_Changed();
                      },
                    ),
                    ElevatedButton(
                      child: Text(">>"),
                      onPressed: () {
                        super.widget.viewmodelVideobase.GetVideoLast();
                        this._Value_Changed();
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
