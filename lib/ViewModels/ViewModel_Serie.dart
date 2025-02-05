import 'package:unistream/Services/Databases/Serie_Manager.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';

class ViewmodelSerie extends ViewmodelSeriebase {
  late List list_series;

  ViewmodelSerie._create(List list_detailseries, List list_of_viewmodel,
      Map<String, dynamic> dictionnary_methode_and_args)
      : list_series = list_of_viewmodel,
        super(list_detailseries, dictionnary_methode_and_args);

  static Future<ViewmodelSerie> create() async {
    List listDetailsSeries = await ViewmodelSeriebase.GetListDetailsSeries();
    List list_series = await ViewmodelSerie.GetListSeries();
    Map<String, dynamic> dictionnary_methode_and_args = {
      "method": ViewmodelSerie.GetSeries,
      "args": [list_series]
    };

    ViewmodelSerie viewmodel = ViewmodelSerie._create(
        listDetailsSeries, list_series, dictionnary_methode_and_args);

    return viewmodel;
  }

  static Iterable GetSeries(Iterable items) {
    return SerieManager().GetGen(items);
  }

  static Future<List> GetListSeries() async {
    return await SerieManager().getList({});
  }
}
