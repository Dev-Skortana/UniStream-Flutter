import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:unistream/Views/View_Acceuille.dart';
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

  /// Pour recharger la grille après un ajout ou une synchronisation.
  final GlobalKey<ViewBibliothequeState> _cleBibliotheque = GlobalKey();

  static const List<String> _titres = ['UniStream', 'Bibliothèque', 'Outils'];

  void _rechargerBibliotheque() => _cleBibliotheque.currentState?.recharger();

  Future<void> _ouvrir(Widget ecran) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ecran));
    _rechargerBibliotheque();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Un seul texte, qui se coupe proprement s'il manque de place
        // (l'ancienne Row « UniStream + onglet » débordait).
        title: Text(_titres[currentIndex], overflow: TextOverflow.ellipsis),
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
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: [
            ViewAcceuille(),
            ViewBibliotheque(key: _cleBibliotheque),
            ViewOutils(onBibliothequeModifiee: _rechargerBibliotheque),
          ],
        ),
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
