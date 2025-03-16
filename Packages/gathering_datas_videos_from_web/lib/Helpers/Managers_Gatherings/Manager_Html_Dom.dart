part of gathering_data_videos_from_web;

class ManagerHtmlDom {
  ManagerHtmlDom() {}

  static Element ParseHtmlDoc(String html_doc) {
    Element html_dom = parse(html_doc).documentElement!;
    return html_dom;
  }
}
