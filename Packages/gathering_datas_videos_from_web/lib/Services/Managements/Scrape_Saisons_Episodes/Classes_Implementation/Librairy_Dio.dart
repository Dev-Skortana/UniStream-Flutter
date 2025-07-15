import 'package:dio/dio.dart';
import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Interface/ILibrairy_Scrape.dart';

class LibrairyDio implements IlibrairyScrape<Dio> {
  LibrairyDio() {}

  @override
  Future<Dio> getInstanceOfObjectScraping() async {
    Dio dio = Dio();
    dio = await this
        .getInstanceConfiguredOfObjectScraping(instance_objectscrape: dio);
    return dio;
  }

  @override
  Future<Dio> getInstanceConfiguredOfObjectScraping(
      {required Dio instance_objectscrape}) async {
    instance_objectscrape.options = BaseOptions();
    return instance_objectscrape;
  }

  @override
  Future<String> getHtmlDoc(
      {required Dio instance_objectscrape, required String url_target}) async {
    return (await instance_objectscrape.get(url_target)).data.toString();
  }

  @override
  void dispose({required Dio instance_objectscrape}) {
    // Not nedeed
  }
}
