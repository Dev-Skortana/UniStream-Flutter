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
  ViewmodelFilm? viewmodel;
  late FilmsBlockDisplay filmBlockDisplay;
  @override
  void initState() {
    super.initState();
  }

  void valueChanged() {
    setState(() {});
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
                FutureBuilder(
                    future: ViewmodelFilm.create(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        this.viewmodel = snapshot.data;
                        Function callbacksetstate = () {
                          this.valueChanged();
                        };
                        return FilmsBlockDisplay(
                            viewmodel: this.viewmodel!,
                            value_changed_of_topview: callbacksetstate);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
                PaginationDisplay(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
