import 'dart:ffi';

import 'package:unistream/Models/Detail_Video_Serie.dart';
import 'package:unistream/Services/Databases/Detail_Video_Serie_Manager.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_VideoBase.dart';

class ViewmodelSeriebase extends ViewmodelVideobase {
  late List _ListDetailsSeries;

  ViewmodelSeriebase(
      List list_of_viewmodel, Map<String, dynamic> dictionnary_methode_and_args)
      : _ListDetailsSeries = list_of_viewmodel,
        super(dictionnary_methode_and_args);

  static Future<List> GetListDetailsSeries() async {
    return await DetailVideoSerieManager().getList({});
  }

  Iterable GetDetailsSeries(Iterable items) {
    return DetailVideoSerieManager().GetGen(items);
  }

  void FillVideoSerieWithDetails(Map<String, dynamic> video_serie) {
    video_serie["Video"].DetailsVideosSeries =
        this.GetGenerator_DetailSerieOfVideoSerie(video_serie["Video"].Titre);
  }

  Iterable? GetGenerator_DetailSerieOfVideoSerie(String titre_video) sync* {
    for (var detail in this.GetDetailsSeries(this._ListDetailsSeries)) {
      if (detail["Video"].Titre == titre_video) {
        yield DetailVideoSerie(
            titreVideoSerie: titre_video,
            saison: detail["Video"].Saison,
            episode: detail["Video"].Episode);
      }
    }
  }
}
