import 'package:unistream/Models/Drama_Film.dart';
import 'package:unistream/Services/Databases/Drama_Film_Manager.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';

class ViewmodelDramafilm extends ViewmodelFilmbase {
  late List list_dramas_films;
  ViewmodelDramafilm._create(
      List list_of_viewmodel, Map<String, dynamic> dictionnary_methode_and_args)
      : list_dramas_films = list_of_viewmodel,
        super(dictionnary_methode_and_args);

  static Future<ViewmodelDramafilm> create() async {
    List list_dramas_films = await ViewmodelDramafilm.GetListDramasFilms();
    Map<String, dynamic> dictionnary_methode_and_args = {
      "method": ViewmodelDramafilm.GetDramasFilms,
      "args": [list_dramas_films]
    };

    ViewmodelDramafilm viewmodel = ViewmodelDramafilm._create(
        list_dramas_films, dictionnary_methode_and_args);

    return viewmodel;
  }

  static Iterable GetDramasFilms(Iterable items) {
    return DramaFilmManager().GetGen(items);
  }

  static Future<List> GetListDramasFilms() async {
    return await DramaFilmManager().getList({});
  }
}
