part of gathering_urls_videos_from_web;

class AccesOfPageOnV6voiranime extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<String>,
        IrequestSaisonVideo<bool>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<bool> {
  AccesOfPageOnV6voiranime() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks
          .DontHavePanelLinksSaison_And_HavePanelLinksEpisodes;

  @override
  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  @override
  String getRequeteXpathOfIconMenu() =>
      "div.search-navigation.search-sidebar ul > li.menu-search";

  @override
  String getRequeteXpathOfEntryFieldSearch() => "div.probox  input.orig";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "//div[@class='results']/div[@class='resdrg']/descendant::div[contains(@class,'item')]/div/h3/a/@href";

  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "" : ""; //[1]
    return "//div[@class='results']/div[@class='resdrg']/descendant::div[contains(@class,'item')]/div/h3/a${attrib}!div.results > div.resdrg  div.item > div > h3";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => true;

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "###";
  @override
  bool getRequeteXpathOfButtonSearch() => false;

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//div[@class='c-page__content']/descendant::div[@class='page-content-listing single-page']/descendant::li/a/@href";

  @override
  String getRequeteXpathOfLinkOfMovieOnVideo() =>
      "//div[@class='c-page__content']/descendant::div[@class='page-content-listing single-page']/descendant::li/a/@href";

  @override
  bool getRequeteXpathOfLinksOfSaisonsOnVideo() => false;
}
