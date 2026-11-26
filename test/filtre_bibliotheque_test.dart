import 'package:flutter_test/flutter_test.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';

OeuvreBibliotheque oeuvre(String titre,
        {FamilleOeuvre famille = FamilleOeuvre.anime,
        FormatOeuvre format = FormatOeuvre.serie,
        DateTime? date,
        List<String> genres = const []}) =>
    OeuvreBibliotheque(
        video: Video(titre: titre, date_parution: date),
        famille: famille,
        format: format,
        genres: genres);

void main() {
  final kimetsu = oeuvre('Kimetsu no Yaiba: Saison 3', date: DateTime(2023, 4, 9));
  final bloodhounds = oeuvre('Bloodhounds',
      famille: FamilleOeuvre.drama, date: DateTime(2023, 6, 9));
  final fate = oeuvre('Fate', format: FormatOeuvre.film);
  final ewilan = oeuvre("La Quête d'Ewilan",
      famille: FamilleOeuvre.live, date: DateTime(2025, 10, 1));
  final toutes = [kimetsu, bloodhounds, fate, ewilan];

  group('puces', () {
    test('aucune puce cochée : tout passe', () {
      expect(const FiltreBibliotheque().appliquer(toutes).length, 4);
    });

    test('une famille cochée', () {
      final f = const FiltreBibliotheque().basculerFamille(FamilleOeuvre.anime);
      expect(f.appliquer(toutes), containsAll([kimetsu, fate]));
      expect(f.appliquer(toutes).length, 2);
    });

    test('familles cumulées (OU) puis format (ET)', () {
      final f = const FiltreBibliotheque()
          .basculerFamille(FamilleOeuvre.anime)
          .basculerFamille(FamilleOeuvre.drama)
          .basculerFormat(FormatOeuvre.serie);
      expect(f.appliquer(toutes).toSet(), {kimetsu, bloodhounds});
    });

    test('basculer deux fois revient à l’état initial', () {
      final f = const FiltreBibliotheque()
          .basculerFormat(FormatOeuvre.film)
          .basculerFormat(FormatOeuvre.film);
      expect(f.estVide, isTrue);
    });
  });

  group('recherche', () {
    test('insensible à la casse, aux accents et à la ponctuation', () {
      expect(const FiltreBibliotheque(recherche: 'quete EWILAN').appliquer(toutes),
          [ewilan]);
      expect(const FiltreBibliotheque(recherche: 'yaiba saison').appliquer(toutes),
          [kimetsu]);
    });

    test('tous les mots doivent être présents', () {
      expect(const FiltreBibliotheque(recherche: 'kimetsu fate').appliquer(toutes),
          isEmpty);
    });

    test('espaces seuls : pas de filtre', () {
      expect(const FiltreBibliotheque(recherche: '   ').appliquer(toutes).length, 4);
    });
  });

  test('tri : plus récentes d’abord, sans date à la fin', () {
    expect(const FiltreBibliotheque().appliquer(toutes),
        [ewilan, bloodhounds, kimetsu, fate]);
  });

  group('genres', () {
    final action = oeuvre('A', genres: ['Action', 'Comédie']);
    final comedie = oeuvre('B', genres: ['comédie ']);
    final drame = oeuvre('C', genres: ['Drame']);
    final sans = oeuvre('D');
    final lot = [action, comedie, drame, sans];

    test('un genre coché : casse, accents et espaces ignorés', () {
      final f = const FiltreBibliotheque().basculerGenre('COMEDIE');
      expect(f.appliquer(lot).toSet(), {action, comedie});
      expect(f.aLeGenre('Comédie'), isTrue);
    });

    test('plusieurs genres cochés s’additionnent (OU)', () {
      final f = const FiltreBibliotheque()
          .basculerGenre('Action')
          .basculerGenre('Drame');
      expect(f.appliquer(lot).toSet(), {action, drame});
    });

    test('genres combinés aux autres groupes (ET)', () {
      final f = const FiltreBibliotheque()
          .basculerGenre('Comédie')
          .basculerFormat(FormatOeuvre.film);
      expect(f.appliquer(lot), isEmpty);
    });

    test('sansGenres retire seulement les genres', () {
      final f = const FiltreBibliotheque(recherche: 'a')
          .basculerGenre('Action')
          .sansGenres();
      expect(f.genres, isEmpty);
      expect(f.recherche, 'a');
    });

    test('genresDisponibles : un par nom, plus fréquents d’abord', () {
      expect(FiltreBibliotheque.genresDisponibles(lot),
          [('Comédie', 2), ('Action', 1), ('Drame', 1)]);
    });

    test('un genre écrit deux fois dans une œuvre ne compte qu’une fois', () {
      expect(
          FiltreBibliotheque.genresDisponibles(
              [oeuvre('E', genres: ['Action', 'action'])]),
          [('Action', 1)]);
    });
  });
}
