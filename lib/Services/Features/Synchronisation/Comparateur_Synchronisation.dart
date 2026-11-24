import 'package:unistream/Models/Synchronisation.dart';

// Comparaison « ce que l'appli a » ↔ « ce que le serveur sait » — logique PURE (ni base ni réseau), testée seule.
// Règles : le serveur fait foi, SAUF qu'une valeur vide ne remplace jamais une valeur existante, qu'un nombre
// d'épisodes ne diminue jamais, et qu'une date complète n'est jamais remplacée par la seule année.

class ComparateurSynchronisation {
  static bool _vide(String? v) => v == null || v.trim().isEmpty;

  /// « 24 » (minutes) → « 00:24:00 » ; borné à 23:59 comme Manager_Convert_Duration_To_Time.
  static String? dureeDepuisMinutes(Object? minutes) {
    final m = minutes is num ? minutes.toInt() : int.tryParse('${minutes ?? ''}');
    if (m == null || m <= 0) return null;
    final b = m > 23 * 60 + 59 ? 23 * 60 + 59 : m;
    return '${(b ~/ 60).toString().padLeft(2, '0')}:${(b % 60).toString().padLeft(2, '0')}:00';
  }

  /// Date à écrire : la date de sortie du site si elle est lisible, sinon le 1er janvier de l'année.
  static String? dateDepuisChamps(Map<String, dynamic> champs) {
    final d = DateTime.tryParse('${champs['date_sortie'] ?? ''}');
    if (d != null) return d.toIso8601String().split('T').first;
    final a = champs['annee'] is num ? (champs['annee'] as num).toInt() : int.tryParse('${champs['annee'] ?? ''}');
    return (a != null && a > 1900 && a < 2200) ? '$a-01-01' : null;
  }

  /// L'appli affiche l'affiche avec Image.file : seule compte la présence du FICHIER sur l'appareil.
  /// Une adresse http ou un chemin d'un autre appareil (« Images\video posters\… ») ne s'affiche jamais.
  static bool afficheARemplacer(EtatLocal local, String? afficheServeur) =>
      !_vide(afficheServeur) && (_vide(local.lienAffiche) || !local.afficheExiste);

  static List<Changement> comparer(EtatLocal local, Map<String, dynamic>? details, Map<String, dynamic>? fiche) {
    final out = <Changement>[];
    if (details == null) return out;
    final champs = (details['champs'] as Map?)?.cast<String, dynamic>() ?? const {};
    final saisons = (details['saisons'] as List?) ?? const [];

    // Description : seulement si l'appli n'en a pas. Deux sites décrivent la même œuvre avec des textes
    // différents ; remplacer un texte valable par un autre n'est pas une correction.
    final synopsis = '${champs['synopsis'] ?? ''}'.trim();
    if (synopsis.isNotEmpty && _vide(local.description)) {
      out.add(Changement(TypeChangement.description,
          _vide(local.description) ? '(vide)' : _court(local.description!), _court(synopsis),
          valeur: synopsis));
    }

    final duree = dureeDepuisMinutes(champs['duree']);
    if (duree != null && duree != local.duree) {
      out.add(Changement(TypeChangement.duree, local.duree ?? '(vide)', duree, valeur: duree));
    }

    final date = dateDepuisChamps(champs);
    final anneeLocale = int.tryParse((local.dateParution ?? '').split('-').first);
    if (date != null && int.parse(date.substring(0, 4)) != anneeLocale) {
      out.add(Changement(TypeChangement.annee, local.dateParution ?? '(vide)', date, valeur: date));
    }

    final affiche = '${champs['url_poster'] ?? fiche?['url_poster'] ?? ''}';
    if (afficheARemplacer(local, affiche)) {
      out.add(Changement(TypeChangement.affiche,
          _vide(local.lienAffiche) ? '(aucune)' : '${local.lienAffiche} (introuvable sur l\'appareil)', affiche,
          valeur: affiche));
    }

    if (local.estSerie) {
      // Sites à une fiche par saison (Vostfree, VoirDrama, Anime-Ultime) : la fiche « Dr. STONE Saison 3 » est
      // lue « saison 3 » par le serveur, mais l'appli l'a rangée en saison 1. Une seule saison de chaque côté :
      // c'est la même, quel que soit son numéro.
      // Sans épisode local, une saison unique va en saison 1 (convention de l'appli pour ces fiches).
      final uneSeule = saisons.length == 1 && local.episodesParSaison.length <= 1;
      for (final s in saisons) {
        final lu = (s['numero'] as num?)?.toInt();
        final nb = (s['episodes'] as num?)?.toInt();
        if (lu == null || nb == null || nb <= 0) continue; // saison illisible côté serveur : rien à proposer
        final n = uneSeule ? (local.episodesParSaison.keys.firstOrNull ?? 1) : lu;
        final avant = local.episodesParSaison[n];
        if (avant == null) {
          out.add(Changement(TypeChangement.saison, '—', 'S$n : $nb épisode(s)', valeur: nb, saison: n));
        } else if (nb > avant) {
          out.add(Changement(TypeChangement.episodes, 'S$n : $avant', 'S$n : $nb', valeur: nb, saison: n));
        }
      }
    }
    return out;
  }

  static String _court(String t) => t.length <= 80 ? t : '${t.substring(0, 77)}…';

  /// Nombre d'œuvres concernées par type de changement.
  static Map<TypeChangement, int> compterParType(Iterable<ApercuOeuvre> apercus) {
    final c = <TypeChangement, int>{};
    for (final a in apercus) {
      for (final t in a.changements.map((x) => x.type).toSet()) {
        c[t] = (c[t] ?? 0) + 1;
      }
    }
    return c;
  }
}
