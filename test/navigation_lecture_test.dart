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
}
