import 'package:flutter/material.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/ViewModels/ViewModel_Bibliotheque.dart';
import 'package:unistream/Views/Templates/Affiche_Teintee.dart';
import 'package:unistream/Views/View_Detail.dart';

/// Onglet « Bibliothèque » : toutes les œuvres en grille d'affiches,
/// avec recherche par titre et puces de filtre (famille × format).
class ViewBibliotheque extends StatefulWidget {
  const ViewBibliotheque({super.key});

  @override
  State<ViewBibliotheque> createState() => ViewBibliothequeState();
}

class ViewBibliothequeState extends State<ViewBibliotheque> {
  final ViewmodelBibliotheque _vm = ViewmodelBibliotheque();

  static const Map<FamilleOeuvre, String> _familles = {
    FamilleOeuvre.anime: 'Animes',
    FamilleOeuvre.drama: 'Dramas',
    FamilleOeuvre.live: 'Live action',
  };
  static const Map<FormatOeuvre, String> _formats = {
    FormatOeuvre.serie: 'Séries',
    FormatOeuvre.film: 'Films',
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

  Future<void> _ouvrir(OeuvreBibliotheque oeuvre) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ViewDetail(oeuvre: oeuvre)));
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge(
          [_vm.chargement, _vm.erreur, _vm.filtre, _vm.oeuvres]),
      builder: (context, _) {
        final filtre = _vm.filtre.value;
        final oeuvres = _vm.oeuvres.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SearchBar(
                hintText: 'Rechercher un titre',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll<double>(0),
                onChanged: _vm.rechercher,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final e in _familles.entries)
                    FilterChip(
                      label: Text(e.value),
                      selected: filtre.familles.contains(e.key),
                      onSelected: (_) => _vm.basculerFamille(e.key),
                    ),
                  for (final e in _formats.entries)
                    FilterChip(
                      label: Text(e.value),
                      selected: filtre.formats.contains(e.key),
                      onSelected: (_) => _vm.basculerFormat(e.key),
                    ),
                ],
              ),
            ),
            if (_vm.erreur.value != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(_vm.erreur.value!,
                    style: TextStyle(color: couleurs.error)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                _vm.chargement.value
                    ? 'Chargement…'
                    : '${oeuvres.length} œuvre${oeuvres.length > 1 ? 's' : ''}'
                        '${filtre.estVide ? '' : ' sur ${_vm.total}'}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: couleurs.onSurfaceVariant),
              ),
            ),
            Expanded(child: _corps(context, oeuvres)),
          ],
        );
      },
    );
  }

  Widget _corps(BuildContext context, List<OeuvreBibliotheque> oeuvres) {
    if (_vm.chargement.value && _vm.total == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    if (oeuvres.isEmpty) {
      return RefreshIndicator(
        onRefresh: _vm.charger,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            Icon(Icons.video_library_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              _vm.total == 0
                  ? 'Ta bibliothèque est vide.\nAjoute des œuvres depuis le serveur (bouton +).'
                  : 'Aucune œuvre ne correspond.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _vm.charger,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        // Le nombre de colonnes suit la largeur : 3 sur téléphone, plus en
        // paysage ou sur tablette. Aucune taille fixe à maintenir.
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          childAspectRatio: 0.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
        ),
        itemCount: oeuvres.length,
        itemBuilder: (context, i) => CarteAffiche(
          oeuvre: oeuvres[i],
          onTap: () => _ouvrir(oeuvres[i]),
        ),
      ),
    );
  }
}

/// Vignette d'une œuvre : affiche 2:3, titre sur 2 lignes, famille · format.
class CarteAffiche extends StatelessWidget {
  final OeuvreBibliotheque oeuvre;
  final VoidCallback onTap;

  const CarteAffiche({super.key, required this.oeuvre, required this.onTap});

  static const Map<FamilleOeuvre, String> _famille = {
    FamilleOeuvre.anime: 'Anime',
    FamilleOeuvre.drama: 'Drama',
    FamilleOeuvre.live: 'Live',
  };

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: oeuvre.titre,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: AfficheTeintee(chemin: oeuvre.lienAffiche)),
            const SizedBox(height: 6),
            Text(oeuvre.titre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textes.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            Text(
                '${_famille[oeuvre.famille]} · '
                '${oeuvre.format == FormatOeuvre.serie ? 'Série' : 'Film'}',
                maxLines: 1,
                style: textes.bodySmall?.copyWith(color: couleurs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
