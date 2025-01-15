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
  int iteration_global = 0;
  int iteration_row = 0;

  @override
  void initState() {
    super.initState();
    this.viewmodelAcceuille = ViewmodelAcceuille();
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

            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                if (this.iteration_row < this.number_rows ||
                    this.iteration_global < this.countVideos) {
                  final Row row = Row(
                    spacing: 0,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: this._getCardsVideosOfRow(
                      number_total_videos: this.countVideos,
                      number_videos_by_row: this.number_videos_by_row,
                      iteration_global: this.iteration_global,
                      index: index,
                    ),
                  );
                  final Column column = Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [row],
                  );
                  this.iteration_global =
                      this.iteration_global + row.children.length;
                  this.iteration_row += 1;

                  return column;
                }
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

  List<Widget> _getCardsVideosOfRow(
      {required int number_total_videos,
      required int number_videos_by_row,
      required int iteration_global,
      required int index}) {
    List<Widget> controls = [];
    for (int iteration_cellule = 0;
        iteration_cellule < number_videos_by_row;
        iteration_cellule++) {
      if (iteration_global < number_total_videos) {
        controls.add(this._getCardVideo(iteration_global));
        iteration_global += 1;
      }
    }
    return controls;
  }

  Widget _getCardVideo(int iteration) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey,
      surfaceTintColor: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        height: 150,
        width: 80,
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
              backgroundColor: Colors.white54,
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
    return SingleChildScrollView(
        child: Container(
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
                    child: this.buildListViewWithData(),
                  ),
                ]),
          ),
          ElevatedButton(
            child: Text("Réinitialiser la base de données"),
            onPressed: () {},
          )
        ],
      ),
    ));
  }
}
