import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Interface/ILibrairy_Scrape.dart';
import 'package:http/http.dart' as http;

class LibrairyHttp implements IlibrairyScrape<http.Client> {
  LibrairyHttp() {}

  @override
  Future<http.Client> getInstanceOfObjectScraping() async {
    http.Client http_client = http.Client();
    http_client = await this.getInstanceConfiguredOfObjectScraping(
        instance_objectscrape: http_client);
    return http_client;
  }

  @override
  Future<http.Client> getInstanceConfiguredOfObjectScraping(
      {required http.Client instance_objectscrape}) async {
    return instance_objectscrape;
  }

  @override
  Future<String> getHtmlDoc(
      {required http.Client instance_objectscrape,
      required String url_target}) async {
    return (await instance_objectscrape.get(Uri.parse(url_target))).body;
  }

  @override
  void dispose({required http.Client instance_objectscrape}) {
    // Not nedeed
  }
}
