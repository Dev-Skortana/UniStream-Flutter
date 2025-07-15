part of gathering_urls_videos_from_web;

class UseDictionnaryUrlObjectacess {
  late Map<String, dynamic> _dictionnaryUrlObjectAcess;
  Map<String, dynamic> get dictionnaryUrlObjectAcess =>
      this._dictionnaryUrlObjectAcess;

  UseDictionnaryUrlObjectacess._create(
      Map<String, dynamic> dictionnary_url_object_acess)
      : _dictionnaryUrlObjectAcess = dictionnary_url_object_acess;

  static Future<UseDictionnaryUrlObjectacess> create() async {
    return UseDictionnaryUrlObjectacess._create({
      await GatheringUrls.staticGetUrlBase(AccesOfPagesOnAnimesama):
          AccesOfPagesOnAnimesama.new,
      await GatheringUrls.staticGetUrlBase(AccesOfPageOnVostfree):
          AccesOfPageOnVostfree.new,
      await GatheringUrls.staticGetUrlBase(AccesOfPageOnVoirdrama):
          AccesOfPageOnVoirdrama.new,
      await GatheringUrls.staticGetUrlBase(AccesOfPageOnV6voiranime):
          AccesOfPageOnV6voiranime.new
    });
  }
}
