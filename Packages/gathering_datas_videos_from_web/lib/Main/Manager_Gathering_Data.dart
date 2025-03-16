part of gathering_data_videos_from_web;

class ManagerGatheringData {

  List<RegisterData> get listDataVideo => this._listDataVideo;
  void set listDataVideo(List<RegisterData> value) {
    this._listDataVideo = value;
  }

   Map<String,int> get dictionnaryNumerosPagination => this._dictionnaryNumerosPagination;
  void set dictionnaryNumerosPagination(Map<String,int> value) {
    this._dictionnaryNumerosPagination = value;
  }


  late EnumerationCategorieVideo _targetCategorieVideo;

  EnumerationCategorieVideo get targetCategorieVideo => this._targetCategorieVideo;
  void set targetCategorieVideo(EnumerationCategorieVideo value) {
    this._targetCategorieVideo = value;
  }

  late List<RegisterData> _listDataVideo;
  late dynamic _HtmlDom;
  late Acces _accesPageObject;
  late dynamic _session;
  late Map<String,int> _dictionnaryNumerosPagination;

  ManagerGatheringData({EnumerationCategorieVideo categorie_video_target=EnumerationCategorieVideo.AllCategories,int numpagebegenning=1,int numpageend=0}) {
    Map<String,dynamic> dictionnary_arguments={
      "categorie_video_target": categorie_video_target,
      "numpagebeginning":numpagebegenning,
      "numpageend":numpageend
    };
    this._initialize_parameters(dictionnary_arguments);
  }

  bool _isCheckArgumentIsPassedInContructor(
          {required Map<String, dynamic> parameters}) =>
      (parameters.length >= 2 &&
          parameters.keys.contains("type_video_target") &&
          parameters.keys.contains("numpagebegenning"));

  void _initialize_parameters(Map<String,dynamic> dictionnary_arguments) {
    this.targetCategorieVideo=dictionnary_arguments["type_video_target"];
    this._listDataVideo=List.empty();
    this._session=null;
    this._dictionnaryNumerosPagination={
      "numpagebeginning": dictionnary_arguments["numpagebegenning"],
            "numpageend": dictionnary_arguments["numpageend"]>0 && dictionnary_arguments["numpageend"]>dictionnary_arguments["numpagebegenning"] ? dictionnary_arguments["numpageend"] : dictionnary_arguments["numpagebegenning"],
            "numberspagemax": 1
    };
  }

  void startGathering()async {
    for(var row_register in await ManipulateJsonFileRegister.getDataFromJson()){
      this.asyncGatheringDataWithUrl(row_register["Url_Reference"]);
    }
  }

  Future asyncGatheringDataWithUrl(String url_reference_fromjson)async {
    /* TODO */
    this._accesPageObject=this.getObjectAcceesPage(url_reference_fromjson: url_reference_fromjson,targetcategorievideo:this._targetCategorieVideo.name);
    this._dictionnaryNumerosPagination["numberspagemax"]=await (this._accesPageObject as IscrapeData).getNumbersOfPages() ;
  
    return Future(() {});
  }

 static IscrapeData convertAccesToIscrapeData(Acces gathering_data)=>gathering_data as IscrapeData;

  Future _asyncStartGetDataFromPages(String url_reference_fromjson) {
    /* TODO */
    return Future(() {});
  }

  Future<bool> _IsConsistentNumbersOfPageBeginningAndEnd() =>
      Future(() => true);

  Future _asyncGetDataOfVideosFromOnePage({required int numpage,required String url_format_pagination,required String url_reference_fromjson}) {
    /* TODO */
    return Future(() {});
  }

  Future<RegisterMetaData> _load_MetaDataByUrlSpecific(String url_fromjson)async {
    /* TODO */
    var data=await ManipulateJsonFileRegister.getDataFromJson();
    return [for(var item in data) if (item["Url_Reference"]==url_fromjson) RegisterMetaData(item["Name"],item["Url_Reference"], item["Titre"], item["Description"], item["Duree"], item["Date_Parution"], item["Type_Video"], item["Lien_Affiche"], item["Liste_Genres"], item["Liste_Pays"], item["Liste_Realisateurs"], _saisons:item["Saisons"], _episodes:item["Episodes"], _studio_Animes:item["Studio_Animes"])][0] as RegisterMetaData;
  }

  Acces getObjectAcceesPage({required String url_reference_fromjson,required String targetcategorievideo}) => Acces();

  Future<Iterable<Map<String, String>>>
      _asyncGetDictionnaryOfTitleAndLinkPosterANDLinkPageVideo({required RegisterMetaData metadata,required String requete_xpath_oflinkonevideo}) =>
          Future(() => []);

  Future<Iterable> _asyncGetDatasOfDictionnary({required String request,required String field_to_gathering,required String field_condition}) => Future(() => []);

  Future<Iterable> _asyncParse({required RegisterMetaData metadata,required List<Map<String,String>> listdictionnary_title_and_linkposter_and_linkpagevideo}) => Future(() => []);

  Future<Map<int, Iterable<int>>> _getSaisonsEpisodes({required RegisterMetaData metadata,required String lienpage_video}) => Future(() => {});

  Future<bool> _isTypeVideoRight(String type_video_ghatering) => Future(() => true);

  Future<RegisterData> _asyncGetData({required dynamic html_dom,required RegisterMetaData metadata,required Map<String,String> dictionnary}) => Future(()=>);

  Future<flutter_type.TimeOfDay> _getDataDuration({required dynamic html_dom,required String requete_xpath})=>Future(()=>flutter_type.TimeOfDay.now());
}
