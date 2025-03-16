part of gathering_data_videos_from_web;

class ManagerSeasonsAndTheirEpisodes {
  Map<int, List<int>> _dictionnarySaisonsEpisode = {};
  Map<int, List<int>> get dictionnarySaisonsEpisode =>
      this._dictionnarySaisonsEpisode;

  ManagerSeasonsAndTheirEpisodes(
      {required EnumerationLibrairyGathering librairy_use_for_gathering,
      required Map<String, String> dictionnary_request_and_regex_saison,
      required Map<String, String> dictionnary_request_and_regex_episode}) {
    /*TODO*/
  }

  Future<void> getSeasonsAndTheirEpisodes(
      {required String url_pagepresentation_video,
      required Element htmldom_pagevideo,
      required String requete_xpathoflinksofsaisonsonvideo}) async {
    /*TODO*/
  }
}
