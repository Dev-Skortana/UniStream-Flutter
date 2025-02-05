enum EnumerationsMethodesRecherches {
  Egale,
  Commence,
  Contient,
  Fini,
  Superieure,
  Inferieure,
  Avant,
  Apres,
  Fourchette
}

extension on EnumerationsMethodesRecherches {
  static EnumerationsMethodesRecherches GetValueFromStr(String chaine) =>
      EnumerationsMethodesRecherches.values.byName(chaine);
}
