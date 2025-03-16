import 'package:html/parser.dart';
import 'package:xpath_selector_html_parser/src/ext.dart';
import 'package:html/dom.dart';

class ManagerHtmlDom {
  ManagerHtmlDom() {}

  static Element ParseHtmlDoc(String html_doc) {
    Element html_dom = parse(html_doc).documentElement!;
    return html_dom;
  }
}
