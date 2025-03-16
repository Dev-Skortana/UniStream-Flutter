part of gathering_data_videos_from_web;

class ManipulateJsonFileRegister {
  late List<Map<String, dynamic>> _dataFromJson;

  List<Map<String, dynamic>> get dataFromJson => this._dataFromJson;
  void set dataFromJson(List<Map<String, dynamic>> value) {
    this._dataFromJson = value;
  }

  late ManipJsonFileRead manipulateJsonFileRead;
  late ManipJsonFileUpdate manipulateJsonFileUpdate;

  ManipulateJsonFileRegister._create(
      List<Map<String, dynamic>> data_from_json) {
    this._dataFromJson = data_from_json;
    this.manipulateJsonFileRead = ManipJsonFileRead(this._dataFromJson);
    this.manipulateJsonFileUpdate = ManipJsonFileUpdate(this._dataFromJson);
  }

  static Future<ManipulateJsonFileRegister> create() async {
    List<Map<String, dynamic>> data_from_json =
        await ManipulateJsonFileRegister.getDataFromJson();
    return ManipulateJsonFileRegister._create(data_from_json);
  }

  static Future<List<Map<String, dynamic>>> getDataFromJson() async {
    final file =
        File('lib/Services/Manipulate_Json_File/Scrapping_Register.json');
    Stream<String> content = file.openRead().transform(utf8.decoder);
    List<Map<String, dynamic>> data_json = jsonDecode(await content.single);
    return data_json;
  }

  void checkConsistanceFile() {
    if (this._isDictionnarysHasRightIdentifiants() == false) {
      this._generateIdentifiants();
    }
  }

  void _generateIdentifiants() {
    List<String> list_identifiants = BuilderIdentifiants()
        .getIdentifiants(how_many_identifiers: 0, lenght: 0);
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
