import 'package:unistream/Models/Templates/Base_Model.dart';

class Pays extends BaseModel {
  String _nom = "";
  String get nom => this._nom;
  void set nom(String value) {
    this._nom = value;
  }

  Pays({String nom = ""}) : super() {
    this._nom = nom;
  }
}
