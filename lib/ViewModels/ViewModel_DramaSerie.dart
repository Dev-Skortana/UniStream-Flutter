import 'package:unistream/Services/Databases/Drama_Serie_Manager.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';

class ViewmodelDramaserie extends ViewmodelSeriebase {
  late List list_dramas_series;

  ViewmodelDramaserie._create(List list_detailseries, List list_of_viewmodel,
      Map<String, dynamic> dictionnary_methode_and_args)
      : list_dramas_series = list_of_viewmodel,
        super(list_detailseries, dictionnary_methode_and_args);

  static Future<ViewmodelDramaserie> create() async {
    List listDetailsSeries = await ViewmodelSeriebase.GetListDetailsSeries();
    List list_dramas_series = await ViewmodelDramaserie.GetListDramasSeries();
    Map<String, dynamic> dictionnary_methode_and_args = {
      "method": ViewmodelDramaserie.GetDramasSeries,
      "args": [list_dramas_series]
    };

    ViewmodelDramaserie viewmodel = ViewmodelDramaserie._create(
        listDetailsSeries, list_dramas_series, dictionnary_methode_and_args);

    return viewmodel;
  }

  static Iterable GetDramasSeries(Iterable items) {
    return DramaSerieManager().GetGen(items);
  }

  static Future<List> GetListDramasSeries() async {
    return await DramaSerieManager().getList({});
  }
}
