import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Interface/ILibrairy_Scrape.dart';
import 'package:gathering_datas_videos_from_web/Services/Managements/Browser_Automation.dart';

class LibrairyWebviewheadless implements IlibrairyScrape<Browser> {
  @override
  Future<Browser> getInstanceOfObjectScraping() async {
    Browser browser = await WebAutomationFramework.launch();
    browser = await this
        .getInstanceConfiguredOfObjectScraping(instance_objectscrape: browser);

    return browser;
  }

  @override
  Future<Browser> getInstanceConfiguredOfObjectScraping(
      {required Browser instance_objectscrape}) async {
    await instance_objectscrape.newPage();

    (await instance_objectscrape.newPage()).emulate(Device(
        viewport: Viewport(height: 1920, width: 1080, isMobile: false),
        userAgent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36"));

    return instance_objectscrape;
  }

  @override
  Future<String> getHtmlDoc(
      {required Browser instance_objectscrape,
      required String url_target}) async {
    Page page_current = instance_objectscrape.pages().first;
    await page_current.goto(url: url_target);
    return (await page_current.content())!;
  }

  @override
  void dispose({required Browser instance_objectscrape}) async {
    await instance_objectscrape.close();
  }
}
