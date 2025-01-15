import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Dropdown_Onglets.dart';

class ViewDrama extends StatefulWidget {
  const ViewDrama({super.key});

  @override
  State<ViewDrama> createState() => ViewDramaState();
}

class ViewDramaState extends State<ViewDrama> {
  void _dropdown_change(event) {}
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownOnglets((event) => this._dropdown_change(event)),
    );
  }
}
