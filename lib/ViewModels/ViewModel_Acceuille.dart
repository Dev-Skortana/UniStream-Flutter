import 'package:unistream/Services/Reboot_Database_Manager.dart';
import 'package:unistream/Services/Special_Management.dart';

class ViewmodelAcceuille {
  late Stream VideosOfTwelveMonths;

  ViewmodelAcceuille() {
    this.VideosOfTwelveMonths = this.getVideosOnTheLastTwelveMonths();
  }

  Stream getVideosOnTheLastTwelveMonths() async* {
    await for (var item in SpecialManagement.getVideosOnTheLastTwelveMonths()) {
      yield item;
    }
  }

  Future<List> r(String chaine_condition, String chaine_order) async {
    return await SpecialManagement.getVideosFilmsOnTheLastTwelveMonths(
            chaine_condition, chaine_order)
        .toList();
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
