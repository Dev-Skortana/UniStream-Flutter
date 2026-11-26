import 'package:flutter/material.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Detail/Infos_Detail.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';
import 'package:unistream/ViewModels/ViewModel_Detail.dart';
import 'package:unistream/Views/Templates/Affiche_Teintee.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:unistream/Views/View_Services/BoxDialog_WatchsResults/Service_BoxDialog_WatchsResults.dart';

/// Écran Détail d'une œuvre, ouvert depuis la Bibliothèque.
/// Remplace l'ancienne fiche (Video / Series / Films_Block_Display).
class ViewDetail extends StatefulWidget {
  final OeuvreBibliotheque oeuvre;
  const ViewDetail({super.key, required this.oeuvre});

  @override
  State<ViewDetail> createState() => ViewDetailState();
}

class ViewDetailState extends State<ViewDetail> {
  late final ViewmodelDetail _vm = ViewmodelDetail(widget.oeuvre);

  static const Map<FamilleOeuvre, String> _familles = {
    FamilleOeuvre.anime: 'Anime',
    FamilleOeuvre.drama: 'Drama',
    FamilleOeuvre.live: 'Live action',
  };

  @override
  void initState() {
    super.initState();
    _vm.charger();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _regarder() async {
    try {
      final liens = await _vm.chercherLiens();
      if (liens == null || !mounted) return;
      await showDialog(
        context: context,
        builder: (_) => ServiceBoxdialogWatchsresults(
          categorie: _vm.categorieLecture,
          mapsWatchResult: liens,
          episode_into_caracteres: _vm.estSerie ? '${_vm.episode.value}' : '',
          surLecture: _vm.enregistrerLecture,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recherche des liens impossible : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [BoutonTheme()]),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _vm.chargement,
          _vm.erreur,
          _vm.infos,
          _vm.saison,
          _vm.episode,
          _vm.rechercheEnCours,
          _vm.suivi,
        ]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            _entete(context),
            const SizedBox(height: 20),
            if (_vm.estSerie) ...[
              _choixEpisode(context),
              const SizedBox(height: 12),
            ],
            _boutonRegarder(context),
            if (_vm.suivi.value case final suivi?) ...[
              const SizedBox(height: 8),
              _ligneSuivi(context, suivi),
            ],
            if (_vm.erreur.value != null) ...[
              const SizedBox(height: 12),
              Text(_vm.erreur.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            _synopsis(context),
            if (_vm.infos.value.genres.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in _vm.infos.value.genres) Chip(label: Text(g)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            _fiche(context),
          ],
        ),
      ),
    );
  }

  Widget _entete(BuildContext context) {
    final textes = Theme.of(context).textTheme;
    final couleurs = Theme.of(context).colorScheme;
    final o = widget.oeuvre;
    final infos = _vm.infos.value;

    final ligne1 = [
      _familles[o.famille],
      o.format == FormatOeuvre.serie ? 'Série' : 'Film',
      if (o.dateParution != null) '${o.dateParution!.year}',
    ].join(' · ');

    final saisons = infos.saisons.length;
    final ligne2 = [
      if (saisons > 0) '$saisons saison${saisons > 1 ? 's' : ''}',
      if (infos.nombreEpisodes > 0)
        '${infos.nombreEpisodes} épisode${infos.nombreEpisodes > 1 ? 's' : ''}',
      if (InfosDetail.formaterDuree(o.video.duree) case final duree?) duree,
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 120,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: AfficheTeintee(
                chemin: o.lienAffiche,
                rayon: 14,
                force: 1.4,
                largeurDecodage: 360),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(o.titre,
                  style: textes.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(ligne1,
                  style: textes.bodyMedium
                      ?.copyWith(color: couleurs.onSurfaceVariant)),
              if (ligne2.isNotEmpty)
                Text(ligne2,
                    style: textes.bodyMedium
                        ?.copyWith(color: couleurs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _choixEpisode(BuildContext context) {
    final infos = _vm.infos.value;
    if (_vm.chargement.value) return const LinearProgressIndicator();
    if (infos.saisons.isEmpty) {
      return Text('Aucun épisode enregistré pour cette série.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
    }
    final saison = _vm.saison.value;
    // DropdownMenu (stable depuis Flutter 3.10) plutôt que
    // DropdownButtonFormField, dont le paramètre value/initialValue
    // a changé de nom selon les versions.
    Widget menu<T>({
      required String cle,
      required String label,
      required T? selection,
      required List<DropdownMenuEntry<T>> entrees,
      required void Function(T) onChoix,
    }) =>
        LayoutBuilder(
          builder: (context, contraintes) => DropdownMenu<T>(
            // La clé recrée le menu quand la sélection change dans le
            // ViewModel (initialSelection n'est lu qu'à la création).
            key: ValueKey(cle),
            width: contraintes.maxWidth,
            label: Text(label),
            initialSelection: selection,
            menuHeight: 320,
            dropdownMenuEntries: entrees,
            onSelected: (v) {
              if (v != null) onChoix(v);
            },
          ),
        );

    return Row(
      children: [
        Expanded(
          child: menu<int>(
            cle: 'saison-$saison',
            label: 'Saison',
            selection: saison,
            entrees: [
              for (final s in infos.saisons)
                DropdownMenuEntry(value: s, label: 'Saison $s'),
            ],
            onChoix: _vm.choisirSaison,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: menu<int>(
            cle: 'episode-$saison-${_vm.episode.value}',
            label: 'Épisode',
            selection: _vm.episode.value,
            entrees: [
              for (final e in infos.episodesDe(saison ?? -1))
                DropdownMenuEntry(
                  value: e,
                  label: 'Épisode $e',
                  // Épisode déjà lancé : coche « vu ».
                  trailingIcon: _vm.estVu(saison ?? -1, e)
                      ? Icon(Icons.check_circle,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
            ],
            onChoix: _vm.choisirEpisode,
          ),
        ),
      ],
    );
  }

  Widget _boutonRegarder(BuildContext context) {
    final enCours = _vm.rechercheEnCours.value;
    final libelle = enCours
        ? 'Recherche des liens…'
        : _vm.estSerie
            ? (_vm.episode.value == null
                ? 'Regarder'
                : '${_vm.estUneReprise ? 'Reprendre' : 'Regarder'} '
                    'S${_vm.saison.value} · É${_vm.episode.value}')
            : 'Regarder le film';
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: enCours || !_vm.peutRegarder ? null : _regarder,
        icon: enCours
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.play_arrow_rounded),
        label: Text(libelle),
      ),
    );
  }

  /// « Dernier épisode vu : S1 · É4 », « Vu le 12 novembre 2026 » (film),
  /// « 2 nouveaux épisodes depuis ta dernière visite ».
  Widget _ligneSuivi(BuildContext context, SuiviOeuvre suivi) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    final date = InfosDetail.formaterDate(suivi.derniereLecture);
    final principal = switch (suivi.dernierLu) {
      (final s, final e) => 'Dernier épisode lancé : S$s · É$e, le $date',
      null => 'Lancé le $date',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.history, size: 18, color: couleurs.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(principal,
                style:
                    textes.bodySmall?.copyWith(color: couleurs.onSurfaceVariant)),
          ),
        ]),
        if (suivi.aNouveaute) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.fiber_new_rounded, size: 18, color: couleurs.tertiary),
            const SizedBox(width: 6),
            Text(
                '${suivi.nouveaux} '
                '${suivi.nouveaux > 1 ? 'nouveaux épisodes' : 'nouvel épisode'} '
                'depuis ta dernière lecture',
                style: textes.bodySmall?.copyWith(color: couleurs.tertiary)),
          ]),
        ],
        if (suivi.progression case final p? when p > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: p, minHeight: 4),
          ),
        ],
      ],
    );
  }

  Widget _synopsis(BuildContext context) {
    final textes = Theme.of(context).textTheme;
    final description = widget.oeuvre.video.description.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Synopsis', style: textes.titleMedium),
        const SizedBox(height: 8),
        description.isEmpty
            ? Text('Pas de synopsis.',
                style: textes.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant))
            : SelectableText(description,
                style: textes.bodyMedium?.copyWith(height: 1.5)),
      ],
    );
  }

  Widget _fiche(BuildContext context) {
    final infos = _vm.infos.value;
    final o = widget.oeuvre;
    final lignes = <(String, String)>[
      if (_vm.studio case final studio?) ('Studio', studio),
      if (infos.realisateurs.isNotEmpty) ('Réalisation', infos.realisateurs.join(', ')),
      if (infos.pays.isNotEmpty) ('Pays', infos.pays.join(', ')),
      if (InfosDetail.formaterDate(o.dateParution) case final date?) ('Parution', date),
    ];
    if (lignes.isEmpty) return const SizedBox.shrink();

    final couleurs = Theme.of(context).colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            for (final (i, (libelle, valeur)) in lignes.indexed) ...[
              if (i > 0) Divider(height: 1, color: couleurs.outlineVariant),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(libelle,
                          style: TextStyle(color: couleurs.onSurfaceVariant)),
                    ),
                    Expanded(child: SelectableText(valeur)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
