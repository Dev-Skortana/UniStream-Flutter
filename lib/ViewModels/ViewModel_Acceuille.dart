import 'dart:async';

import 'package:unistream/Services/Databases/Reboot_Database_Manager.dart';
import 'package:unistream/Services/Databases/Special_Management.dart';

class ViewmodelAcceuille {
  //late List VideosOfTwelveMonths;

  ViewmodelAcceuille() {}
  Stream<Iterator<Map<String, dynamic>>>
      getVideosOnTheLastTwelveMonths() async* {
    yield await SpecialManagement.getVideosOnTheLastTwelveMonths();
  }

  Future<int> getTotalVideosOnTheLastTwelveMonths() async {
    return await SpecialManagement.getTotalVideosFilmsOnTheLastTwelveMonths() +
        await SpecialManagement.getTotalVideosSeriesOnTheLastTwelveMonths();
  }

  Map<String, String> getManyResultLinkWatchOfVideo(Map criteria) {
    return {"": ""};
  }

  void rebootDatabase() {
    RebootDatabaseManager().reboot();
  }
}
