part of gathering_data_videos_from_web;

class UseDictionnaryCategorieUrlpage {
  late String siteName;
  late String urlOfPageVideos;
  late Map<String, String> _dictionnaryCategorieUrlpage;

  Map<String, String> get dictionnaryCategorieUrlpage =>
      this._dictionnaryCategorieUrlpage;
  UseDictionnaryCategorieUrlpage(
      {required String site_name, required String url_page_videos}) {
    this.siteName = site_name;
    this.urlOfPageVideos = url_page_videos;
    this._dictionnaryCategorieUrlpage = this._createDictionnary();
  }

  Map<String, String> _createDictionnary() =>
      {"SiteName": this.siteName, "UrlPageVideos": this.urlOfPageVideos};
}
