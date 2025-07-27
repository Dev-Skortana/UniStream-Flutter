import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Classes_Base/Parameters_Get_LinkWatchs.dart';

class ParametersGetLinkWatchsMovie extends ParametersGetLinkwatchs {
  late String titre_video;
  ParametersGetLinkWatchsMovie(this.titre_video) : super();

  @override
  void preparedParametersData() {
    this.mapParametersData["titre_video"] = this.titre_video;
  }
}
