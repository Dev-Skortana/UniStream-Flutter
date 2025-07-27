import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/ViewModels/ViewModel_Acceuille.dart';
import 'package:unistream/Views/Helpers/Theme_Provider.dart';
import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Service_BoxDialog_WatchsResults.dart';

class ViewAcceuille extends StatefulWidget {
  @override
  State<ViewAcceuille> createState() => ViewAcceuilleState();
}

class ViewAcceuilleState extends State<ViewAcceuille> {
  late ViewmodelAcceuille viewmodelAcceuille;
  late StreamBuilder componentsWithData;

  ValueNotifier<bool> isVisibleBarProgress = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    this.viewmodelAcceuille = ViewmodelAcceuille();
    //this.componentsWithData = this.buildComponentsWithData();
  }

  StreamBuilder buildComponentsWithData() {
    return StreamBuilder(
        stream: this.viewmodelAcceuille.getVideosOnTheLastTwelveMonths(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Iterator<Map<String, dynamic>> video_iterator = snapshot.data;
            if (video_iterator.moveNext()) {
              List<Widget> cards = [];
              cards.add(this._getCardVideo(video_iterator.current));
              while (video_iterator.moveNext()) {
                cards.add(this._getCardVideo(video_iterator.current));
              }
              return GridView.count(
                physics: ScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                children: cards,
              );
            }
            return Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Aucune videos datant de moins 1 ans"),
                Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                )
              ],
            );
          }
          return Container();
        });
  }

  Widget _getCardVideo(Map<String, dynamic> data) {
    return Card(
      elevation: 10,
      shadowColor: Colors.red,
      surfaceTintColor: Colors.transparent,
      child: Container(
        height: 100,
        color: Colors.transparent,
        child: Column(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                child: Image.file(
              File(data["Lien_Affiche"]),
              fit: BoxFit.cover,
              width: 80,
              height: 50,
            )),
            Flexible(
              child: TextField(
                minLines: null,
                maxLines: null,
                textAlign: TextAlign.center,
                readOnly: true,
                decoration: InputDecoration(
                    hintText: data["Titre"],
                    border: InputBorder.none,
                    fillColor: Colors.tealAccent),
                expands: true,
              ),
            ),
            FloatingActionButton.extended(
              elevation: 10,
              disabledElevation: 0,
              backgroundColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .surface,
              foregroundColor: Colors.white70,
              label: Text(data.containsKey("Titre_Serie") ? "Serie" : "Film"),
              icon: const Icon(Icons.ondemand_video_sharp),
              onPressed: this.isVisibleBarProgress.value == false
                  ? () async {
                      await this.buttonSeeVideoPressed(data);
                    }
                  : null,
            )
          ],
        ),
      ),
    );
  }

  Future<void> buttonSeeVideoPressed(Map<String, dynamic> map_video) async {
    if (this.isVisibleBarProgress.value == false) {
      setState(() {
        this.isVisibleBarProgress.value = true;
      });

      Map<String, String> arguments_to_pass = {
        "titre_video": map_video["Titre"]
      };
      arguments_to_pass.addAll(map_video.containsKey("Titre_Serie")
          ? {"saison": "1", "episode": "1"}
          : {});
      final List<Map<String, String>> mapsWatchResult = await this
          .viewmodelAcceuille
          .getManyResultLinkWatchOfVideo({...arguments_to_pass});
      ;
      final String categorie_video =
          map_video.containsKey("Titre_Serie") ? "Video_Serie" : "Video_Film";
      this.showDialogForDisplayResultLinks(categorie_video, mapsWatchResult);
    }
    setState(() {
      this.isVisibleBarProgress.value = false;
    });
  }

  Future<void> showDialogForDisplayResultLinks(
      String categorie_video, List<Map<String, String>> mapsWatchResult) async {
    showDialog(
        context: context,
        builder: (context) {
          return ServiceBoxdialogWatchsresults(
              categorie: categorie_video,
              mapsWatchResult: mapsWatchResult,
              episode_into_caracteres:
                  categorie_video == "Video_Serie" ? "1" : "");
        });
  }

  Future<void> showDialogIsConfirmDeleteData() async {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Demande de confirmation"),
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        "La base de données sera réinitialiser.\nLes affiches seront aussi supprimer.\n\nVoulez vous continuer ?"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    onPressed: () async {
                      await this.viewmodelAcceuille.rebootDatabase();
                      await this.deleteFilesimages();
                      Navigator.of(context).pop();
                      this.showDialogDataDeletedConfirmed();
                    },
                    child: Text("Supprimer les données")),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text("Annuler")),
              ],
              elevation: 24.0,
            ));
  }

  Future<void> deleteFilesimages() async {
    List<Future> tasks = List.empty(growable: true);
    Directory folder_pictures =
        await ManagerOfLocationFolderFileOfApp.getFolderPictures();
    Iterable<FileSystemEntity> files_pictures_dowloaded = folder_pictures
        .listSync()
        .where((file_fetch) =>
            !file_fetch.path.endsWith("visuals-NotFound-unsplash.jpg"));

    for (var file in files_pictures_dowloaded) {
      tasks.add(file.delete());
    }
    await Future.wait(tasks);
  }

  Future<void> showDialogDataDeletedConfirmed() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Confirmation"),
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        "La base de données à été réinitialiser\n avec succès !"),
                    Icon(Icons.check)
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok")),
              ],
              elevation: 24.0,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("UniStream la bibliothéque des cinéphiles"),
          ListTile(
            leading: Icon(Icons.personal_video),
            title: Text("Derniers publications"),
            subtitle: Text("de ces 12 derniers mois ..."),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 530,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 43, 42, 41),
                      border: Border.all(
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: this.buildComponentsWithData(),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                if (this.isVisibleBarProgress.value)
                  Row(children: [
                    Expanded(
                      child: SizedBox(
                          height: 5,
                          child: LinearProgressIndicator(
                            color: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .surface,
                            backgroundColor: Colors.white70,
                          )),
                    )
                  ]),
                SizedBox(
                  height: 25,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(foregroundColor: Colors.white),
                    child: Text("Réinitialiser la base de données"),
                    onPressed: () {
                      this.showDialogIsConfirmDeleteData();
                    },
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}
