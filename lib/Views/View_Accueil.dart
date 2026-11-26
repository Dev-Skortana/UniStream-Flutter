import 'package:flutter/material.dart';
import 'package:unistream/Services/Features/Accueil/Selection_Accueil.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/ViewModels/ViewModel_Accueil.dart';
import 'package:unistream/Views/Helpers/Couleurs_Affiches.dart';
import 'package:unistream/Views/Helpers/Theme.dart';
import 'package:unistream/Views/Templates/Affiche_Teintee.dart';
import 'package:unistream/Views/View_Detail.dart';

/// Onglet Accueil « salon » : une œuvre en vedette sur un dégradé tiré de son
/// affiche, puis des rangées horizontales (récentes, animes, dramas, live).
class ViewAccueil extends StatefulWidget {
  const ViewAccueil({super.key});

  @override
  State<ViewAccueil> createState() => ViewAccueilState();
}

class ViewAccueilState extends State<ViewAccueil> {
  final ViewmodelAccueil _vm = ViewmodelAccueil();

  static const Map<FamilleOeuvre?, String> _pilules = {
    null: 'Tout',
    FamilleOeuvre.anime: 'Animes',
    FamilleOeuvre.drama: 'Dramas',
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

  /// Appelée par MainWrapper après un ajout ou une synchronisation.
  Future<void> recharger() => _vm.charger();

  void _ouvrir(OeuvreBibliotheque oeuvre) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ViewDetail(oeuvre: oeuvre)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
          [_vm.chargement, _vm.erreur, _vm.famille, _vm.contenu]),
      builder: (context, _) {
        final contenu = _vm.contenu.value;
        if (_vm.chargement.value && contenu.estVide) {
          return const SafeArea(
              child: Center(child: CircularProgressIndicator()));
        }
        return RefreshIndicator(
          onRefresh: _vm.charger,
          // L'indicateur apparaît sous la barre, pas derrière.
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Vedette(
                oeuvre: contenu.vedette,
                pilules: _barrePilules(context),
                onOuvrir: _ouvrir,
              ),
              if (_vm.erreur.value != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(_vm.erreur.value!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              if (contenu.estVide) _vide(context),
              for (final rangee in contenu.rangees)
                _Rangee(rangee: rangee, onOuvrir: _ouvrir),
            ],
          ),
        );
      },
    );
  }

  Widget _barrePilules(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final e in _pilules.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.value),
                selected: _vm.famille.value == e.key,
                showCheckmark: false,
                shape: const StadiumBorder(),
                // Pilule « verre » : fond translucide sur le dégradé,
                // pleine et contrastée quand elle est choisie.
                backgroundColor: couleurs.surface.withValues(alpha: 0.55),
                selectedColor: couleurs.onSurface,
                labelStyle: TextStyle(
                    color: _vm.famille.value == e.key
                        ? couleurs.surface
                        : couleurs.onSurface,
                    fontWeight: FontWeight.w500),
                side: BorderSide(
                    color: couleurs.onSurface.withValues(alpha: 0.15)),
                onSelected: (_) => _vm.choisirFamille(e.key),
              ),
            ),
        ],
      ),
    );
  }

  Widget _vide(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
        child: Column(
          children: [
            Icon(Icons.video_library_outlined,
                size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              _vm.famille.value == null
                  ? 'Ta bibliothèque est vide.\nAjoute des œuvres depuis le serveur (bouton +).'
                  : 'Rien dans cette catégorie pour l’instant.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

/// Haut de l'Accueil : dégradé de la couleur de l'affiche vers le fond,
/// pilules de catégorie, affiche en relief, titre et bouton.
class _Vedette extends StatelessWidget {
  final OeuvreBibliotheque? oeuvre;
  final Widget pilules;
  final void Function(OeuvreBibliotheque) onOuvrir;

  const _Vedette(
      {required this.oeuvre, required this.pilules, required this.onOuvrir});

  @override
  Widget build(BuildContext context) {
    final o = oeuvre;
    final couleurs = Theme.of(context).colorScheme;
    final sombre = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Color?>(
      future: o == null ? Future.value(null) : CouleursAffiches.de(o.lienAffiche),
      initialData: o == null ? null : CouleursAffiches.immediate(o.lienAffiche),
      builder: (context, instantane) {
        final teinte = instantane.data ?? couleurs.primary;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                teinte.withValues(alpha: sombre ? 0.85 : 0.35),
                teinte.withValues(alpha: sombre ? 0.30 : 0.10),
                couleurs.surface,
              ],
              stops: const [0, 0.55, 1],
            ),
          ),
          // Le dégradé part du haut de l'écran (sous la barre transparente) ;
          // le contenu commence sous la barre.
          padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 8, bottom: 8),
          child: Column(
            children: [
              pilules,
              if (o != null) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => onOuvrir(o),
                  child: Semantics(
                    button: true,
                    label: 'Ouvrir la fiche de ${o.titre}',
                    child: SizedBox(
                      width: 150,
                      height: 225,
                      child: AfficheTeintee(
                          chemin: o.lienAffiche,
                          rayon: 16,
                          force: 1.6,
                          largeurDecodage: 450),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(o.titre,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                const SizedBox(height: 6),
                Text(_meta(o),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: couleurs.onSurfaceVariant)),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => onOuvrir(o),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Voir la fiche'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(200, 48),
                      shape: const StadiumBorder()),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _meta(OeuvreBibliotheque o) => [
        switch (o.famille) {
          FamilleOeuvre.anime => 'Anime',
          FamilleOeuvre.drama => 'Drama',
          FamilleOeuvre.live => 'Live action',
        },
        o.format == FormatOeuvre.serie ? 'Série' : 'Film',
        if (o.dateParution != null) '${o.dateParution!.year}',
      ].join(' · ');
}

/// Une rangée : sur-titre espacé, titre arrondi, affiches qui défilent.
class _Rangee extends StatelessWidget {
  final RangeeAccueil rangee;
  final void Function(OeuvreBibliotheque) onOuvrir;

  const _Rangee({required this.rangee, required this.onOuvrir});

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rangee.surTitre,
                    style: textes.labelSmall?.copyWith(
                        fontFamily: policeTitres,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: couleurs.primary)),
                Text(rangee.titre, style: textes.titleMedium),
              ],
            ),
          ),
          SizedBox(
            // Hauteur = marge haute + affiche + titre + marge basse
            // (la marge basse laisse la place à la lueur sous les affiches).
            height: 226,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
              itemCount: rangee.oeuvres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final o = rangee.oeuvres[i];
                return SizedBox(
                  width: 110,
                  child: InkWell(
                    onTap: () => onOuvrir(o),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: 165,
                            child: AfficheTeintee(chemin: o.lienAffiche)),
                        const SizedBox(height: 8),
                        Text(o.titre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textes.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
