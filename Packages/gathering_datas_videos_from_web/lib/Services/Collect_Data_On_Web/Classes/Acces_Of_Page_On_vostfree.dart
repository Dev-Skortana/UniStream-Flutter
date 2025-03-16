part of gathering_data_videos_from_web;

class AccesOfPageOnVostfree extends Acces
    implements
        IscrapeData,
        IrequestForDataMandatory,
        IrequestSaisonVideo<bool> {
  AccesOfPageOnVostfree(
      UseDictionnaryCategorieUrlpage objectdictionnary_categorie_urlpage)
      : super(objectdictionnary_categorie_urlpage) {}

  @override
  String get typeVideo => "Anime";

  @override
  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  @override
  String getRequeteXpathOfLinkOfOneVideo() =>
      "//div[@id='dle-content']/div[@class='movie-poster']/div[@class='play']/a";

  @override
  bool getRequeteXpathOfLinksOfSaisonsOnVideo() => false;

  @override
  String getCategorieVideo(
      {required Element html_dom, required String requete_xpath}) {
    String replace(Match match) {
      Map<String, String> dictionnary_replace = {
        "Films": "Film",
        "Animes": "Serie"
      };
      return dictionnary_replace.containsKey(match.group(1))
          ? match.group(1)!
          : "Autre";
    }

    return this.getCategorie(
        html_dom: html_dom,
        requete_xpath: requete_xpath,
        replace_regex: replace);
  }

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
        requete_xpath: "//div[@class='navigation']/div[@class='pages']/a",
        requete_regex: "/page(s)?/([0-9]+)",
        methode_replaceofregex: replace);
  }

  @override
  Future<int> getNumbersOfPages() async => this.getNumbersPages(
      requete_xpath:
          "//div[@id='dle-content']/descendant::div[@class='pages']/a[last()]");
}
