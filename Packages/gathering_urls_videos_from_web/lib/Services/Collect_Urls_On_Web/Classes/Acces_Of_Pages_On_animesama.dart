part of gathering_urls_videos_from_web;

class AccesOfPagesOnAnimesama extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<String>,
        IrequestSaisonVideo<String>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<bool> {
  AccesOfPagesOnAnimesama() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks
          .HavePanelLinksSaisons_And_DontHavePanelLinksEpisodes;

  @override
  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "J'ACCEPTE";

  @override
  String getRequeteXpathOfIconMenu() => "";

  @override
  bool getRequeteXpathOfButtonSearch() => false;

  @override
  String getRequeteXpathOfEntryFieldSearch() => "nav >a > input#search_text";

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//select[@id='selectEpisodes']/option";

  @override
  String getRequeteXpathOfLinkOfMovieOnVideo() =>
      "//h2[text()='Anime']/following::div[1]/a/div[contains(text(),'Film')]/ancestor::a/@href";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "//div[@id='result']/child::a";

  @override
  String getRequeteXpathOfLinksOfSaisonsOnVideo() =>
      "//h2[text()='Anime']/following::div[1]/a[contains(@href,'saison')]/div/ancestor::a/@href";

  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "/text()" : "";
    return " //div[@id='result']/a/div/h3${attrib}!div#result > a > div > h3";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => true;
}
