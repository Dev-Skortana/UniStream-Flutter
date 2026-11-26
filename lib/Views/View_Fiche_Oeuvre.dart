import 'package:flutter/material.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_FilmBase.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_VideoBase.dart';
import 'package:unistream/ViewModels/ViewModel_Bibliotheque.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:unistream/Views/Templates/Films_Block_Display.dart';
import 'package:unistream/Views/Templates/Series_Block_Display.dart';

/// Fiche d'une œuvre ouverte depuis la Bibliothèque.
///
/// PROVISOIRE (étape 3) : réutilise les blocs existants (saison / épisode,
/// recherche des liens de lecture) pour que la lecture marche tout de suite.
/// L'écran Détail redessiné le remplacera à l'étape 4.
class ViewFicheOeuvre extends StatefulWidget {
  final OeuvreBibliotheque oeuvre;
  const ViewFicheOeuvre({super.key, required this.oeuvre});

  @override
  State<ViewFicheOeuvre> createState() => ViewFicheOeuvreState();
}

class ViewFicheOeuvreState extends State<ViewFicheOeuvre> {
  late final Future<ViewmodelVideobase> _viewmodel =
      ViewmodelBibliotheque.viewModelDeLaFiche(widget.oeuvre);
  ValueNotifier? _videoNotifier;

  @override
  void dispose() {
    _videoNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.oeuvre.titre, overflow: TextOverflow.ellipsis),
        actions: const [BoutonTheme()],
      ),
      body: FutureBuilder<ViewmodelVideobase>(
        future: _viewmodel,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final vm = snapshot.data;
          if (snapshot.hasError || vm == null) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text("Impossible d'ouvrir la fiche : ${snapshot.error}",
                  textAlign: TextAlign.center),
            ));
          }
          _videoNotifier ??= ValueNotifier(vm.video["Video"]);
          return SingleChildScrollView(
            child: vm is ViewmodelSeriebase
                ? SeriesBlockDisplay(
                    viewmodel: vm, video_notifier: _videoNotifier!)
                : FilmsBlockDisplay(
                    viewmodel: vm as ViewmodelFilmbase,
                    video_notifier: _videoNotifier!),
          );
        },
      ),
    );
  }
}
