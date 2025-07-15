import 'package:meta/meta.dart';

abstract class IlibrairyScrape<T> {
  Future<T> getInstanceOfObjectScraping();
  Future<T> getInstanceConfiguredOfObjectScraping(
      {required T instance_objectscrape});
  Future<String> getHtmlDoc(
      {required T instance_objectscrape, required String url_target});
  void dispose({required T instance_objectscrape});
}
