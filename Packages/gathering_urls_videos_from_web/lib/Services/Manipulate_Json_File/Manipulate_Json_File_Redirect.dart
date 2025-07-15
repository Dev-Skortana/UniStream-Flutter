part of gathering_urls_videos_from_web;

class ManipulateJsonFileRedirect {
  late List<Map<String, dynamic>> _dataFromJson;

  List<Map<String, dynamic>> get dataFromJson => this._dataFromJson;
  void set dataFromJson(List<Map<String, dynamic>> value) {
    this._dataFromJson = value;
  }

  late ManipJsonFileRead manipulateJsonFileRead;
  late ManipJsonFileUpdate manipulateJsonFileUpdate;

  ManipulateJsonFileRedirect._create(
      List<Map<String, dynamic>> data_from_json) {
    this._dataFromJson = data_from_json;
    this.manipulateJsonFileRead = ManipJsonFileRead(this._dataFromJson);
    this.manipulateJsonFileUpdate = ManipJsonFileUpdate(this._dataFromJson);
  }

  static Future<ManipulateJsonFileRedirect> create() async {
    List<Map<String, dynamic>> data_from_json =
        await ManipulateJsonFileRedirect.getDataFromJson();
    return ManipulateJsonFileRedirect._create(data_from_json);
  }

  static Future<List<Map<String, dynamic>>> getDataFromJson() async {
    final bytesdata_json = await rootBundle.load(
      "packages/gathering_urls_videos_from_web/assets/raw/Scrapping_Redirect.json",
    );
    final uint8from_bytesdata = Uint8List.sublistView(bytesdata_json);

    List<Map<String, dynamic>> data_json =
        (jsonDecode(utf8.decode(uint8from_bytesdata)) as List)
            .cast<Map<String, dynamic>>();
    return data_json;
  }

  void checkConsistanceFile() {
    if (this._isDictionnarysHasRightIdentifiants() == false) {
      // this._generateIdentifiants();
    }
  }

  void _generateIdentifiants() {
    List<String> identifiants = BuilderIdentifiants()
        .getIdentifiants(how_many_identifiers: this._dataFromJson.length);
    this.manipulateJsonFileUpdate.addIdentifiantsToJson(identifiants);
    this._actualiseDataOfJson();
  }

  void _actualiseDataOfJson() {
    this._dataFromJson = this.manipulateJsonFileUpdate.dataFromJson;
    this.manipulateJsonFileRead._dataFromJson =
        this.manipulateJsonFileUpdate.dataFromJson;
  }

  bool _isDictionnarysHasRightIdentifiants() {
    if (this.__IsEveryDictionnaryHasIdentifiants() == false) {
      return false;
    }

    if (this.__IsEveryValuesUnique() == false) {
      return false;
    }
    return true;
  }

  bool __IsEveryDictionnaryHasIdentifiants() {
    for (var dictionnary in this._dataFromJson) {
      if (dictionnary.containsKey("Identifiant") == false) {
        return false;
      }
    }
    return true;
  }

  bool __IsEveryValuesUnique() {
    List<String> liste_identifiants =
        this.manipulateJsonFileRead.getIdentifiants();
    Set set_identifiants = {...liste_identifiants};
    if (liste_identifiants.length != set_identifiants.length) {
      return false;
    }
    return true;
  }
}
