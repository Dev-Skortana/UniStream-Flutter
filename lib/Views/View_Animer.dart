import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Dropdown_Onglets.dart';

class ViewAnimer extends StatefulWidget {
  const ViewAnimer({super.key});

  @override
  State<ViewAnimer> createState() => ViewAnimerState();
}

class ViewAnimerState extends State<ViewAnimer> {
  void _dropdown_change(event) {}
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownOnglets((event) => this._dropdown_change(event)),
    );
  }
}
