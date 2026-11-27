"""Rend le son de démarrage d'UniStream (« mystère », Sol1, v2) à l'identique.

Usage : python3 utils/son/generer_son_splash.py   (numpy, scipy, ffmpeg)
Résultat : utils/son/sortie/splash_mystere.mp3, à copier dans assets/sons/.

Réglages trouvés au banc d'essai (banc_son.py), mesurés :
centroïde 92 Hz · sub < 60 Hz 56 % · boue 200-500 Hz 4,4 % · perte au téléphone -11,7 dB ·
frappe au téléphone -6 dB · pleine présence jusqu'à ~1,6 s · extinction naturelle jusqu'à 2,7 s · -16 LUFS.
Chronologie (utilisée par l'animation, lib/Views/Splash/View_Splash.dart) :
frappe 0 s · perles 0,20 / 0,35 / 0,50 s · accord 0,50 s (montée 0,28 s).
"""
import json, subprocess, sys, pathlib

REGLAGES = {
    "tonique": "Sol1", "harmonie": "min_perles_susp", "montee": 0.28, "desaccord": 0.0045, "souffle": 0.15,
    "vol_perles": 0.16, "creux_db": -3.5, "vol_frappe": 1.15, "satur_frappe": 3.4,
    "gain_fixe": 2.344229, "fondu_debut": 1.55, "duree": 2.7, "fondu_courbe": 1.5, "comble": 0.45,
}
ici = pathlib.Path(__file__).parent
subprocess.run([sys.executable, str(ici / "banc_son.py"), json.dumps({"splash_mystere": REGLAGES})], check=True, cwd=ici)
