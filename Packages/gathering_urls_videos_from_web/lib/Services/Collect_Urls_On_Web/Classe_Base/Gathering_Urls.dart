import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';
import 'package:gathering_urls_videos_from_web/Services/Manipulate_Json_File/Manipulate_Json_File_Redirect.dart';
import 'package:meta/meta.dart';

class GatheringUrls {
  late String urlPageWelcome;

  GatheringUrls() {
    this.urlPageWelcome = this.getUrlBase();
  }

  @protected
  String searchUrlBaseFromName(Type child_class_of_this) {
    int length_underscore = child_class_of_this.toString().split("_").length;
    return ManipulateJsonFileRedirect()
        .dataFromJson
        .where((element) => child_class_of_this
            .toString()
            .split("_")[length_underscore]
            .contains(element["Name"]))
        .first["Url_Reference"];
  }

  String getAbsoluteLinkFromUrlPageVideos() {
    /*TODO*/
    return "";
  }

  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() {
    throw UnimplementedError();
  }

  String getUrlBase() => this.searchUrlBaseFromName(this.runtimeType);
}
