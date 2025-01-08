import 'package:unistream/Models/Templates/Base_Model.dart';

class Genre extends BaseModel {
  String _nom = "";
  String get nom => this._nom;
  void set nom(String value) {
    this._nom = value;
  }

  Genre({String nom = ""}) {
    this._nom = nom;
  }
}
