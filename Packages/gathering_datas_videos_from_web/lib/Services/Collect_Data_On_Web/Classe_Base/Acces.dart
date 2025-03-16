part of gathering_data_videos_from_web;

class Acces {
  late UseDictionnaryCategorieUrlpage dictionnary_categorie_urlpage;
  late EnumerationCategorieVideo cursorCurrentCategorieVideo;
  late String urlPageVideos;

  Acces(UseDictionnaryCategorieUrlpage objectdictionnary_categorie_urlpage) {
    this.dictionnary_categorie_urlpage = objectdictionnary_categorie_urlpage;
    this.urlPageVideos = this.dictionnary_categorie_urlpage.urlOfPageVideos;
  }

  @protected
  Future<String> searchUrlBaseFromName(Type child_class_of_this) async {
    int length_underscore = child_class_of_this.toString().split("_").length;
    return (await ManipulateJsonFileRegister.create())
        .dataFromJson
        .where((element) => child_class_of_this
            .toString()
            .split("_")[length_underscore]
            .contains(element["Name"]))
        .first["Url_Reference"];
  }

  String get typeVideo => "";

  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  static Future<String> staticGetUrlBase(Type child_class_of_this) async =>
      await Acces(UseDictionnaryCategorieUrlpage(
              site_name: "", url_page_videos: ""))
          .searchUrlBaseFromName(child_class_of_this);

  EnumerationFulltypeVideo getFullTypeVideo(String categorie_video) =>
      EnumerationFulltypeVideo.values
          .byName("${categorie_video}_${this.typeVideo}");

  Future<String> getAbsoluteLinkFromUrlPageVideos(String url) async {
    /*TODO*/
    return url.startsWith(RegExp("http|HTTP")) == false
        ? path.joinAll([this.urlPageVideos, url])
        : url;
  }

  String getCategorie(
      {required Element html_dom,
      required String requete_xpath,
      required String Function(Match) replace_regex}) {
    RegExpMatch result_match;
    try {
      XPathResult elements = html_dom.queryXPath(requete_xpath);
      String chaine_format =
          elements.toString().replaceAllMapped("([A-Za-z]+)", replace_regex);
      result_match = RegExp("(Film|Serie|Autre)").firstMatch(chaine_format)!;
    } on IndexError catch (exception_index_error) {
      return "Autre";
    } on Exception catch (exception_base) {
      return "Autre";
    }
    return result_match.group(1)!;
  }

  @protected
  Future<String> getFormatPage(
      {required String requete_xpath,
      String requete_regex = "",
      String Function(Match)? methode_replaceofregex = null}) async {
    String base_of_url = this.urlPageVideos.split("//")[1];
    String start_point_of_url = base_of_url.split("/")[0];
    String endpoint_of_url = base_of_url.split("/")[1];
    http.Response response =
        await http.get(Uri.https(start_point_of_url, endpoint_of_url));
    String html_doc = response.body;
    Element html_dom = ManagerHtmlDom.ParseHtmlDoc(html_doc);
    XPathResult xpath_result = html_dom.queryXPath(requete_xpath);
    String element = await this.getAbsoluteLinkFromUrlPageVideos(
        xpath_result.attrs.where((item) => item == "href").first!);
    return element.replaceAllMapped(requete_regex, methode_replaceofregex!);
  }

  @protected
  Future<int> getNumbersPages(
      {required String requete_xpath, String requete_regex = ""}) async {
    String base_of_url = this.urlPageVideos.split("//")[1];
    String start_point_of_url = base_of_url.split("/")[0];
    String endpoint_of_url = base_of_url.split("/")[1];
    http.Response response =
        await http.get(Uri.https(start_point_of_url, endpoint_of_url));
    String html_doc = response.body;
    Element html_dom = ManagerHtmlDom.ParseHtmlDoc(html_doc);
    String numpagemax = html_dom.queryXPath(requete_xpath).toString();
    if (requete_regex != "") {
      Match match_regex = RegExp(requete_regex).firstMatch(numpagemax)!;
      String numero_page_max = match_regex.group(1)!;
      return int.parse(numero_page_max);
    } else {
      return int.parse(numpagemax);
    }
  }

  String getUrl() {
    return this.urlPageVideos;
  }

  @protected
  Future<Map<int, List<int>>> getSaisonWithEpisodeThem(
      {required String url_pagepresentation_video,
      required Element html_dom_pagepresentation_video,
      required String request_saisons,
      required String request_episodes,
      required String requete_xpath_of_links_of_saisons_on_video}) async {
    RegExp regex_extract_urlbase = RegExp(r'https?:\/\/[^\/]+');
    String url_base =
        regex_extract_urlbase.firstMatch(this.urlPageVideos)!.group(1)!;

    Map row_register = (await ManipulateJsonFileRegister.create())
        .manipulateJsonFileRead
        .getDictionnaryOfSiteData(url_base);
    return await this._ghatheringSaisonsAndTheirEpisodes(
        url_pagepresentation_video: url_pagepresentation_video,
        requete_xpath_of_links_of_saisons_on_video:
            requete_xpath_of_links_of_saisons_on_video,
        html_dom_pagepresentation_video: html_dom_pagepresentation_video,
        list_dictionnary_requests_regexs__saison_and_episode: [
          {
            "request": request_saisons,
            "regex": row_register["Extract_Saisons_On_Xpath"]
          },
          {
            "request": request_episodes,
            "regex": row_register["Extract_Episodes_On_Xpath"]
          }
        ]);
  }

  Future<Map<int, List<int>>> _ghatheringSaisonsAndTheirEpisodes(
      {required String url_pagepresentation_video,
      required String requete_xpath_of_links_of_saisons_on_video,
      required Element html_dom_pagepresentation_video,
      required List<Map>
          list_dictionnary_requests_regexs__saison_and_episode}) async {
    const int MAX_TRY = 2;
    Map<int, List<int>> dictionnary_saisons_episode = {};
    EnumerationLibrairyGathering library_ghatering =
        EnumerationLibrairyGathering.Requests;
    int count_try_gathering = 0;

    do {
      ManagerSeasonsAndTheirEpisodes manager = ManagerSeasonsAndTheirEpisodes(
          librairy_use_for_gathering: library_ghatering,
          dictionnary_request_and_regex_saison: {
            "request": list_dictionnary_requests_regexs__saison_and_episode[0]
                ["request"],
            "regex": list_dictionnary_requests_regexs__saison_and_episode[0]
                ["regex"]
          },
          dictionnary_request_and_regex_episode: {
            "request": list_dictionnary_requests_regexs__saison_and_episode[1]
                ["request"],
            "regex": list_dictionnary_requests_regexs__saison_and_episode[1]
                ["regex"]
          });
      await manager.getSeasonsAndTheirEpisodes(
          url_pagepresentation_video: url_pagepresentation_video,
          htmldom_pagevideo: html_dom_pagepresentation_video,
          requete_xpathoflinksofsaisonsonvideo:
              requete_xpath_of_links_of_saisons_on_video);
      dictionnary_saisons_episode = manager.dictionnarySaisonsEpisode;
      library_ghatering = EnumerationLibrairyGathering.Playwright;
      count_try_gathering += 1;
    } while (dictionnary_saisons_episode.length == 0 &&
        count_try_gathering != MAX_TRY);
    return Map.fromEntries(dictionnary_saisons_episode.entries.toList()
      ..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  Future<Map<int, List<int>>> getSaisonAndEpisode(
      {required String url_pagepresentation_video,
      required Element html_dom_pagepresentation_video,
      required String request_saisons,
      required String request_episodes}) async {
    return await this.getSaisonWithEpisodeThem(
        url_pagepresentation_video: url_pagepresentation_video,
        html_dom_pagepresentation_video: html_dom_pagepresentation_video,
        request_saisons: request_saisons,
        request_episodes: request_episodes,
        requete_xpath_of_links_of_saisons_on_video: (this as dynamic)
            .getRequeteXpathOfLinksOfSaisonsOnVideo()
            .toString());
  }
}
