import 'package:flutter_test/flutter_test.dart';
//import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

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
                                <p>Contenu</p>
                            </body>
                        </html> 
          """;
  });
  group("test_ParseHtmlDoc", () {
    test("Expect htmlDom have value ", () {
      //ARRANGE
      //ACT
      Element? html_dom = parse(htmlDoc).documentElement!;
      //ASSERT
      expect(html_dom, isNotNull);
    });
    test("Expect htmlDom is instance of Element", () {
      //ARRANGE
      //ACT
      var html_dom = parse(htmlDoc).documentElement!;
      //ASSERT
      expect(html_dom.runtimeType, Element);
    });
  });
}
