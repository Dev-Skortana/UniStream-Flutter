import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/ViewModels/ViewModel_Acceuille.dart';

class ViewAcceuille extends StatefulWidget {
  @override
  State<ViewAcceuille> createState() => ViewAcceuilleState();
}

class ViewAcceuilleState extends State<ViewAcceuille> {
  late ViewmodelAcceuille viewmodelAcceuille;
  late StreamBuilder componentsWithData;

  @override
  void initState() {
    super.initState();
    this.viewmodelAcceuille = ViewmodelAcceuille();
    this.componentsWithData = this.buildComponentsWithData();
  }

  StreamBuilder buildComponentsWithData() {
    return StreamBuilder(
        stream: this.viewmodelAcceuille.getVideosOnTheLastTwelveMonths(),
        builder: (context, snaphot) {
          if (!snaphot.hasData) {
            return CircularProgressIndicator();
          }
          Iterator<Map<String, dynamic>> video_iterator = snaphot.data;
          List<Widget> cards = [];
          while (video_iterator.moveNext()) {
            cards.add(this._getCardVideo(video_iterator.current));
          }
          return GridView.count(
            physics: ScrollPhysics(),
            crossAxisCount: 2,
            shrinkWrap: true,
            children: cards,
          );
        });
  }

  /*
  void doasync() async {
    List<Widget> list_children = [];

    while (await this.iterat.moveNext()) {
      list_children.add(this._getCardVideo(iterat.current));
      print(iterat.current);
    }
    this.setstate_comp(list_children);
  }
  */
  /*
  void setstate_comp(List<Widget> liste) {
    setState(() => this.list_children_of_griview = liste);
  }
  */

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
              child: Image.asset(
                data["Lien_Affiche"],
                fit: BoxFit.cover,
                width: 80,
                height: 50,
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              readOnly: true,
              decoration: InputDecoration(
                  hintText: data["Titre"],
                  border: InputBorder.none,
                  fillColor: Colors.tealAccent),
            ),
            FloatingActionButton.extended(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white70,
              label: Text("Voir"),
              icon: Icon(Icons.videocam),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
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
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.darken,
                  color: Colors.transparent),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: this.componentsWithData,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white),
                      child: Text("Réinitialiser la base de données"),
                      onPressed: () {
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: Text("Demande de confirmation"),
                                  content: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                        onPressed: () {},
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
                      },
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
