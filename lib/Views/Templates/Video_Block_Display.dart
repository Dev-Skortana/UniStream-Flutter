import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unistream/Helpers/Duration_Util.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Features/Search_Data/Set_Search.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_VideoBase.dart';
import 'package:unistream/ViewModels/ViewModel_AnimeFilm.dart';
import 'package:unistream/ViewModels/ViewModel_AnimeSerie.dart';
import 'package:unistream/Views/View_Services/Service_Components_Search.dart';

class VideoBlockDisplay extends StatefulWidget {
  late ValueNotifier videoNotifier;

  late ViewmodelVideobase viewmodelVideobase;
  VideoBlockDisplay({
    Key? key,
    required ViewmodelVideobase viewmodel,
    required ValueNotifier video_notifier,
  }) : super(key: key) {
    this.viewmodelVideobase = viewmodel;
    this.videoNotifier = video_notifier;
  }

  @override
  State createState() => VideoBlockDisplayState();
}

class VideoBlockDisplayState extends State<VideoBlockDisplay> {
  late ValueNotifier fieldNotifier;
  late Iterable videosToDisplay;
  late bool isComponentSearchSecondaryVisible;
  late final bool hasAttributeStudio;

  late int index;

  @override
  void initState() {
    super.initState();

    this.videosToDisplay =
        super.widget.viewmodelVideobase.videosFromDictionnary; // à revoir !
    this.isComponentSearchSecondaryVisible = false;
    this.hasAttributeStudio = [ViewmodelAnimefilm, ViewmodelAnimeserie]
            .contains(super.widget.viewmodelVideobase.runtimeType)
        ? true
        : false;
    this.initializeControlsVideo();
  }

  void initializeControlsVideo() {}

  _value_Changed(VoidCallback callback_naviguation) {
    callback_naviguation();
    widget.videoNotifier.value = super.widget.viewmodelVideobase.video["Video"];
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
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                child: ServiceComponentsSearch(
                    fields_names:
                        super.widget.viewmodelVideobase.getFieldsSearch(),
                    function_getTypeOfFieldSelected:
                        this.widget.viewmodelVideobase.getTypeOfFieldSelected,
                    functionGetVideosOfSearch:
                        this.widget.viewmodelVideobase.GetVideosOfSearch,
                    videoNotifier: this.widget.videoNotifier),
              )
            ]),
            ValueListenableBuilder(
                valueListenable: widget.videoNotifier,
                builder: (context, value, child) {
                  if (this.isVideosDipslayNotEmpty() == false) {
                    return Container();
                  }
                  Video video = (value as Video);
                  return SizedBox(
                      height: 600,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 3,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (video.lienAffiche.isNotEmpty)
                                  Image.file(
                                    File(video.lienAffiche),
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 150,
                                  )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Titre :"),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    width: 300,
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      child: TextField(
                                        maxLines: null,
                                        minLines: null,
                                        decoration: InputDecoration(
                                            constraints: BoxConstraints(),
                                            hintText: video.titre,
                                            border: InputBorder.none),
                                        readOnly: true,
                                        expands: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text("Description :"),
                                        SizedBox(height: 5),
                                        SizedBox(
                                          width: 350,
                                          height: 100,
                                          child: Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    0, 43, 42, 41),
                                                border: Border.all(
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: SingleChildScrollView(
                                              child: TextField(
                                                maxLines: 200,
                                                readOnly: true,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                decoration: InputDecoration(
                                                  constraints: BoxConstraints(),
                                                  hintText:
                                                      video.description.trim(),
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Durée :"),
                                Text(DurationUtil.getDurationIntoString(
                                        video.duree) ??
                                    ""),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Date de parution :"),
                                Text(video.dateParution != null
                                    ? video.dateParution!
                                        .toIso8601String()
                                        .split("T")
                                        .first
                                    : "")
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: this.hasAttributeStudio
                                  ? [
                                      Text("Studio de réalisation :"),
                                      Text((super
                                              .widget
                                              .viewmodelVideobase
                                              .video["Video"])
                                          .studio)
                                    ]
                                  : [],
                            ),
                            Row(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Genre :"),
                                  Flexible(
                                    child: SizedBox(
                                      child: TextField(
                                        maxLines: null,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            constraints: BoxConstraints(),
                                            hintText: this._Unsplit([
                                              for (var item in video.genres)
                                                item.nom
                                            ]),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  )
                                ]),
                            Column(
                              spacing: 5,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Infos Additionnel : (en dessous !)")
                                    ]),
                                Row(
                                    spacing: 5,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Réalisateurs :"),
                                      Flexible(
                                        child: SizedBox(
                                          child: TextField(
                                            maxLines: null,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                constraints: BoxConstraints(),
                                                hintText: this._Unsplit([
                                                  for (var item
                                                      in video.realisateurs)
                                                    item.nom
                                                ]),
                                                border: InputBorder.none),
                                          ),
                                        ),
                                      )
                                    ]),
                                Row(
                                  spacing: 5,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Pays :"),
                                    Flexible(
                                      child: SizedBox(
                                        child: TextField(
                                          maxLines: null,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                              constraints: BoxConstraints(),
                                              hintText: this._Unsplit([
                                                for (var item in video.pays)
                                                  item.nom
                                              ]),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ]));
                }),
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
