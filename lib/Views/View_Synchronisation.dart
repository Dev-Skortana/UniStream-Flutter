import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:unistream/Models/Synchronisation.dart';
import 'package:unistream/ViewModels/ViewModel_Synchronisation.dart';

/// Écran Synchronisation : relier les titres au serveur, voir ce qui changerait, puis appliquer (après sauvegarde).
/// Toute la logique est dans ViewmodelSynchronisation ; la vue affiche ses ValueNotifier.
class ViewSynchronisation extends StatefulWidget {
  const ViewSynchronisation({super.key});

  @override
  State<ViewSynchronisation> createState() => ViewSynchronisationState();
}

class ViewSynchronisationState extends State<ViewSynchronisation> {
  late final Future<ViewmodelSynchronisation> _viewmodel;
  ViewmodelSynchronisation? _vm;

  @override
  void initState() {
    super.initState();
    _viewmodel = ViewmodelSynchronisation.create();
    // un seul abonnement aux messages (le builder, lui, est rappelé à chaque reconstruction)
    _viewmodel.then((vm) {
      _vm = vm;
      vm.message.addListener(() => _afficherMessage(vm));
    });
  }

  @override
  void dispose() {
    _vm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchronisation · v3.3'),
        actions: const [BoutonTheme()],
      ), // marqueur de version : change à chaque livraison
      body: FutureBuilder<ViewmodelSynchronisation>(
        future: _viewmodel,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Impossible d\'ouvrir la synchronisation : ${snapshot.error}'));
          }
          final vm = snapshot.data!;
          return ListenableBuilder(
            listenable: Listenable.merge(
                [vm.occupe, vm.etape, vm.erreur, vm.titresRelies, vm.aValider, vm.apercus, vm.enFile, vm.selection]),
            builder: (context, _) => _contenu(context, vm),
          );
        },
      ),
    );
  }

  void _afficherMessage(ViewmodelSynchronisation vm) {
    final m = vm.message.value;
    if (m == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 6)));
    vm.message.value = null;
  }

  Future<bool> _confirmer(String titre, String texte) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(titre),
          content: Text(texte),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirmer')),
          ],
        ),
      ) ??
      false;

  Widget _contenu(BuildContext context, ViewmodelSynchronisation vm) {
    final occupe = vm.occupe.value;
    final (relies, total) = vm.titresRelies.value;
    final aMettreAJour = vm.aMettreAJour;
    final nbCoches = vm.selection.value.length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (!vm.apiConfiguree)
        const ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text('API non configurée'),
          subtitle: Text('Ajoute UNISTREAM_API_URL et UNISTREAM_API_CLE dans config.json, puis relance avec '
              '--dart-define-from-file=config.json'),
        ),
      ListTile(
        leading: const Icon(Icons.link),
        title: Text('$relies titre(s) relié(s) sur $total'),
        subtitle: vm.aValider.value > 0 ? Text('${vm.aValider.value} à valider (plus tard, sur le serveur)') : null,
      ),
      if (vm.erreur.value != null)
        ListTile(
            leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            title: Text(vm.erreur.value!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      if (occupe) ListTile(leading: const CircularProgressIndicator(), title: Text(vm.etape.value ?? '')),
      Wrap(spacing: 12, runSpacing: 8, children: [
        FilledButton.icon(
            onPressed: occupe ? null : vm.relier, icon: const Icon(Icons.join_inner), label: const Text('Relier mes titres')),
        FilledButton.icon(
            onPressed: occupe || relies == 0 ? null : vm.calculerApercu,
            icon: const Icon(Icons.preview),
            label: const Text('Voir ce qui changerait')),
        OutlinedButton.icon(
          onPressed: occupe
              ? null
              : () async {
                  if (await _confirmer('Annuler la dernière synchronisation ?',
                      'La base est remise telle qu\'elle était juste avant la dernière synchronisation. '
                      'Ce qui a été modifié depuis sera perdu.')) {
                    await vm.annulerDerniere();
                  }
                },
          icon: const Icon(Icons.restore),
          label: const Text('Annuler la dernière'),
        ),
      ]),
      if (vm.apercus.value.isNotEmpty) ...[
        const Divider(height: 32),
        Text('${aMettreAJour.length} œuvre(s) à mettre à jour sur ${vm.apercus.value.length}',
            style: Theme.of(context).textTheme.titleMedium),
        for (final e in vm.parType.entries) Text('• ${Changement(e.key, '', '').libelle} : ${e.value}'),
        if (vm.sansDetails > 0 || vm.enFile.value > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${vm.sansDetails} fiche(s) pas encore lue(s) par le serveur (${vm.enFile.value} en file) : '
                'elles le seront la nuit prochaine.'),
          ),
        if (aMettreAJour.isNotEmpty) ...[
          // Wrap plutôt que Row : sur un écran étroit, le bouton passe à la ligne au lieu de déborder
          Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
            TextButton(onPressed: occupe ? null : () => vm.toutSelectionner(true), child: const Text('Tout cocher')),
            TextButton(onPressed: occupe ? null : () => vm.toutSelectionner(false), child: const Text('Tout décocher')),
            FilledButton.icon(
              onPressed: occupe || nbCoches == 0
                  ? null
                  : () async {
                      if (await _confirmer('Mettre à jour $nbCoches œuvre(s) ?',
                          'Une sauvegarde de la base est faite avant l\'écriture : « Annuler la dernière » '
                          'permet de revenir en arrière.')) {
                        await vm.appliquer();
                      }
                    },
              icon: const Icon(Icons.save_alt),
              label: Text('Appliquer ($nbCoches)'),
            ),
          ]),
          for (final a in aMettreAJour)
            ExpansionTile(
              leading: Checkbox(
                  value: vm.selection.value.contains(a.titre), onChanged: occupe ? null : (_) => vm.basculer(a.titre)),
              title: Text(a.titre),
              subtitle: Text('${a.site ?? '?'} — ${a.changements.length} changement(s)'),
              children: [
                if (a.avertissement != null)
                  ListTile(dense: true, leading: const Icon(Icons.warning_amber), title: Text(a.avertissement!)),
                for (final c in a.changements)
                  ListTile(dense: true, title: Text(c.libelle), subtitle: Text('${c.avant}\n→ ${c.apres}')),
              ],
            ),
        ],
      ],
    ]);
  }
}
