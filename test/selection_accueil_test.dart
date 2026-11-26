import 'package:flutter_test/flutter_test.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Features/Accueil/Selection_Accueil.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';

OeuvreBibliotheque oeuvre(String titre,
        {FamilleOeuvre famille = FamilleOeuvre.anime,
        FormatOeuvre format = FormatOeuvre.serie,
        DateTime? date,
        String affiche = '/affiches/x.jpg'}) =>
    OeuvreBibliotheque(
        video: Video(titre: titre, date_parution: date, lien_affiche: affiche),
        famille: famille,
        format: format);

void main() {
  final maintenant = DateTime(2026, 11, 26);

  final sansAffiche = oeuvre('Sans affiche', date: DateTime(2026, 11, 1), affiche: '');
  final kimetsu = oeuvre('Kimetsu', date: DateTime(2026, 9, 1));
  final bloodhounds = oeuvre('Bloodhounds',
      famille: FamilleOeuvre.drama, date: DateTime(2026, 6, 1));
  final naruto = oeuvre('Naruto', date: DateTime(2002, 10, 3));
  final fate = oeuvre('Fate', format: FormatOeuvre.film);
  final ewilan = oeuvre('Ewilan', famille: FamilleOeuvre.live, format: FormatOeuvre.film,
      date: DateTime(2025, 1, 1));
  final toutes = [naruto, ewilan, fate, bloodhounds, kimetsu, sansAffiche];

  test('bibliothèque vide', () {
    expect(SelectionAccueil.composer([], maintenant: maintenant).estVide, isTrue);
  });

  test('vedette : la plus récente avec une affiche', () {
    final c = SelectionAccueil.composer(toutes, maintenant: maintenant);
    expect(c.vedette, kimetsu);
  });

  test('vedette : à défaut, la plus récente même sans affiche', () {
    final c = SelectionAccueil.composer([sansAffiche], maintenant: maintenant);
    expect(c.vedette, sansAffiche);
  });

  test('rangée « récent » : moins d’un an, sans la vedette, plus récentes d’abord', () {
    final c = SelectionAccueil.composer(toutes, maintenant: maintenant);
    expect(c.rangees.first.surTitre, 'RÉCENT');
    expect(c.rangees.first.oeuvres, [sansAffiche, bloodhounds]);
  });

  test('sans filtre : une rangée par famille, les vides retirées', () {
    final c = SelectionAccueil.composer(toutes, maintenant: maintenant);
    expect(c.rangees.map((r) => r.surTitre),
        ['RÉCENT', 'ANIMES', 'DRAMAS', 'LIVE ACTION']);
    expect(c.rangees[1].oeuvres, [sansAffiche, kimetsu, naruto, fate]);
  });

  test('filtre famille : rangées par format', () {
    final c = SelectionAccueil.composer(toutes,
        famille: FamilleOeuvre.anime, maintenant: maintenant);
    expect(c.vedette, kimetsu);
    expect(c.rangees.map((r) => r.surTitre), ['RÉCENT', 'SÉRIES', 'FILMS']);
    expect(c.rangees.last.oeuvres, [fate]);
  });

  test('au plus 20 œuvres par rangée', () {
    final beaucoup = [
      for (var i = 0; i < 30; i++) oeuvre('Anime $i', date: DateTime(2020, 1, i + 1))
    ];
    final c = SelectionAccueil.composer(beaucoup, maintenant: maintenant);
    expect(c.rangees.single.oeuvres.length, SelectionAccueil.maxParRangee);
  });

  group('reprendre', () {
    SuiviOeuvre suivi(String titre, int jour, (int, int)? prochain) =>
        SuiviOeuvre(
            titre: titre,
            derniereLecture: DateTime(2026, 11, jour),
            dernierLu: (1, 1),
            prochain: prochain);

    test('en tête, la plus récemment regardée d’abord, avec l’épisode suivant', () {
      final c = SelectionAccueil.composer(toutes, maintenant: maintenant, suivis: {
        'Naruto': suivi('Naruto', 20, (1, 2)),
        'Bloodhounds': suivi('Bloodhounds', 25, (2, 1)),
      });
      final r = c.rangees.first;
      expect(r.surTitre, 'REPRENDRE');
      expect(r.oeuvres, [bloodhounds, naruto]);
      expect(r.legendes['Bloodhounds'], 'S2 · É1');
    });

    test('série terminée (pas d’épisode suivant) : absente', () {
      final c = SelectionAccueil.composer(toutes,
          maintenant: maintenant, suivis: {'Naruto': suivi('Naruto', 20, null)});
      expect(c.rangees.first.surTitre, 'RÉCENT');
    });

    test('suit le filtre de famille', () {
      final c = SelectionAccueil.composer(toutes,
          famille: FamilleOeuvre.drama,
          maintenant: maintenant,
          suivis: {'Naruto': suivi('Naruto', 20, (1, 2))});
      expect(c.rangees.any((r) => r.surTitre == 'REPRENDRE'), isFalse);
    });
  });
}
