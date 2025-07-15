part of gathering_urls_videos_from_web;

class AccesOfPageOnPapadustream extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<bool>,
        IrequestSaisonVideo<String>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<String> {
  AccesOfPageOnPapadustream() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks.HavePanelLinksSaisons_And_HavePanelLinksEpisodes;

  @override
  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  @override
  bool getRequeteXpathOfLinkOfMovieOnVideo() => false;

  @override
  String getRequeteXpathOfIconMenu() => "span.fa-search";

  @override
  String getRequeteXpathOfButtonSearch() =>
      "form#quicksearch > div.search_box > button";

  @override
  String getRequeteXpathOfEntryFieldSearch() =>
      "form#quicksearch > div.search_box > input";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "//div[@class='short gridder-list']/div/div[@id='short_title']/a/@href";

  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "/text()" : "";
    return "//div[@class='short gridder-list']/div/div[@id='short_title']/a${attrib}!div.short.gridder-list > div > div#short_title > a";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => false;

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "###";

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//div[@class='saisontab']/h2[contains(text(), 'Voir tous les épisodes')]/ancestor::div/div[@class='floats clearfix']/div/a";

  @override
  String getRequeteXpathOfLinksOfSaisonsOnVideo() =>
      "//div[@class='seasontab']/div/div[@align='center']/a/@href";
}
