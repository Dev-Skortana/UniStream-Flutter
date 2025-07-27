import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unistream/Helpers/Duration_Util.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Features/Search_Data/Enumeration/Enumerations_Methodes_Recherches.dart';
import 'package:unistream/Services/Features/Search_Data/Set_Search.dart';
import 'package:unistream/Views/View_Services/Composants_Of_Filter.dart';

class ServiceComponentsSearch extends StatefulWidget {
  List<String> fields_names = [];
  late Future<String> Function(String field_name)
      function_getTypeOfFieldSelected;
  late Iterable Function(SetSearch set_search) functionGetVideosOfSearch;
  late ValueNotifier videoNotifier;

  ServiceComponentsSearch(
      {super.key,
      required this.fields_names,
      required this.function_getTypeOfFieldSelected,
      required this.functionGetVideosOfSearch,
      required this.videoNotifier});

  @override
  State<ServiceComponentsSearch> createState() =>
      _ServiceComponentsSearchState();
}

class _ServiceComponentsSearchState extends State<ServiceComponentsSearch> {
  late String field_selected;
  List<Widget> composantsOfSearch = List.empty(growable: true);
  int currentLevelPriorityEntry = 0;
  late Widget composantsOfFilter;

  late List<DropdownMenuItem<String>> DropdownFieldsSearch;

  Object firstValue = "";
  Object? secondValue;
  final currentOptionNotifier = ValueNotifier<String>("");
  @override
  void initState() {
    super.initState();
    this.DropdownFieldsSearch = this._fillDropdownFieldsSearch();
    this.field_selected = this.DropdownFieldsSearch.first.value!;
    this.composantsOfFilter = Column();
  }

  Future<void> textSearchChange({required String name_field}) async {
    if (this.firstValue.toString().isEmpty) {
      return;
    }

    final String type_of_field =
        await super.widget.function_getTypeOfFieldSelected(this.field_selected);
    final SetSearch set_search = SetSearch(
        type_of_field,
        name_field,
        this.firstValue,
        EnumerationsMethodesRecherches.values
            .byName(this.currentOptionNotifier.value),
        this.secondValue);
    var videos = super.widget.functionGetVideosOfSearch(set_search);
    this.widget.videoNotifier.value =
        videos.isNotEmpty ? videos.first["Video"] : Video.getEmptyVideo();
  }

  List<DropdownMenuItem<String>> _fillDropdownFieldsSearch() {
    return super
        .widget
        .fields_names
        .map((field_search) => DropdownMenuItem<String>(
            child: Text(field_search), value: field_search))
        .toList();
  }

  Widget _generateComposantOfSearch(String type_field) {
    //TODO
    int level_priority = this.getLevelPriority();
    final Map<String, dynamic> map_type_control = {
      "varchar": TextField.new,
      "INTEGER": TextField.new,
      "TEXT": TextField.new,
      "date": TextField.new,
      "time": TextField.new
    };
    Map<String, dynamic> map_arguments_controlsearch = {};
    final name_field = this.field_selected;

    map_arguments_controlsearch = {};

    final Map<String, dynamic> map_arguments_event_needed = {
      "INTEGER": this._getArgumentsAndEventOfComposantsOfSearchForNumbers,
      "varchar": this._getArgumentsAndEventEventOfComposantsOfSearchForString,
      "TEXT": this._getArgumentsAndEventEventOfComposantsOfSearchForString,
      "date": this._getArgumentAndEventOfComposantsOfSearchForDate,
      "time": this._getArgumentAndEventOfComposantsOfSearchForTime
    };
    final Map<String, dynamic> map_argument_event_of_control_search =
        map_arguments_event_needed[type_field](name_field, level_priority);
    map_arguments_controlsearch.addAll(map_argument_event_of_control_search);

    Widget control_search = map_type_control[type_field](
        decoration: map_arguments_controlsearch.containsKey("decoration")
            ? map_arguments_controlsearch["decoration"]
            : null,
        inputFormatters:
            map_arguments_controlsearch.containsKey("inputFormatters")
                ? map_arguments_controlsearch["inputFormatters"]
                : <TextInputFormatter>[],
        keyboardType: map_arguments_controlsearch.containsKey("keyboardType")
            ? map_arguments_controlsearch["keyboardType"]
            : null,
        onChanged: map_arguments_controlsearch.containsKey("onChanged")
            ? map_arguments_controlsearch["onChanged"]
            : null,
        onTap: map_arguments_controlsearch.containsKey("onTap")
            ? map_arguments_controlsearch["onTap"]
            : null,
        enabled: map_arguments_controlsearch.containsKey("enabled")
            ? map_arguments_controlsearch["enabled"] as bool
            : null,
        maxLines: null,
        minLines: null,
        expands: true);
    return Expanded(
      child: SizedBox(width: 120, child: control_search),
    );
  }

  Map<String, dynamic> _getArgumentsAndEventEventOfComposantsOfSearchForString(
      String name_field, int level_priority) {
    return {
      "decoration": InputDecoration(label: Text("Rechercher")),
      "onChanged": (String value) async {
        this.saveValue(value, level_priority);
        if (this.currentLevelPriorityEntry == level_priority) {
          await this.textSearchChange(name_field: name_field);
        }
      }
    };
  }

  Map<String, dynamic> _getArgumentsAndEventOfComposantsOfSearchForNumbers(
      String name_field, int level_priority) {
    return {
      "decoration": InputDecoration(label: Text("Rechercher")),
      "inputFormatters": [
        FilteringTextInputFormatter.digitsOnly,
      ],
      "keyboardType": TextInputType.number,
      "onChanged": (String value) async {
        this.saveValue(value, level_priority);
        if (this.currentLevelPriorityEntry == level_priority) {
          await this.textSearchChange(name_field: name_field);
        }
      }
    };
  }

  Map<String, dynamic> _getArgumentAndEventOfComposantsOfSearchForDate(
      String name_field, int level_priority) {
    DateTime date_current = DateTime.now();
    return {
      "decoration": InputDecoration(
          labelText: "${level_priority}",
          filled: true,
          prefixIcon: Icon(Icons.calendar_today),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue))),
      "onTap": () async {
        final DateTime? date_selected = await showDatePicker(
            context: context,
            initialDate: date_current,
            firstDate: DateTime(1950),
            lastDate: DateTime.now());
        if (date_selected != null) {
          final String date_selected_into_string =
              date_selected.toString().split(" ").first;
          this.saveValue(
              DateTime.parse(date_selected_into_string), level_priority);
        }
        if (this.currentLevelPriorityEntry == level_priority) {
          if (date_selected != null) {
            await this.textSearchChange(name_field: name_field);
            setState(() {
              date_current = date_selected;
            });
          }
        }
      },
      "enabled:": false
    };
  }

  Map<String, dynamic> _getArgumentAndEventOfComposantsOfSearchForTime(
      String name_field, int level_priority) {
    TimeOfDay time_current = TimeOfDay(hour: 0, minute: 0);
    return {
      "decoration": InputDecoration(
          labelText: "${level_priority}",
          filled: true,
          prefixIcon: Icon(Icons.calendar_today),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue))),
      "onTap": () async {
        final TimeOfDay? time_selected = await showTimePicker(
          context: context,
          initialTime: time_current,
        );

        if (time_selected != null) {
          final String time_selected_into_string =
              DurationUtil.getDurationIntoString(time_selected)!;
          this.saveValue(time_selected, level_priority);
        }

        if (this.currentLevelPriorityEntry == level_priority) {
          if (time_selected != null) {
            await this.textSearchChange(name_field: name_field);
            setState(() {
              time_current = time_selected;
            });
          }
        }
      },
      "enabled:": false
    };
  }

  void saveValue(Object value, int level_priority) {
    if (level_priority == 1) {
      this.firstValue = value;
    } else {
      this.secondValue = value;
    }
  }

  int getLevelPriority() {
    this.incrementCurrentLevelPriority();
    return this.currentLevelPriorityEntry;
  }

  void incrementCurrentLevelPriority() {
    this.currentLevelPriorityEntry += 1;
  }

  void decrementCurrentLevelPriority() {
    this.currentLevelPriorityEntry -= 1;
  }

  void resetCurrentLevelPriority() {
    this.currentLevelPriorityEntry = 0;
  }

  Widget _generateComposantsOfSearchSecondary(String type_field) {
    return this._generateComposantOfSearch(type_field);
  }

  String _getTypeFieldWithoutMarkeupOfLenght(String type_field) {
    return type_field.replaceFirst(RegExp("\([0-9]+\)"), "");
  }

  void setstateRadioButtonFourchetteChanged(String current_option) async {
    if (this.composantsOfSearch.length >= 2) {
      this.composantsOfSearch.removeLast();
      this.secondValue = null;
      this.decrementCurrentLevelPriority();
    }
    if (current_option == "Fourchette") {
      final String type_of_field = this
          ._getTypeFieldWithoutMarkeupOfLenght(await super
              .widget
              .function_getTypeOfFieldSelected(this.field_selected))
          .replaceFirst("()", "");
      this
          .composantsOfSearch
          .add(this._generateComposantsOfSearchSecondary(type_of_field));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 5,
            children: [
              DropdownButton<String>(
                items: this.DropdownFieldsSearch,
                value: this.field_selected,
                menuWidth: 130,
                onChanged: (value) async {
                  this.field_selected = value!;
                  final String type_of_field = this
                      ._getTypeFieldWithoutMarkeupOfLenght(await super
                          .widget
                          .function_getTypeOfFieldSelected(this.field_selected))
                      .replaceFirst("()", "");

                  setState(() {
                    this.composantsOfSearch.clear();
                    this.resetCurrentLevelPriority();
                    this
                        .composantsOfSearch
                        .add(this._generateComposantOfSearch(type_of_field));
                    this.composantsOfFilter = ComposantsOfFilter(
                      typeField: type_of_field,
                      callbachSetstateFromServiceSearch:
                          this.setstateRadioButtonFourchetteChanged,
                      currentOptionNotifier: this.currentOptionNotifier,
                    );
                  });
                },
                alignment: Alignment.center,
              ),
              Row(children: [
                SizedBox(
                  height: 50,
                  width: 100,
                  child: Column(
                    children: [...this.composantsOfSearch],
                  ),
                ),
                Column(children: [
                  SizedBox(
                    width: 164,
                    child: this.composantsOfFilter,
                  )
                ])
              ]),
            ],
          ),
        ),
      )
    ]);
  }
}
