import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Views/Helpers/Theme_Controller.dart';

/// Bouton « Thème » à placer dans les `actions:` de chaque AppBar.
/// Il n'a aucun état propre : il lit et modifie le ThemeController partagé.
class BoutonTheme extends StatelessWidget {
  const BoutonTheme({super.key});

  static const Map<ThemeMode, String> _libelles = {
    ThemeMode.light: 'Clair',
    ThemeMode.dark: 'Sombre',
    ThemeMode.system: 'Système',
  };

  @override
  Widget build(BuildContext context) {
    final controleur = context.watch<ThemeController>();
    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.contrast),
      tooltip: 'Thème',
      initialValue: controleur.value,
      onSelected: controleur.choisir,
      itemBuilder: (_) => [
        for (final entree in _libelles.entries)
          CheckedPopupMenuItem<ThemeMode>(
            value: entree.key,
            checked: entree.key == controleur.value,
            child: Text(entree.value),
          ),
      ],
    );
  }
}
