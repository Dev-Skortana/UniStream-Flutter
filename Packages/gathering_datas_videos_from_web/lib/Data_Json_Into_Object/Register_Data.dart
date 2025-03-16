part of gathering_data_videos_from_web;

class RegisterData {
  late RegisterMetaData _registerMetaData;

  RegisterMetaData get registerMetaData => this._registerMetaData;
  void set registerMetaData(RegisterMetaData value) {
    this._registerMetaData = value;
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

  late DateTime _date_Parution;

  DateTime get Date_Parution => this._date_Parution;
  void set Date_Parution(DateTime value) {
    this._date_Parution = value;
  }

  late flutter_type.TimeOfDay _duree;

  flutter_type.TimeOfDay get Duree => this._duree;
  void set Duree(flutter_type.TimeOfDay value) {
    this._duree = value;
  }

  late String _lien_Affiche;

  String get Lien_Affiche => this._lien_Affiche;
  void set Lien_Affiche(String value) {
    this._lien_Affiche = value;
  }

  late List<String> _liste_Genres;

  List<String> get Liste_Genres => this._liste_Genres;
  void set Liste_Genres(List<String> value) {
    this._liste_Genres = value;
  }

  late List<String> _liste_Pays;

  List<String> get Liste_Pays => this._liste_Pays;
  void set Liste_Pays(List<String> value) {
    this._liste_Pays = value;
  }

  late List<String> _liste_Realisateurs;

  List<String> get Liste_Realisateurs => this._liste_Realisateurs;
  void set Liste_Realisateurs(List<String> value) {
    this._liste_Realisateurs = value;
  }

  late Map<int, List<int>> _dictionnarySaisonWithEpisodeThem;

  Map<int, List<int>> get DictionnarySaisonWithEpisodeThem =>
      this._dictionnarySaisonWithEpisodeThem;
  void set DictionnarySaisonWithEpisodeThem(Map<int, List<int>> value) {
    this._dictionnarySaisonWithEpisodeThem = value;
  }

  late String _studio_Animes;

  String get Studio_Animes => this._studio_Animes;
  void set Studio_Animes(String value) {
    this._studio_Animes = value;
  }

  late EnumerationFulltypeVideo _fullType_Video;

  EnumerationFulltypeVideo get FullType_Video => this._fullType_Video;
  void set FullType_Video(EnumerationFulltypeVideo value) {
    this._fullType_Video = value;
  }

  RegisterData(
      this._registerMetaData,
      this._titre,
      this._description,
      this._duree,
      this._date_Parution,
      this._lien_Affiche,
      this._liste_Genres,
      this._liste_Pays,
      this._liste_Realisateurs,
      this._dictionnarySaisonWithEpisodeThem,
      this._studio_Animes,
      this._fullType_Video) {}
}
