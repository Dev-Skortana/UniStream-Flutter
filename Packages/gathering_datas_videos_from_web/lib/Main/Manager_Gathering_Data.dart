part of gathering_data_videos_from_web;

class ManagerGatheringData {
  final lock = Lock();

  List<RegisterData> get listDataVideo => this._listDataVideo;
  void set listDataVideo(List<RegisterData> value) {
    this._listDataVideo = value;
  }

  Map<String, int> get dictionnaryNumerosPagination =>
      this._dictionnaryNumerosPagination;
  void set dictionnaryNumerosPagination(Map<String, int> value) {
    this._dictionnaryNumerosPagination = value;
  }

  late EnumerationCategorieVideo _targetCategorieVideo;

  EnumerationCategorieVideo get targetCategorieVideo =>
      this._targetCategorieVideo;
  void set targetCategorieVideo(EnumerationCategorieVideo value) {
    this._targetCategorieVideo = value;
  }

  late List<RegisterData> _listDataVideo;
  late Element _HtmlDom;
  late Acces _accesPageObject;
  late dynamic _session;
  late Map<String, int> _dictionnaryNumerosPagination;

  ManagerGatheringData(
      {EnumerationCategorieVideo categorie_video_target =
          EnumerationCategorieVideo.AllCategories,
      int numpagebegenning = 1,
      int numpageend = 0}) {
    Map<String, dynamic> dictionnary_arguments = {
      "categorie_video_target": categorie_video_target,
      "numpagebeginning": numpagebegenning,
      "numpageend": numpageend
    };
    if (this._isCheckArgumentIsPassedInContructor(
        parameters: dictionnary_arguments)) {
      ManagerLogging.createLoggerIfNotExistAndConfigure();
      this._initialize_parameters(dictionnary_arguments);
    }
  }

  bool _isCheckArgumentIsPassedInContructor(
          {required Map<String, dynamic> parameters}) =>
      (parameters.length >= 2 &&
          parameters.keys.contains("categorie_video_target") &&
          parameters.keys.contains("numpagebeginning"));

  void _initialize_parameters(Map<String, dynamic> dictionnary_arguments) {
    this.targetCategorieVideo = dictionnary_arguments["categorie_video_target"];
    this._listDataVideo = List.empty();
    this._session = null;
    this._dictionnaryNumerosPagination = {
      "numpagebeginning": dictionnary_arguments["numpagebeginning"],
      "numpageend": dictionnary_arguments["numpageend"] > 0 &&
              dictionnary_arguments["numpageend"] >
                  dictionnary_arguments["numpagebeginning"]
          ? dictionnary_arguments["numpageend"]
          : dictionnary_arguments["numpagebeginning"],
      "numberspagemax": 1
    };
  }

  void startGathering() async {
    for (var row_register
        in await ManipulateJsonFileRegister.getDataFromJson()) {
      this.asyncGatheringDataWithUrl(row_register["Url_Reference"]);
    }
  }

  Future asyncGatheringDataWithUrl(String url_reference_fromjson) async {
    /* TODO */

    await lock.run(() async {
      this._accesPageObject = await this.getObjectAcceesPage(
          url_reference_fromjson: url_reference_fromjson,
          targetcategorievideo: this._targetCategorieVideo.name);
      this._dictionnaryNumerosPagination["numberspagemax"] =
          await (this._accesPageObject as IscrapeData).getNumbersOfPages();
      return await Future.value();
    });
    await this._asyncStartGetDataFromPages(url_reference_fromjson);
  }

  static IscrapeData convertAccesToIscrapeData(Acces gathering_data) =>
      gathering_data as IscrapeData;

  Future _asyncStartGetDataFromPages(String url_reference_fromjson) async {
    /* TODO */
    bool isConsistentNumbersOfPages =
        await this._IsConsistentNumbersOfPageBeginningAndEnd();
    int numpagebeginning = 0;
    int numpageend = 0;
    String url_format_pagination = "";
    await lock.run(() async {
      numpagebeginning =
          this._dictionnaryNumerosPagination["numpagebeginning"]!;
      numpageend = this._dictionnaryNumerosPagination["numpageend"]! + 1;
      url_format_pagination = await (this._accesPageObject as IscrapeData)
          .getFormatOfPaginationinUrl();
    });
    for (int numpage = numpagebeginning; numpage < numpageend; numpage++) {
      await this._asyncGetDataOfVideosFromOnePage(
          numpage: numpage,
          url_format_pagination: url_format_pagination,
          url_reference_fromjson: url_reference_fromjson);
      await Future.delayed(Duration(seconds: 3), () {});
    }
  }

  Future<bool> _IsConsistentNumbersOfPageBeginningAndEnd() async {
    bool rep = false;
    await lock.run(() async {
      rep = this._dictionnaryNumerosPagination["numberspagemax"]! >=
              this._dictionnaryNumerosPagination["numpagebeginning"]! &&
          this._dictionnaryNumerosPagination["numpageend"]! <=
              this._dictionnaryNumerosPagination["numberspagemax"]! &&
          this._dictionnaryNumerosPagination["numpagebeginning"]! <=
              this._dictionnaryNumerosPagination["numpageend"]!;
      return rep;
    });
    return rep;
  }

  Future _asyncGetDataOfVideosFromOnePage(
      {required int numpage,
      required String url_format_pagination,
      required String url_reference_fromjson}) async {
    /* TODO */
    final RegisterMetaData metaData =
        await this._load_MetaDataByUrlSpecific(url_reference_fromjson);
    final String urlpage =
        url_format_pagination.replaceFirst(":mark:", numpage.toString());
    final http.Response response = await http.get(Uri.parse(urlpage));
    String requeteXpathOfLinkOfOneVideo = "";
    await lock.run(() async {
      this._HtmlDom = ManagerHtmlDom.ParseHtmlDoc(response.body);
      requeteXpathOfLinkOfOneVideo =
          (this._accesPageObject as IrequestForDataMandatory)
              .getRequeteXpathOfLinkOfOneVideo();
    });
    final Iterable<Map<String, String>> map_titre_linkposter_linkpagevideo =
        await this._asyncGetDictionnaryOfTitleAndLinkPosterANDLinkPageVideo(
            metadata: metaData,
            requete_xpath_oflinkonevideo: requeteXpathOfLinkOfOneVideo);
    final List<RegisterData> data_videos_of_this_page = await this._asyncParse(
        metadata: metaData,
        listdictionnary_title_and_linkposter_and_linkpagevideo:
            map_titre_linkposter_linkpagevideo);
    await lock.run(() async {
      this.listDataVideo = this.listDataVideo + data_videos_of_this_page;
    });
  }

  Future<RegisterMetaData> _load_MetaDataByUrlSpecific(
      String url_fromjson) async {
    var data = await ManipulateJsonFileRegister.getDataFromJson();
    final Map map_metadata =
        data.firstWhere((element) => element["Url_Reference"] == url_fromjson);
    return RegisterMetaData(
        map_metadata["Name"],
        map_metadata["Url_Reference"],
        map_metadata["Titre"],
        map_metadata["Description"],
        map_metadata["Duree"],
        map_metadata["Date_Parution"],
        map_metadata["Type_Video"],
        map_metadata["Lien_Affiche"],
        map_metadata["Liste_Genres"],
        map_metadata["Liste_Pays"],
        map_metadata["Liste_Realisateurs"],
        map_metadata["Saisons"],
        map_metadata["Episodes"],
        map_metadata.containsKey("Studio_Animes")
            ? map_metadata["Studio_Animes"]
            : "none"); // à rectifier !
  }

  Future<Acces> getObjectAcceesPage(
      {required String url_reference_fromjson,
      required String targetcategorievideo}) async {
    final ManipulateJsonFileRegister manipulate_register =
        await ManipulateJsonFileRegister.create();
    final Map row_register = manipulate_register.manipulateJsonFileRead
        .getDictionnaryOfSiteData(url_reference_fromjson);
    final String site_name = row_register["Name"];
    final String identifiant = row_register["Identifiant"];
    UseDictionnaryCategorieUrlpage map_categoriepage =
        UseDictionnaryCategorieUrlpage(
            site_name: site_name,
            url_page_videos: manipulate_register.manipulateJsonFileRead
                .getUrlOfPageVideos(
                    identifiant: identifiant,
                    categorie_video: targetcategorievideo));
    return (await UseDictionnaryUrlObjectacess.create())
        .dictionnaryUrlObjectAcess[url_reference_fromjson]!(map_categoriepage);
  }

  Future<Iterable<Map<String, String>>>
      _asyncGetDictionnaryOfTitleAndLinkPosterANDLinkPageVideo(
          {required RegisterMetaData metadata,
          required String requete_xpath_oflinkonevideo}) async {
    List<Map<String, String>> list_dicos_titreandlinkposterandlinkpagevideo =
        List.empty(growable: true);
    final Future<List> tasks = Future.wait([
      this._asyncGetDatasOfDictionnary(
          request: metadata.titre,
          field_to_gathering: "alt",
          field_condition: "alt"),
      this._asyncGetDatasOfDictionnary(
          request: metadata.lien_Affiche, field_to_gathering: "src"),
      this._asyncGetDatasOfDictionnary(
          request: requete_xpath_oflinkonevideo, field_to_gathering: "href")
    ]);
    var lists_winthin_list = await tasks;
    List<String> titles = lists_winthin_list[0];

    List<String> lien_affiches = lists_winthin_list[1];
    List<String> liens_page_presentation = lists_winthin_list[2];
    for (var item in IterableZip<String>(
        [titles, lien_affiches, liens_page_presentation])) {
      list_dicos_titreandlinkposterandlinkpagevideo.add({
        "Title": item[0],
        "Link_poster": item[1],
        "Link_pagevideo": item[2]
      });
    }
    return list_dicos_titreandlinkposterandlinkpagevideo;
  }

  Future<Iterable> _asyncGetDatasOfDictionnary(
      {required String request,
      required String field_to_gathering,
      String field_condition = ""}) async {
    Iterable results = Iterable.empty();
    await lock.run(() async {
      if (field_condition != "") {
        results = _HtmlDom.queryXPath(request).nodes.map((el) {
          String? value_of_condition = el.attributes[field_condition];
          return value_of_condition != null
              ? el.attributes[field_to_gathering]
              : el.text!;
        });
      } else {
        results = _HtmlDom.queryXPath(request)
            .nodes
            .map((el) => el.attributes[field_to_gathering]);
      }

      return results.cast<String>().toList();
    });
    return results.cast<String>().toList();
  }

  Future<List<RegisterData>> _asyncParse(
      {required RegisterMetaData metadata,
      required Iterable<Map<String, String>>
          listdictionnary_title_and_linkposter_and_linkpagevideo}) async {
    List<Map<String, dynamic>> maps_linkvideo_registerdata =
        List.empty(growable: true);
    List<Future<Map<String, dynamic>>> tasks = List.empty(growable: true);
    bool is_filter_needed = false;
    await lock.run(() async {
      is_filter_needed =
          this.targetCategorieVideo != EnumerationCategorieVideo.AllCategories
              ? true
              : false;
    });
    for (Map dictionnary
        in listdictionnary_title_and_linkposter_and_linkpagevideo) {
      late Element html_dom_page_video_detailed;
      String categorie_video = "";
      await lock.run(() async {
        http.Response response =
            await http.get(Uri.parse(dictionnary["Link_pagevideo"]));
        html_dom_page_video_detailed =
            ManagerHtmlDom.ParseHtmlDoc(response.body);
        categorie_video = (this._accesPageObject as IscrapeData)
            .getCategorieVideo(
                html_dom: html_dom_page_video_detailed,
                requete_xpath: metadata.type_Video);
      });
      if (categorie_video != "Autre") {
        if (is_filter_needed) {
          if (await this._isTypeVideoRight(categorie_video)) {
            tasks.add((this._asyncGetMapLinkvideoWithDataregister(
                html_dom: html_dom_page_video_detailed,
                metadata: metadata,
                dictionnary: dictionnary.cast<String, String>())));
          }
        } else {
          tasks.add(this._asyncGetMapLinkvideoWithDataregister(
              html_dom: html_dom_page_video_detailed,
              metadata: metadata,
              dictionnary: dictionnary.cast<String, String>()));
        }
      }
      await Future.delayed(Duration(seconds: 1), () {});
    }
    maps_linkvideo_registerdata = await Future.wait(tasks);

    //Ce bloc de code doit etre executer de façon synchrone du faite qu'on ne peut pas lancer simultanement plusieurs instances de puppeter !
    //TODO
    List<RegisterData> datas_registers = List.empty(growable: true);
    for (var map_link_data in maps_linkvideo_registerdata) {
      map_link_data["Data"].dictionnarySaisonWithEpisodeThem = await this
          ._getSaisonsEpisodes(
              metadata: metadata,
              lienpage_video: map_link_data["Link_pagevideo"]);
      datas_registers.add(map_link_data["Data"]);
      debugPrint(
          " receive : ${map_link_data["Data"].titre} -> ${map_link_data["Data"].dictionnarySaisonWithEpisodeThem.toString()} from ${map_link_data["Link_pagevideo"]}");
    }

    return datas_registers.cast<RegisterData>();
  }

  Future<Map<int, List<int>>> _getSaisonsEpisodes(
      {required RegisterMetaData metadata,
      required String lienpage_video}) async {
    final http.Response response = await http.get(Uri.parse(lienpage_video));
    Element html_dom_pagepresentation_video =
        ManagerHtmlDom.ParseHtmlDoc(response.body);
    late Acces acces_page_object;
    String categorie_video;
    await lock.run(() async {
      acces_page_object = this._accesPageObject;
    });
    categorie_video = (acces_page_object as IscrapeData).getCategorieVideo(
        html_dom: html_dom_pagepresentation_video,
        requete_xpath: metadata.type_Video);
    try {
      if (categorie_video ==
          EnumerationCategorieVideo.Video_Serie.name.split("_").last) {
        return await acces_page_object.getSaisonAndEpisode(
            url_pagepresentation_video: lienpage_video,
            html_dom_pagepresentation_video: html_dom_pagepresentation_video,
            request_saisons: metadata.saisons,
            request_episodes: metadata._episodes);
      }
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la recuperation du dictionnaire comportant les saisons avec leurs episodes à été levée : ${exception}");
    }
    return <int, List<int>>{};
  }

  Future<bool> _isTypeVideoRight(String type_video_ghatering) async {
    String value_to_evaluate = "";
    await lock.run(() async {
      value_to_evaluate = this.targetCategorieVideo.name.split("_").last;
    });
    return value_to_evaluate == type_video_ghatering;
  }

  Future<Map<String, dynamic>> _asyncGetMapLinkvideoWithDataregister(
      {required Element html_dom,
      required RegisterMetaData metadata,
      required Map<String, String> dictionnary}) async {
    late Acces acces_page_object;
    await lock.run(() async {
      acces_page_object = this._accesPageObject;
    });
    String categorie_video = (acces_page_object as IscrapeData)
        .getCategorieVideo(
            html_dom: html_dom, requete_xpath: metadata.type_Video);
    RegisterData data_register = RegisterData.getEmptyRegisterData();
    data_register.registerMetaData = metadata;
    data_register.titre = dictionnary["Title"]!.trim();
    data_register.lien_Affiche = (await acces_page_object
            .getAbsoluteLinkFromUrlPageVideos(dictionnary["Link_poster"]!))
        .trim();
    try {
      var query_result = html_dom.queryXPath(metadata.description);
      if (query_result.nodes.isNotEmpty) {
        data_register.description = query_result.nodes.first.text!.trim();
      }
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la récuperation de la description à été levée : ${exception}");
    }

    try {
      data_register.duree = await this
          ._getDataDuration(html_dom: html_dom, requete_xpath: metadata.duree);
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la récuperation de la durée à été levée : ${exception}");
    }

    try {
      if (metadata.date_Parution != "none") {
        var query_result = html_dom.queryXPath(metadata.date_Parution);
        if (query_result.nodes.isNotEmpty) {
          String date_string = query_result.nodes.first.text!.trim();
          data_register.date_Parution = DateFormat("MMM dd, yyyy")
              .parse(date_string.replaceAll(RegExp(" {2,}"), " "));
        }
      }
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la récuperation de la date de parution à été levée : ${exception}");
    }

    try {
      if (metadata.liste_Genres != "none") {
        data_register.liste_Genres =
            GettingsValuesOrValue.getListOfOneOrManyValue(
                    html_dom: html_dom, requete_xpath: metadata.liste_Genres)
                .cast<String>();
      }
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la recuperation de la liste des genres à été levée : ${exception}");
    }

    try {
      if (metadata.liste_Pays != "none") {
        data_register.liste_Pays =
            GettingsValuesOrValue.getListOfOneOrManyValue(
                    html_dom: html_dom, requete_xpath: metadata.liste_Pays)
                .cast<String>();
      }
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la recuperation de la liste des pays à été levée : ${exception}");
    }

    try {
      if (metadata.liste_Realisateurs != "none") {
        data_register.liste_Realisateurs =
            GettingsValuesOrValue.getListOfOneOrManyValue(
                    html_dom: html_dom,
                    requete_xpath: metadata.liste_Realisateurs)
                .cast<String>();
      }
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la recuperation de la liste des réalisateurs à été levée : ${exception}");
    }

    try {
      if (metadata.studio_Animes != "none") {
        var query_result = html_dom.queryXPath(metadata.studio_Animes);
        if (query_result.nodes.isNotEmpty) {
          data_register.studio_Animes = query_result.nodes.first.text!.trim();
        }
      }
    } on Exception catch (exception) {
      ManagerLogging.logger.e(
          "Une erreure lors de la recuperation du studio animer ayant réaliser l'animer à été levée : ${exception}");
    }
    data_register.fullType_Video =
        acces_page_object.getFullTypeVideo(categorie_video);
    final Map<String, dynamic> map_to_return = {
      "Link_pagevideo": dictionnary["Link_pagevideo"]!,
      "Data": data_register
    };
    return map_to_return;
  }

  Future<flutter_type.TimeOfDay> _getDataDuration(
      {required Element html_dom, required String requete_xpath}) async {
    flutter_type.TimeOfDay result_to_return =
        flutter_type.TimeOfDay(hour: 0, minute: 0);
    late Acces acces_page_object;
    await lock.run(() async {
      acces_page_object = this._accesPageObject;
    });
    if (requete_xpath != "none") {
      final dynamic object_resultquery = html_dom.queryXPath(requete_xpath);
      final String value = object_resultquery.nodes.isNotEmpty
          ? object_resultquery.nodes.first.text!
          : "";
      final String request_regex = (await ManipulateJsonFileRegister.create())
          .manipulateJsonFileRead
          .getDictionnaryOfSiteData(
              await acces_page_object.getUrlBase())["Extract_Duree_On_Xpath"];
      RegExp regex_on_value = RegExp(request_regex);
      late RegExpMatch resul_regex_on_value;
      if (regex_on_value.hasMatch(value)) {
        resul_regex_on_value = regex_on_value.firstMatch(value)!;
        ManagerConvertDurationToTime managerDurationToTime =
            ManagerConvertDurationToTime(resul_regex_on_value);
        result_to_return = managerDurationToTime.convertStringDurationToTime();
      }
    }
    return result_to_return;
  }
}
