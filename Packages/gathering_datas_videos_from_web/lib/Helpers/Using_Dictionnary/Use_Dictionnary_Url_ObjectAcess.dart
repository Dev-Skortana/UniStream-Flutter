part of gathering_data_videos_from_web;

class UseDictionnaryUrlObjectacess {
  late Map<String, dynamic> _dictionnaryUrlObjectAcess;
  Map<String, dynamic> get dictionnaryUrlObjectAcess =>
      this._dictionnaryUrlObjectAcess;

  UseDictionnaryUrlObjectacess._create(
      Map<String, dynamic> dictionnary_url_object_acess)
      : _dictionnaryUrlObjectAcess = dictionnary_url_object_acess;

  static Future<UseDictionnaryUrlObjectacess> create() async {
    return UseDictionnaryUrlObjectacess._create({
      await Acces.staticGetUrlBase(AccesOfPagesOnAnimesama):
          AccesOfPagesOnAnimesama.new,
      await Acces.staticGetUrlBase(AccesOfPageOnVostfree):
          AccesOfPageOnVostfree.new,
      await Acces.staticGetUrlBase(AccesOfPageOnVoirdrama):
          AccesOfPageOnVoirdrama.new,
      await Acces.staticGetUrlBase(AccesOfPageOnPapadustream):
          AccesOfPageOnPapadustream.new,
      await Acces.staticGetUrlBase(AccesOfPageOnV6voiranime):
          AccesOfPageOnV6voiranime.new
    });
  }
}
