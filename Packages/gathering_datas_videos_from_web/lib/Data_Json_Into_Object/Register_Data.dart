part of gathering_data_videos_from_web;

class RegisterData {
  late RegisterMetaData _registerMetaData;

  RegisterMetaData get registerMetaData => this._registerMetaData;
  void set registerMetaData(RegisterMetaData value) {
    this._registerMetaData = value;
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

  late DateTime? _date_Parution;

  DateTime? get date_Parution => this._date_Parution;
  void set date_Parution(DateTime? value) {
    this._date_Parution = value;
  }

  late flutter_type.TimeOfDay _duree;

  flutter_type.TimeOfDay get duree => this._duree;
  void set duree(flutter_type.TimeOfDay value) {
    this._duree = value;
  }

  late String _lien_Affiche;

  String get lien_Affiche => this._lien_Affiche;
  void set lien_Affiche(String value) {
    this._lien_Affiche = value;
  }

  late List<String> _liste_Genres;

  List<String> get liste_Genres => this._liste_Genres;
  void set liste_Genres(List<String> value) {
    this._liste_Genres = value;
  }

  late List<String> _liste_Pays;

  List<String> get liste_Pays => this._liste_Pays;
  void set liste_Pays(List<String> value) {
    this._liste_Pays = value;
  }

  late List<String> _liste_Realisateurs;

  List<String> get liste_Realisateurs => this._liste_Realisateurs;
  void set liste_Realisateurs(List<String> value) {
    this._liste_Realisateurs = value;
  }

  late Map<int, List<int>> _dictionnarySaisonWithEpisodeThem;

  Map<int, List<int>> get dictionnarySaisonWithEpisodeThem =>
      this._dictionnarySaisonWithEpisodeThem;
  void set dictionnarySaisonWithEpisodeThem(Map<int, List<int>> value) {
    this._dictionnarySaisonWithEpisodeThem = value;
  }

  late String _studio_Animes;

  String get studio_Animes => this._studio_Animes;
  void set studio_Animes(String value) {
    this._studio_Animes = value;
  }

  late EnumerationFulltypeVideo _fullType_Video;

  EnumerationFulltypeVideo get fullType_Video => this._fullType_Video;
  void set fullType_Video(EnumerationFulltypeVideo value) {
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

  //fonction à revoir !
  static RegisterData getEmptyRegisterData() => RegisterData(
      RegisterMetaData.getEmptyRegisterMetaData(),
      "",
      "",
      flutter_type.TimeOfDay(hour: 0, minute: 0),
      null,
      "",
      [],
      [],
      [],
      {},
      "",
      EnumerationFulltypeVideo.Film_Anime);
}
