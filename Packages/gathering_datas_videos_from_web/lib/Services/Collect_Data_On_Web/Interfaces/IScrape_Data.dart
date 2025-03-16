part of gathering_data_videos_from_web;

abstract class IscrapeData {
  String getCategorieVideo(
      {required Element html_dom, required String requete_xpath});
  Future<String> getFormatOfPaginationinUrl();
  Future<int> getNumbersOfPages();
}
