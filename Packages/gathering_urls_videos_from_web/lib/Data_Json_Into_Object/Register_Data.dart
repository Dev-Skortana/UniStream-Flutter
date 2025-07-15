part of gathering_urls_videos_from_web;

class RegisterData {
  late RegisterMetaData _registerMetaData;

  RegisterMetaData get registerMetaData => this._registerMetaData;
  void set registerMetaData(RegisterMetaData value) {
    this._registerMetaData = value;
  }

  late List<Map<String, String>> _listDictionnaryResult;

  List<Map<String, String>> get listDictionnaryResult =>
      this._listDictionnaryResult;
  void set listDictionnaryResult(List<Map<String, String>> value) {
    this._listDictionnaryResult = value;
  }

  RegisterData(this._registerMetaData, this._listDictionnaryResult) {}

  static getEmptyRegisterData() =>
      RegisterData(RegisterMetaData.getEmptyRegisterMetaData(), []);
}
