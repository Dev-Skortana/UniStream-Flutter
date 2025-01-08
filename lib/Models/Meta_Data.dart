class MetaData {
  String _nameField = "";
  String _typeField = "";

  String get nameField => this._nameField;
  void set nameField(String value) {
    this._nameField = value;
  }

  String get typeField => this._typeField;
  void set typeField(String value) {
    this._typeField = value;
  }

  MetaData({required String nameField, required String typeField}) : super() {
    this._nameField = nameField;
    this._typeField = typeField;
  }
}
