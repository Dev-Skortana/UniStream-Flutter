part of gathering_data_videos_from_web;

class AccesOfPagesOnAnimesama extends Acces
    implements
        IscrapeData,
        IrequestForDataMandatory,
        IrequestSaisonVideo<String> {
  AccesOfPagesOnAnimesama(
      UseDictionnaryCategorieUrlpage objectdictionnary_categorie_urlpage)
      : super(objectdictionnary_categorie_urlpage) {}

  @override
  String get typeVideo => "Anime";

  @override
  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  @override
  String getRequeteXpathOfLinkOfOneVideo() =>
      "//div[@id='result_catalogue']/div[contains(@class,'cardListAnime')]/descendant::a";

  @override
  String getRequeteXpathOfLinksOfSaisonsOnVideo() =>
      "//h2[text()='Anime']/following::div[1]/a[contains(@href,'saison')]/div/..";

  /*    Cette méthode redefinie, recupere le type video scrapé cependant sur ce site une video 
        peut etre une série et un film en meme temps de ce faite on considerera que c'est une série
        ce qui causera moins de perte de données non scrapé(généralement il y a plus de couple saison/episode que de film).
        Néanmoins cela restera tant que cette méthode n'est pas retravailler un Bug creér intentionnellement.               */

  @override
  String getCategorieVideo(
      {required Element html_dom, required String requete_xpath}) {
    String replace(Match match) {
      String chaine_evaluer = match.input;
      if (chaine_evaluer.contains("Saison") &&
          !chaine_evaluer.contains("Film")) {
        return "Serie";
      } else if (chaine_evaluer.contains("Film") &&
          !chaine_evaluer.contains("Saison")) {
        return "Film";
      } else if (chaine_evaluer.contains("Saison") &&
          !chaine_evaluer.contains("Film")) {
        return "Serie";
      }
      return "Autre";
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
        requete_xpath: "//div[@id='nav_pages']/div/a",
        requete_regex: "page(s)?=([0-9]+)",
        methode_replaceofregex: replace);
  }

  @override
  Future<int> getNumbersOfPages() async => this.getNumbersPages(
      requete_xpath: "//div[@id='nav_pages']/descendant::a[last()]");

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
