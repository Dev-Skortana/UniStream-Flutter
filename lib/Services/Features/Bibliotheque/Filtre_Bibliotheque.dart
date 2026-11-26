import 'package:unistream/Models/Video.dart';

/// Famille d'une œuvre de la bibliothèque (correspond aux tables SQLite :
/// Animes_*, Dramas_*, et Series / Films pour le reste).
enum FamilleOeuvre { anime, drama, live }

enum FormatOeuvre { serie, film }

/// Une œuvre telle que la Bibliothèque l'affiche : le modèle existant
/// (AnimeSerie, DramaFilm, Film…) plus sa famille et son format.
class OeuvreBibliotheque {
  final Video video;
  final FamilleOeuvre famille;
  final FormatOeuvre format;

  const OeuvreBibliotheque(
      {required this.video, required this.famille, required this.format});

  String get titre => video.titre;
  String get lienAffiche => video.lienAffiche;
  DateTime? get dateParution => video.dateParution;
}

/// Critères de la Bibliothèque. Logique pure (aucun accès base ni widget) :
/// testée dans test/filtre_bibliotheque_test.dart.
///
/// Règle des puces : un groupe sans puce cochée ne filtre rien
/// (aucune famille cochée = toutes les familles).
class FiltreBibliotheque {
  final Set<FamilleOeuvre> familles;
  final Set<FormatOeuvre> formats;
  final String recherche;

  const FiltreBibliotheque(
      {this.familles = const {},
      this.formats = const {},
      this.recherche = ''});

  bool get estVide =>
      familles.isEmpty && formats.isEmpty && recherche.trim().isEmpty;

  FiltreBibliotheque copierAvec(
          {Set<FamilleOeuvre>? familles,
          Set<FormatOeuvre>? formats,
          String? recherche}) =>
      FiltreBibliotheque(
          familles: familles ?? this.familles,
          formats: formats ?? this.formats,
          recherche: recherche ?? this.recherche);

  FiltreBibliotheque basculerFamille(FamilleOeuvre f) => copierAvec(
      familles: familles.contains(f)
          ? ({...familles}..remove(f))
          : {...familles, f});

  FiltreBibliotheque basculerFormat(FormatOeuvre f) => copierAvec(
      formats:
          formats.contains(f) ? ({...formats}..remove(f)) : {...formats, f});

  bool accepte(OeuvreBibliotheque oeuvre) {
    if (familles.isNotEmpty && !familles.contains(oeuvre.famille)) return false;
    if (formats.isNotEmpty && !formats.contains(oeuvre.format)) return false;
    final mots = normaliser(recherche)
        .split(' ')
        .where((m) => m.isNotEmpty);
    final titre = normaliser(oeuvre.titre);
    return mots.every(titre.contains);
  }

  /// Filtre puis trie : les plus récentes d'abord (date de parution),
  /// les œuvres sans date à la fin, puis par titre.
  List<OeuvreBibliotheque> appliquer(Iterable<OeuvreBibliotheque> oeuvres) {
    final resultat = oeuvres.where(accepte).toList();
    resultat.sort(comparer);
    return resultat;
  }

  static int comparer(OeuvreBibliotheque a, OeuvreBibliotheque b) {
    final da = a.dateParution, db = b.dateParution;
    if (da != null && db != null && da != db) return db.compareTo(da);
    if (da == null && db != null) return 1;
    if (da != null && db == null) return -1;
    return normaliser(a.titre).compareTo(normaliser(b.titre));
  }

  static const Map<String, String> _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a',
    'ç': 'c',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ÿ': 'y', 'ñ': 'n', 'œ': 'oe', 'æ': 'ae',
  };

  /// Minuscules, sans accents, ponctuation remplacée par des espaces :
  /// « Kimetsu no Yaiba: Saison 3 » et « kimetsu saison » se retrouvent.
  static String normaliser(String texte) {
    final buffer = StringBuffer();
    for (final rune in texte.toLowerCase().runes) {
      final c = String.fromCharCode(rune);
      buffer.write(_accents[c] ?? c);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}
