import 'package:unistream/Models/Detail_Video_Serie.dart';
import 'package:unistream/Services/Databases/Anime_Serie_Manager.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';

class ViewmodelAnimeserie extends ViewmodelSeriebase {
  late List _list_animes_series;

  ViewmodelAnimeserie._create(List list_detailseries, List list_of_viewmodel,
      Map<String, dynamic> dictionnary_methode_and_args)
      : _list_animes_series = list_of_viewmodel,
        super(list_detailseries, dictionnary_methode_and_args);

  static Future<ViewmodelAnimeserie> create() async {
    List listDetailsSeries = await ViewmodelSeriebase.GetListDetailsSeries();
    List list_animes_series = await ViewmodelAnimeserie.GetListAnimesSeries();
    Map<String, dynamic> dictionnary_methode_and_args = {
      "method": ViewmodelAnimeserie.GetAnimesSeries,
      "args": [list_animes_series]
    };

    ViewmodelAnimeserie viewmodel = ViewmodelAnimeserie._create(
        listDetailsSeries, list_animes_series, dictionnary_methode_and_args);

    return viewmodel;
  }

  static Iterable GetAnimesSeries(Iterable items) {
    return AnimeSerieManager().GetGen(items);
  }

  static Future<List> GetListAnimesSeries() async {
    return AnimeSerieManager().getList({});
  }
}
