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
  ViewmodelSerie? viewmodel;
  late FutureBuilder data;
  Function? valueChangedOfThisTopView;

  ViewSerieState() {
    this.valueChangedOfThisTopView = () {
      setState(() {});
    };
  }

  FutureBuilder getData() => FutureBuilder(
      future: ViewmodelSerie.create(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          this.viewmodel = snapshot.data;

          return SeriesBlockDisplay(
            viewmodel: this.viewmodel!,
            value_changed_topview: this.valueChangedOfThisTopView!,
          );
        }
      });

  @override
  void initState() {
    super.initState();
    this.data = this.getData();
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
              children: [this.data],
            ),
          ),
          PaginationDisplay()
        ],
      ),
    );
  }
}
