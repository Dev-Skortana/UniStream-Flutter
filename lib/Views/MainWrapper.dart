import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:unistream/Views/View_Accueil.dart';
import 'package:unistream/Views/View_Ajout_Oeuvre.dart';
import 'package:unistream/Views/View_Bibliotheque.dart';
import 'package:unistream/Views/View_Outils.dart';
import 'package:unistream/Views/View_Synchronisation.dart';

/// Écran racine : 3 onglets (Accueil · Bibliothèque · Outils).
/// Animer / Drama / Série / Film sont regroupés dans la Bibliothèque,
/// Enregistrements et Sites (beta) sont dans Outils.
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int currentIndex = 0;

  /// Pour recharger l'Accueil et la grille après un ajout,
  /// une synchronisation ou une réinitialisation.
  final GlobalKey<ViewAccueilState> _cleAccueil = GlobalKey();
  final GlobalKey<ViewBibliothequeState> _cleBibliotheque = GlobalKey();

  static const List<String> _titres = ['UniStream', 'Bibliothèque', 'Outils'];

  void _rechargerBibliotheque() {
    _cleAccueil.currentState?.recharger();
    _cleBibliotheque.currentState?.recharger();
  }

  /// « Uni » + « Stream » dans la couleur d'accent, sur l'Accueil.
  Widget _titre(BuildContext context) {
    if (currentIndex != 0) {
      return Text(_titres[currentIndex], overflow: TextOverflow.ellipsis);
    }
    return Text.rich(TextSpan(children: [
      const TextSpan(text: 'Uni'),
      TextSpan(
          text: 'Stream',
          style: TextStyle(color: Theme.of(context).colorScheme.primary)),
    ]));
  }

  Future<void> _ouvrir(Widget ecran) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ecran));
    _rechargerBibliotheque();
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final surAccueil = currentIndex == 0;
    return Scaffold(
      // Sur l'Accueil, le dégradé de la vedette passe sous la barre du haut ;
      // la barre redevient opaque dès que la page défile.
      extendBodyBehindAppBar: surAccueil,
      appBar: AppBar(
        backgroundColor: surAccueil
            ? WidgetStateColor.resolveWith((etats) =>
                etats.contains(WidgetState.scrolledUnder)
                    ? couleurs.surface
                    : Colors.transparent)
            : null,
        // Un seul texte, qui se coupe proprement s'il manque de place
        // (l'ancienne Row « UniStream + onglet » débordait).
        title: _titre(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_add_outlined),
            tooltip: 'Ajouter depuis le serveur',
            onPressed: () => _ouvrir(const ViewAjoutOeuvre()),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Synchronisation',
            onPressed: () => _ouvrir(const ViewSynchronisation()),
          ),
          const BoutonTheme(),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          // Pas de SafeArea : l'Accueil place lui-même son contenu sous la
          // barre (MediaQuery.paddingOf(context).top inclut sa hauteur).
          ViewAccueil(key: _cleAccueil),
          SafeArea(child: ViewBibliotheque(key: _cleBibliotheque)),
          SafeArea(
              child:
                  ViewOutils(onBibliothequeModifiee: _rechargerBibliotheque)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil'),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Bibliothèque'),
          NavigationDestination(
              icon: Icon(Icons.handyman_outlined),
              selectedIcon: Icon(Icons.handyman),
              label: 'Outils'),
        ],
      ),
    );
  }
}
