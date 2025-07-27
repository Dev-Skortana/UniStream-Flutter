import 'dart:ffi';

import 'package:flutter/material.dart';

class ComposantsOfFilter extends StatefulWidget {
  late dynamic callbachSetstateFromServiceSearch;
  late String typeField;
  late ValueNotifier<String> currentOptionNotifier;
  ComposantsOfFilter(
      {super.key,
      required this.typeField,
      required this.callbachSetstateFromServiceSearch,
      required this.currentOptionNotifier});

  @override
  State<ComposantsOfFilter> createState() => ComposantsOfFilterState();
}

class ComposantsOfFilterState extends State<ComposantsOfFilter> {
  late Widget composantsOfFilter;
  String currentOption = "Egale";

  @override
  void initState() {
    super.initState();
  }

  Widget _generateComposantsOfFilter(String type_field) {
    //TODO
    final Map<String, List<Map<String, dynamic>>>
        map_type_aruguments_radios_controls = {
      "varchar": [
        {"title": Text("Milieu"), "value": "Contient"},
        {"title": Text("Début"), "value": "Commence"},
        {"title": Text("Egale"), "value": "Egale"},
        {"title": Text("Fin"), "value": "Fini"},
      ],
      "INTEGER": [
        {"title": Text("Egale"), "value": "Egale"},
        {"title": Text("Supérieure"), "value": "Superieure"},
        {"title": Text("Inférieure"), "value": "Inferieure"}
      ],
      "TEXT": [
        {"title": Text("Egale"), "value": "Egale"},
        {"title": Text("Début"), "value": "Commence"},
        {"title": Text("Milieu"), "value": "Contient"},
        {"title": Text("Fin"), "value": "Fini"}
      ],
      "date": [
        {"title": Text("Egale"), "value": "Egale"},
        {"title": Text("Avant"), "value": "Inferieure"},
        {"title": Text("Apres"), "value": "Superieure"},
        {"title": Text("Fourchette"), "value": "Fourchette"}
      ],
      "time": [
        {"title": Text("Egale"), "value": "Egale"},
        {"title": Text("Avant"), "value": "Inferieure"},
        {"title": Text("Apres"), "value": "Superieure"},
        {"title": Text("Fourchette"), "value": "Fourchette"}
      ]
    };

    List<Map<String, dynamic>> list_map_argument_of_radio =
        map_type_aruguments_radios_controls[type_field]!;

    void valueRadioButtonChanged(dynamic value) {
      super.widget.currentOptionNotifier.value = value.toString();
      setState(() {
        this.currentOption = value.toString();
      });
      super.widget.callbachSetstateFromServiceSearch(currentOption);
    }

    List<SizedBox> element_radios = list_map_argument_of_radio
        .map((map_argument_of_radio) => SizedBox(
              height: 35,
              width: 164,
              child: RadioListTile(
                  title: map_argument_of_radio["title"],
                  value: map_argument_of_radio["value"],
                  groupValue: this.currentOption,
                  onChanged: valueRadioButtonChanged),
            ))
        .toList();
    return Column(
      children: element_radios,
    );
  }

  @override
  Widget build(BuildContext context) {
    return this._generateComposantsOfFilter(super.widget.typeField);
  }
}
