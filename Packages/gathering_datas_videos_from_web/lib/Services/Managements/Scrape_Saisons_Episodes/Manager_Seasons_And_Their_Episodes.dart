part of gathering_data_videos_from_web;

class ManagerSeasonsAndTheirEpisodes {
  final lock = Lock();

  late IlibrairyScrape librairyUseForGathering;
  late dynamic instanceObjectScrape;

  Map<int, List<int>> dictionnarySaisonsEpisode = {};

  late ObjectSelector selectorSaison;

  late ObjectSelector selectorEpisode;

  ManagerSeasonsAndTheirEpisodes(
      {required IlibrairyScrape librairy_use_for_gathering,
      required Map<String, String> dictionnary_request_and_regex_saison,
      required Map<String, String> dictionnary_request_and_regex_episode}) {
    this.librairyUseForGathering = librairy_use_for_gathering;
    this.selectorSaison = ObjectSelector(
        request: dictionnary_request_and_regex_saison["request"]!,
        regex: dictionnary_request_and_regex_saison["regex"]!);
    this.selectorEpisode = ObjectSelector(
        request: dictionnary_request_and_regex_episode["request"]!,
        regex: dictionnary_request_and_regex_episode["regex"]!);
    this.dictionnarySaisonsEpisode = {};
  }

  Future<void> getSeasonsAndTheirEpisodes(
      {required String url_pagepresentation_video,
      required Element htmldom_pagevideo,
      required String requete_xpathoflinksofsaisonsonvideo}) async {
    /*TODO*/
    late IlibrairyScrape librairy_use_for_gathering;
    late dynamic instance_object_scrape;

    await this.lock.run(() async {
      librairy_use_for_gathering = this.librairyUseForGathering;
      this.instanceObjectScrape =
          await this.librairyUseForGathering.getInstanceOfObjectScraping();
      instance_object_scrape = this.instanceObjectScrape;
    });
    htmldom_pagevideo = ManagerHtmlDom.ParseHtmlDoc(
        await librairy_use_for_gathering.getHtmlDoc(
            instance_objectscrape: instance_object_scrape,
            url_target: url_pagepresentation_video));
    await this._getSeasonsEpisodes(
        url_pagepresentation_video: url_pagepresentation_video,
        htmldom_pagevideo: htmldom_pagevideo,
        requete_xpathoflinksofsaisonsonvideo:
            requete_xpathoflinksofsaisonsonvideo);
    librairy_use_for_gathering.dispose(
        instance_objectscrape: instance_object_scrape);
  }

  Future<void> _getSeasonsEpisodes(
      {required String url_pagepresentation_video,
      required Element htmldom_pagevideo,
      required String requete_xpathoflinksofsaisonsonvideo}) async {
    final ObjectSelector selector_saison = await this.lock.run(() async {
      return this.selectorSaison;
    });
    if (selector_saison.regex.isNotEmpty) {
      await this._proccesOnSaisonsAndEpisodes(
          url_pagepresentation_video: url_pagepresentation_video,
          htmldom_pagevideo: htmldom_pagevideo,
          requete_xpathoflinksofsaisonsonvideo:
              requete_xpathoflinksofsaisonsonvideo);
    } else {
      await this._processOnEpisodesDirectly(htmldom_pagevideo);
    }
  }

  Future<void> _proccesOnSaisonsAndEpisodes(
      {required String url_pagepresentation_video,
      required Element htmldom_pagevideo,
      required String requete_xpathoflinksofsaisonsonvideo}) async {
    late IlibrairyScrape librairy_use_for_gathering;
    late dynamic instance_object_scrape;
    late ObjectSelector selector_saison;
    late ObjectSelector selector_episode;

    await this.lock.run(() async {
      librairy_use_for_gathering = this.librairyUseForGathering;
      instance_object_scrape = this.instanceObjectScrape;
      selector_saison = this.selectorSaison;
      selector_episode = this.selectorEpisode;
    });

    final List<int> saisons = this._getNumerosSaisons(
        htmldom_pagevideo: htmldom_pagevideo, selector_saison: selector_saison);
    final List<String> urls_videos_saisons = this._getUrlsSaisons(
        htmldom_pagevideo: htmldom_pagevideo,
        requete_xpathoflinksofsaisonsonvideo:
            requete_xpathoflinksofsaisonsonvideo,
        url_pagepresentation_video: url_pagepresentation_video);

    for (final (index_saison, url_videos_saison)
        in urls_videos_saisons.indexed) {
      Element html_dom_page_saisonofvideo = ManagerHtmlDom.ParseHtmlDoc(
          await librairy_use_for_gathering.getHtmlDoc(
              instance_objectscrape: instance_object_scrape,
              url_target: url_videos_saison));
      final List<int> episodes = this
          ._getNumerosEpisodes(
              htmldom_pagevideo_contains_episodes: html_dom_page_saisonofvideo,
              selector_episode: selector_episode)
          .toSet()
          .toList();
      await this._updateDictionnarySaisonsEpisode(
          key_saison_to_add: saisons[index_saison], episodes: episodes);
    }
  }

  List<int> _getNumerosSaisons(
      {required Element htmldom_pagevideo,
      required ObjectSelector selector_saison}) {
    return GettingsValuesOrValue.getListOfManyValueWithUsingRegex(
            html_dom: htmldom_pagevideo,
            requete_xpath: selector_saison.request,
            requete_regex: selector_saison.regex)
        .map((element) => int.parse(element))
        .toList();
  }

  List<String> _getUrlsSaisons(
      {required Element htmldom_pagevideo,
      required String requete_xpathoflinksofsaisonsonvideo,
      required String url_pagepresentation_video}) {
    final String symbol =
        url_pagepresentation_video.endsWith("/") == false ? "/" : "";
    String begin_url = "${url_pagepresentation_video}${symbol}";
    return htmldom_pagevideo
        .queryXPath(requete_xpathoflinksofsaisonsonvideo)
        .nodes
        .map((node) {
          bool is_link_saison_startwith_http =
              node.attributes["href"]!.startsWith(RegExp("(http|HTTP)"));
          return is_link_saison_startwith_http == false
              ? "${begin_url}${node.attributes["href"]}"
              : node.attributes["href"];
        })
        .cast<String>()
        .toList();
  }

  Future<void> _processOnEpisodesDirectly(Element htmldom_pagevideo) async {
    final ObjectSelector selector_episode = await this.lock.run(() async {
      return this.selectorEpisode;
    });
    List<int> episodes = this._getNumerosEpisodes(
        htmldom_pagevideo_contains_episodes: htmldom_pagevideo,
        selector_episode: selector_episode);
    await this._updateDictionnarySaisonsEpisode(
        key_saison_to_add: 1, episodes: episodes);
  }

  List<int> _getNumerosEpisodes(
      {required Element htmldom_pagevideo_contains_episodes,
      required ObjectSelector selector_episode}) {
    return GettingsValuesOrValue.getListOfManyValueWithUsingRegex(
            html_dom: htmldom_pagevideo_contains_episodes,
            requete_xpath: selector_episode.request,
            requete_regex: selector_episode.regex)
        .map((element) => int.parse(element))
        .toList()
      ..sort();
  }

  Future<void> _updateDictionnarySaisonsEpisode(
      {required int key_saison_to_add, required List<int> episodes}) async {
    if (episodes.isNotEmpty) {
      await this.lock.run(() async {
        this.dictionnarySaisonsEpisode[key_saison_to_add] = episodes;
      });
    }
  }
}
