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
            label: Text("Onglet"),
            hintText: "Onglet",
            dropdownMenuEntries: <DropdownMenuEntry>[
              DropdownMenuEntry(value: "Films", label: "Films"),
              DropdownMenuEntry(value: "Films", label: "Séries")
            ],
            onSelected: this._on_change,
          )
        ],
      ),
    );
  }
}
