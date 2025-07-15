class ObjectSelector {
  late String _request;

  String get request => this._request;

  late String _regex;

  String get regex => this._regex;

  ObjectSelector({required String request, required String regex})
      : _request = request,
        _regex = regex;
}
