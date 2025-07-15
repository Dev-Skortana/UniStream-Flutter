part of gathering_urls_videos_from_web;

class ManagerHtmlDom {
  ManagerHtmlDom() {}

  static html.Element ParseHtmlDoc(String html_doc) {
    html.Element html_dom = parse(html_doc).documentElement!;
    return html_dom;
  }
}
