import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/ViewModel_Acceuille.dart';

class ViewAcceuille extends StatefulWidget {
  @override
  State<ViewAcceuille> createState() => ViewAcceuilleState();
}

class ViewAcceuilleState extends State<ViewAcceuille> {
  late ViewmodelAcceuille viewmodelAcceuille;
  late List videosInList;
  late int countVideos;
  late int number_rows;
  late int number_videos_by_row;

  late FutureBuilder _future_builder;

  @override
  void initState() {
    super.initState();
    this.viewmodelAcceuille = ViewmodelAcceuille();
    this._future_builder = this.buildListViewWithData();
  }

  FutureBuilder buildListViewWithData() {
    return FutureBuilder(
        future: this.viewmodelAcceuille.getVideosOnTheLastTwelveMonths(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            this.videosInList = snapshot.data;
            this.countVideos = snapshot.data?.length;
            this.number_rows = (this.countVideos / 3).toInt() ?? 1;
            this.number_videos_by_row =
                this._getNumberVideosByRow(nb_total_videos: this.countVideos);

            return GridView.builder(
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return this._getCardVideo(index);
              },
              shrinkWrap: true,
            );
          } else {
            return CircularProgressIndicator(
              backgroundColor: Colors.white70,
              color: Colors.greenAccent,
              semanticsLabel: "Chargement",
              strokeCap: StrokeCap.round,
            );
          }
        });
  }

  Widget _getCardVideo(int iteration) {
    return Card(
      elevation: 10,
      child: Container(
        height: 100,
        color: Colors.transparent,
        child: Column(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                this.videosInList[iteration]["Lien_Affiche"],
                fit: BoxFit.cover,
                width: 80,
                height: 50,
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              readOnly: true,
              decoration: InputDecoration(
                  hintText: this.videosInList[iteration]["Titre"],
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

  int _getNumberVideosByRow({required int nb_total_videos}) {
    return nb_total_videos % 6 == 0 ? 3 : 2;
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
                      child: this._future_builder,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white),
                      child: Text("Réinitialiser la base de données"),
                      onPressed: () {},
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
