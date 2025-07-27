import 'package:flutter/material.dart';

class DropdownOnglets extends StatelessWidget {
  late ValueChanged<dynamic> _on_change;

  DropdownOnglets(on_change_dropdown, {super.key}) {
    this._on_change = on_change_dropdown;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 0,
        children: [
          DropdownMenu(
            hintText: "Onglet",
            initialSelection: "Films",
            label: Text("Films"),
            dropdownMenuEntries: <DropdownMenuEntry>[
              DropdownMenuEntry(value: "Video_Film", label: "Films"),
              DropdownMenuEntry(value: "Video_Serie", label: "Séries")
            ],
            onSelected: this._on_change,
          )
        ],
      ),
    );
  }
}
