part of gathering_urls_videos_from_web;

class ManipJsonFileUpdate {
  late List<Map<String, dynamic>> _dataFromJson;

  List<Map<String, dynamic>> get dataFromJson => this._dataFromJson;
  void set dataFromJson(List<Map<String, dynamic>> value) {
    this._dataFromJson = value;
  }

  ManipJsonFileUpdate(this._dataFromJson) {}

  void addIdentifiantsToJson(List identififants) {
    List<Map<String, dynamic>> copy_datafromjson =
        jsonDecode(jsonEncode(this._dataFromJson));
    for (var (index, dictionnary) in copy_datafromjson.indexed) {
      dictionnary["Identifiant"] = identififants[index];
    }
    this._updateFile(copy_datafromjson);
  }

  void _updateFile(List<Map<String, dynamic>> newdata_fromjson) async {
    var file = File(
        'packages/gathering_urls_videos_from_web/assets/raw/Scrapping_Redirect.json');
    var sink = file.openWrite(mode: FileMode.write);
    sink.write(jsonEncode(newdata_fromjson));
    await sink.flush();
    await sink.close();
    this._dataFromJson = newdata_fromjson;
  }
}
