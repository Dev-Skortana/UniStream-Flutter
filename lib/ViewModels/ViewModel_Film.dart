import 'package:unistream/Services/Databases/Film_Manager.dart';
import 'package:unistream/Models/Film.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';

class ViewmodelFilm extends ViewmodelFilmbase {
  late List list_films;
  ViewmodelFilm._create(
      List list_of_viewmodel, Map<String, dynamic> dictionnary_methode_and_args)
      : list_films = list_of_viewmodel,
        super(dictionnary_methode_and_args);

  static Future<ViewmodelFilm> create() async {
    List list_films = await ViewmodelFilm.GetListFilms();
    Map<String, dynamic> dictionnary_methode_and_args = {
      "method": ViewmodelFilm.GetFilms,
      "args": [list_films]
    };

    ViewmodelFilm viewmodel =
        ViewmodelFilm._create(list_films, dictionnary_methode_and_args);

    return viewmodel;
  }

  static Future<List> GetListFilms() async {
    return await FilmManager().getList({});
  }

  static Iterable GetFilms(Iterable items) {
    return FilmManager().GetGen(items);
  }
}
