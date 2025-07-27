@Timeout(Duration(seconds: 240))

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/Helpers/FileYamlOfThisAsset.dart';
import 'package:gathering_datas_videos_from_web/Services/Managements/Browser_Automation.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:integration_test/integration_test.dart';
import 'package:unistream/Services/Features/Link_Watch_Video/Result_Link_Watch_Of_Video.dart';
import 'package:unistream/main.dart' as app;
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'package:puppeteer/puppeteer.dart' as pu;
import 'package:http/http.dart' as http;

import 'automation.dart' as au;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  ManagerGatheringData manager = ManagerGatheringData(
      categorie_video_target: EnumerationCategorieVideo.Video_Serie,
      numpagebegenning: 6);
  group("App Test", () {
    testWidgets("Test Gathering_Urls", (WidgetTester tester) async {
      //arrange
      //act
      await tester.pumpAndSettle();
      ResultLinkWatchOfVideo manager_links = ResultLinkWatchOfVideo();
      var results = await manager_links.getManyResultLinkWatchOfVideo({
        "titre_video": "Boku no Kokoro no Yabai Yatsu (VF)",
        "saison": "1",
        "episode": "5"
      });
      debugPrint(results.toString());
      expect(results.length, greaterThan(0));
    });

    testWidgets("Test Yaml File (Gathering_Data_Videos)",
        (WidgetTester tester) async {
      //arrange
      //act
      await tester.pumpAndSettle();
      /* Tester le fonctionnement de l'app */

      final yamlmap = loadYaml(await GetAssetFileYamlForTest.getasset());
      final result = (jsonDecode(jsonEncode(yamlmap)) as List)
          .cast<Map<String, dynamic>>();

      expect(result.length, greaterThan(0));
    });

    testWidgets("test [Puppeter For Desktop Only]",
        (WidgetTester tester) async {
      //app.main();
      await tester.pumpAndSettle();
      pu.Browser browser = await pu.puppeteer.launch(headless: true);
      await browser.newPage();

      pu.Page page = (await browser.pages).first;
      await page.goto(
          'https://vostfree.ws/1109-made-in-abyss-vf-ddl-streaming-1fichier-uptobox.html');

      debugPrint(await page.content);
    });

    testWidgets("test [WebAutomationFramework for Mobile Only]",
        (WidgetTester tester) async {
      //app.main();
      await tester.pumpAndSettle();

      final browser = await au.WebAutomationFramework.launch();

      final page = await browser.newPage();
      await page.emulate(au.Device(
          viewport: au.Viewport(height: 1296, width: 976, isMobile: true),
          userAgent: ""));

      //voirdrama
      /*
      await page.goto(url: 'https://voirdrama.org');

      await page.click(
          selector: "div.search-navigation.search-sidebar ul > li.menu-search");

      await page.evaluate(
          source:
              "document.querySelector('div.probox  input.orig').value =\"\";");
      await page.type(
          selector: "div.probox  input.orig",
          text: "Chanbara Beauty: The Movie");
      //await Future.delayed(Duration(seconds: 1));
      await page.waitForSelector(
          selector: "div.results > div.resdrg  div.item > div > h3");

      final value = await page.evaluate(
          source:
              "document.querySelector('div.results > div.resdrg  div.item > div > h3').innerText;");
      print(value);
      await browser.close();
      */
      // papadustream
      /*
      await page.goto(url: 'https://papadustream.vote');

      await page.click(selector: "span.fa-search");

      await page.evaluate(
          source:
              "document.querySelector('form#quicksearch > div.search_box > input').value = \"\";");

      await page.type(
          selector: "form#quicksearch > div.search_box > input", text: "Halo");
      await Future.delayed(Duration(seconds: 1));

      await page.click(selector: "form#quicksearch > div.search_box > button");
      await page.waitForNavigation();
      print(await page.content());
      
      await browser.close();
      */
      //voiranime
      /*
      await page.goto(url: 'https://v6.voiranime.com');

      await page.click(
          selector: "div.search-navigation.search-sidebar ul > li.menu-search");

      await page.evaluate(
          source:
              "document.querySelector('nav > a > input#search_text').value =\"\";");
      await page.type(
          selector: "div.probox  input.orig", text: "Lupin III: Pilot Film");
      //await Future.delayed(Duration(seconds: 1));
      await page.waitForSelector(
          selector: "div.results > div.resdrg  div.item > div > h3");

      final value = await page.evaluate(
          source:
              "document.querySelector('div.results > div.resdrg  div.item > div > h3').innerText;");
      print(value);
      await browser.close();
      */
      //anime sama
      /*
      await page.goto(url: 'https://anime-sama.fr');

      await page.evaluate(
          source:
              "document.querySelector('nav > a > input#search_text').value =\"\";");

      await page.type(
          selector: "nav > a > input#search_text",
          text: "Blue Archive The Animation");
      await Future.delayed(Duration(seconds: 1));

      await page.waitForSelector(selector: "div#result > a > div > h3");

      final value = await page.evaluate(
          source:
              "document.querySelector('div#result > a > div > h3').innerText;");
      print(value);
      await browser.close();
      */
      //vostfree
      /*
      await page.goto(
          url: 'https://vostfree.ws', waitUntil: au.WaitUntil.domcontentloaded);

      await page.click(selector: "div#user-bar button");
      final req = "div#user-bar  div.infobar-right > div > form input#story";
      await page.evaluate(
          source: "document.querySelector('${req}').value = \"\";");

      await page.type(
          selector: "div#user-bar  div.infobar-right > div > form input#story",
          text: "Promare FRENCH");
      //await Future.delayed(Duration(seconds: 1));

      await page.click(
          selector: "div#user-bar  div.infobar-right > div > form button");
      await page.waitForNavigation();
      print(await page.content());
      await page.waitForSelector(
          selector:
              "div#dle-content > div.shortstory-in  div.short-content > h4.short-link > a");

      await browser.close();
    */
      expect(0, 0);
    });
  });

  group("Gathering_data Abd others", () {
    test("Is greaterThan 0", () async {
      //ARRANGE
      //ACT
      await manager.asyncGatheringDataWithUrl("https://fs-mirror07.lol");
      final R = manager.listDataVideo;
      //ASSERT
      for (var item in R) {
        print(item.titre);
        print(item.description);
        print(item.duree);
        print(item.lien_Affiche);
        print(item.liste_Realisateurs);
        print(item.liste_Genres);
      }
      expect(R.length, greaterThan(0));
    });

    test("", () {});
  });
}
