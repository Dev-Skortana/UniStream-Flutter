import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Episode_Video.dart';
import 'package:gathering_urls_videos_from_web/gathering_urls_videos_from_web.dart';

/// Prépare l'ouverture d'un lien dans l'écran de lecture.
///
/// Repris tel quel de l'ancienne boîte de dialogue des liens
/// (Service_BoxDialog_WatchsResults) : sur les sites dont la page de saison
/// ne liste pas les épisodes en liens séparés, la WebView doit cliquer sur
/// l'épisode elle-même, à l'aide d'une requête XPath fournie par le site.
class PreparationLecture {
  /// Requête XPath de l'épisode à sélectionner dans la page, ou "" si la
  /// page ouverte est déjà celle de l'épisode (ou pour un film).
  static Future<String> requeteEpisode(
      {required String lien, required bool estSerie, required int episode}) async {
    if (!estSerie) return "";
    final accesSite =
        await ManagerGatheringData.getObjectAcceesPage(Uri.parse(lien).origin);
    final dynamic configuration =
        (accesSite as dynamic).getConfigurationPanelsLinksOnSite();
    final besoinRequete = configuration ==
            EnumerationPanelsLinks
                .DontHavePanelLinksSaisons_And_DontHavePanelLinksEpisodes ||
        configuration ==
            EnumerationPanelsLinks
                .HavePanelLinksSaisons_And_DontHavePanelLinksEpisodes;
    if (!besoinRequete) return "";
    return "${(accesSite as IrequestEpisodeVideo).getRequeteXpathOfEpisodeOnVideo()}[$episode]";
  }
}
