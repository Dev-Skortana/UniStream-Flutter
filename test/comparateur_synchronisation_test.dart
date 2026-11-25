import 'package:flutter_test/flutter_test.dart';
import 'package:unistream/Models/Synchronisation.dart';
import 'package:unistream/Services/Features/Synchronisation/Comparateur_Synchronisation.dart';

Map<String, dynamic> details({Map<String, dynamic> champs = const {}, List saisons = const []}) =>
    {'champs': champs, 'saisons': saisons};

List<Changement> comparer(EtatLocal l, Map<String, dynamic>? d) => ComparateurSynchronisation.comparer(l, d, null);

void main() {
  group('comparer', () {
    test('une description existante n\'est pas remplacée par le texte d\'un autre site', () {
      const local = EtatLocal(titre: 'Edens Zero', description: 'L\'histoire d\'Eden\'s Zero…');
      expect(comparer(local, details(champs: {'synopsis': 'Basé sur le manga Edens Zero…'})), isEmpty);
    });

    test('fiche par saison : « saison 3 » du serveur = saison 1 de l\'appli', () {
      const local = EtatLocal(titre: 'Dr. STONE Saison 3', estSerie: true, episodesParSaison: {1: 11});
      expect(comparer(local, details(saisons: [{'numero': 3, 'episodes': 10}])), isEmpty);   // 10 < 11 : rien
      final c = comparer(local, details(saisons: [{'numero': 3, 'episodes': 12}]));
      expect(c.single.toString(), 'Épisodes : S1 : 11 → S1 : 12');
      expect(c.single.saison, 1);
    });

    test('fiche par saison sans épisode local : rangée en saison 1, pas en saison 3', () {
      const local = EtatLocal(titre: 'Dr. STONE Saison 3 FRENCH', estSerie: true);
      final c = comparer(local, details(saisons: [{'numero': 3, 'episodes': 10}]));
      expect((c.single.type, c.single.saison, c.single.apres), (TypeChangement.saison, 1, 'S1 : 10 épisode(s)'));
    });

    test('une valeur vide du serveur ne remplace jamais une valeur locale', () {
      const local = EtatLocal(titre: 'X', description: 'Ma description', duree: '00:24:00');
      expect(comparer(local, details(champs: {'synopsis': '', 'duree': null})), isEmpty);
    });

    test('description, durée et date ajoutées quand elles manquent ; valeur complète gardée pour l\'écriture', () {
      final long = 'R' * 200;
      final c = comparer(const EtatLocal(titre: 'X'), details(champs: {'synopsis': long, 'duree': 24, 'annee': 2011}));
      expect(c.map((x) => x.type), [TypeChangement.description, TypeChangement.duree, TypeChangement.annee]);   // description vide : ajoutée
      expect(c[0].valeur, long);
      expect(c[0].apres.length, lessThan(long.length));
      expect(c[1].valeur, '00:24:00');
      expect(c[2].valeur, '2011-01-01');
    });

    test('une date complète locale de la même année est gardée ; date de sortie complète préférée', () {
      expect(comparer(const EtatLocal(titre: 'X', dateParution: '2011-04-07'), details(champs: {'annee': 2011})), isEmpty);
      final c = comparer(const EtatLocal(titre: 'X'), details(champs: {'annee': 2011, 'date_sortie': '2011-04-07'}));
      expect(c.single.valeur, '2011-04-07');
    });

    test('épisodes : jamais en baisse, nouvelle saison signalée, seulement pour une série', () {
      const local = EtatLocal(titre: 'X', estSerie: true, episodesParSaison: {1: 12, 2: 10});
      final d = details(saisons: [
        {'numero': 1, 'episodes': 11},
        {'numero': 2, 'episodes': 12},
        {'numero': 3, 'episodes': 4},
        {'numero': 4, 'episodes': null},
      ]);
      final c = comparer(local, d);
      expect(c.map((x) => x.toString()), ['Épisodes : S2 : 10 → S2 : 12', 'Nouvelle saison : — → S3 : 4 épisode(s)']);
      expect((c[0].saison, c[0].valeur), (2, 12));
      expect(comparer(const EtatLocal(titre: 'Film'), d), isEmpty);
    });

    test('sans détails (fiche pas encore lue) : rien à proposer', () {
      expect(comparer(const EtatLocal(titre: 'X'), null), isEmpty);
    });
  });

  group('afficheARemplacer', () {
    const nouvelle = 'https://ipv4.vostfree.ws/img/x.jpg';
    test('fichier présent sur l\'appareil → gardé', () {
      expect(ComparateurSynchronisation.afficheARemplacer(
          const EtatLocal(titre: 'X', lienAffiche: '/data/x/video posters/a.jpg', afficheExiste: true), nouvelle), isFalse);
    });
    test('adresse http, chemin d\'un autre appareil, image par défaut ou rien → remplacé', () {
      for (final l in ['https://vostfree.ws/img/x.jpg', r'Images\video posters\a.jpg', '', null]) {
        expect(ComparateurSynchronisation.afficheARemplacer(EtatLocal(titre: 'X', lienAffiche: l), nouvelle), isTrue,
            reason: '$l');
      }
    });
    test('pas d\'affiche côté serveur → rien', () {
      expect(ComparateurSynchronisation.afficheARemplacer(const EtatLocal(titre: 'X'), ''), isFalse);
    });
  });

  test('dureeDepuisMinutes', () {
    expect(ComparateurSynchronisation.dureeDepuisMinutes(95), '01:35:00');
    expect(ComparateurSynchronisation.dureeDepuisMinutes(5000), '23:59:00');
    expect(ComparateurSynchronisation.dureeDepuisMinutes(null), isNull);
    expect(ComparateurSynchronisation.dureeDepuisMinutes('0'), isNull);
  });
}
