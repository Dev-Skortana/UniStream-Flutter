import 'dart:async';

import 'package:unistream/Services/Databases/Reboot_Database_Manager.dart';
import 'package:unistream/Services/Databases/Special_Management.dart';
import 'package:unistream/Services/Features/Link_Watch_Video/Result_Link_Watch_Of_Video.dart';

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

  Future<List<Map<String, String>>> getManyResultLinkWatchOfVideo(
      Map<String, String> criteria) async {
    return await ResultLinkWatchOfVideo()
        .getManyResultLinkWatchOfVideo(criteria);
  }

  Future<void> rebootDatabase() async {
    await RebootDatabaseManager().reboot();
  }
}
