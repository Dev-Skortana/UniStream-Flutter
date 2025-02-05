import 'package:flutter/material.dart';
import 'package:unistream/ViewModels/ViewModel_Film.dart';
import 'package:unistream/Views/Templates/Films_Block_Display.dart';
import 'package:unistream/Views/Templates/Pagination_Display.dart';

class ViewFilm extends StatefulWidget {
  const ViewFilm({super.key});

  @override
  State<ViewFilm> createState() => ViewFilmState();
}

class ViewFilmState extends State<ViewFilm> {
  late ViewmodelFilm viewmodel;
  late FilmsBlockDisplay filmBlockDisplay;
  @override
  void initState() {
    super.initState();
    this._setViewModelAsync();
    this.filmBlockDisplay = FilmsBlockDisplay(viewmodel: this.viewmodel);
  }

  void _setViewModelAsync() async {
    this.viewmodel = await ViewmodelFilm.create();
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
                this.filmBlockDisplay,
                PaginationDisplay(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
