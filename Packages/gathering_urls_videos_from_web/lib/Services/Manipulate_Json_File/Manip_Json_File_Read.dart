part of gathering_urls_videos_from_web;

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
}
