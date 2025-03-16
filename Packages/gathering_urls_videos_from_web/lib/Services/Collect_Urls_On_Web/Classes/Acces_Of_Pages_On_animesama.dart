import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Classe_Base/Gathering_Urls.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_ButtonSearch.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Episode_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_For_Data_Mandatory.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Movie_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Saison_Video.dart';

class AccesOfPagesOnAnimesama extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<String>,
        IrequestSaisonVideo<String>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<bool> {
  AccesOfPagesOnAnimesama() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks
          .HavePanelLinksSaisons_And_DontHavePanelLinksEpisodes;

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "J'ACCEPTE";

  @override
  bool getRequeteXpathOfButtonSearch() => false;

  @override
  String getRequeteXpathOfEntryFieldSearch() =>
      "//div[contains(@class,'flex hidden')]/descendant::input[@id='search_text']";

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//select[@id='selectEpisodes']/option";

  @override
  String getRequeteXpathOfLinkOfMovieOnVideo() =>
      "//h2[text()='Anime']/following::div[1]/a/div[contains(text(),'Film')]/../@href";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "(//div[@id='result'])[1]/a/@href";

  @override
  String getRequeteXpathOfLinksOfSaisonsOnVideo() =>
      "//h2[text()='Anime']/following::div[1]/a[contains(@href,'saison')]/div/../@href";

  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "/text()[1]" : "";
    return "(//div[@id='result'])[1]/a/div/h3${attrib}";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => true;
}
