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

  Future<Map<int, List<int>>> getSaisonAndEpisode(
      {required String url_pagepresentation_video,
      required Element html_dom_pagepresentation_video,
      required String request_saisons,
      required String request_episodes}) async {
    return await super.getSaisonWithEpisodeThem(
        url_pagepresentation_video: url_pagepresentation_video,
        html_dom_pagepresentation_video: html_dom_pagepresentation_video,
        request_saisons: request_saisons,
        request_episodes: request_episodes,
        requete_xpath_of_links_of_saisons_on_video:
            this.getRequeteXpathOfLinksOfSaisonsOnVideo());
  }
}
