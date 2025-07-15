part of gathering_urls_videos_from_web;

class AccesOfPageOnVostfree extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<String>,
        IrequestSaisonVideo<bool>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<String> {
  AccesOfPageOnVostfree() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks
          .DontHavePanelLinksSaisons_And_DontHavePanelLinksEpisodes;

  @override
  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "###";

  @override
  String getRequeteXpathOfIconMenu() => "div#user-bar button";

  @override
  String getRequeteXpathOfButtonSearch() =>
      "div#user-bar  div.infobar-right > div > form button";

  @override
  String getRequeteXpathOfEntryFieldSearch() =>
      "div#user-bar  div.infobar-right > div > form input#story";

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//div[@class='jq-selectbox__dropdown']/ul[1]/li";

  @override
  String getRequeteXpathOfLinkOfMovieOnVideo() =>
      "//div[@class='jq-selectbox__dropdown']/ul[1]/li";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "//div[@id='dle-content']/div[@class='shortstory-in']/descendant::div[@class='short-content']/h4[@class='short-link']/a/@href";

  @override
  bool getRequeteXpathOfLinksOfSaisonsOnVideo() => false;
  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "" : "";
    return "//div[@id='dle-content']/div[@class='shortstory-in']/descendant::div[@class='short-content']/h4[@class='short-link']/a${attrib}!div#dle-content > div.shortstory-in  div.short-content > h4.short-link > a";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => false;
}
