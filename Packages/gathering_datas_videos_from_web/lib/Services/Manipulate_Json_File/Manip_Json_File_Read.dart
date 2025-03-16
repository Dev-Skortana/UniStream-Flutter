part of gathering_data_videos_from_web;

class ManipJsonFileRead {
  late List<Map<String, dynamic>> _dataFromJson;

  ManipJsonFileRead(this._dataFromJson) {}

  List<String> getIdentifiants() {
    List<String> identifiants = [];
    for (var iteration in this._dataFromJson) {
      identifiants.add(iteration["Identifiant"]);
    }
    return identifiants;
  }

  Map<String, dynamic> getDictionnaryOfSiteData(String url_reference_fromjson) {
    Map<String, dynamic> row_register = {};
    for (var dictionnary in this._dataFromJson) {
      if (dictionnary["Url_Reference"] == url_reference_fromjson) {
        row_register = dictionnary;
        return row_register;
      }
    }
    return row_register;
  }

  List<String> getListSitesNames() {
    List<String> sites_names = [];
    for (var iteration in this._dataFromJson) {
      if (iteration.containsKey("Name")) {
        sites_names.add(iteration["Name"]);
      }
    }
    return sites_names;
  }

  String getUrlReferenceSite(String identifiant) {
    String url_reference_site = "";
    for (var iteration in this._dataFromJson) {
      if (iteration["Identifiant"] == identifiant) {
        url_reference_site = iteration["Url_Reference"];
      }
    }
    return url_reference_site;
  }

  String getUrlOfPageVideos(
      {required String identifiant, required String categorie_video}) {
    if (this._isAllCategorieFromJson(identifiant)) {
      return this._accessCategories(identifiant)["AllCategories"]["Url"];
    }
    return this._accessCategories(identifiant)[categorie_video]["Url"];
  }

  List<String> getListCategoriesVideo(String identifiant) {
    List<String> categories = [];
    for (var key_categorie in this._accessCategories(identifiant).keys) {
      categories.add(key_categorie);
    }
    return categories;
  }

  List<String> getListTypeVideo(
      {required String identifiant, required String categorie}) {
    Map dictionnary_categories = this._accessCategories(identifiant);
    if (this._isAllCategorieFromJson(identifiant)) {
      return this._getListTypeVideoOnSiteThatHaveAllCategorie(
          dictionnary_categories: dictionnary_categories, categorie: categorie);
    } else {
      return this._getListTypeVideoOnSiteDontHaveAllCategorie(
          dictionnary_categories: dictionnary_categories, categorie: categorie);
    }
  }

  List<String> _getListTypeVideoOnSiteThatHaveAllCategorie(
      {required Map dictionnary_categories, required String categorie}) {
    List<String> types_videos = [];
    Map dictionnary_types = dictionnary_categories["AllCategories"]["Types"];
    if (categorie == "AllCategories") {
      for (var entry in dictionnary_types.entries) {
        for (var value_type in entry.value) {
          types_videos.add(value_type);
        }
      }
    } else {
      for (var value in dictionnary_types[categorie]) {
        types_videos.add(value);
      }
    }
    return types_videos;
  }

  List<String> _getListTypeVideoOnSiteDontHaveAllCategorie(
      {required Map dictionnary_categories, required String categorie}) {
    List<String> types_videos = [];
    for (var key_categorie in dictionnary_categories.keys) {
      if (key_categorie == categorie) {
        for (var type in dictionnary_categories[key_categorie]["Types"]
            [categorie]) {
          types_videos.add(type);
        }
      }
    }
    return types_videos;
  }

  Map _accessCategories(String identifiant) {
    for (var iteration in this._dataFromJson) {
      if (iteration["Identifiant"] == identifiant) {
        return iteration["Categories"];
      }
    }
    return {};
  }

  bool _isAllCategorieFromJson(String identifiant) {
    List<String> categories = this.getListCategoriesVideo(identifiant);
    if (categories[0] == "AllCategories") {
      return true;
    }
    return false;
  }
}
