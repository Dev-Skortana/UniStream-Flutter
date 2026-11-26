import 'package:flutter_test/flutter_test.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';

EntreeHistorique lu(String titre, int saison, int episode, int jour,
        {int connus = 0}) =>
    EntreeHistorique(
        titre: titre,
        saison: saison,
        episode: episode,
        vuLe: DateTime(2026, 11, jour),
        episodesConnus: connus);

void main() {
  // Saison 1 : 3 épisodes, saison 2 : 2 épisodes (5 au total).
  final serie = {1: [1, 2, 3], 2: [1, 2]};

  group('suivant', () {
    test('dans la saison, puis début de la saison suivante, puis fin', () {
      expect(SuiviVisionnage.suivant(serie, 1, 1), (1, 2));
      expect(SuiviVisionnage.suivant(serie, 1, 3), (2, 1));
      expect(SuiviVisionnage.suivant(serie, 2, 2), isNull);
    });

    test('épisodes non triés et numérotation trouée', () {
      expect(SuiviVisionnage.suivant({1: [5, 1, 3]}, 1, 1), (1, 3));
    });
  });

  group('calculer', () {
    test('dernière lecture, prochain épisode, progression, vus', () {
      final suivis = SuiviVisionnage.calculer(
          [lu('A', 1, 1, 1), lu('A', 1, 2, 3), lu('A', 1, 1, 2)], {'A': serie});
      final a = suivis['A']!;
      expect(a.dernierLu, (1, 2));
      expect(a.prochain, (1, 3));
      expect(a.derniereLecture, DateTime(2026, 11, 3));
      expect(a.vus, {(1, 1), (1, 2)});
      expect(a.progression, closeTo(2 / 5, 1e-9));
    });

    test('c’est la lecture la plus RÉCENTE qui compte, pas l’épisode le plus loin', () {
      // Revu l'épisode 1 après avoir vu le 3 : on reprend après le 1.
      final a = SuiviVisionnage.calculer(
          [lu('A', 1, 3, 1), lu('A', 1, 1, 5)], {'A': serie})['A']!;
      expect(a.dernierLu, (1, 1));
      expect(a.prochain, (1, 2));
    });

    test('nouveaux épisodes depuis la dernière lecture', () {
      final a = SuiviVisionnage.calculer(
          [lu('A', 1, 3, 1, connus: 3)], {'A': serie})['A']!;
      expect(a.nouveaux, 2);
      expect(a.aNouveaute, isTrue);
      expect(a.prochain, (2, 1));
    });

    test('nombre d’épisodes inconnu à la lecture : pas de « nouveau »', () {
      final a = SuiviVisionnage.calculer(
          [lu('A', 1, 1, 1, connus: 0)], {'A': serie})['A']!;
      expect(a.aNouveaute, isFalse);
    });

    test('série terminée : pas de prochain épisode', () {
      final a = SuiviVisionnage.calculer(
          [lu('A', 2, 2, 1, connus: 5)], {'A': serie})['A']!;
      expect(a.prochain, isNull);
      expect(a.aNouveaute, isFalse);
    });

    test('film : ni épisode, ni progression', () {
      final f = SuiviVisionnage.calculer([lu('F', 0, 0, 1)], {})['F']!;
      expect(f.dernierLu, isNull);
      expect(f.prochain, isNull);
      expect(f.progression, isNull);
    });

    test('un épisode lu puis retiré de la base ne fausse pas la progression', () {
      final a = SuiviVisionnage.calculer(
          [lu('A', 9, 9, 1), lu('A', 1, 1, 2)], {'A': serie})['A']!;
      expect(a.progression, closeTo(1 / 5, 1e-9));
    });
  });
}
