part of gathering_urls_videos_from_web;

class GatheringUrls {
  late String urlPageWelcome;

  GatheringUrls() {}

  GatheringUrls._create() {}

  static Future<GatheringUrls> create() async {
    GatheringUrls gatheringUrls = GatheringUrls._create();
    await gatheringUrls.setUrlPageWelcome();
    return gatheringUrls;
  }

  Future<void> setUrlPageWelcome() async {
    this.urlPageWelcome = await this.getUrlBase();
  }

  @protected
  Future<String> searchUrlBaseFromName(Type child_class_of_this) async {
    return (await ManipulateJsonFileRedirect.create())
        .dataFromJson
        .where((element) => child_class_of_this
            .toString()
            .toLowerCase()
            .contains(element["Name"].toString().toLowerCase()))
        .first["Url_Reference"];
  }

  Future<String> getUrlBase() async =>
      await this.searchUrlBaseFromName(this.runtimeType);

  static Future<String> staticGetUrlBase(Type child_class_of_this) async =>
      await GatheringUrls._create().searchUrlBaseFromName(child_class_of_this);

  String getAbsoluteLinkFromUrlPageVideos(String url) {
    if (this.urlPageWelcome.isEmpty) return url;
    if (url.isEmpty) return this.urlPageWelcome;
    if (url.startsWith(RegExp("http|HTTP")) == false) {
      var start_string_relative_link = "${this.urlPageWelcome.split("/").last}";
      return Uri.parse(this.urlPageWelcome)
          .resolve("${start_string_relative_link}${url}")
          .toString();
    }
    return url;
  }

  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() {
    throw UnimplementedError();
  }
}
