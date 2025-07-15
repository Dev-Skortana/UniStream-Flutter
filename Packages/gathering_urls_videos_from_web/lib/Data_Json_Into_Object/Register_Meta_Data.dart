part of gathering_urls_videos_from_web;

class RegisterMetaData {
  late String _name;

  String get name => this._name;
  void set name(String value) {
    this._name = value;
  }

  late String _url_Reference;

  String get url_Reference => this._url_Reference;
  void set url_Reference(String value) {
    this._url_Reference = value;
  }

  late String _regex_On_Saisons;

  String get regex_On_Saisons => this._regex_On_Saisons;
  void set regex_On_Saisons(String value) {
    this._regex_On_Saisons = value;
  }

  late String _regex_On_Episodes;

  String get regex_On_Episodes => this._regex_On_Episodes;
  void set regex_On_Episodes(String value) {
    this._regex_On_Episodes = value;
  }

  RegisterMetaData(this._name, this._url_Reference, this._regex_On_Episodes,
      this._regex_On_Saisons) {}

  static RegisterMetaData getEmptyRegisterMetaData() =>
      RegisterMetaData("", "", "", "");
}
