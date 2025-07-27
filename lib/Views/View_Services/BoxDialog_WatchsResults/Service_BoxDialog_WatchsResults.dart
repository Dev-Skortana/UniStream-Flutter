import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Episode_Video.dart';
import 'package:gathering_urls_videos_from_web/gathering_urls_videos_from_web.dart';
import 'package:unistream/Views/View_WatchVideo.dart';

class ServiceBoxdialogWatchsresults extends StatefulWidget {
  late String categorie;
  late List<Map<String, String>> mapsWatchResult;
  late String episode_into_caracteres;
  ServiceBoxdialogWatchsresults(
      {Key? key,
      required this.categorie,
      required this.mapsWatchResult,
      this.episode_into_caracteres = ""})
      : super(key: key);

  @override
  State<ServiceBoxdialogWatchsresults> createState() =>
      _ServiceBoxdialogWatchsresultsState();
}

class _ServiceBoxdialogWatchsresultsState
    extends State<ServiceBoxdialogWatchsresults> {
  String link_watch_video = "";

  @override
  void initState() {
    super.initState();
  }

  bool isMapsNotEmpty() => super.widget.mapsWatchResult.isNotEmpty;

  Widget _generateComponentBlockresult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var watch_result in super.widget.mapsWatchResult)
          this._generateButton(watch_result)
      ],
    );
  }

  ElevatedButton _generateButton(Map<String, String> map) {
    String name_watch = map["Name_Site"]!;
    String link_watch = map["Link"]!;

    return ElevatedButton(
        key: Key(link_watch),
        onPressed: () {
          this.setDataToClipboard(link_watch);
          this.displayLinkWatchSelected(link_watch);
        },
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
            foregroundColor: WidgetStatePropertyAll<Color>(Colors.white)),
        child: Text(textAlign: TextAlign.center, name_watch));
  }

  Future<void> setDataToClipboard(String link_watch) async {
    Clipboard.setData(ClipboardData(text: link_watch));
  }

  void displayLinkWatchSelected(String link_watch) {
    setState(() {
      this.link_watch_video = link_watch;
    });
  }

  Future<String> getRequestEpisodeIfNeeded() async {
    final Uri uri_link_sitevideo = Uri.parse(this.link_watch_video);
    final object_accees_site = await ManagerGatheringData.getObjectAcceesPage(
        uri_link_sitevideo.origin);
    if (this.isRequestEpisodeNeeded(object_accees_site)) {
      String request = (object_accees_site as IrequestEpisodeVideo)
          .getRequeteXpathOfEpisodeOnVideo();
      request += "[${super.widget.episode_into_caracteres}]";
      return request;
    }
    return "";
  }

  bool isRequestEpisodeNeeded(dynamic object_accees_site) {
    var configuration_panel_links_on_site =
        object_accees_site.getConfigurationPanelsLinksOnSite();
    return super.widget.categorie == "Video_Serie" &&
        (configuration_panel_links_on_site ==
                EnumerationPanelsLinks
                    .DontHavePanelLinksSaisons_And_DontHavePanelLinksEpisodes ||
            configuration_panel_links_on_site ==
                EnumerationPanelsLinks
                    .HavePanelLinksSaisons_And_DontHavePanelLinksEpisodes);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      alignment: Alignment.center,
      elevation: 15,
      title: Text(textAlign: TextAlign.center, "Panel visionnage Vidéo."),
      children: [
        Container(
            child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: isMapsNotEmpty()
              ? [
                  this._generateComponentBlockresult(),
                  Text(
                      textAlign: TextAlign.center,
                      "En cliquant sur l'un des boutons ci-dessus, le lien apparaîtra dans la zone de text en dessous :"),
                  TextField(
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        constraints: BoxConstraints(),
                        hintText: this.link_watch_video,
                        border: InputBorder.none),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  IconButton(
                      tooltip: "Voir la video !",
                      onPressed: () async {
                        if (this.link_watch_video.isNotEmpty) {
                          final String request_episode =
                              await this.getRequestEpisodeIfNeeded();

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ViewWatchvideo(
                                    UrlSiteVideo: this.link_watch_video,
                                    RequestEpisode: request_episode,
                                    episode_into_caracteres:
                                        super.widget.episode_into_caracteres,
                                  )));
                        }
                      },
                      icon: const Icon(Icons.ondemand_video_sharp))
                ]
              : [
                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off, color: Colors.red, size: 50),
                      Flexible(
                        child: Text(
                            "Oups, aucun liens de visionnage n'a été trouver pour cette vidéo ! ! !"),
                      )
                    ],
                  )
                ],
        ))
      ],
    );
  }
}
