import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/ViewModel_Serie.dart';
import 'package:unistream/Views/Templates/Series_Block_Display.dart';
import 'package:unistream/Views/Templates/Pagination_Display.dart';

class ViewSerie extends StatefulWidget {
  const ViewSerie({super.key});

  @override
  State<ViewSerie> createState() => ViewSerieState();
}

class ViewSerieState extends State<ViewSerie> {
  late ViewmodelSerie viewmodel;
  late SeriesBlockDisplay serieBlockDisplay;

  @override
  void initState() {
    super.initState();
    this._setViewModelAsync();
    this.serieBlockDisplay = SeriesBlockDisplay(viewmodel: this.viewmodel);
  }

  void _setViewModelAsync() async {
    this.viewmodel = await ViewmodelSerie.create();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                this.serieBlockDisplay,
                PaginationDisplay(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
