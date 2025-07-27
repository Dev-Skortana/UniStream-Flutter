import 'package:flutter/material.dart';
import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Classes_Base/Parameters_Get_LinkWatchs.dart';

class ParametersGetLinkWatchsSeries extends ParametersGetLinkwatchs {
  late String titreVideo;
  late int saison;
  late int episode;

  ParametersGetLinkWatchsSeries(
      {required String titreVideo,
      required String saison,
      required String episode})
      : this.titreVideo = titreVideo,
        this.saison = int.parse(saison),
        this.episode = int.parse(episode) {}

  @override
  void preparedParametersData() {
    this.mapParametersData["titre_video"] = this.titreVideo;
    this.mapParametersData["saison"] = this.saison;
    this.mapParametersData["episode"] = this.episode;
  }
}
