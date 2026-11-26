import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:unistream/Services/Features/Detail/Infos_Detail.dart';

void main() {
  group('rangerEpisodes', () {
    test('trie les saisons et les épisodes, retire les doublons', () {
      final rangement = InfosDetail.rangerEpisodes(
          [(2, 3), (1, 2), (2, 1), (1, 1), (1, 2)]);
      expect(rangement, {1: [1, 2], 2: [1, 3]});
      expect(rangement.keys.toList(), [1, 2]);
    });

    test('accepte les colonnes en texte et ignore les lignes illisibles', () {
      expect(
          InfosDetail.rangerEpisodes(
              [('1', '10'), (' 1 ', '2'), (null, 3), ('S2', '1'), (2, 'x')]),
          {1: [2, 10]});
    });

    test('nombre d’épisodes et saisons', () {
      final infos = InfosDetail(
          episodesParSaison: InfosDetail.rangerEpisodes([(1, 1), (1, 2), (3, 1)]));
      expect(infos.saisons, [1, 3]);
      expect(infos.nombreEpisodes, 3);
      expect(infos.episodesDe(2), isEmpty);
    });
  });

  test('nettoyerNoms : espaces, vides et doublons (casse ignorée)', () {
    expect(InfosDetail.nettoyerNoms([' Action', 'action ', '', null, 'Comédie']),
        ['Action', 'Comédie']);
  });

  group('formaterDuree', () {
    test('minutes, heures, les deux', () {
      expect(InfosDetail.formaterDuree(const TimeOfDay(hour: 0, minute: 24)), '24 min');
      expect(InfosDetail.formaterDuree(const TimeOfDay(hour: 2, minute: 0)), '2 h');
      expect(InfosDetail.formaterDuree(const TimeOfDay(hour: 1, minute: 5)), '1 h 05');
    });

    test('absente ou nulle', () {
      expect(InfosDetail.formaterDuree(null), isNull);
      expect(InfosDetail.formaterDuree(const TimeOfDay(hour: 0, minute: 0)), isNull);
    });
  });

  test('formaterDate', () {
    expect(InfosDetail.formaterDate(DateTime(2015, 10, 5)), '5 octobre 2015');
    expect(InfosDetail.formaterDate(null), isNull);
  });
}
