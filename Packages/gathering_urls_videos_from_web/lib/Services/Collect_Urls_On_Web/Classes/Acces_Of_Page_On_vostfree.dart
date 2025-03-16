import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Classe_Base/Gathering_Urls.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_ButtonSearch.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Episode_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_For_Data_Mandatory.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Movie_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Saison_Video.dart';

class AccesOfPageOnVostfree extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<String>,
        IrequestSaisonVideo<bool>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<String> {
  AccesOfPageOnVostfree() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks
          .DontHavePanelLinksSaisons_And_DontHavePanelLinksEpisodes;

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "###";

  @override
  String getRequeteXpathOfButtonSearch() => "//input[@name='submit']";

  @override
  String getRequeteXpathOfEntryFieldSearch() => "//input[@class='search-box']";

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//div[@class='jq-selectbox__dropdown']/ul[1]/li";

  @override
  String getRequeteXpathOfLinkOfMovieOnVideo() =>
      "//div[@class='jq-selectbox__dropdown']/ul[1]/li";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "//div[@id='dle-content']/div[@class='search-result']/descendant::div[@class='title']/a/@href";

  @override
  bool getRequeteXpathOfLinksOfSaisonsOnVideo() => false;
  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "/text()" : "";
    return "//div[@id='dle-content']/div[@class='search-result']/descendant::div[@class='title']/a${attrib}";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => false;
}
