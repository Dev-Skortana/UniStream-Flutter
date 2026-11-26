import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:unistream/Models/Ajout_Oeuvre.dart';
import 'package:unistream/ViewModels/ViewModel_Ajout_Oeuvre.dart';

/// Écran « Ajouter depuis le serveur » : rechercher une œuvre dans l'index, choisir la version (site, VF/VOSTFR),
/// vérifier ce qui sera ajouté, puis l'ajouter. Toute la logique est dans ViewmodelAjoutOeuvre.
class ViewAjoutOeuvre extends StatefulWidget {
  const ViewAjoutOeuvre({super.key});

  @override
  State<ViewAjoutOeuvre> createState() => ViewAjoutOeuvreState();
}

class ViewAjoutOeuvreState extends State<ViewAjoutOeuvre> with SingleTickerProviderStateMixin {
  late final Future<ViewmodelAjoutOeuvre> _viewmodel;
  ViewmodelAjoutOeuvre? _vm;
  late final TabController _onglets = TabController(length: 2, vsync: this); // état d'affichage : reste dans la vue
  final _recherche = TextEditingController();
  final _titre = TextEditingController();
  String? _cleAffichee; // version dont le titre est dans _titre

  static const Map<EnumerationFulltypeVideo, String> _libelles = {
    EnumerationFulltypeVideo.Film_Film: 'Film',
    EnumerationFulltypeVideo.Film_Anime: 'Film d\'animation',
    EnumerationFulltypeVideo.Film_Drama: 'Film (drama)',
    EnumerationFulltypeVideo.Serie_Serie: 'Série',
    EnumerationFulltypeVideo.Serie_Anime: 'Série animée',
    EnumerationFulltypeVideo.Serie_Drama: 'Série (drama)',
  };

  @override
  void initState() {
    super.initState();
    _viewmodel = ViewmodelAjoutOeuvre.create();
    _viewmodel.then((vm) {
      _vm = vm;
      vm.message.addListener(() => _afficherMessage(vm));
    });
  }

  @override
  void dispose() {
    _vm?.dispose();
    _onglets.dispose();
    _recherche.dispose();
    _titre.dispose();
    super.dispose();
  }

  void _afficherMessage(ViewmodelAjoutOeuvre vm) {
    final m = vm.message.value;
    if (m == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 6)));
    vm.message.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter depuis le serveur · v4.5'),
        actions: const [BoutonTheme()],
      ), // marqueur de version
      body: FutureBuilder<ViewmodelAjoutOeuvre>(
        future: _viewmodel,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Impossible d\'ouvrir l\'ajout : ${snapshot.error}'));
          }
          final vm = snapshot.data!;
          return ListenableBuilder(
            listenable: Listenable.merge([
              vm.occupe, vm.chercheEnCours, vm.etape, vm.erreur, vm.intitule, vm.groupes, vm.bibliotheque,
              vm.filtres, vm.apercu,
              _recherche, // bouton « effacer » : visible dès qu'il y a du texte
            ]),
            builder: (context, _) => _contenu(context, vm),
          );
        },
      ),
    );
  }

  Widget _contenu(BuildContext context, ViewmodelAjoutOeuvre vm) {
    final occupe = vm.occupe.value;
    final a = vm.apercu.value;
    if (a == null) _cleAffichee = null;
    if (a != null && a.version.cle != _cleAffichee) {
      _cleAffichee = a.version.cle;
      _titre.text = a.titre;
    }
    final (aAjouter, presentes) = vm.onglets;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!vm.apiConfiguree)
            const ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('API non configurée'),
              subtitle: Text('Ajoute UNISTREAM_API_URL et UNISTREAM_API_CLE dans config.json'),
            ),
          // la saisie n'est jamais bloquée par une recherche en cours (seulement par une lecture ou un ajout)
          TextField(
            controller: _recherche,
            enabled: !occupe,
            textInputAction: TextInputAction.search,
            onChanged: vm.saisir,
            onSubmitted: vm.rechercher,
            decoration: InputDecoration(
              labelText: 'Titre à chercher',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _recherche.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Effacer (revenir aux nouveautés)',
                      onPressed: () {
                        _recherche.clear();
                        vm.saisir('');
                      }),
            ),
          ),
          const SizedBox(height: 8),
          _filtres(vm, occupe),
        ]),
      ),
      SizedBox(height: 4, child: vm.chercheEnCours.value ? const LinearProgressIndicator() : null),
      if (vm.erreur.value != null)
        ListTile(
            dense: true,
            leading: const Icon(Icons.error_outline, color: Colors.red),
            title: Text(vm.erreur.value!, style: const TextStyle(color: Colors.red))),
      if (occupe) ListTile(dense: true, leading: const CircularProgressIndicator(), title: Text(vm.etape.value ?? '')),
      if (a != null)
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [_apercu(context, vm, a, occupe)]))
      else ...[
        if (vm.intitule.value != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(vm.intitule.value!, style: Theme.of(context).textTheme.labelLarge)),
          ),
        TabBar(controller: _onglets, tabs: [
          Tab(text: 'À ajouter (${aAjouter.length})'),
          Tab(text: 'Dans ma bibliothèque (${presentes.length})'),
        ]),
        Expanded(
          child: TabBarView(controller: _onglets, children: [
            _liste(vm, aAjouter, occupe, 'Rien à ajouter ici'),
            _liste(vm, presentes, occupe, 'Aucune de ces œuvres n\'est dans ta bibliothèque'),
          ]),
        ),
      ],
    ]);
  }

  /// Deux filtres seulement, sur des données fiables : la langue et la famille.
  /// (La catégorie Film/Série est souvent inconnue avant lecture de la fiche : la filtrer cacherait des films.)
  Widget _filtres(ViewmodelAjoutOeuvre vm, bool occupe) {
    final f = vm.filtres.value;
    Widget puce(String libelle, bool choisi, VoidCallback action) => FilterChip(
        label: Text(libelle), selected: choisi, visualDensity: VisualDensity.compact, onSelected: occupe ? null : (_) => action());
    return Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
      puce('VF', f.langues.contains('vf'), () => vm.basculerLangue('vf')),
      puce('VOSTFR', f.langues.contains('vostfr'), () => vm.basculerLangue('vostfr')),
      const SizedBox(width: 8),
      puce('Anime', f.familles.contains('Anime'), () => vm.basculerFamille('Anime')),
      puce('Drama', f.familles.contains('Drama'), () => vm.basculerFamille('Drama')),
      if (f.actifs) TextButton(onPressed: occupe ? null : vm.effacerFiltres, child: const Text('Effacer')),
    ]);
  }

  Widget _liste(ViewmodelAjoutOeuvre vm, List<GroupeOeuvre> groupes, bool occupe, String vide) {
    if (groupes.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(vm.chercheEnCours.value ? 'Recherche…' : vide),
          // un onglet vide à cause des filtres doit le dire, sinon on croit que le serveur n'a rien
          if (vm.filtres.value.actifs && !vm.chercheEnCours.value)
            TextButton(onPressed: vm.effacerFiltres, child: const Text('Effacer les filtres')),
        ]),
      );
    }
    // Les correspondances partielles (milieu / fin de mot) arrivent du serveur APRÈS les autres : un simple
    // intertitre les sépare, sans rien déplacer de ce qui est au-dessus.
    final premierePartielle = groupes.indexWhere((g) => g.partielle);
    final elements = <Object>[
      for (final (i, g) in groupes.indexed) ...[
        if (i == premierePartielle) 'Autres correspondances (${groupes.length - i})',
        g,
      ]
    ];
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: elements.length,
      separatorBuilder: (_, i) =>
          elements[i] is String || (i + 1 < elements.length && elements[i + 1] is String)
              ? const SizedBox.shrink()
              : const Divider(height: 1),
      itemBuilder: (context, i) {
        final e = elements[i];
        return e is GroupeOeuvre ? _groupe(context, vm, e, occupe) : _intertitre(context, e as String);
      },
    );
  }

  Widget _intertitre(BuildContext context, String texte) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(children: [
          Text(texte, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).hintColor)),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ]),
      );

  /// Une œuvre, ses versions en puces : un seul toucher pour choisir (✓ = déjà dans la bibliothèque).
  Widget _groupe(BuildContext context, ViewmodelAjoutOeuvre vm, GroupeOeuvre g, bool occupe) {
    final affiche = g.versions.map((v) => v.urlPoster).whereType<String>().firstOrNull;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _vignette(affiche, 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(g.titreOeuvre, style: Theme.of(context).textTheme.titleSmall),
            Text(g.famille.isEmpty ? 'famille ?' : g.famille, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 4, children: [
              for (final v in g.versions)
                vm.possedee(v)
                    ? Chip(
                        avatar: const Icon(Icons.check, size: 16),
                        label: Text('${v.libelleLangues} · ${v.site}'),
                        visualDensity: VisualDensity.compact)
                    : ActionChip(
                        label: Text('${v.libelleLangues} · ${v.site}'),
                        visualDensity: VisualDensity.compact,
                        tooltip: v.titre,
                        onPressed: occupe ? null : () => vm.choisir(v)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _vignette(String? url, double largeur) => SizedBox(
        width: largeur,
        height: largeur * 1.5,
        child: url == null
            ? const Icon(Icons.image_not_supported_outlined)
            // certains sites refusent l'affichage direct (403) : l'icône remplace l'image, l'ajout la télécharge
            // quand même avec le bon Referer
            : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined)),
      );

  Widget _ligne(String libelle, String valeur) => valeur.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$libelle : ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: valeur),
          ])),
        );

  Widget _apercu(BuildContext context, ViewmodelAjoutOeuvre vm, ApercuAjout a, bool occupe) {
    final d = a.dureeMinutes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextButton.icon(
          onPressed: occupe ? null : vm.fermerApercu, icon: const Icon(Icons.arrow_back), label: const Text('Résultats')),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _vignette(a.urlPoster, 100),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${a.version.site} · ${a.version.libelleLangues}', style: Theme.of(context).textTheme.titleSmall),
            _ligne('Sortie', a.dateParution == null ? '' : '${a.dateParution!.year}'),
            _ligne('Durée', d == null ? '' : '$d min'),
            _ligne('Genres', a.genres.join(', ')),
            _ligne('Pays', a.pays.join(', ')),
            _ligne('Studio', a.studio),
            _ligne('Réalisation', a.realisateurs.join(', ')),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      TextField(
        controller: _titre,
        enabled: !occupe,
        onSubmitted: vm.changerTitre,
        decoration: const InputDecoration(labelText: 'Titre dans la bibliothèque', border: OutlineInputBorder()),
      ),
      if (a.dejaPresent)
        const ListTile(
          dense: true,
          leading: Icon(Icons.warning_amber, color: Colors.orange),
          title: Text('Ce titre est déjà dans la bibliothèque. Change-le pour ajouter cette version à part ; '
              'pour mettre l\'existant à jour, passe par Synchronisation.'),
        ),
      const SizedBox(height: 12),
      DropdownButtonFormField<EnumerationFulltypeVideo>(
        key: ValueKey(a.typeComplet), // reconstruit le champ quand le ViewModel change le type
        value: a.typeComplet,
        decoration: InputDecoration(
          labelText: 'Type',
          border: const OutlineInputBorder(),
          helperText: a.typeDeduit ? null : 'Catégorie inconnue du serveur : vérifie le type',
        ),
        items: [
          for (final t in ViewmodelAjoutOeuvre.typesProposes)
            DropdownMenuItem(value: t, child: Text(_libelles[t] ?? t.name))
        ],
        onChanged: occupe
            ? null
            : (t) {
                if (t != null) vm.changerType(t);
              },
      ),
      if (a.estSerie) ...[
        const SizedBox(height: 12),
        if (a.episodesParSaison.isEmpty)
          const Text('Aucun épisode lisible pour l\'instant : la synchronisation les ajoutera.')
        else
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final e in a.episodesParSaison.entries) Chip(label: Text('S${e.key} : ${e.value} ép.'))
          ]),
      ],
      if (a.avertissement != null)
        ListTile(dense: true, leading: const Icon(Icons.info_outline), title: Text(a.avertissement!)),
      if (a.synopsis.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(a.synopsis),
      ],
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: occupe
            ? null
            : () async {
                await vm.changerTitre(_titre.text); // titre modifié sans « Entrée »
                await vm.ajouter();
              },
        icon: const Icon(Icons.library_add),
        label: const Text('Ajouter à la bibliothèque'),
      ),
    ]);
  }
}
