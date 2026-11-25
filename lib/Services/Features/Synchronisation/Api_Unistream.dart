import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Réglages de l'API UniStream, lus à la compilation depuis config.json
/// (`flutter run --dart-define-from-file=config.json`), comme le jeton TMDB :
///   `"UNISTREAM_API_URL": "http://192.168.1.80:8090",`
///   `"UNISTREAM_API_CLE": "(contenu de serveur/api_cle.txt sur le Pi)"`
class ApiUnistreamConfig {
  static const String url = String.fromEnvironment('UNISTREAM_API_URL');
  static const String cle = String.fromEnvironment('UNISTREAM_API_CLE');

  static bool get configuree => url.isNotEmpty && cle.isNotEmpty;
}

/// Erreur lisible par l'utilisateur : « je n'ai pas pu répondre » (réseau, clé, serveur),
/// à distinguer d'une réponse vide.
class ApiUnistreamException implements Exception {
  final String message;
  final int? statut;
  ApiUnistreamException(this.message, {this.statut});
  @override
  String toString() => message;
}

/// Client de l'API de l'index (routes /v1). Aucune écriture dans la base de l'appli ici.
class ApiUnistream {
  final http.Client _client;
  final String _url;
  final String _cle;
  static const Duration _delai = Duration(seconds: 30);

  ApiUnistream({http.Client? client, String? url, String? cle})
      : _client = client ?? http.Client(),
        _url = (url ?? ApiUnistreamConfig.url).replaceAll(RegExp(r'/+$'), ''),
        _cle = cle ?? ApiUnistreamConfig.cle;

  Map<String, String> get _entetes => {
        'Authorization': 'Bearer $_cle',
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };

  Future<dynamic> _envoyer(String methode, String chemin, [Object? corps, Duration delai = _delai]) async {
    if (_url.isEmpty || _cle.isEmpty) {
      throw ApiUnistreamException(
          "API UniStream non configurée (UNISTREAM_API_URL / UNISTREAM_API_CLE dans config.json)");
    }
    final uri = Uri.parse('$_url$chemin');
    late http.Response rep;
    try {
      rep = await (methode == 'GET'
              ? _client.get(uri, headers: _entetes)
              : _client.post(uri, headers: _entetes, body: jsonEncode(corps)))
          .timeout(delai);
    } on TimeoutException {
      throw ApiUnistreamException("Le serveur UniStream ne répond pas (délai dépassé) : êtes-vous sur le réseau de la maison ?");
    } catch (e) {
      throw ApiUnistreamException("Serveur UniStream injoignable ($e)");
    }
    if (rep.statusCode == 401) {
      throw ApiUnistreamException("Clé d'API refusée (UNISTREAM_API_CLE)", statut: 401);
    }
    if (rep.statusCode >= 400) {
      // FastAPI renvoie {"detail": "…"} : plus parlant que le seul code (fiche illisible, site injoignable…)
      String detail = '';
      try {
        detail = ' : ${(jsonDecode(utf8.decode(rep.bodyBytes)) as Map)['detail']}';
      } catch (_) {}
      throw ApiUnistreamException("Erreur du serveur UniStream (HTTP ${rep.statusCode})$detail", statut: rep.statusCode);
    }
    return jsonDecode(utf8.decode(rep.bodyBytes));
  }

  Future<bool> sante() async {
    try {
      final r = await _envoyer('GET', '/v1/sante');
      return r is Map && r['status'] == 'ok';
    } on ApiUnistreamException {
      return false;
    }
  }

  /// Fiches de l'index dont le titre ressemble à [q] (une fiche = une version : site + langue), les meilleures
  /// d'abord. `total` > nombre de résultats : la liste est tronquée (les correspondances partielles en premier).
  Future<({List<dynamic> resultats, int total})> rechercher(String q, {int limite = 200}) async {
    final r = await _envoyer('GET', '/v1/rechercher?${Uri(queryParameters: {'q': q, 'limite': '$limite'}).query}');
    final resultats = r['resultats'] as List;
    return (resultats: resultats, total: (r['total'] as num?)?.toInt() ?? resultats.length);
  }

  /// Fiches apparues sur les sites ces [jours] derniers jours, la plus récente d'abord.
  Future<List<dynamic>> nouveautes({int jours = 7, int limite = 100}) async {
    final r = await _envoyer('GET', '/v1/nouveautes?jours=$jours&limite=$limite');
    return r['resultats'] as List;
  }

  /// Détails d'une fiche. Cache du serveur s'il a moins de [ageMaxH] heures, sinon lecture du site :
  /// plusieurs secondes (une page par saison), d'où un délai plus long que les autres appels.
  Future<Map<String, dynamic>> details(String urlFiche, {String? idSite, double ageMaxH = 168}) async {
    final q = Uri(queryParameters: {'url': urlFiche, if (idSite != null) 'site': idSite, 'age_max_h': '$ageMaxH'}).query;
    return (await _envoyer('GET', '/v1/fiches/details?$q', null, const Duration(seconds: 150)) as Map)
        .cast<String, dynamic>();
  }

  /// titres : [{titre, familles: [Anime|Drama], categorie: Film|Serie, affiche}]
  Future<Map<String, dynamic>> rapprocher(List<Map<String, dynamic>> titres) async {
    final sures = <dynamic>[], aValider = <dynamic>[];
    for (var i = 0; i < titres.length; i += 1000) {
      final r = await _envoyer('POST', '/v1/rapprocher',
          {'titres': titres.sublist(i, i + 1000 > titres.length ? titres.length : i + 1000)});
      sures.addAll(r['sures'] as List);
      aValider.addAll(r['a_valider'] as List);
    }
    return {'sures': sures, 'a_valider': aValider};
  }

  /// elements : [{id_oeuvre, cle_fiche}] → réponse de /v1/sync (cache du serveur, jamais d'attente des sites)
  Future<Map<String, dynamic>> sync(List<Map<String, dynamic>> elements) async {
    final out = <dynamic>[];
    var enFile = 0;
    for (var i = 0; i < elements.length; i += 500) {
      final r = await _envoyer('POST', '/v1/sync',
          {'elements': elements.sublist(i, i + 500 > elements.length ? elements.length : i + 500)});
      out.addAll(r['elements'] as List);
      enFile += (r['en_file'] as num).toInt();
    }
    return {'elements': out, 'en_file': enFile};
  }
}
