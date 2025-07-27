import './Enumeration/Enumerations_Methodes_Recherches.dart';

class SetSearch {
  late String _typeField;

  String get typeField => this._typeField;
  void set typeField(String value) {
    this._typeField = value;
  }

  late String _field;

  String get field => this._field;
  void set field(String value) {
    this._field = value;
  }

  late Object _value_of_search;

  Object get valueOfSearch => this._value_of_search;
  void set valueOfSearch(Object value) {
    this._value_of_search = value;
  }

  late Object? _value_of_search_secondary = "";

  Object? get valueOfSearchSecondary => this._value_of_search_secondary;
  void set valueOfSearchSecondary(Object? value) {
    this._value_of_search_secondary = value!;
  }

  late EnumerationsMethodesRecherches _methode_recherche;

  EnumerationsMethodesRecherches get methodeRecherche =>
      this._methode_recherche;
  void set methodeRecherche(EnumerationsMethodesRecherches value) {
    this._methode_recherche = value;
  }

  SetSearch(this._typeField, this._field, this._value_of_search,
      this._methode_recherche,
      [this._value_of_search_secondary]);
}
