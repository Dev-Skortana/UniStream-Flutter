import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' show WebUri;
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Chrome_Safari/Chrome_Safari_Custom.dart';
import 'package:unistream/Services/Features/Detail/Infos_Detail.dart';
import 'package:unistream/Services/Features/Lecture/Navigation_Lecture.dart';
import 'package:unistream/ViewModels/ViewModel_Lecture.dart';
import 'package:unistream/Views/Helpers/Theme.dart';
import 'package:unistream/Views/Templates/Affiche_Teintee.dart';
import 'package:unistream/Views/View_WatchVideo.dart';

/// Ouvre la feuille de lecture (remplace l'ancienne boîte de dialogue des
/// liens). [episode] : (saison, épisode) de départ, null pour un film.
Future<void> ouvrirFeuilleLecture(
  BuildContext context, {
  required OeuvreBibliotheque oeuvre,
  required Map<int, List<int>> episodesParSaison,
  (int, int)? episode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.78,
      child: FeuilleLecture(
          oeuvre: oeuvre,
          episodesParSaison: episodesParSaison,
          episode: episode),
    ),
  );
}

/// Feuille de lecture « mixte » : en-tête de l'œuvre, onglets soulignés
/// Sources | Épisodes, tuiles de sources numérotées, grille d'épisodes,
/// et une barre fixe en bas : ‹ épisode précédent · Regarder · suivant ›.
class FeuilleLecture extends StatefulWidget {
  final OeuvreBibliotheque oeuvre;
  final Map<int, List<int>> episodesParSaison;
  final (int, int)? episode;

  const FeuilleLecture(
      {super.key,
      required this.oeuvre,
      required this.episodesParSaison,
      this.episode});

  @override
  State<FeuilleLecture> createState() => FeuilleLectureState();
}

class FeuilleLectureState extends State<FeuilleLecture> {
  late final ViewmodelLecture _vm = ViewmodelLecture(
      oeuvre: widget.oeuvre,
      episodesParSaison: widget.episodesParSaison,
      episodeInitial: widget.episode);

  /// Message bref en pilule (« Lien copié »…). Une SnackBar s'afficherait
  /// sous la feuille, dans le Scaffold de l'écran d'en dessous.
  final ValueNotifier<String?> _message = ValueNotifier(null);
  Timer? _minuteur;

  /// Saison affichée dans l'onglet Épisodes (pas forcément celle choisie).
  int? _saisonAffichee;

  static const Map<FamilleOeuvre, String> _familles = {
    FamilleOeuvre.anime: 'Anime',
    FamilleOeuvre.drama: 'Drama',
    FamilleOeuvre.live: 'Live action',
  };

  @override
  void initState() {
    super.initState();
    _vm.demarrer();
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _message.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _afficher(String texte) {
    _message.value = texte;
    _minuteur?.cancel();
    _minuteur = Timer(const Duration(seconds: 2), () {
      if (mounted) _message.value = null;
    });
  }

  void _fermer() {
    _vm.annuler();
    Navigator.of(context).pop();
  }

  Future<void> _regarder(int index) async {
    try {
      final (lien, requete) = await _vm.preparer(index);
      if (!mounted) return;
      final ep = _vm.episode.value;
      // La feuille reste ouverte dessous : au retour, ‹ › enchaîne l'épisode.
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ViewWatchvideo(
                UrlSiteVideo: lien,
                RequestEpisode: requete,
                episode_into_caracteres: ep == null ? '' : '${ep.$2}',
              )));
    } catch (e) {
      if (mounted) _afficher('Lecture impossible : $e');
    }
  }

  Future<void> _copier(SourceLecture source) async {
    await Clipboard.setData(ClipboardData(text: source.lien));
    if (mounted) _afficher('Lien copié');
  }

  Future<void> _ouvrirNavigateur(SourceLecture source) async {
    try {
      await ChromeSafariCustom().open(url: WebUri(source.lien));
    } catch (_) {
      if (mounted) _afficher("Impossible d'ouvrir le navigateur");
    }
  }

  /// « É6 » dans la même saison, « S2·É1 » sinon.
  String _libelle((int, int) ep) {
    final courant = _vm.episode.value;
    return courant != null && courant.$1 == ep.$1 ? 'É${ep.$2}' : 'S${ep.$1}·É${ep.$2}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _vm.episode,
        _vm.etat,
        _vm.erreur,
        _vm.sources,
        _vm.choisie,
        _vm.onglet,
        _vm.suivi,
      ]),
      builder: (context, _) {
        final enCours = _vm.etat.value == EtatRecherche.enCours;
        final surEpisodes =
            _vm.estSerie && _vm.onglet.value == OngletLecture.episodes;
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _entete(context),
                if (_vm.estSerie) _onglets(context),
                SizedBox(
                  height: 3,
                  child: enCours ? const LinearProgressIndicator() : null,
                ),
                Expanded(
                    child: surEpisodes
                        ? _vueEpisodes(context)
                        : _vueSources(context)),
                _barreBas(context),
              ],
            ),
            // Positioned doit être l'enfant direct du Stack : le
            // ValueListenableBuilder est donc à l'intérieur.
            Positioned(
              left: 0,
              right: 0,
              bottom: 100,
              child: IgnorePointer(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _message,
                  builder: (context, texte, _) => texte == null
                      ? const SizedBox.shrink()
                      : Center(child: _Pilule(texte: texte)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------- en-tête

  Widget _entete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final o = widget.oeuvre;
    final ep = _vm.episode.value;
    final duree = InfosDetail.formaterDuree(o.video.duree);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 66,
            child: AfficheTeintee(
                chemin: o.lienAffiche, rayon: 8, force: 0.6, largeurDecodage: 132),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (ep != null)
                      _Etiquette(
                          texte: 'S${ep.$1} · É${ep.$2}',
                          fond: cs.primary,
                          couleur: cs.onPrimary),
                    _Etiquette(
                        texte: _familles[o.famille]!,
                        couleur: cs.onSurfaceVariant,
                        contour: cs.outline),
                    if (duree != null)
                      Text(duree,
                          style: TextStyle(
                              fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Fermer',
            icon: const Icon(Icons.close),
            onPressed: _fermer,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- onglets

  Widget _onglets(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nombreSources = switch (_vm.etat.value) {
      EtatRecherche.enCours => '…',
      EtatRecherche.aucun => '0',
      EtatRecherche.resultats => '${_vm.sources.value.length}',
    };
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant))),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _Onglet(
            libelle: 'Sources',
            nombre: nombreSources,
            actif: _vm.onglet.value == OngletLecture.sources,
            onTap: () => _vm.choisirOnglet(OngletLecture.sources),
          ),
          const SizedBox(width: 24),
          _Onglet(
            libelle: 'Épisodes',
            nombre: '${_vm.nombreEpisodes}',
            actif: _vm.onglet.value == OngletLecture.episodes,
            onTap: () => _vm.choisirOnglet(OngletLecture.episodes),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- sources

  Widget _vueSources(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final petit = TextStyle(fontSize: 12, color: cs.onSurfaceVariant);
    const marge = EdgeInsets.fromLTRB(20, 14, 20, 16);

    switch (_vm.etat.value) {
      case EtatRecherche.enCours:
        return ListView(
          padding: marge,
          children: [
            Text(
                _vm.estSerie
                    ? 'Recherche des liens sur les sites… tu peux changer d’épisode avec ‹ ›'
                    : 'Recherche des liens sur les sites…',
                style: petit),
            const SizedBox(height: 10),
            _grille([for (var i = 0; i < 4; i++) _TuileFantome(largeur: 0.45 + 0.07 * (i % 3))]),
          ],
        );

      case EtatRecherche.aucun:
        final ep = _vm.episode.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.outline, width: 2),
                ),
                // Petit visage dépité, façon mascotte japonaise.
                child: Text('(>_<)',
                    style: TextStyle(
                        fontFamily: policeTitres,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: cs.onSurface)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              ep == null ? 'Aucun lien pour ce film' : 'Aucun lien pour l’épisode ${ep.$2}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _vm.erreur.value ??
                  'Aucun des sites interrogés ne l’a trouvé, ou l’un d’eux est injoignable.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4, color: cs.onSurfaceVariant),
            ),
            if (_vm.estSerie) ...[
              const SizedBox(height: 14),
              Center(
                child: OutlinedButton(
                  onPressed: () => _vm.choisirOnglet(OngletLecture.episodes),
                  child: const Text('Choisir un autre épisode'),
                ),
              ),
            ],
          ],
        );

      case EtatRecherche.resultats:
        final sources = _vm.sources.value;
        final derniereRetenue = sources.isNotEmpty &&
            _vm.estDerniereSource(sources[_vm.choisie.value]);
        return ListView(
          padding: marge,
          children: [
            Text.rich(
              TextSpan(style: petit, children: [
                TextSpan(
                    text: '${sources.length} source${sources.length > 1 ? 's' : ''} · '),
                TextSpan(
                  text: derniereRetenue
                      ? 'ta dernière source est choisie'
                      : 'touche une tuile pour la choisir',
                  style: TextStyle(color: cs.onSurface),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            _grille([
              for (var i = 0; i < sources.length; i++)
                _TuileSource(
                  source: sources[i],
                  rang: (i + 1).toString().padLeft(2, '0'),
                  accent: _accent(context, i),
                  choisie: i == _vm.choisie.value,
                  derniere: _vm.estDerniereSource(sources[i]),
                  onTap: () => _vm.choisirSource(i),
                  onLongPress: () {
                    _vm.choisirSource(i);
                    _regarder(i);
                  },
                  onCopier: () => _copier(sources[i]),
                  onNavigateur: () => _ouvrirNavigateur(sources[i]),
                ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Icon(Icons.lightbulb_outline, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Appui long sur une source : regarder tout de suite',
                      style: petit)),
            ]),
          ],
        );
    }
  }

  Widget _grille(List<Widget> tuiles) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.75,
        children: tuiles,
      );

  /// Couleur du numéro « 01 / 02 / 03 » : une teinte par rang.
  Color _accent(BuildContext context, int i) {
    final cs = Theme.of(context).colorScheme;
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final teintes = [
      cs.primary,
      cs.tertiary,
      sombre ? const Color(0xFF9ED5B5) : const Color(0xFF1F6B47),
    ];
    return teintes[i % teintes.length];
  }

  // ---------------------------------------------------------------- épisodes

  Widget _vueEpisodes(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final petit = TextStyle(fontSize: 12, color: cs.onSurfaceVariant);
    final saisons = _vm.episodesParSaison.keys.toList()..sort();
    if (saisons.isEmpty) {
      return Center(child: Text('Aucun épisode enregistré.', style: petit));
    }
    final saison = _saisonAffichee ?? _vm.episode.value?.$1 ?? saisons.first;
    final episodes = [..._vm.episodesParSaison[saison] ?? const <int>[]]..sort();
    final tous = NavigationLecture.ordre(_vm.episodesParSaison);
    final nbVus = tous.where(_vm.estVu).length;
    final avant = _vm.episodesAvant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        Row(
          children: [
            Expanded(child: Text('$nbVus vus sur ${tous.length}', style: petit)),
            if (saisons.length > 1)
              PopupMenuButton<int>(
                tooltip: 'Changer de saison',
                initialValue: saison,
                onSelected: (s) => setState(() => _saisonAffichee = s),
                itemBuilder: (_) => [
                  for (final s in saisons)
                    PopupMenuItem(value: s, child: Text('Saison $s')),
                ],
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Saison $saison', style: const TextStyle(fontSize: 13)),
                    const Icon(Icons.expand_more, size: 16),
                  ]),
                ),
              )
            else
              Text('Saison $saison', style: petit),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisExtent: 44,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: episodes.length,
          itemBuilder: (context, i) {
            final ep = (saison, episodes[i]);
            final vu = _vm.estVu(ep);
            return _TuileEpisode(
              numero: episodes[i],
              courant: ep == _vm.episode.value,
              vu: vu,
              onTap: () => _vm.choisirEpisode(ep),
              onLongPress: () async {
                await _vm.basculerVu(ep);
                if (mounted) {
                  _afficher('Épisode ${ep.$2} marqué ${vu ? 'non vu' : 'vu'}');
                }
              },
            );
          },
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _Legende(couleur: cs.primary, texte: 'en cours'),
            _Legende(couleur: cs.secondaryContainer, texte: 'vu'),
            _Legende(contour: cs.outline, texte: 'à voir'),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                    'Vu ailleurs ? Appui long sur un épisode pour le marquer vu ou non vu.',
                    style: petit.copyWith(height: 1.4)),
              ),
              if (avant.isNotEmpty) ...[
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () async {
                    await _vm.marquerVusJusquIci();
                    if (mounted) _afficher('${avant.length} épisode${avant.length > 1 ? 's' : ''} marqué${avant.length > 1 ? 's' : ''} vu${avant.length > 1 ? 's' : ''}');
                  },
                  child: Text('Vus jusqu’à ${_libelle(avant.last)}'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- barre du bas

  Widget _barreBas(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final precedent = _vm.precedent;
    final suivant = _vm.suivant;
    final ep = _vm.episode.value;
    const forme = StadiumBorder();
    const taille = Size.fromHeight(56);
    final style = TextStyle(
        fontFamily: policeTitres, fontWeight: FontWeight.w800, fontSize: 16);

    final Widget action = switch (_vm.etat.value) {
      EtatRecherche.enCours => OutlinedButton(
          onPressed: _fermer,
          style: OutlinedButton.styleFrom(minimumSize: taille, shape: forme),
          child: Text('Annuler la recherche', style: style),
        ),
      EtatRecherche.aucun => FilledButton.icon(
          onPressed: _vm.chercher,
          style: FilledButton.styleFrom(minimumSize: taille, shape: forme),
          icon: const Icon(Icons.refresh),
          label: Text('Réessayer', style: style),
        ),
      EtatRecherche.resultats => FilledButton.icon(
          onPressed: () => _regarder(_vm.choisie.value),
          style: FilledButton.styleFrom(minimumSize: taille, shape: forme),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            '${_vm.sources.value[_vm.choisie.value].site}'
            '${ep == null ? '' : ' · É${ep.$2}'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
    };

    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cs.outlineVariant))),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_vm.estSerie) ...[
              _Fleche(
                vers: 'précédent',
                libelle: precedent == null ? null : _libelle(precedent),
                icone: Icons.chevron_left,
                avant: true,
                onTap: precedent == null ? null : () => _vm.choisirEpisode(precedent),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: action),
            if (_vm.estSerie) ...[
              const SizedBox(width: 8),
              _Fleche(
                vers: 'suivant',
                libelle: suivant == null ? null : _libelle(suivant),
                icone: Icons.chevron_right,
                avant: false,
                onTap: suivant == null ? null : () => _vm.choisirEpisode(suivant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================ composants

class _Etiquette extends StatelessWidget {
  final String texte;
  final Color couleur;
  final Color? fond;
  final Color? contour;
  const _Etiquette(
      {required this.texte, required this.couleur, this.fond, this.contour});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(5),
          border: contour == null ? null : Border.all(color: contour!),
        ),
        child: Text(texte,
            style: TextStyle(
                fontSize: 11,
                fontWeight: fond == null ? FontWeight.w500 : FontWeight.w700,
                color: couleur)),
      );
}

/// Onglet souligné (emprunt coréen), texte arrondi et compteur en pastille.
class _Onglet extends StatelessWidget {
  final String libelle;
  final String nombre;
  final bool actif;
  final VoidCallback onTap;
  const _Onglet(
      {required this.libelle,
      required this.nombre,
      required this.actif,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      selected: actif,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(libelle,
                        style: TextStyle(
                            fontFamily: policeTitres,
                            fontSize: 15,
                            fontWeight: actif ? FontWeight.w800 : FontWeight.w700,
                            color: actif ? cs.onSurface : cs.onSurfaceVariant)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                          color: actif ? cs.primary : cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(9)),
                      child: Text(nombre,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: actif ? cs.onPrimary : cs.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              if (actif)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(3))),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tuile d'une source : numéro coloré, site, domaine, menu ⋮.
/// Toucher = choisir ; appui long = regarder tout de suite.
class _TuileSource extends StatelessWidget {
  final SourceLecture source;
  final String rang;
  final Color accent;
  final bool choisie;
  final bool derniere;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onCopier;
  final VoidCallback onNavigateur;

  const _TuileSource({
    required this.source,
    required this.rang,
    required this.accent,
    required this.choisie,
    required this.derniere,
    required this.onTap,
    required this.onLongPress,
    required this.onCopier,
    required this.onNavigateur,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      selected: choisie,
      label: '${source.site}, ${source.domaine}',
      child: Material(
        color: choisie
            ? cs.primaryContainer.withValues(alpha: 0.45)
            : cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: choisie ? BorderSide(color: cs.primary, width: 2) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 0, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rang,
                        style: TextStyle(
                            fontFamily: policeTitres,
                            fontSize: 22,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: accent)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(source.site,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          if (derniere) ...[
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                  color: cs.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text('Dernière utilisée',
                                  style: TextStyle(
                                      fontFamily: policeTitres,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onTertiaryContainer)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: PopupMenuButton<String>(
                        tooltip: 'Autres actions pour ${source.site}',
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                        onSelected: (choix) =>
                            choix == 'copier' ? onCopier() : onNavigateur(),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'copier',
                            child: ListTile(
                                leading: Icon(Icons.copy_outlined),
                                title: Text('Copier le lien'),
                                contentPadding: EdgeInsets.zero),
                          ),
                          PopupMenuItem(
                            value: 'navigateur',
                            child: ListTile(
                                leading: Icon(Icons.open_in_new),
                                title: Text('Ouvrir dans le navigateur'),
                                contentPadding: EdgeInsets.zero),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(source.domaine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                      ),
                      if (choisie)
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: cs.primary,
                          child: Icon(Icons.check, size: 14, color: cs.onPrimary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TuileFantome extends StatelessWidget {
  /// Largeur de la barre de titre, en fraction de la tuile.
  final double largeur;
  const _TuileFantome({required this.largeur});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barre = cs.onSurfaceVariant.withValues(alpha: 0.15);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FractionallySizedBox(
            widthFactor: largeur,
            child: Container(
                height: 14,
                decoration: BoxDecoration(
                    color: barre, borderRadius: BorderRadius.circular(7))),
          ),
          Container(
              width: 64,
              height: 10,
              decoration: BoxDecoration(
                  color: barre, borderRadius: BorderRadius.circular(5))),
        ],
      ),
    );
  }
}

/// Tuile numérotée d'un épisode : pleine si en cours, teintée si vue.
class _TuileEpisode extends StatelessWidget {
  final int numero;
  final bool courant;
  final bool vu;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TuileEpisode({
    required this.numero,
    required this.courant,
    required this.vu,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fond = courant
        ? cs.primary
        : vu
            ? cs.secondaryContainer
            : Colors.transparent;
    final texte = courant
        ? cs.onPrimary
        : vu
            ? cs.onSecondaryContainer
            : cs.onSurface;
    return Semantics(
      selected: courant,
      label: 'Épisode $numero${vu ? ', vu' : ''}',
      child: Material(
        color: fond,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: courant || vu ? BorderSide.none : BorderSide(color: cs.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              Center(
                child: Text('$numero',
                    style: TextStyle(
                        fontFamily: policeTitres,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: texte)),
              ),
              if (vu && !courant)
                Positioned(
                  top: 5,
                  right: 5,
                  child: CircleAvatar(radius: 3, backgroundColor: cs.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  final Color? couleur;
  final Color? contour;
  final String texte;
  const _Legende({this.couleur, this.contour, required this.texte});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: couleur,
              borderRadius: BorderRadius.circular(4),
              border: contour == null ? null : Border.all(color: contour!),
            ),
          ),
          const SizedBox(width: 6),
          Text(texte,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      );
}

/// Bouton ‹ / › de la barre du bas, avec l'épisode visé en petit.
class _Fleche extends StatelessWidget {
  final String vers;
  final String? libelle;
  final IconData icone;
  final bool avant;
  final VoidCallback? onTap;

  const _Fleche({
    required this.vers,
    required this.libelle,
    required this.icone,
    required this.avant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final actif = onTap != null;
    final couleur = actif ? cs.onSurface : cs.outline;
    final contenu = [
      Icon(icone, size: 20, color: couleur),
      if (libelle != null)
        Text(libelle!,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: couleur)),
    ];
    return Semantics(
      button: true,
      enabled: actif,
      label: libelle == null ? 'Pas d’épisode $vers' : 'Épisode $vers, $libelle',
      child: SizedBox(
        width: 56,
        height: 56,
        child: Material(
          color: actif ? cs.surfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: avant ? contenu : contenu.reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pilule extends StatelessWidget {
  final String texte;
  const _Pilule({required this.texte});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.inverseSurface,
      shape: const StadiumBorder(),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(texte,
            style: TextStyle(color: cs.onInverseSurface, fontSize: 14)),
      ),
    );
  }
}
