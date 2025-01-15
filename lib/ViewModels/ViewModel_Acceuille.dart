import 'package:unistream/Services/Reboot_Database_Manager.dart';
import 'package:unistream/Services/Special_Management.dart';

class ViewmodelAcceuille {
  late List VideosOfTwelveMonths;

  ViewmodelAcceuille() {}

  Future<List> getVideosOnTheLastTwelveMonths() async {
    var v = await SpecialManagement.getVideosOnTheLastTwelveMonths().toList();
    return SpecialManagement.getVideosOnTheLastTwelveMonths().toList();
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
