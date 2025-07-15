import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:html/dom.dart';

void main() {
  late String htmlDoc;
  setUpAll(() {
    htmlDoc = """
                        <!DOCTYPE html>
                        <html lang="fr">
                            <head>
                                <meta charset="utf-8">
                                <title>Le titre</title>
                            </head>
                            <body>
                                <h1>Titre</h1>
                                <p id="object">demande</p>
                                <p id="content" class="c1">Contenu</p>
                                <p id='c1'>Action,Drame,Horreur,Épouvante,Mystère,Psychologique,Seinen,Surnaturel</p>
                                <div id="section_1">
                                  <p class="c1">Target</p>
                                  <a href="#" class="pappers">curiculum</a>
                                  <a href="#" class="pappers">motivaton</a>
                                </div>
                                <div id="section_2">
                                  <a href="saison1/vostfr" class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">Saison 1</div></a>
                                  <a href="saison2/vostfr" class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">Saison 2</div></a>
                                  <a href="saison3/vostfr" class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">Saison 3</div></a>
                                  <a href="saison4.5/vostfr" class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">Saison 4.5</div></a>
                                  <div>
                                    <a href="..." class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">episode 1</div></a>
                                    <a href="..." class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">episode 2</div></a>
                                    <a href="..." class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">episode 3</div></a>
                                    <a href="..." class="shrink-0 grid items-center bg-zinc-900 hover:opacity-70 border-double border-4 border-blue-500 rounded-lg w-32 h-20 m-3 transition-all duration-200"><img id="imgOeuvre" class="opacity-40 h-18 bg-cover" src="https://cdn.statically.io/gh/Anime-Sama/IMG/img/contenu/blue-archive-the-animation.jpg"><div class="text-white font-bold text-center absolute w-28 h-18">episode 4.5</div></a>
                                  </div>
                                </div>

                            </body>
                        </html> 
          """;
  });
  group("getListOfOneOrManyValue", () {
    test("return empty", () {
      //ARRANGE
      //ACT
      Element element = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      List result = GettingsValuesOrValue.getListOfOneOrManyValue(
        html_dom: element,
        requete_xpath: "//footer",
      );
      //ASSERT
      expect(result, List.empty());
    });

    test("return one value with content single", () async {
      //ARRANGE
      //ACT
      Element element = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      List result = GettingsValuesOrValue.getListOfOneOrManyValue(
        html_dom: element,
        requete_xpath: "//p[@id='object']",
      );
      //ASSERT
      expect(result, ["demande"]);
    });

    test("return one value with content composite", () async {
      //ARRANGE
      //ACT
      Element element = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      List result = GettingsValuesOrValue.getListOfOneOrManyValue(
        html_dom: element,
        requete_xpath: "//p[@id='c1']",
      );
      //ASSERT
      expect(result, [
        "Action",
        "Drame",
        "Horreur",
        "Épouvante",
        "Mystère",
        "Psychologique",
        "Seinen",
        "Surnaturel"
      ]);
    });

    test("return multiple value with content single", () async {
      //ARRANGE
      //ACT
      Element element = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      List result = GettingsValuesOrValue.getListOfOneOrManyValue(
        html_dom: element,
        requete_xpath: "//div[@id='section_1']/a[@class='pappers']",
      );
      //ASSERT
      expect(result, ["curiculum", "motivaton"]);
    });
  });

  group("getListOfManyValueWithUsingRegex", () {
    test("return empty", () {
      //ARRANGE
      //ACT
      Element element = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      List result = GettingsValuesOrValue.getListOfManyValueWithUsingRegex(
          html_dom: element, requete_xpath: "//nothing", requete_regex: "");
      //ASSERT
      expect(result, List.empty());
    });
    test("return values in attribute href", () {
      //ARRANGE
      //ACT
      Element element = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      List result = GettingsValuesOrValue.getListOfManyValueWithUsingRegex(
          html_dom: element,
          requete_xpath: "//div[@id='section_2']/a",
          requete_regex: "saison.?([0-9]+)");
      //ASSERT
      expect(result, ['1', '2', '3', '4']);
    });

    test("return values in text of tag", () {
      //ARRANGE
      //ACT
      Element element = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      List result = GettingsValuesOrValue.getListOfManyValueWithUsingRegex(
          html_dom: element,
          requete_xpath: "//div[@id='section_2']/div/a",
          requete_regex: "episode.?([0-9]+)");
      //ASSERT
      expect(result, ["1", "2", "3", "4"]);
    });
  });
}
