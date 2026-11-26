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

  /// Genres de l'œuvre (table Videos_Genres), tels qu'enregistrés.
  final List<String> genres;

  const OeuvreBibliotheque(
      {required this.video,
      required this.famille,
      required this.format,
      this.genres = const []});

  String get titre => video.titre;
  String get lienAffiche => video.lienAffiche;
  DateTime? get dateParution => video.dateParution;
}

/// Critères de la Bibliothèque. Logique pure (aucun accès base ni widget) :
/// testée dans test/filtre_bibliotheque_test.dart.
///
/// Règle des puces, la même pour chaque groupe (familles, formats, genres) :
/// un groupe sans puce cochée ne filtre rien, plusieurs puces cochées dans
/// un groupe s'additionnent (OU), et les groupes se combinent entre eux (ET).
class FiltreBibliotheque {
  final Set<FamilleOeuvre> familles;
  final Set<FormatOeuvre> formats;

  /// Genres cochés, sous forme normalisée (voir [normaliser]).
  final Set<String> genres;
  final String recherche;

  const FiltreBibliotheque(
      {this.familles = const {},
      this.formats = const {},
      this.genres = const {},
      this.recherche = ''});

  bool get estVide =>
      familles.isEmpty &&
      formats.isEmpty &&
      genres.isEmpty &&
      recherche.trim().isEmpty;

  FiltreBibliotheque copierAvec(
          {Set<FamilleOeuvre>? familles,
          Set<FormatOeuvre>? formats,
          Set<String>? genres,
          String? recherche}) =>
      FiltreBibliotheque(
          familles: familles ?? this.familles,
          formats: formats ?? this.formats,
          genres: genres ?? this.genres,
          recherche: recherche ?? this.recherche);

  /// [genre] tel qu'affiché ; comparé sans casse ni accents.
  FiltreBibliotheque basculerGenre(String genre) {
    final cle = normaliser(genre);
    return copierAvec(
        genres: genres.contains(cle) ? ({...genres}..remove(cle)) : {...genres, cle});
  }

  bool aLeGenre(String genre) => genres.contains(normaliser(genre));

  FiltreBibliotheque sansGenres() => copierAvec(genres: const {});

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
    if (genres.isNotEmpty &&
        !oeuvre.genres.any((g) => genres.contains(normaliser(g)))) {
      return false;
    }
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

  /// Genres présents dans la bibliothèque, pour les puces : un seul par nom
  /// (casse et accents ignorés, première écriture rencontrée gardée),
  /// les plus fréquents d'abord, puis par ordre alphabétique.
  static List<(String nom, int nombre)> genresDisponibles(
      Iterable<OeuvreBibliotheque> oeuvres) {
    final noms = <String, String>{};
    final nombres = <String, int>{};
    for (final oeuvre in oeuvres) {
      // Un genre compte une fois par œuvre, même écrit deux fois.
      final vus = <String>{};
      for (final brut in oeuvre.genres) {
        final nom = brut.trim();
        final cle = normaliser(nom);
        if (cle.isEmpty || !vus.add(cle)) continue;
        noms.putIfAbsent(cle, () => nom);
        nombres[cle] = (nombres[cle] ?? 0) + 1;
      }
    }
    final cles = nombres.keys.toList()
      ..sort((a, b) {
        final ecart = nombres[b]!.compareTo(nombres[a]!);
        return ecart != 0 ? ecart : a.compareTo(b);
      });
    return [for (final c in cles) (noms[c]!, nombres[c]!)];
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
