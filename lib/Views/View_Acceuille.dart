import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/ViewModel_Acceuille.dart';

class ViewAcceuille extends StatefulWidget {
  @override
  State<ViewAcceuille> createState() => ViewAcceuilleState();
}

class ViewAcceuilleState extends State<ViewAcceuille> {
  late ViewmodelAcceuille viewmodelAcceuille;

  @override
  void initState() {
    super.initState();

    this.test();
  }

  void test() {
    var viewmodelAcceuill = ViewmodelAcceuille();
    const String chaine_condition =
        "where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')";
    const String chaine_order = "order by Videos.Titre asc";
    viewmodelAcceuill.r(chaine_condition, chaine_order).then((values) {
      for (var item in values) {
        print(item);
      }
    });
  }

  List<Widget> _getColumnsWithTheirRows() {
    final int number_total_videos = 12;
    final int number_rows = int.tryParse("${(number_total_videos / 4)}") ?? 3;
    final int number_videos_by_row =
        this._getNumberVideosByRow(nb_total_videos: number_total_videos);
    int iteration_global = 0;
    int iteration_row = 0;

    List<Widget> controls = [];
    while (
        iteration_row < number_rows || iteration_global < number_total_videos) {
      final Row row = Row(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this._getCardsVideosOfRow(
            number_total_videos: number_total_videos,
            number_videos_by_row: number_videos_by_row,
            iteration_global: iteration_global),
      );
      final Column column = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [row],
      );
      iteration_global = iteration_global + row.children.length;
      controls.add(column);
      iteration_row += 1;
    }
    return controls;
  }

  List<Card> _getCardsVideosOfRow(
      {required int number_total_videos,
      required int number_videos_by_row,
      required int iteration_global}) {
    List<Card> controls = [];
    for (int iteration_cellule = 0;
        iteration_cellule < number_videos_by_row;
        iteration_cellule++) {
      if (iteration_global < number_total_videos) {
        controls.add(this._getCardVideo());
        iteration_global += 1;
      }
    }
    return controls;
  }

  Card _getCardVideo() {
    return Card(
      elevation: 10,
      shadowColor: Colors.red,
      surfaceTintColor: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        height: 200,
        width: 100,
        child: Column(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                "assets/images/video_posters/1529636559_persona-5-the-animation-vostfr-ddl.jpg",
                fit: BoxFit.cover,
                width: 80,
                height: 50,
              ),
            ),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                  hintText: "Title vidéo",
                  border: InputBorder.none,
                  fillColor: Colors.tealAccent),
            ),
            FloatingActionButton.extended(
              backgroundColor: Colors.white38,
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
    return nb_total_videos % 6 == 0 ? 6 : 5;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Column(
          children: [
            Text("UniStream la bibliothéque des cinéphiles"),
            ListTile(
              leading: Icon(Icons.personal_video),
              title: Text("Derniers publications"),
              subtitle: Text("de ces 12 derniers mois ..."),
            ),
            Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: this._getColumnsWithTheirRows(),
                      ),
                    )
                  ]),
            ),
            ElevatedButton(
              child: Text("Réinitialiser la base de données"),
              onPressed: () {},
            )
          ],
        )
      ],
    ));
  }
}
