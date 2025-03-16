import 'dart:convert';
import 'dart:io';

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
  }

  void _updateFile(List<Map<String, dynamic>> newdata_fromjson) async {
    var file =
        File('lib/Services/Manipulate_Json_File/Scrapping_Register.json');
    var sink = file.openWrite(mode: FileMode.write);
    sink.write(jsonEncode(newdata_fromjson));
    await sink.flush();
    await sink.close();
    this._dataFromJson = newdata_fromjson;
  }
}
