import 'package:flutter_test/flutter_test.dart';
import 'package:unistream/Services/Features/Lecture/Navigation_Lecture.dart';

void main() {
  group('sources', () {
    test('conversion, liens vides et doublons retirés', () {
      final s = NavigationLecture.sources([
        {'Name_Site': 'Anime-Sama', 'Link': 'https://anime-sama.to/a'},
        {'Name_Site': 'Vostfree', 'Link': '  '},
        {'Name_Site': 'Copie', 'Link': 'https://anime-sama.to/a'},
        {'Name_Site': '', 'Link': 'https://x.example/b'},
      ]);
      expect(s.map((x) => x.site), ['Anime-Sama', 'Source']);
      expect(s.first.domaine, 'anime-sama.to');
    });

    test('domaine : le lien entier si ce n’est pas une URL', () {
      expect(const SourceLecture(site: 'X', lien: 'pas une url').domaine,
          'pas une url');
    });
  });

  group('sourceParDefaut', () {
    final s = [
      const SourceLecture(site: 'Anime-Sama', lien: 'a'),
      const SourceLecture(site: 'Vostfree', lien: 'b'),
    ];
    test('la dernière utilisée si présente (casse ignorée)', () {
      expect(NavigationLecture.sourceParDefaut(s, 'vostfree'), 1);
    });
    test('sinon la première', () {
      expect(NavigationLecture.sourceParDefaut(s, 'JustStream'), 0);
      expect(NavigationLecture.sourceParDefaut(s, null), 0);
    });
  });

  group('épisodes', () {
    final eps = {2: [2, 1], 1: [1, 2, 3]};

    test('ordre de visionnage', () {
      expect(NavigationLecture.ordre(eps), [(1, 1), (1, 2), (1, 3), (2, 1), (2, 2)]);
    });

    test('voisin : passe d’une saison à l’autre, null aux bouts', () {
      expect(NavigationLecture.voisin(eps, (1, 3), 1), (2, 1));
      expect(NavigationLecture.voisin(eps, (2, 1), -1), (1, 3));
      expect(NavigationLecture.voisin(eps, (1, 1), -1), isNull);
      expect(NavigationLecture.voisin(eps, (2, 2), 1), isNull);
      expect(NavigationLecture.voisin(eps, (9, 9), 1), isNull);
    });

    test('avant : épisodes strictement précédents', () {
      expect(NavigationLecture.avant(eps, (2, 1)), [(1, 1), (1, 2), (1, 3)]);
      expect(NavigationLecture.avant(eps, (1, 1)), isEmpty);
      expect(NavigationLecture.avant(eps, (9, 9)), isEmpty);
    });
  });

  group('depuisServeur', () {
    Map<String, dynamic> src(String site, String statut,
            {String? page, String? cible, String? requete, List<String> langues = const []}) =>
        {'site': site, 'statut': statut, 'page': page, 'cible': cible, 'requete_episode': requete, 'langues': langues};

    test('épisode, saison avec requête, fiche : gardés ; requête "" sauf pour une saison', () {
      final (s, sans) = NavigationLecture.depuisServeur({
        'sources': [
          src('JustStream', 'trouve', page: 'https://js/1-saison/3-episode.html', cible: 'episode', langues: ['VF']),
          src('Anime-sama', 'trouve',
              page: 'https://as/saison1/vostfr', cible: 'saison',
              requete: ".//select[@id='selectEpisodes']/option[3]", langues: ['VOSTFR']),
          src('Film', 'trouve', page: 'https://f/film.html', cible: 'fiche'),
        ]
      });
      expect(s.map((x) => x.site), ['JustStream · VF', 'Anime-sama · VOSTFR', 'Film']);
      expect(s.map((x) => x.requete), ['', ".//select[@id='selectEpisodes']/option[3]", '']);
      expect(sans, isEmpty);
    });

    test('page de saison sans requête écartée (le téléphone s’en chargera)', () {
      final (s, _) = NavigationLecture.depuisServeur({
        'sources': [src('VoirDrama', 'trouve', page: 'https://vd/serie/', cible: 'saison')]
      });
      expect(s, isEmpty);
    });

    test('sites sans lien, sauf ceux qui ont un lien dans une autre langue', () {
      final (s, sans) = NavigationLecture.depuisServeur({
        'sources': [
          src('Vostfree', 'trouve', page: 'https://vf/a', cible: 'saison', requete: 'x/select/option[1]'),
          src('Vostfree', 'absent'),
          src('VoirDrama', 'injoignable'),
          src('VoirDrama', 'injoignable'),
          src('Anime-Ultime', 'absent'),
        ]
      });
      expect(s.length, 1);
      expect(sans.map((x) => x.libelle), ['VoirDrama injoignable', 'Anime-Ultime : absent']);
    });

    test('doublon de page retiré', () {
      final (s, _) = NavigationLecture.depuisServeur({
        'sources': [
          src('A', 'trouve', page: 'https://p/1', cible: 'episode'),
          src('B', 'trouve', page: 'https://p/1', cible: 'episode'),
        ]
      });
      expect(s.length, 1);
    });

    test('dernière source « Anime-sama » retrouvée parmi « Anime-sama · VF »', () {
      final s = [
        const SourceLecture(site: 'JustStream · VF', lien: 'a'),
        const SourceLecture(site: 'Anime-sama · VOSTFR', lien: 'b'),
      ];
      expect(NavigationLecture.sourceParDefaut(s, 'anime-sama'), 1);
      expect(NavigationLecture.sourceParDefaut(s, 'Anime-sama · VOSTFR'), 1);
    });
  });
}
