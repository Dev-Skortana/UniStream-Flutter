import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Interface/ILibrairy_Scrape.dart';
import 'package:puppeteer/plugin.dart';
import 'package:puppeteer/puppeteer.dart';

/* Cette classe est un prototype, en raison du faite que pour puppeter puisse fonctionner sur mobile il faut créer un serveur.
  De ce faite elle n'est pas à etre utiliser pour le moment.
*/
class LibrairyPuppeteer implements IlibrairyScrape<Browser> {
  LibrairyPuppeteer() {}

  @override
  Future<Browser> getInstanceOfObjectScraping() async {
    Browser browser = await puppeteer.launch(headless: true);
    browser = await this
        .getInstanceConfiguredOfObjectScraping(instance_objectscrape: browser);
    return browser;
  }

  @override
  Future<Browser> getInstanceConfiguredOfObjectScraping(
      {required Browser instance_objectscrape}) async {
    await instance_objectscrape.newPage();
    return instance_objectscrape;
  }

  @override
  Future<String> getHtmlDoc(
      {required Browser instance_objectscrape,
      required String url_target}) async {
    Page page = (await instance_objectscrape.pages).first;
    await page.goto(url_target);
    return (await page.content)!;
  }

  @override
  void dispose({required Browser instance_objectscrape}) {
    // Not nedeed
  }
}
