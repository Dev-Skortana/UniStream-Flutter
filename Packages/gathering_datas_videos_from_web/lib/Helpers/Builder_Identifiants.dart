part of gathering_data_videos_from_web;

class BuilderIdentifiants {
  static const CHARS =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  BuilderIdentifiants() {}

  List<String> getIdentifiants(
          {required int how_many_identifiers, int length = 12}) =>
      List.generate(
          how_many_identifiers, (int index) => this._CreateIdentifiant(length));

  String _CreateIdentifiant(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => CHARS.codeUnitAt(Random().nextInt(CHARS.length))));
}
