part of gathering_data_videos_from_web;

class AccesOfPageOnPapadustream extends Acces
    implements
        IscrapeData,
        IrequestForDataMandatory,
        IrequestSaisonVideo<String> {
  AccesOfPageOnPapadustream(
      UseDictionnaryCategorieUrlpage objectdictionnary_categorie_urlpage)
      : super(objectdictionnary_categorie_urlpage) {}

  @override
  String get typeVideo => "Serie";

  @override
  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  @override
  String getRequeteXpathOfLinkOfOneVideo() =>
      "//div[@class='short gridder-list']/div[1]/a";
  @override
  String getRequeteXpathOfLinksOfSaisonsOnVideo() =>
      "//div[@class='seasontab']/div/div[@align='center']/a";

  @override
  String getCategorieVideo(
          {required Element html_dom, required String requete_xpath}) =>
      "Serie";
  @override
  Future<String> getFormatOfPaginationinUrl() async {
    String replace(Match match) {
      if (match.group(0)!.contains("pages")) {
        return "/pages/:mark:";
      } else {
        return "/page/:mark:";
      }
    }

    return await this.getFormatPage(
        requete_xpath:
            "//div[contains(@class,'bottom_nav')]/descendant::span[@class='navigation']/a",
        requete_regex: "/page(s)?/([0-9]+)",
        methode_replaceofregex: replace);
  }

  @override
  Future<int> getNumbersOfPages() async => await super.getNumbersPages(
      requete_xpath:
          "//div[contains(@class,'bottom_nav')]/descendant::span[@class='navigation']/a[last()]",
      requete_regex: "([0-9]+)\$");
}
