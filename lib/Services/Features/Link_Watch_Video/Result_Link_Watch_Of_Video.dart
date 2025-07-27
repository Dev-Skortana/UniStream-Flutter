import 'package:gathering_urls_videos_from_web/gathering_urls_videos_from_web.dart';

class ResultLinkWatchOfVideo {
  ResultLinkWatchOfVideo() {}

  Future<List<Map<String, String>>> getManyResultLinkWatchOfVideo(
      Map<String, String> map_arguments) async {
    late ManagerGatheringData manager_gathering_urls;
    if (this._isFromFilm(map_arguments)) {
      manager_gathering_urls =
          this._getManagerGatheringDataFromFilm(map_arguments);
    }

    if (this._isFromSerie(map_arguments)) {
      manager_gathering_urls =
          this._getManagerGatheringDataFromSerie(map_arguments);
    }
    await manager_gathering_urls.gatheringLinkByFetchEveryUrlInJson();
    return manager_gathering_urls.dataResult.listDictionnaryResult;
  }

  bool _isFromFilm(Map<String, String> map_arguments) =>
      map_arguments.length == 1;

  bool _isFromSerie(Map<String, String> map_arguments) =>
      map_arguments.length == 3;

  ManagerGatheringData _getManagerGatheringDataFromFilm(
      Map<String, String> map_arguments) {
    List<Map<String, String>> maps_result = List.empty(growable: true);
    return ManagerGatheringData.createManagerGatheringUrlFromMovie(
        map_arguments["titre_video"] ?? "");
  }

  ManagerGatheringData _getManagerGatheringDataFromSerie(
      Map<String, String> map_arguments) {
    List<Map<String, String>> maps_result = List.empty(growable: true);
    return ManagerGatheringData.createManagerGatheringUrlFromSerie(
        titre_video: map_arguments["titre_video"] ?? "",
        saison: int.parse(map_arguments["saison"]!),
        episode: int.parse(map_arguments["episode"]!));
  }
}
