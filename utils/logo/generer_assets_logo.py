"""Génère toutes les images du logo UniStream (« le U qui se dissout en flux ») à partir d'une seule géométrie.

Usage : python3 utils/logo/generer_assets_logo.py   (depuis la racine du dépôt)
Dépendances : rsvg-convert (librsvg) et Pillow.

Sorties (assets/images/Ressources/logo/) :
  logo_unistream.svg / logo_unistream_signe.svg / logo_unistream_signe_clair.svg   sources vectorielles
  icone_ios.png          1024², carré plein, sans transparence (iOS arrondit lui-même)
  icone_android.png      1024², carré arrondi (anciens Android sans icône adaptative)
  icone_fond.png         1024², fond dégradé de l'icône adaptative
  icone_avant_plan.png   1024², signe réduit à 62 % (zone sûre du masque rond)
  icone_monochrome.png   1024², silhouette blanche (icônes à thème d'Android 13+)
  icone_bureau.png       1024², carré arrondi de 824 px avec marge (macOS, Windows)
  splash_logo.png        768², disque dégradé + U et lecture, sans perles (écran natif : Android < 12, iOS, web)
  splash_android12.png   1152², même disque inscrit dans le cercle de 768 px (Android 12+)

La même géométrie est reprise en Dart dans lib/Views/Splash/Logo_UniStream.dart : si on la modifie ici,
la modifier là-bas aussi.
"""
import pathlib
import subprocess
import tempfile

from PIL import Image, ImageDraw

RACINE = pathlib.Path(__file__).resolve().parents[2]
SORTIE = RACINE / "assets/images/Ressources/logo"
SORTIE.mkdir(parents=True, exist_ok=True)

# ── Géométrie (repère 1024 × 1024) ──
U = "M300 270 V560 A212 212 0 0 0 724 560 V430"   # trait de 128, bouts ronds
LECTURE = "M452 412 L452 608 L602 510 Z"             # contour de 44, angles ronds
PERLES = [(726, 306, 50, "#FFC2A6"), (740, 196, 35, "#9FEBD3"), (760, 116, 23, "#FFE596")]
DECALAGE_Y = 34                                      # recentrage vertical du signe

DEFS = """
<linearGradient id="fond" x1="0" y1="0" x2="1" y2="1">
  <stop offset="0" stop-color="#9C8CFF"/><stop offset=".6" stop-color="#C79BF5"/><stop offset="1" stop-color="#FFA9C6"/></linearGradient>
<linearGradient id="lecture" x1="0" y1="0" x2="1" y2="1">
  <stop offset="0" stop-color="#4355B9"/><stop offset="1" stop-color="#8A5CF6"/></linearGradient>
<linearGradient id="u_clair" x1="0" y1="0" x2="1" y2="1">
  <stop offset="0" stop-color="#8E7BFF"/><stop offset="1" stop-color="#E98AB4"/></linearGradient>
<filter id="ombre" x="-20%" y="-20%" width="140%" height="140%">
  <feDropShadow dx="0" dy="18" stdDeviation="20" flood-color="#5B3FC4" flood-opacity=".35"/></filter>"""


def signe(echelle=1.0, couleur_u="#FFFFFF", couleur_lecture="url(#lecture)", perles=True, ombre=True, mono=None):
    if mono:
        couleur_u = couleur_lecture = mono
    filtre = ' filter="url(#ombre)"' if ombre else ""
    corps = (f'<g{filtre}><path d="{U}" fill="none" stroke="{couleur_u}" stroke-width="128" stroke-linecap="round"/>'
             f'<path d="{LECTURE}" fill="{couleur_lecture}" stroke="{couleur_lecture}" stroke-width="44" '
             f'stroke-linejoin="round"/></g>')
    if perles:
        corps += "".join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{mono or c}"/>' for x, y, r, c in PERLES)
    return (f'<g transform="translate(512 512) scale({echelle}) translate(-512 -{512 - DECALAGE_Y})">'
            f'{corps}</g>')


def svg(contenu, fond=False):
    bg = '<rect width="1024" height="1024" fill="url(#fond)"/>' if fond else ""
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">'
            f'<defs>{DEFS}</defs>{bg}{contenu}</svg>')


def rendre(code_svg, taille=1024):
    with tempfile.NamedTemporaryFile("w", suffix=".svg", delete=False) as f:
        f.write(code_svg)
    png = pathlib.Path(f.name).with_suffix(".png")
    subprocess.run(["rsvg-convert", "-w", str(taille), "-h", str(taille), f.name, "-o", png], check=True)
    return Image.open(png).convert("RGBA")


def masque(taille, rayon=None, cercle=False):
    m = Image.new("L", (taille, taille), 0)
    d = ImageDraw.Draw(m)
    if cercle:
        d.ellipse([0, 0, taille - 1, taille - 1], fill=255)
    else:
        d.rounded_rectangle([0, 0, taille - 1, taille - 1], rayon, fill=255)
    return m


def avec_masque(im, m):
    im = im.copy()
    im.putalpha(Image.composite(im.getchannel("A"), Image.new("L", im.size, 0), m))
    return im


# Sources vectorielles
(SORTIE / "logo_unistream.svg").write_text(svg(signe(), fond=True))
(SORTIE / "logo_unistream_signe.svg").write_text(svg(signe()))
(SORTIE / "logo_unistream_signe_clair.svg").write_text(svg(signe(couleur_u="url(#u_clair)")))

# Icônes
complete = rendre(svg(signe(), fond=True))
complete.convert("RGB").save(SORTIE / "icone_ios.png")
avec_masque(complete, masque(1024, rayon=225)).save(SORTIE / "icone_android.png")
rendre(svg("", fond=True)).convert("RGB").save(SORTIE / "icone_fond.png")
rendre(svg(signe(echelle=0.62))).save(SORTIE / "icone_avant_plan.png")
rendre(svg(signe(echelle=0.62, ombre=False, mono="#FFFFFF"))).save(SORTIE / "icone_monochrome.png")

bureau = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
carre = avec_masque(complete.resize((824, 824), Image.LANCZOS), masque(824, rayon=185))
bureau.alpha_composite(carre, (100, 100))
bureau.save(SORTIE / "icone_bureau.png")

# Écran natif : disque dégradé + signe SANS les perles (même cadrage que l'icône adaptative découpée en rond).
# Les perles apparaissent ensuite dans l'animation Flutter, au rythme des trois notes du son.
fond_et_signe = Image.alpha_composite(rendre(svg("", fond=True)), rendre(svg(signe(echelle=0.62, perles=False))))
visible = int(1024 * 72 / 108)              # le masque adaptatif montre les 72 dp centraux sur 108
o = (1024 - visible) // 2
disque = avec_masque(fond_et_signe.crop((o, o, o + visible, o + visible)), masque(visible, cercle=True))
disque.resize((768, 768), Image.LANCZOS).save(SORTIE / "splash_logo.png")
a12 = Image.new("RGBA", (1152, 1152), (0, 0, 0, 0))
a12.alpha_composite(disque.resize((768, 768), Image.LANCZOS), (192, 192))
a12.save(SORTIE / "splash_android12.png")

print("Assets générés dans", SORTIE.relative_to(RACINE))
