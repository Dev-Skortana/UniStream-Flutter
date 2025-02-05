import 'package:unistream/Models/Anime_Film.dart';
import 'package:unistream/Services/Databases/Anime_Film_Manager.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';

class ViewmodelAnimefilm extends ViewmodelFilmbase {
  late List list_animes_films;

  ViewmodelAnimefilm._create(
      List list_of_viewmodel, Map<String, dynamic> dictionnary_methode_and_args)
      : list_animes_films = list_of_viewmodel,
        super(dictionnary_methode_and_args);

  static Future<ViewmodelAnimefilm> create(
      Map<String, dynamic> dictionnary_methode_and_args) async {
    List list_animes_films = await ViewmodelAnimefilm.GetListAnimesFilms();
    Map<String, dynamic> dictionnary_methode_and_args = {
      "method": ViewmodelAnimefilm.GetAnimesFilms,
      "args": [list_animes_films]
    };

    ViewmodelAnimefilm viewmodel = ViewmodelAnimefilm._create(
        list_animes_films, dictionnary_methode_and_args);

    return viewmodel;
  }

  static Iterable GetAnimesFilms(Iterable items) {
    return AnimeFilmManager().GetGen(items);
  }

  static Future<List> GetListAnimesFilms() async {
    return await AnimeFilmManager().getList({});
  }
}
