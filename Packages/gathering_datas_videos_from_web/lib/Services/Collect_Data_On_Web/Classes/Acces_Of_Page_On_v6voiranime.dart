part of gathering_data_videos_from_web;

class AccesOfPageOnV6voiranime extends Acces
    implements
        IscrapeData,
        IrequestForDataMandatory,
        IrequestSaisonVideo<bool> {
  AccesOfPageOnV6voiranime(
      UseDictionnaryCategorieUrlpage objectdictionnary_categorie_urlpage)
      : super(objectdictionnary_categorie_urlpage) {}

  @override
  String get typeVideo => "Anime";

  @override
  String getRequeteXpathOfLinkOfOneVideo() =>
      "//div[@class='row c-tabs-item__content']/div[@class='col-8 col-sm-10 col-md-10']/descendant::h3/a";

  @override
  bool getRequeteXpathOfLinksOfSaisonsOnVideo() => false;

  @override
  String getCategorieVideo(
      {required Element html_dom, required String requete_xpath}) {
    String replace(Match match) {
      Map<String, String> dictionnary_replace = {
        'MOVIE': 'Film',
        'TV': 'Serie',
        'Films': 'Film',
        'Animes': 'Serie'
      };
      return dictionnary_replace.containsKey(match.group(1)?.trim())
          ? dictionnary_replace[match.group(1)!.trim()]!
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
      String chaine_mark = ":mark:";
      String chaine_cadre =
          RegExp('(/pages?/|pages?=)').firstMatch(match.group(0)!)!.group(1)!;
      String chaine = "${chaine_cadre}${chaine_mark}";
      return chaine;
    }

    return await this.getFormatPage(
        requete_xpath: "//div[@role='navigation']/a",
        requete_regex: "/page(s)?/([0-9]+)",
        methode_replaceofregex: replace);
  }

  @override
  Future<int> getNumbersOfPages() async => await this.getNumbersPages(
      requete_xpath:
          "//div[@class='main-col-inner']/descendant::div[@class='tab-content-wrap']/div[@class='col-12 col-md-12']/descendant::span[@class='pages']",
      requete_regex: "([0-9]+)\$");
}
