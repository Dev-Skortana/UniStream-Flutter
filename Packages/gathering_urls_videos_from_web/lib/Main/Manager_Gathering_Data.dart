part of gathering_urls_videos_from_web;

class ManagerGatheringData {
  final lock = Lock();

  RegisterData get dataResult => this._dataResult;

  static ManagerGatheringData createManagerGatheringUrlFromMovie(
      String titre_video) {
    var dictionnary_parameters_video = {
      "Categorie": "Film",
      "Titre": titre_video
    };
    return ManagerGatheringData(dictionnary_parameters_video);
  }

  static ManagerGatheringData createManagerGatheringUrlFromSerie(
      {required String titre_video,
      required int saison,
      required int episode}) {
    var dictionnary_parameters_video = {
      "Categorie": "Serie",
      "Titre": titre_video,
      "Saison": saison,
      "Episode": episode
    };
    return ManagerGatheringData(dictionnary_parameters_video);
  }

  late bool _isLinkatLeastOneFound;
  late RegisterData _dataResult;
  late Map<String, dynamic> _dictionnaryParametersVideo;
  ManagerGatheringData(Map<String, dynamic> dictionnary_parameters_video) {
    if (this._checkArgumentIsPassedInContructor(dictionnary_parameters_video)) {
      this._initialize(dictionnary_parameters_video);
    }
  }

  bool _checkArgumentIsPassedInContructor(
      Map<String, dynamic> dictionnary_parameters_video) {
    return dictionnary_parameters_video.keys.length >= 2 &&
        dictionnary_parameters_video.containsKey("Categorie") &&
        dictionnary_parameters_video.containsKey("Titre");
  }

  void _initialize(Map<String, dynamic> dictionnary_parameters_video) {
    this._isLinkatLeastOneFound = false;
    this._dataResult = RegisterData.getEmptyRegisterData();
    this._dataResult.listDictionnaryResult = List.empty(growable: true);
    this._dictionnaryParametersVideo = dictionnary_parameters_video;
  }

  Future<RegisterMetaData> _load_MetaDataByUrlSpecific(
      String url_fromjson) async {
    var data = await ManipulateJsonFileRedirect.getDataFromJson();
    final Map map_metadata =
        data.firstWhere((element) => element["Url_Reference"] == url_fromjson);
    final String value_regex_for_saisons =
        map_metadata.containsKey("Regex_On_Saisons")
            ? map_metadata["Regex_On_Saisons"]
            : "";
    final String value_regex_for_episodes =
        map_metadata.containsKey("Regex_On_Episodes")
            ? map_metadata["Regex_On_Episodes"]
            : "";
    return RegisterMetaData(map_metadata["Name"], map_metadata["Url_Reference"],
        value_regex_for_episodes, value_regex_for_saisons);
  }

  Future<void> gatheringLinkByFetchEveryUrlInJson() async {
    final manager_json = await ManipulateJsonFileRedirect.create();
    List<Map<String, dynamic>> data_fromjsonList = manager_json.dataFromJson;
    if (data_fromjsonList.isNotEmpty) {
      List<Future> tasks_gathering_data = List.empty(growable: true);
      au.Browser browser = await au.WebAutomationFramework.launch();
      for (var map_data_json in data_fromjsonList) {
        final String url_reference = map_data_json["Url_Reference"];
        final GatheringUrls acces_page_object =
            await this._getObjectAcceesPage(url_reference);
        final RegisterMetaData _metaData =
            await this._load_MetaDataByUrlSpecific(url_reference);
        Map<String, dynamic> map_acceesobject_metadata = {
          "accees": acces_page_object,
          "metadata": _metaData
        };
        tasks_gathering_data.add(this.gatheringDataWithUrl(
            map_acceesobject_metadata, url_reference, browser));
      }
      await Future.wait(tasks_gathering_data);
      await browser.close();
    }
  }

  Future<void> gatheringDataWithUrl(
      Map<String, dynamic> map_acceesobject_metadata,
      String url_reference_fromjson,
      au.Browser browser) async {
    final GatheringUrls object_accees = map_acceesobject_metadata["accees"];
    String titre_parameter = "";
    await lock.run(() async {
      titre_parameter = this._dictionnaryParametersVideo["Titre"];
    });
    au.Page page_from_browser = await browser.newPage();
    await page_from_browser.emulate(au.Device(
        viewport: au.Viewport(height: 1296, width: 976, isMobile: true),
        userAgent: ""));
    try {
      await page_from_browser.goto(
          url: url_reference_fromjson,
          waitUntil: au.WaitUntil.domcontentloaded,
          timeout: 15);
    } on Exception catch (exception) {
      await page_from_browser.close();
      return;
    }
    try {
      final String requete_Of_IconMenu_search =
          (object_accees as IrequestForDataMandatory)
              .getRequeteXpathOfIconMenu();
      if (requete_Of_IconMenu_search.isNotEmpty) {
        await page_from_browser.click(selector: requete_Of_IconMenu_search);
      }
    } on Exception catch (exeption) {
      await page_from_browser.close();
      return;
    }
    try {
      final requete_Of_Entry_Field_Search =
          (object_accees as IrequestForDataMandatory)
              .getRequeteXpathOfEntryFieldSearch();
      await page_from_browser.evaluate(
          source:
              "document.querySelector('${requete_Of_Entry_Field_Search}').value =\"\";");
      await Future.delayed(Duration(milliseconds: 500)); //
      final String titre_parameter_without_special_caracteres =
          titre_parameter.replaceAll("'", "").replaceAll("\"", "");
      await page_from_browser.type(
          selector: (object_accees as IrequestForDataMandatory)
              .getRequeteXpathOfEntryFieldSearch(),
          text: titre_parameter_without_special_caracteres);
      await Future.delayed(Duration(milliseconds: 2500)); //
    } on Exception catch (exception) {
      await page_from_browser.close();
      return;
    }
    if ((object_accees as IrequestForDataMandatory)
            .isResulstOFSearchOnSamePageThatPageContainsEntry() ==
        false) {
      try {
        await page_from_browser.click(
            selector: (object_accees as IrequestButtonsearch)
                .getRequeteXpathOfButtonSearch() as String);

        await page_from_browser.waitForNavigation();
      } on Exception catch (exception) {
        await page_from_browser.close();
        return;
      }
    }

    try {
      await page_from_browser.waitForSelector(
          selector: (object_accees as IrequestForDataMandatory)
              .getRequeteXpathOfTitleInResultsOfSearch()
              .split("!")
              .last);
    } on Exception catch (exception) {
      await page_from_browser.close();
      return;
    }

    html.Element html_dom_at_display_result_search =
        ManagerHtmlDom.ParseHtmlDoc("${await page_from_browser.content()}");
    dynamic titles_of_result_after_search;
    try {
      titles_of_result_after_search = html_dom_at_display_result_search
          .queryXPath((object_accees as IrequestForDataMandatory)
              .getRequeteXpathOfTitleInResultsOfSearch(
                  is_for_value_of_attribute: true)
              .split("!")
              .first);
    } on Exception catch (exception) {
      debugPrint(
          "resultat de titres non recuperer ! => ${(object_accees as IrequestForDataMandatory).getRequeteXpathOfTitleInResultsOfSearch(is_for_value_of_attribute: true).split("!").first} from ${exception}");
      return;
    }

    if (titles_of_result_after_search.nodes.isNotEmpty) {
      String link_page_next = "";
      for (final (index, title_result)
          in (titles_of_result_after_search.nodes as Iterable).indexed) {
        final String title_formated =
            title_result.text!.replaceAll("\n", "").trim().toUpperCase();
        if (titre_parameter.toUpperCase() == title_formated) {
          final String request_links_in_result =
              (object_accees as IrequestForDataMandatory)
                  .getRequeteXpathOfLinksInResultsOfSearch();
          final XPathResult result_xpath = html_dom_at_display_result_search
              .queryXPath(request_links_in_result);
          final XPathNode node_link = result_xpath.nodes[index];
          if (node_link.attributes.containsKey("href")) {
            link_page_next = node_link.attributes["href"]!;
          } else {
            link_page_next = node_link.nextSibling!.attributes["href"]!;
          }
          break;
        }
      }
      if (link_page_next.isEmpty) {
        await page_from_browser.close();
        return;
      }
      try {
        await page_from_browser.goto(
            url: link_page_next, waitUntil: au.WaitUntil.domcontentloaded);
      } on Exception catch (exception) {
        await page_from_browser.close();
        return;
      }
      await Future.delayed(Duration(milliseconds: 600)); //
      html_dom_at_display_result_search =
          ManagerHtmlDom.ParseHtmlDoc((await page_from_browser.content())!);
      final String categorie_parameter = await lock.run(() async {
        return this._dictionnaryParametersVideo["Categorie"];
      });
      if (categorie_parameter == "Film") {
        await this._process_GetLinkWatchOnMovie(map_acceesobject_metadata,
            html_dom_at_display_result_search, link_page_next);
      } else if (categorie_parameter == "Serie") {
        await this._process_GetLinkWatchOnSerie(
            map_acceesobject_metadata,
            html_dom_at_display_result_search,
            link_page_next,
            page_from_browser);
      }
    }
  }

  Future<void> _process_GetLinkWatchOnMovie(
      Map<String, dynamic> map_acceesobject_metadata,
      html.Element _html_dom_at_page_video_display,
      String _link_page_video_display) async {
    final String requete_xpath_of_link_video =
        (map_acceesobject_metadata["accees"] as IrequestMovieVideo)
            .getRequeteXpathOfLinkOfMovieOnVideo()
            .toString();
    Object link_video = "";
    if (requete_xpath_of_link_video.split(r"/").last != "@href") {
      link_video = _link_page_video_display;
    } else {
      link_video = _html_dom_at_page_video_display
          .queryXPath(requete_xpath_of_link_video.replaceFirst("/@href", ""))
          .nodes
          .first;
    }

    final bool is_urlvideo_has_attrib_get = link_video is XPathNode
        ? (link_video).attributes.containsKey("href")
        : false;

    final bool is_urlvideo_has_attrib_get_and_startwith_http =
        is_urlvideo_has_attrib_get &&
            link_video.attributes["href"]!.startsWith(RegExp("http|HTTP"));

    if (is_urlvideo_has_attrib_get_and_startwith_http) {
      link_video = link_video.attributes["href"]!;
    } else if (is_urlvideo_has_attrib_get) {
      link_video = link_video.attributes["href"]!;
      link_video =
          "${_link_page_video_display}${_link_page_video_display.endsWith("/") == false ? "/" : ""}$link_video";
    } else {
      link_video = link_video as String;
    }
    await this._updateListOfResults(
        name_site:
            (map_acceesobject_metadata["metadata"] as RegisterMetaData).name,
        link_video: link_video.toString());
  }

  Future<void> _process_GetLinkWatchOnSerie(
      Map<String, dynamic> map_acceesobject_metadata,
      html.Element _html_dom_at_page_video_display,
      String _link_page_video_display,
      au.Page page_from_browser) async {
    GatheringUrls object_accees = map_acceesobject_metadata["accees"];
    RegisterMetaData meta_data = map_acceesobject_metadata["metadata"];
    String link_video = "";
    try {
      if ((object_accees).getConfigurationPanelsLinksOnSite() ==
          EnumerationPanelsLinks
              .HavePanelLinksSaisons_And_HavePanelLinksEpisodes) {
        final au.Page page_from_browser_of_saison_on_video = await this
            ._goto_page_of_saison_specific_with_browser(
                map_acceesobject_metadata,
                _html_dom_at_page_video_display,
                _link_page_video_display,
                page_from_browser);
        final html.Element html_dom_containing_linkvideo =
            ManagerHtmlDom.ParseHtmlDoc(
                (await page_from_browser_of_saison_on_video.content())!);
        link_video = await this._get_Url_Episode_Corresponding(
            map_acceesobject_metadata: map_acceesobject_metadata,
            html_dom_at_page_video_where_is_episodes:
                html_dom_containing_linkvideo);
      } else if ((object_accees).getConfigurationPanelsLinksOnSite() ==
          EnumerationPanelsLinks
              .HavePanelLinksSaisons_And_DontHavePanelLinksEpisodes) {
        final au.Page page_from_browser_of_saison_on_video = await this
            ._goto_page_of_saison_specific_with_browser(
                map_acceesobject_metadata,
                _html_dom_at_page_video_display,
                _link_page_video_display,
                page_from_browser);
        link_video = (await page_from_browser_of_saison_on_video.url())!;
      } else if ((object_accees).getConfigurationPanelsLinksOnSite() ==
          EnumerationPanelsLinks
              .DontHavePanelLinksSaison_And_HavePanelLinksEpisodes) {
        link_video = await this._get_Url_Episode_Corresponding(
            map_acceesobject_metadata: map_acceesobject_metadata,
            html_dom_at_page_video_where_is_episodes:
                _html_dom_at_page_video_display);
      } else if ((object_accees).getConfigurationPanelsLinksOnSite() ==
          EnumerationPanelsLinks
              .DontHavePanelLinksSaisons_And_DontHavePanelLinksEpisodes) {
        link_video = _link_page_video_display;
      }
      if (link_video.isNotEmpty) {
        await this._updateListOfResults(
            name_site: meta_data.name, link_video: link_video);
      }
    } on Exception catch (exception) {
      await page_from_browser.close();
      return;
    }
  }

  Future<au.Page> _goto_page_of_saison_specific_with_browser(
      Map<String, dynamic> map_acceesobject_metadata,
      html.Element _html_dom_at_page_video_display,
      String _link_page_video_display,
      au.Page page_from_browser) async {
    GatheringUrls object_accees = map_acceesobject_metadata["accees"];
    RegisterMetaData meta_data = map_acceesobject_metadata["metadata"];
    int saison_parameter = 0;
    await lock.run(() async {
      saison_parameter = this._dictionnaryParametersVideo["Saison"];
    });
    await Future.delayed(Duration(milliseconds: 600)); //
    final String request_saison = (object_accees as IrequestSaisonVideo)
        .getRequeteXpathOfLinksOfSaisonsOnVideo()
        .toString()
        .replaceFirst("/@href", "");
    final List<XPathNode> nodes_xpath_result =
        _html_dom_at_page_video_display.queryXPath(request_saison).nodes;
    for (var node_result in nodes_xpath_result) {
      RegExpMatch? result_on_regex = null;
      bool is_matched = false;
      final List<String> values_of_attributes_on_this_tag = [node_result.text!];
      if (node_result.attributes.containsKey("href")) {
        int length_in_value_href =
            node_result.attributes["href"]!.split("/").length;
        values_of_attributes_on_this_tag.add(node_result.attributes["href"]!
            .split(
                "/")[length_in_value_href > 1 ? length_in_value_href - 2 : 0]);
      }

      int index_fetch_values = 0;
      while (index_fetch_values < values_of_attributes_on_this_tag.length &&
          is_matched == false) {
        result_on_regex = RegExp(meta_data.regex_On_Saisons, multiLine: true)
            .firstMatch(values_of_attributes_on_this_tag[index_fetch_values]);
        index_fetch_values += 1;
        if (result_on_regex != null) {
          is_matched = true;
        }
      }
      final int numero_saison =
          is_matched ? int.parse(result_on_regex!.group(1)!) : 0;
      if (numero_saison == saison_parameter) {
        final String url_saison = this.__extractUrlSaison(
            link_page_video_display: _link_page_video_display,
            node_saison: node_result);
        await page_from_browser.goto(
            url: url_saison, waitUntil: au.WaitUntil.domcontentloaded);
        await Future.delayed(Duration(seconds: 1)); //
        return page_from_browser;
      }
    }
    return page_from_browser;
  }

  Future<void> _updateListOfResults(
      {required String name_site, required String link_video}) async {
    await lock.run(() async {
      this.dataResult.listDictionnaryResult.add(this
          ._getDictionnaryResultCreated(
              name_site: name_site, link_video: link_video));
      this._isLinkatLeastOneFound = true;
    });
  }

  String __extractUrlSaison(
      {required String link_page_video_display,
      required XPathNode node_saison}) {
    final String url_saison = node_saison.attributes["href"]!;
    final bool is_url_saison_startwith_http =
        url_saison.startsWith(RegExp("http|HTTP"));
    if (is_url_saison_startwith_http) {
      return url_saison;
    } else {
      return "${link_page_video_display}${link_page_video_display.endsWith("/") == false ? "/" : ""}$url_saison";
    }
  }

  Future<String> _get_Url_Episode_Corresponding(
      {required Map<String, dynamic> map_acceesobject_metadata,
      required html.Element html_dom_at_page_video_where_is_episodes}) async {
    int episode_parameter = 1;
    await lock.run(() async {
      episode_parameter = this._dictionnaryParametersVideo["Episode"];
    });
    final String request_episodes =
        (map_acceesobject_metadata["accees"] as IrequestEpisodeVideo)
            .getRequeteXpathOfEpisodeOnVideo()
            .toString()
            .replaceFirst("/@href", "");
    final List<XPathNode> nodes_xpath_result =
        html_dom_at_page_video_where_is_episodes
            .queryXPath(request_episodes)
            .nodes;
    for (var node_result in nodes_xpath_result) {
      final int numero_episode = int.parse(RegExp(
              (map_acceesobject_metadata["metadata"] as RegisterMetaData)
                  .regex_On_Episodes,
              multiLine: true)
          .firstMatch(node_result.text!.trim())!
          .group(1)!);
      if (numero_episode == episode_parameter) {
        return this._extractUrlEpisode(node_result);
      }
    }
    return "";
  }

  String _extractUrlEpisode(XPathNode node_episode) =>
      node_episode.attributes["href"]!;

  Map<String, String> _getDictionnaryResultCreated(
          {required String name_site, required String link_video}) =>
      {"Name_Site": name_site, "Link": link_video};

  Future<GatheringUrls> _getObjectAcceesPage(
      String url_reference_fromjson) async {
    return (await UseDictionnaryUrlObjectacess.create())
        .dictionnaryUrlObjectAcess[url_reference_fromjson]!();
  }

  static Future<GatheringUrls> getObjectAcceesPage(
      String url_reference_fromjson) async {
    return (await UseDictionnaryUrlObjectacess.create())
        .dictionnaryUrlObjectAcess[url_reference_fromjson]!();
  }
}
