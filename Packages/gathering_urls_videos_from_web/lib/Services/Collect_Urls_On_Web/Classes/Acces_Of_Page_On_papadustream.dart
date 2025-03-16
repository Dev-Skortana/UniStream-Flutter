import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Classe_Base/Gathering_Urls.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IConfiguration_Panel_Link_Site.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_ButtonSearch.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Episode_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_For_Data_Mandatory.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Movie_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Saison_Video.dart';

class AccesOfPageOnPapadustream extends GatheringUrls
    implements
        IrequestForDataMandatory,
        IrequestMovieVideo<bool>,
        IrequestSaisonVideo<String>,
        IrequestEpisodeVideo<String>,
        IrequestButtonsearch<String> {
  AccesOfPageOnPapadustream() {}

  @override
  EnumerationPanelsLinks getConfigurationPanelsLinksOnSite() =>
      EnumerationPanelsLinks.HavePanelLinksSaisons_And_HavePanelLinksEpisodes;

  @override
  bool getRequeteXpathOfLinkOfMovieOnVideo() => false;

  @override
  String getRequeteXpathOfButtonSearch() =>
      "//div[@id='filter-wrap']/form/descendant::input[@type='button']";

  @override
  String getRequeteXpathOfEntryFieldSearch() =>
      "//div[@id='filter-wrap']/form/descendant::input[@class='search form-control']";

  @override
  String getRequeteXpathOfLinksInResultsOfSearch() =>
      "//div[@class='short gridder-list']/div/div[@id='short_title']/a/@href";

  @override
  String getRequeteXpathOfTitleInResultsOfSearch(
      {bool is_for_value_of_attribute = false}) {
    String attrib = is_for_value_of_attribute ? "/text()[1]" : "";
    return "//div[@class='short gridder-list']/div/div[@id='short_title']/a${attrib}";
  }

  @override
  bool isResulstOFSearchOnSamePageThatPageContainsEntry() => false;

  @override
  String getRequeteXpathOfButtonAcceptCokkie() => "###";

  @override
  String getRequeteXpathOfEpisodeOnVideo() =>
      "//div[@class='saisontab']/div[@class='floats clearfix']/div[@style]/../div[@align='center']/a[not(@class)]/@href";

  @override
  String getRequeteXpathOfLinksOfSaisonsOnVideo() =>
      "//div[@class='seasontab']/div/div[@align='center']/a/@href";
}
