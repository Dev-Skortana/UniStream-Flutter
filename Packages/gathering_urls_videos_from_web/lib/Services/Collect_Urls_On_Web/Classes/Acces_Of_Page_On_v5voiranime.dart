import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Classe_Base/Gathering_Urls.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_ButtonSearch.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Episode_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_For_Data_Mandatory.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Movie_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Saison_Video.dart';

class AccesOfPageOnV5voiranime extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<String>,
        IrequestSaisonVideo<bool>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<bool> {
  AccesOfPageOnV5voiranime() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks
          .DontHavePanelLinksSaison_And_HavePanelLinksEpisodes;

  @override
  String getRequeteXpathOfEntryFieldSearch() =>
      "(//div[@class='probox']/descendant::input[@class='orig'])[3]";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "//div[@id='ajaxsearchprores4_2']/descendant::div[@class='resdrg']/div/div/h3/a/@href";

  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "/text()[1]" : "";
    return "//div[@id='ajaxsearchprores4_2']/descendant::div[@class='resdrg']/div/div/h3/a${attrib}";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => true;

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "###";
  @override
  bool getRequeteXpathOfButtonSearch() => false;

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//div[@class='c-page__content']/descendant::div[@class='page-content-listing single-page']/descendant::li/a/@href";

  @override
  String getRequeteXpathOfLinkOfMovieOnVideo() =>
      "//div[@class='c-page__content']/descendant::div[@class='page-content-listing single-page']/descendant::li/a/@href";

  @override
  bool getRequeteXpathOfLinksOfSaisonsOnVideo() => false;
}
