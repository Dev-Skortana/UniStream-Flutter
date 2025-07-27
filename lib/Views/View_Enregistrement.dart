import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:collection/collection.dart';

import 'package:unistream/ViewModels/ViewModel_Enregistrement.dart';

class ViewEnregistrement extends StatefulWidget {
  const ViewEnregistrement({super.key});

  @override
  State<ViewEnregistrement> createState() => ViewEnregistrementState();
}

class ViewEnregistrementState extends State<ViewEnregistrement> {
  bool isVisibleMSGRecordingsInProgress = false;
  bool isActiveButtonRegister = false;

  late ViewmodelEnregistrement viewmodelEnregistrement;

  List<DropdownMenuItem<String>> listOptionsSiteNames =
      List.empty(growable: true);
  late String currentValueIdentifiantSite = "";

  late List<DropdownMenuItem<String>> listOptionsCategorieVideo =
      List.empty(growable: true);
  late String currentValueCategorieVideo = "";

  late List<DropdownMenuItem<int>> listOptionsPage = List.empty(growable: true);
  late int currentValuePage = 0;

  late Future data;

  @override
  void initState() {
    super.initState();
    this.data = ViewmodelEnregistrement.create();
    //this.listOptionsSiteNames = this.buildOptionsSitesNames();
  }

  List<DropdownMenuItem<String>> buildOptionsSitesNames() {
    List<DropdownMenuItem<String>> listoptionssitenames =
        List.empty(growable: true);
    final List<String> list_site_name =
        this.viewmodelEnregistrement.getListSitesNames().toList();
    final List<String> list_identifiant =
        this.viewmodelEnregistrement.getListIdentifiants().toList();
    for (var item in IterableZip<String>([list_identifiant, list_site_name])) {
      listoptionssitenames
          .add(DropdownMenuItem<String>(value: item[0], child: Text(item[1])));
    }
    return listoptionssitenames;
  }

  void dropdownSiteChange(dynamic value) {
    final List<String> listcategories = this
        .viewmodelEnregistrement
        .getListCategoriesVideo(this.currentValueIdentifiantSite)
        .toList();
    setState(() {
      this.listOptionsCategorieVideo.clear();
      this.currentValueCategorieVideo = "";
      this.resetDropdownsPage();
      this.disabled_button();

      this.listOptionsCategorieVideo = listcategories
          .map((element) =>
              DropdownMenuItem(value: element, child: Text(element)))
          .toList();
      this.currentValueCategorieVideo =
          this.listOptionsCategorieVideo.first.value!;
      dropdownCategorieVideoChange(currentValueCategorieVideo);
    });
  }

  void dropdownCategorieVideoChange(dynamic value) async {
    int numbers_pages_max = await this
        .viewmodelEnregistrement
        .getPagesNumbersMaximum(
            identifiant: this.currentValueIdentifiantSite,
            categorie: this.currentValueCategorieVideo);
    List<int> range_numbers_pages =
        List<int>.generate(numbers_pages_max, (number) => number + 1);
    setState(() {
      this.resetDropdownsPage();
      this.disabled_button();
      this.listOptionsPage = range_numbers_pages
          .map((element) =>
              DropdownMenuItem(value: element, child: Text(element.toString())))
          .toList();
      this.currentValuePage = this.listOptionsPage.first.value!;
      dropdownPageChange();
    });
    //instruction
  }

  void dropdownPageChange() {
    bool disabled_button_register = this.isDropDownsCheck() ? true : false;

    this.isActiveButtonRegister = !disabled_button_register;
  }

  bool isDropDownsCheck() {
    if (this.currentValueIdentifiantSite == "") return false;

    if (this.currentValueCategorieVideo == "") return false;

    if (this.currentValuePage > 0) {
      return false;
    }
    return true;
  }

  void resetDropdownsPage() {
    this.listOptionsPage.clear();
    this.currentValuePage = 0;
  }

  void disabled_button() {
    this.isActiveButtonRegister = false;
  }

  Future<void> buttonRegisterOnPressed() async {
    this.disabled_button();
    this.showMSGRecordingsInProgress();
    await this.viewmodelEnregistrement.startRecording(
        identifiant: this.currentValueIdentifiantSite,
        categorie: this.currentValueCategorieVideo,
        number_pages_to_scrape: this.currentValuePage);
    this.isActiveButtonRegister = true;
    this.hideMSGRecordingsInProgress();
  }

  void showMSGRecordingsInProgress() {
    setState(() {
      this.isVisibleMSGRecordingsInProgress = true;
    });
  }

  void hideMSGRecordingsInProgress() {
    setState(() {
      this.isVisibleMSGRecordingsInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: this.data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                this.viewmodelEnregistrement = snapshot.data!;
                if (this.listOptionsSiteNames.isEmpty) {
                  this.listOptionsSiteNames = this.buildOptionsSitesNames();
                  this.currentValueIdentifiantSite =
                      this.listOptionsSiteNames.first.value!;
                }
                return Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    spacing: 100,
                    children: [
                      Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 160,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 4)),
                              child: DropdownButton<String>(
                                key: GlobalKey(),
                                hint: Text("Site :"),
                                value: currentValueIdentifiantSite,
                                items: this.listOptionsSiteNames,
                                onChanged: (value) {
                                  this.currentValueIdentifiantSite = value!;

                                  setState(() {
                                    this.dropdownSiteChange(value);
                                  });
                                },
                                style: const TextStyle(color: Colors.white),
                                isExpanded: true,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 4)),
                              child: DropdownButton<String>(
                                key: GlobalKey(),
                                hint: Text("Catégorie:"),
                                value: this.currentValueCategorieVideo,
                                items: this.listOptionsCategorieVideo,
                                onChanged: (value) async {
                                  this.currentValueCategorieVideo = value!;
                                  setState(() {
                                    this.dropdownCategorieVideoChange(value);
                                  });
                                },
                                style: const TextStyle(color: Colors.white),
                                isExpanded: true,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 10,
                        children: [
                          SizedBox(
                            width: 160,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 4)),
                              child: DropdownButton<int>(
                                  key: GlobalKey(),
                                  hint: Text("Page N :"),
                                  value: this.currentValuePage,
                                  items: this.listOptionsPage,
                                  onChanged: (value) {
                                    this.currentValuePage =
                                        int.parse(value!.toString());
                                    setState(() {
                                      this.dropdownPageChange();
                                    });
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  isExpanded: true),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              child: ElevatedButton(
                                  key: GlobalKey(),
                                  style: ElevatedButton.styleFrom(
                                      disabledBackgroundColor: Colors.grey,
                                      disabledForegroundColor: Colors.white,
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white),
                                  onPressed: this.isActiveButtonRegister
                                      ? () async {
                                          await this.buttonRegisterOnPressed();
                                          showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                    title: Text("Confirmation"),
                                                    content:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      child: Row(
                                                        spacing: 3,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .playlist_add_check,
                                                              color:
                                                                  Colors.green),
                                                          Text(
                                                              "L'enregistrement s'est déroulé \navec succès !")
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text("Ok")),
                                                    ],
                                                    elevation: 24.0,
                                                  ));
                                        }
                                      : null,
                                  child: Text("Lancer l'enregistrement"))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (this.isVisibleMSGRecordingsInProgress)
                            Text(key: GlobalKey(), "Enregistrement en cours...")
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}
