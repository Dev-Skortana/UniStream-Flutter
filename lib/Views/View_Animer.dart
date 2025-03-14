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
  ValueNotifier? videoNotifier;
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
          this.videoNotifier =
              ValueNotifier(this.viewmodel_anime_film!.video["Video"]);

          return Column(
            children: [
              FilmsBlockDisplay(
                viewmodel: this.viewmodel_anime_film!,
                video_notifier: this.videoNotifier!,
              ),
              PaginationDisplay(
                  viewmodel_Video: this.viewmodel_anime_film!,
                  video_notifier: this.videoNotifier!)
            ],
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

            this.videoNotifier =
                ValueNotifier(this.viewmodel_anime_serie!.video["Video"]);
            return Column(children: [
              SeriesBlockDisplay(
                  viewmodel: this.viewmodel_anime_serie!,
                  video_notifier: this.videoNotifier!),
              PaginationDisplay(
                  viewmodel_Video: this.viewmodel_anime_serie!,
                  video_notifier: this.videoNotifier!)
            ]);
          } on TypeError catch (e) {
            print('TypeError on DataofSeries');
          }
          return CircularProgressIndicator();
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
            child: Column(children: [
      Container(
        alignment: Alignment.topRight,
        child: DropdownOnglets((event) => this._dropdown_change(event)),
      ),
      Container(child: this.view_to_display)
    ])));
  }
}
