import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/ViewModel_AnimeFilm.dart';
import 'package:unistream/ViewModels/ViewModel_AnimeSerie.dart';
import 'package:unistream/Views/Templates/Dropdown_Onglets.dart';
import 'package:unistream/Views/Templates/Films_Block_Display.dart';
import 'package:unistream/Views/Templates/Pagination_Display.dart';
import 'package:unistream/Views/Templates/Series_Block_Display.dart';

class ViewAnimer extends StatefulWidget {
  const ViewAnimer({super.key});

  @override
  State<ViewAnimer> createState() => ViewAnimerState();
}

enum EnumCategorieVideoToDisplay { Video_Film, Video_Serie }

class ViewAnimerState extends State<ViewAnimer> {
  late FutureBuilder view_to_display;
  EnumCategorieVideoToDisplay? videoCategorie;
  ViewmodelAnimeserie? viewmodel_anime_serie;
  ViewmodelAnimefilm? viewmodel_anime_film;

  @override
  void initState() {
    super.initState();
    this.videoCategorie = EnumCategorieVideoToDisplay.Video_Film;
  }

  // Ces deux méthodes du dessous devront étre retravailler ! ! !

  FutureBuilder getDataOfMovies() => FutureBuilder(
      future: ViewmodelAnimefilm.create(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          print("Movies");
          try {
            this.viewmodel_anime_film = snapshot.data;
          } on TypeError catch (e) {
            print("TypeError on DataofMovies");
          }
          Function valueChanged_data_OfThisTopView = () {
            setState(() {});
          };
          return FilmsBlockDisplay(
            viewmodel: this.viewmodel_anime_film!,
            value_changed_of_topview: valueChanged_data_OfThisTopView,
          );
        }
      });

  FutureBuilder getDataOfSeries() => FutureBuilder(
      future: ViewmodelAnimeserie.create(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          print("Series");
          try {
            this.viewmodel_anime_serie = snapshot.data;

            Function valueChanged_data_OfThisTopView = () {
              setState(() {});
            };
            return SeriesBlockDisplay(
              viewmodel: this.viewmodel_anime_serie!,
              value_changed_topview: valueChanged_data_OfThisTopView,
            );
          } on TypeError catch (e) {
            print('TypeError on DataofSeries');
          }
          return Container();
        }
      });

  valueChangedCategorie(EnumCategorieVideoToDisplay new_categorie) {
    setState(() {
      this.videoCategorie = new_categorie;
    });
  }

  void _dropdown_change(event) {
    this.valueChangedCategorie(
        EnumCategorieVideoToDisplay.values.byName(event.toString()));
  }

  @override
  Widget build(BuildContext context) {
    if (videoCategorie == EnumCategorieVideoToDisplay.Video_Serie) {
      this.view_to_display = this.getDataOfSeries();
    }
    if (videoCategorie == EnumCategorieVideoToDisplay.Video_Film) {
      this.view_to_display = this.getDataOfMovies();
    }
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topRight,
              child: DropdownOnglets((event) => this._dropdown_change(event)),
            ),
            this.view_to_display,
            PaginationDisplay()
          ],
        ),
      ),
    );
    ;
  }
}
