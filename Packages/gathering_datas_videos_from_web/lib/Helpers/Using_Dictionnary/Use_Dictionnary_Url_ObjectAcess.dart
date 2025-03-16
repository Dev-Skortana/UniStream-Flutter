part of gathering_data_videos_from_web;

class UseDictionnaryUrlObjectacess {
  late Map<String, Type> _dictionnaryUrlObjectAcess;
  Map<String, Type> get dictionnaryUrlObjectAcess =>
      this._dictionnaryUrlObjectAcess;

  UseDictionnaryUrlObjectacess._create(
      Map<String, Type> dictionnary_url_object_acess)
      : _dictionnaryUrlObjectAcess = dictionnary_url_object_acess;

  static Future<UseDictionnaryUrlObjectacess> create() async {
    return UseDictionnaryUrlObjectacess._create({
      await Acces.staticGetUrlBase(AccesOfPagesOnAnimesama):
          AccesOfPagesOnAnimesama,
      await Acces.staticGetUrlBase(AccesOfPageOnVostfree):
          AccesOfPageOnVostfree,
      await Acces.staticGetUrlBase(AccesOfPageOnVoirdrama):
          AccesOfPageOnVoirdrama,
      await Acces.staticGetUrlBase(AccesOfPageOnPapadustream):
          AccesOfPageOnPapadustream,
      await Acces.staticGetUrlBase(AccesOfPageOnV5voiranime):
          AccesOfPageOnV5voiranime
    });
  }
}
