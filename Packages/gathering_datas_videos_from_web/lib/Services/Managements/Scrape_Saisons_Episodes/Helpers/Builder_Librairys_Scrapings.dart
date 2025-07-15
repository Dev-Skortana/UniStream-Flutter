import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Classes_Implementation/Librairy_Dio.dart';
import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Classes_Implementation/Librairy_Http.dart';
import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Classes_Implementation/Librairy_WebViewHeadless.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';

class BuilderLibrairysScrapings {
  static Map<EnumerationLibrairyGathering, dynamic>
      getLibrairysScrapingAsMap() =>
          BuilderLibrairysScrapings._buildManyLibrairyScraping();
  static Map<EnumerationLibrairyGathering, dynamic>
      _buildManyLibrairyScraping() => {
            EnumerationLibrairyGathering.Http: LibrairyHttp.new,
            EnumerationLibrairyGathering.Dio: LibrairyDio.new,
            EnumerationLibrairyGathering.WebViewHeadless:
                LibrairyWebviewheadless.new
          };
}
