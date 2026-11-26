import 'package:flutter_test/flutter_test.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';

OeuvreBibliotheque oeuvre(String titre,
        {FamilleOeuvre famille = FamilleOeuvre.anime,
        FormatOeuvre format = FormatOeuvre.serie,
        DateTime? date}) =>
    OeuvreBibliotheque(
        video: Video(titre: titre, date_parution: date),
        famille: famille,
        format: format);

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
}
