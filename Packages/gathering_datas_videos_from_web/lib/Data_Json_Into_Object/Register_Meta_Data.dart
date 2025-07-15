part of gathering_data_videos_from_web;

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

  late String _titre;

  String get titre => this._titre;
  void set titre(String value) {
    this._titre = value;
  }

  late String _description;

  String get description => this._description;
  void set description(String value) {
    this._description = value;
  }

  late String _duree;

  String get duree => this._duree;
  void set duree(String value) {
    this._duree = value;
  }

  late String _date_Parution;

  String get date_Parution => this._date_Parution;
  void set date_Parution(String value) {
    this._date_Parution = value;
  }

  late String _type_Video;

  String get type_Video => this._type_Video;
  void set type_Video(String value) {
    this._type_Video = value;
  }

  late String _lien_Affiche;

  String get lien_Affiche => this._lien_Affiche;
  void set lien_Affiche(String value) {
    this._lien_Affiche = value;
  }

  late String _liste_Genres;

  String get liste_Genres => this._liste_Genres;
  void set liste_Genres(String value) {
    this._liste_Genres = value;
  }

  late String _liste_Pays;

  String get liste_Pays => this._liste_Pays;
  void set liste_Pays(String value) {
    this._liste_Pays = value;
  }

  late String _liste_Realisateurs;

  String get liste_Realisateurs => this._liste_Realisateurs;
  void set liste_Realisateurs(String value) {
    this._liste_Realisateurs = value;
  }

  late String _saisons;

  String get saisons => this._saisons;
  void set saisons(String value) {
    this._saisons = value;
  }

  late String _episodes;

  String get episodes => this._episodes;
  void set episodes(String value) {
    this._episodes = value;
  }

  late String _studio_Animes;

  String get studio_Animes => this._studio_Animes;
  void set studio_Animes(String value) {
    this._studio_Animes = value;
  }

  RegisterMetaData(
      this._name,
      this._url_Reference,
      this._titre,
      this._description,
      this._duree,
      this._date_Parution,
      this._type_Video,
      this._lien_Affiche,
      this._liste_Genres,
      this._liste_Pays,
      this._liste_Realisateurs,
      this._saisons,
      this._episodes,
      this._studio_Animes);
  static RegisterMetaData getEmptyRegisterMetaData() =>
      RegisterMetaData("", "", "", "", "", "", "", "", "", "", "", "", "", "");
}
