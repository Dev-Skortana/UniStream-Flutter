import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Son joué à l'ouverture de l'appli (« jingle »), et le réglage qui l'active.
///
/// Même principe que [ThemeController] : un seul objet, placé au-dessus de
/// MaterialApp, dont la valeur (activé ou non) est conservée entre deux lancements.
///
/// Déroulé :
/// 1. [prechauffer] pendant l'écran natif : le fichier est décodé à l'avance,
///    sinon le premier son joué arrive avec 100 à 300 ms de retard et se décale
///    de l'animation ;
/// 2. [jouer] au premier affichage de l'écran d'ouverture, en même temps que
///    l'animation ;
/// 3. libération automatique à la fin du son.
///
/// Le son ne doit jamais gêner : il se mélange à la musique en cours au lieu de
/// la couper, respecte le mode silencieux, et une erreur audio ne bloque jamais
/// l'ouverture de l'appli.
class SonDemarrage extends ValueNotifier<bool> {
  SonDemarrage._(super.actif);

  static const String _cle = 'son_demarrage';
  // Chemin relatif au préfixe « assets/ » d'audioplayers.
  static const String _fichier = 'sons/splash_mystere.mp3';

  AudioPlayer? _lecteur;
  bool _pret = false;

  /// Vrai une fois l'écran d'ouverture affiché : un lecteur prêt trop tard ne
  /// servira plus, il faut le libérer.
  bool _ouvertureFaite = false;

  /// Lit le choix enregistré ; activé par défaut (première ouverture).
  static Future<SonDemarrage> charger() async {
    final prefs = await SharedPreferences.getInstance();
    return SonDemarrage._(prefs.getBool(_cle) ?? true);
  }

  Future<void> choisir(bool actif) async {
    if (actif == value) return;
    value = actif;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cle, actif);
  }

  /// Contexte audio du jingle, réglé plateforme par plateforme.
  ///
  /// On n'utilise pas `AudioContextConfig(respectSilence: true, focus:
  /// mixWithOthers)` : sur iOS, cette combinaison est refusée (assertion).
  static final AudioContext _contexteJingle = AudioContext(
    // Android : canal « sonnerie », coupé en mode silencieux ou vibreur ;
    // aucune prise du focus audio, donc la musique en cours n'est pas coupée.
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.notificationRingtone,
      audioFocus: AndroidAudioFocus.none,
    ),
    // iOS : « ambient » respecte le bouton silencieux et se mélange
    // naturellement aux autres sons.
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  /// Session audio iOS rendue après le jingle. Sur iOS, la session est commune
  /// à toute l'appli : sans cette remise à zéro, les vidéos regardées ensuite
  /// hériteraient du mode « ambient » (coupées par le bouton silencieux).
  /// « soloAmbient » est la valeur par défaut d'iOS, celle d'avant le jingle.
  static final AudioContext _contexteParDefaut = AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.soloAmbient),
  );

  bool get _ios => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Prépare le lecteur. Sans effet si le son est désactivé.
  Future<void> prechauffer() async {
    if (!value || _lecteur != null) return;
    // Rangé tout de suite dans _lecteur : en cas d'erreur, liberer() le ferme.
    final lecteur = _lecteur = AudioPlayer(playerId: 'son_demarrage');
    try {
      await lecteur.setAudioContext(_contexteJingle);
      await lecteur.setReleaseMode(ReleaseMode.stop);
      await lecteur.setSource(AssetSource(_fichier));
      _pret = true;
      if (_ouvertureFaite) await liberer(); // prêt trop tard (délai dépassé)
    } catch (e) {
      debugPrint('Son de démarrage indisponible : $e');
      await liberer();
    }
  }

  /// Joue le jingle s'il est prêt (sinon, rien : on ne retarde pas l'ouverture).
  Future<void> jouer() async {
    _ouvertureFaite = true;
    final lecteur = _lecteur;
    if (lecteur == null || !_pret || !value) return;
    try {
      // onError : si le lecteur est libéré avant la fin, le flux se ferme
      // sans événement ; ce n'est pas une erreur.
      lecteur.onPlayerComplete.first.then((_) => liberer(), onError: (_) {});
      await lecteur.resume();
    } catch (e) {
      debugPrint('Lecture du son de démarrage impossible : $e');
      await liberer();
    }
  }

  /// Libère le lecteur et rend à iOS sa session audio par défaut.
  Future<void> liberer() async {
    final lecteur = _lecteur;
    _lecteur = null;
    _pret = false;
    try {
      await lecteur?.dispose();
      if (_ios) await AudioPlayer.global.setAudioContext(_contexteParDefaut);
    } catch (e) {
      debugPrint('Libération du son de démarrage : $e');
    }
  }

  @override
  void dispose() {
    liberer();
    super.dispose();
  }
}
