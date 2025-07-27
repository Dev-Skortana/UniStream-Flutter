import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ViewWatchvideo extends StatefulWidget {
  late final String UrlSiteVideo;
  String RequestEpisode;
  String episode_into_caracteres;
  ViewWatchvideo(
      {super.key,
      required this.UrlSiteVideo,
      this.RequestEpisode = "",
      this.episode_into_caracteres = ""});

  @override
  State<ViewWatchvideo> createState() => _ViewWatchvideoState();
}

class _ViewWatchvideoState extends State<ViewWatchvideo> {
  late final String nameSite;
  late InAppWebViewController webViewController;
  @override
  void initState() {
    super.initState();
    this.nameSite = RegExp("https?://([^/]+)/")
        .firstMatch(super.widget.UrlSiteVideo)!
        .group(1)!;
  }

  @override
  void dispose() {
    super.dispose();
    this.webViewController.dispose();
  }

  void selectEpisodeIfNeeded(InAppWebViewController webviewcontroller) async {
    if (super.widget.RequestEpisode.isNotEmpty) {
      if (super
          .widget
          .RequestEpisode
          .contains(RegExp("(select[.+]/|/select|//select)"))) {
        final List<String> request_episode_split =
            super.widget.RequestEpisode.split("/");
        final int length_slash = request_episode_split.length;
        final String request_xpath_ancestor =
            "//${request_episode_split[length_slash - 2]}";
        this.webViewController.evaluateJavascript(source: """
                          document.evaluate(\"${request_xpath_ancestor}\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.selectedIndex=${int.parse(super.widget.episode_into_caracteres) - 1};
                          document.evaluate(\"${request_xpath_ancestor}\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.dispatchEvent(new Event('change'));
      """);
      } else {
        this.webViewController.evaluateJavascript(
            source:
                "document.evaluate(\"${super.widget.RequestEpisode}\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Center(
          child: Text(
              textAlign: TextAlign.center, "Visionnage sur ${this.nameSite}"),
        )),
        body: InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
              supportMultipleWindows: true,
            ),
            onWebViewCreated: (controller) {
              this.webViewController = controller;
            },
            onLoadStop: (controller, url) async {
              this.webViewController = controller;
              Future.delayed(Duration(milliseconds: 100), () {
                this.selectEpisodeIfNeeded(this.webViewController);
              });
            },
            initialUrlRequest:
                URLRequest(url: WebUri(super.widget.UrlSiteVideo))));
  }
}
