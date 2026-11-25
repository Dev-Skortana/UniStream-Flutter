import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:unistream/Models/Ajout_Oeuvre.dart';
import 'package:unistream/Services/Features/Ajout_Oeuvre/Convertisseur_Ajout.dart';

VersionTrouvee version({String famille = 'Anime', String? categorie = 'Serie', int oeuvre = 1, String site = 'Vostfree'}) =>
    VersionTrouvee.depuisJson({
      'cle': 'vostfree|/x',
      'id_site': 'vostfree',
      'site': site,
      'url_fiche': 'https://vostfree.example/x',
      'titre': 'Lazarus (VF)',
      'titre_oeuvre': 'Lazarus',
      'oeuvre_id': oeuvre,
      'famille': famille,
      'categorie': categorie,
      'langues': ['vf'],
      'url_poster': 'https://img.example/p.jpg',
      'score': 100,
    });

void main() {
  group('type complet', () {
    test('famille + catégorie connues', () {
      expect(ConvertisseurAjout.typeComplet(famille: 'Anime', categorie: 'Film', episodesParSaison: {}),
          (EnumerationFulltypeVideo.Film_Anime, true));
      expect(ConvertisseurAjout.typeComplet(famille: 'Drama', categorie: 'Serie', episodesParSaison: {}),
          (EnumerationFulltypeVideo.Serie_Drama, true));
      expect(ConvertisseurAjout.typeComplet(famille: '', categorie: 'Film', episodesParSaison: {}),
          (EnumerationFulltypeVideo.Film_Film, true));
    });
    test('catégorie inconnue : plusieurs épisodes ⇒ série, sinon série à vérifier', () {
      expect(ConvertisseurAjout.typeComplet(famille: 'Anime', categorie: null, episodesParSaison: {1: 12}),
          (EnumerationFulltypeVideo.Serie_Anime, true));
      expect(ConvertisseurAjout.typeComplet(famille: 'Anime', categorie: 'Autre', episodesParSaison: {}),
          (EnumerationFulltypeVideo.Serie_Anime, false));
    });
  });

  test('saison unique rangée en saison 1, saisons illisibles ignorées', () {
    expect(ConvertisseurAjout.episodes([{'numero': 3, 'episodes': 12}]), {1: 12});
    expect(
        ConvertisseurAjout.episodes([
          {'numero': 2, 'episodes': 10},
          {'numero': 1, 'episodes': 24},
          {'numero': 3, 'episodes': null},
        ]),
        {1: 24, 2: 10});
  });

  test('genres : champ liste {valeur} et rubriques du site écartées', () {
    final g = [{'valeur': 'Séries'}, {'valeur': 'Comédie'}, {'valeur': 'Romance'}, {'valeur': 'Séries VOSTFR'}, {'valeur': 'Films'}];
    expect(ConvertisseurAjout.genres(g), ['Comédie', 'Romance']);
    expect(ConvertisseurAjout.liste([{'valeur': 'U.S.A.'}]), ['U.S.A.']);
  });

  test('la langue lue sur la fiche complète la version', () {
    final v = VersionTrouvee.depuisJson({'cle': 'k', 'id_site': 's', 'url_fiche': 'u', 'titre': 'Boomerang (2019)',
      'oeuvre_id': 3, 'langues': []});
    final a = ConvertisseurAjout.apercu(v, {'champs': {}, 'saisons': [], 'langues': ['VOSTFR']}, dejaPresent: false);
    expect(a.version.libelleLangues, 'VOSTFR');
  });

  test('listes : chaîne ou liste, sans doublon ni vide', () {
    expect(ConvertisseurAjout.liste('Action, Comédie, ,action'), ['Action', 'Comédie']);
    expect(ConvertisseurAjout.liste(['Japon']), ['Japon']);
    expect(ConvertisseurAjout.liste(null), isEmpty);
  });

  test('aperçu puis RegisterData : épisodes numérotés à partir de 1', () {
    final a = ConvertisseurAjout.apercu(
        version(),
        {
          'champs': {'synopsis': ' Un monde… ', 'annee': 2025, 'duree': '24', 'genres': ['Action'], 'studios': 'MAPPA'},
          'saisons': [
            {'numero': 1, 'episodes': 3}
          ],
        },
        dejaPresent: false);
    expect((a.titre, a.synopsis, a.dateParution, a.dureeMinutes, a.studio), ('Lazarus (VF)', 'Un monde…', DateTime(2025), 24, 'MAPPA'));
    final r = ConvertisseurAjout.versRegisterData(a, lienAffiche: '/docs/video posters/p.jpg');
    expect(r.fullType_Video, EnumerationFulltypeVideo.Serie_Anime);
    expect(r.dictionnarySaisonWithEpisodeThem, {1: [1, 2, 3]});
    expect((r.duree.hour, r.duree.minute), (0, 24));
    expect(r.lien_Affiche, '/docs/video posters/p.jpg');
  });

  test('un film n\'a pas d\'épisodes même si le site en compte un', () {
    final a = ConvertisseurAjout.apercu(version(categorie: 'Film'), {'champs': {}, 'saisons': [{'numero': 1, 'episodes': 1}]},
        dejaPresent: false);
    expect(ConvertisseurAjout.versRegisterData(a, lienAffiche: '').dictionnarySaisonWithEpisodeThem, isEmpty);
  });

  test('regroupement par œuvre', () {
    final g = ConvertisseurAjout.regrouper([version(oeuvre: 2), version(oeuvre: 1), version(oeuvre: 2, site: 'Anime-sama')]);
    expect({for (final x in g) x.idOeuvre: x.versions.length}, {2: 2, 1: 1});
    expect(g.firstWhere((x) => x.idOeuvre == 2).versions.first.site, 'Anime-sama'); // tri par site
  });

  group('onglets et filtres', () {
    VersionTrouvee v(int oeuvre, String cle, List<String> langues, {String famille = 'Anime', String titre = 'X'}) =>
        VersionTrouvee.depuisJson({
          'cle': cle, 'id_site': 's', 'site': 'S', 'url_fiche': 'u', 'titre': titre, 'titre_oeuvre': 'Œ$oeuvre',
          'oeuvre_id': oeuvre, 'famille': famille, 'langues': langues, 'score': 50,
        });
    final groupes = ConvertisseurAjout.regrouper([
      v(1, 'a|vf', ['vf'], titre: 'Lazarus (VF)'),
      v(1, 'b|vo', ['vostfr']),
      v(2, 'c|vo', ['vostfr'], famille: 'Drama'),
      v(3, 'd|?', [], famille: ''),
    ]);
    const bib = EtatBibliotheque(titres: {'Lazarus (VF)'}); // œuvre 1 présente par son titre (pas encore reliée)

    test('une œuvre dont j\'ai une version va dans « Dans ma bibliothèque », avec ses autres versions', () {
      final (aAjouter, presentes) = ConvertisseurAjout.repartir(groupes, bib, const FiltresAjout());
      expect(aAjouter.map((g) => g.idOeuvre), [2, 3]);
      expect(presentes.single.versions.length, 2);
      expect(ConvertisseurAjout.possedee(presentes.single.versions.firstWhere((x) => x.cle == 'b|vo'), bib), isFalse);
    });

    test('un lien Oeuvres_Liens suffit, même si le titre diffère', () {
      final (aAjouter, presentes) =
          ConvertisseurAjout.repartir(groupes, const EtatBibliotheque(oeuvres: {2}), const FiltresAjout());
      expect(presentes.map((g) => g.idOeuvre), [2]);
      expect(aAjouter.length, 2);
    });

    test('les valeurs inconnues ne sont jamais exclues', () {
      final (aAjouter, _) = ConvertisseurAjout.repartir(
          groupes, const EtatBibliotheque(), const FiltresAjout(langues: {'vf'}, familles: {'Anime'}));
      // œuvre 1 : seule sa version VF reste ; œuvre 2 (VOSTFR, Drama) exclue ; œuvre 3 (langue et famille ?) gardée
      expect({for (final g in aAjouter) g.idOeuvre: g.versions.length}, {1: 1, 3: 1});
    });

    test('langues du serveur en majuscules : le filtre VF les trouve', () {
      final g = ConvertisseurAjout.regrouper([v(5, 'e', ['VF'])]);
      final (aAjouter, _) =
          ConvertisseurAjout.repartir(g, const EtatBibliotheque(), const FiltresAjout(langues: {'vf'}));
      expect(aAjouter.single.versions.single.libelleLangues, 'VF');
    });

    test('groupe partiel seulement si toutes ses versions le sont', () {
      VersionTrouvee c(String cle, String type) => VersionTrouvee.depuisJson({
            'cle': cle, 'id_site': 's', 'url_fiche': 'u', 'titre': 'T', 'oeuvre_id': 7, 'langues': [],
            'correspondance': type,
          });
      expect(ConvertisseurAjout.regrouper([c('a', 'partielle'), c('b', 'debut')]).single.partielle, isFalse);
      expect(ConvertisseurAjout.regrouper([c('a', 'partielle')]).single.partielle, isTrue);
    });

    test('nouveautés : ordre du serveur conservé', () {
      final g = ConvertisseurAjout.regrouper([v(9, 'x', []), v(4, 'y', []), v(9, 'z', [])], trier: false);
      expect(g.map((x) => x.idOeuvre), [9, 4]);
    });
  });
}
