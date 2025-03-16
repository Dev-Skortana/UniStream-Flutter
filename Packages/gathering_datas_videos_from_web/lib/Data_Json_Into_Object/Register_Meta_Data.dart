part of gathering_data_videos_from_web;

class RegisterMetaData {
  late String _name;

  String get Name => this._name;
  void set Name(String value) {
    this._name = value;
  }

  late String _url_Reference;

  String get Url_Reference => this._url_Reference;
  void set Url_Reference(String value) {
    this._url_Reference = value;
  }

  late String _titre;

  String get Titre => this._titre;
  void set Titre(String value) {
    this._titre = value;
  }

  late String _description;

  String get Description => this._description;
  void set Description(String value) {
    this._description = value;
  }

  late String _duree;

  String get Duree => this._duree;
  void set Duree(String value) {
    this._duree = value;
  }

  late String _date_Parution;

  String get Date_Parution => this._date_Parution;
  void set Date_Parution(String value) {
    this._date_Parution = value;
  }

  late String _type_Video;

  String get Type_Video => this._type_Video;
  void set Type_Video(String value) {
    this._type_Video = value;
  }

  late String _lien_Affiche;

  String get Lien_Affiche => this._lien_Affiche;
  void set Lien_Affiche(String value) {
    this._lien_Affiche = value;
  }

  late String _liste_Genres;

  String get Liste_Genres => this._liste_Genres;
  void set Liste_Genres(String value) {
    this._liste_Genres = value;
  }

  late String _liste_Pays;

  String get Liste_Pays => this._liste_Pays;
  void set Liste_Pays(String value) {
    this._liste_Pays = value;
  }

  late String _liste_Realisateurs;

  String get Liste_Realisateurs => this._liste_Realisateurs;
  void set Liste_Realisateurs(String value) {
    this._liste_Realisateurs = value;
  }

  late String _saisons;

  String get Saisons => this._saisons;
  void set Saisons(String value) {
    this._saisons = value;
  }

  late String _episodes;

  String get Episodes => this._episodes;
  void set Episodes(String value) {
    this._episodes = value;
  }

  late String _studio_Animes;

  String get Studio_Animes => this._studio_Animes;
  void set Studio_Animes(String value) {
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
}
