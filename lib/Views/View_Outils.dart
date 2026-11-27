import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Services/Features/Reinitialisation/Reinitialisation_Bibliotheque.dart';
import 'package:unistream/Views/Helpers/Son_Demarrage.dart';
import 'package:unistream/Views/Helpers/Theme_Controller.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:unistream/Views/View_Ajout_Oeuvre.dart';
import 'package:unistream/Views/View_Enregistrement.dart';
import 'package:unistream/Views/View_Synchronisation.dart';

/// Onglet « Outils » : serveur UniStream, ancienne collecte sur l'appareil,
/// réglages du thème et du son d'ouverture. Remplace l'onglet Enregistrements.
class ViewOutils extends StatelessWidget {
  /// Appelé au retour d'un écran qui a pu modifier la bibliothèque.
  final VoidCallback? onBibliothequeModifiee;

  const ViewOutils({super.key, this.onBibliothequeModifiee});

  Future<void> _ouvrir(BuildContext context, Widget ecran,
      {bool modifieBibliotheque = false}) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ecran));
    if (modifieBibliotheque) onBibliothequeModifiee?.call();
  }

  /// Les anciens écrans étaient des onglets : on leur donne un Scaffold.
  Widget _ecranAvecBarre(String titre, Widget corps) => Scaffold(
        appBar: AppBar(title: Text(titre), actions: const [BoutonTheme()]),
        body: SafeArea(child: corps),
      );

  Future<void> _reinitialiser(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogue) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Réinitialiser la bibliothèque ?'),
        content: const Text(
            'Toutes les œuvres de la base et les affiches téléchargées seront '
            'supprimées. Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogue).pop(false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogue).colorScheme.error,
                foregroundColor: Theme.of(dialogue).colorScheme.onError),
            onPressed: () => Navigator.of(dialogue).pop(true),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true || !context.mounted) return;
    final messager = ScaffoldMessenger.of(context);
    try {
      await ReinitialisationBibliotheque.toutEffacer();
      onBibliothequeModifiee?.call();
      messager.showSnackBar(
          const SnackBar(content: Text('Bibliothèque réinitialisée.')));
    } catch (e) {
      messager.showSnackBar(
          SnackBar(content: Text('Réinitialisation impossible : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controleur = context.watch<ThemeController>();
    final sonDemarrage = context.watch<SonDemarrage>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _Titre('Serveur UniStream'),
        _Groupe(children: [
          ListTile(
            leading: const Icon(Icons.library_add_outlined),
            title: const Text('Ajouter depuis le serveur'),
            subtitle: const Text('Recherche et nouveautés des 7 derniers jours'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _ouvrir(context, const ViewAjoutOeuvre(),
                modifieBibliotheque: true),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Synchronisation'),
            subtitle: const Text('Relier mes titres, appliquer les changements'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _ouvrir(context, const ViewSynchronisation(),
                modifieBibliotheque: true),
          ),
        ]),
        const _Titre("Collecte sur l'appareil (ancien système)"),
        _Groupe(children: [
          ListTile(
            leading: const Icon(Icons.travel_explore),
            title: const Text('Enregistrements'),
            subtitle: const Text('Collecter un site, une catégorie, n pages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _ouvrir(
                context, _ecranAvecBarre('Enregistrements', ViewEnregistrement()),
                modifieBibliotheque: true),
          ),
        ]),
        const _Titre('Affichage'),
        _Groupe(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thème'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.light, label: Text('Clair')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Sombre')),
                      ButtonSegment(value: ThemeMode.system, label: Text('Système')),
                    ],
                    selected: {controleur.value},
                    showSelectedIcon: false,
                    onSelectionChanged: (choix) => controleur.choisir(choix.first),
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.music_note_outlined),
            title: const Text('Son au démarrage'),
            subtitle: const Text("Joué à l'ouverture, sauf en mode silencieux"),
            value: sonDemarrage.value,
            onChanged: sonDemarrage.choisir,
          ),
        ]),
        const _Titre('Données'),
        _Groupe(children: [
          ListTile(
            leading: Icon(Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error),
            title: Text('Réinitialiser la bibliothèque',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            subtitle: const Text('Supprime toutes les œuvres et les affiches'),
            onTap: () => _reinitialiser(context),
          ),
        ]),
      ],
    );
  }
}

class _Titre extends StatelessWidget {
  final String texte;
  const _Titre(this.texte);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(texte,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary)),
      );
}

class _Groupe extends StatelessWidget {
  final List<Widget> children;
  const _Groupe({required this.children});

  @override
  Widget build(BuildContext context) => Card.filled(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );
}
