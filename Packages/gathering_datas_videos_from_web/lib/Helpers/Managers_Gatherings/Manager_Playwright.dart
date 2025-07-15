part of gathering_data_videos_from_web;

class ManagerPlaywright {
  String path_to_extension_adblock = "";
  ManagerPlaywright([String path_to_extension_adblock = ""])
      : path_to_extension_adblock = path_to_extension_adblock;

  Future<Browser> getPlaywright(bool headless) async {
    List<String> args = List.empty(growable: true);
    args = this.getArgsDefault() +
        (this.isExtensionsRequest()
            ? this.getArgsOfIntegrateExtensions()
            : List.empty());
    return await puppeteer.launch(
        headless: headless,
        args: args); //userDataDir: "", args: args, headless: headless);
  }

  bool isExtensionsRequest() => path_to_extension_adblock.isNotEmpty;

  List<String> getArgsDefault() =>
      ["--disable-infobars", '--ignore-certificate-errors-spki-list'];
  List<String> getArgsOfIntegrateExtensions() => [
        '--disable-extensions-except=${this.path_to_extension_adblock}',
        '--load-extension=${path_to_extension_adblock}'
      ];
}
