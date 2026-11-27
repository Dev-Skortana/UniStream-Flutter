"""Banc d'essai du son de splash : générateur paramétrable + mesures « monteur son »."""
import subprocess, wave, pathlib, itertools, json, sys
import numpy as np
from scipy.signal import fftconvolve, butter, sosfilt

import son_splash as base   # kalimba, eclosion, placer (fondus anti-clic)

SR = 44100
OUT = pathlib.Path(__file__).parent / "sortie"
OUT.mkdir(exist_ok=True)
TIERCE_MIN, QUINTE = 2 ** (3 / 12), 2 ** (7 / 12)
NOTES = {"Sol1": 49.00, "Lab1": 51.91, "La1": 55.00, "Sib1": 58.27, "Si1": 61.74, "Do2": 65.41, "Ré2": 73.42}


HARMONIES = {
    "mineur":   ([-5, 0, 7, 12, 15], [0, 3, 7]),        # actuel : sombre mais « résolu »
    "sus2":     ([-5, 0, 7, 12, 14], [0, 7, 14]),       # sans tierce : ni triste ni gai, en suspens
    "mineur9":  ([-5, 0, 7, 12, 15, 26], [0, 3, 14]),   # mineur + 9e : sombre et ouvert
    "phrygien": ([-5, 0, 7, 12, 13], [0, 7, 13]),       # seconde mineure : tension, inquiétude
    "triton":   ([-5, 0, 6, 12, 15], [0, 6, 12]),       # quinte diminuée : énigmatique, instable
    # hybrides : base mineure sombre, l'énigme est portée par les perles
    "min_perles_phryg":  ([-5, 0, 7, 12, 15], [0, 7, 13]),   # la dernière perle frotte d'un demi-ton
    "min_perles_triton": ([-5, 0, 7, 12, 15], [0, 3, 6]),    # perles qui finissent sur la quinte diminuée
    "min_perles_susp":   ([-5, 0, 7, 12, 15], [0, 7, 2]),    # perles qui retombent sur la 9e : question sans réponse
}


def ton(R, demi):
    return R * 2 ** (demi / 12)


def eclosion(freqs, dur, vol, ouverture, nmax, declin, pic, montee, desaccord):
    """Accord dont la brillance s'ouvre (variante paramétrable : attaque et désaccord réglables)."""
    t = np.arange(int(SR * dur)) / SR
    k = 1.4 - ouverture * np.exp(-((t - pic) / (0.16 + pic / 3)) ** 2)
    env = np.minimum(t / montee, 1) * np.exp(-t / declin)
    s = np.zeros_like(t)
    for f in freqs:
        for n in range(1, nmax + 1):
            for d in (-desaccord, desaccord):
                s += np.sin(2 * np.pi * f * n * (1 + d) * t) / n * np.exp(-(n - 1) * k)
    return vol * env * s / (2 * len(freqs))


def souffle(dur, vol, R):
    """Souffle filtré qui gonfle puis retombe, centré sur une harmonique de la tonique : « air » mystérieux."""
    rng = np.random.default_rng(5)
    t = np.arange(int(SR * dur)) / SR
    b = filtre(rng.standard_normal(len(t)), [R * 6, R * 12], "band", 2)
    env = np.sin(np.pi * np.clip(t / dur, 0, 1)) ** 2
    return vol * env * b / np.max(np.abs(b))


def filtre(x, f, type_, ordre=4):
    return sosfilt(butter(ordre, f, type_, fs=SR, output="sos"), x)


def frappe(R, dur, tau, vol):
    t = np.arange(int(SR * dur)) / SR
    f = R * 0.42 + (R - R * 0.42) * np.exp(-t / 0.09)
    ph = 2 * np.pi * np.cumsum(f) / SR
    corps = (np.sin(ph) + 0.55 * np.sin(2 * ph) * np.exp(-t / 0.18) + 0.3 * np.sin(3 * ph) * np.exp(-t / 0.10))
    corps *= np.exp(-t / tau)
    bruit = filtre(np.random.default_rng(3).standard_normal(len(t)), [160, 800], "band", 2) * np.exp(-t / 0.015) * 0.45
    return vol * np.minimum(t / 0.002, 1) * (corps + bruit)


def reverb(s, mix, tau, coupure):
    """Réverbération reproductible (graine fixe) et sans grave : l'envoi est coupé sous 150 Hz."""
    rng = np.random.default_rng(11)
    t = np.arange(int(SR * 1.6)) / SR
    out = s.copy()
    for c in range(2):
        ir = filtre(rng.standard_normal(len(t)) * np.exp(-t / tau), coupure, "low", 2)
        ir /= np.sqrt(np.sum(ir ** 2))
        envoi = filtre(s[c], 150, "high", 4)
        out[c] = (1 - mix) * s[c] + mix * fftconvolve(envoi, ir)[: s.shape[1]]
    return out


def creux(x, f0, gain_db, q=0.9):
    """Égaliseur en cloche (biquad RBJ) : gain négatif = creuser une zone."""
    A = 10 ** (gain_db / 40); w = 2 * np.pi * f0 / SR; a = np.sin(w) / (2 * q)
    b = [1 + a * A, -2 * np.cos(w), 1 - a * A]; d = [1 + a / A, -2 * np.cos(w), 1 - a / A]
    from scipy.signal import lfilter
    return lfilter(np.array(b) / d[0], np.array(d) / d[0], x)


def rendre(p):
    """p : dict de paramètres → signal stéréo (2, n)."""
    R = NOTES[p["tonique"]]
    n = int(SR * p["duree"])
    s = np.zeros((2, n))
    fr = frappe(R, 1.4, p["tau_frappe"], p["vol_frappe"])
    if p.get("satur_frappe", 0):                   # harmoniques audibles au téléphone, sur la frappe seule
        g = fr / np.max(np.abs(fr))
        h = filtre(filtre(np.tanh(g * 4), 250, "high", 8), 1000, "low", 4)
        fr = fr + p["satur_frappe"] * h * np.max(np.abs(fr)) * 0.5
    base.placer(s, fr, 0.0)
    acc_int, per_int = HARMONIES[p.get("harmonie", "mineur")]
    perles = [ton(R, i) * p["oct_perles"] for i in per_int]
    for k, (f, pan) in enumerate(zip(perles, (-0.35, 0, 0.35))):
        base.placer(s, base.kalimba(f, dur=1.6, vol=p["vol_perles"], eclat=p["eclat"]), 0.20 + k * 0.15, pan)
    accord = [ton(R, i) for i in acc_int]
    base.placer(s, eclosion(accord, p["duree"], p["vol_accord"], p["ouverture"], p.get("nmax", 6),
                            p["declin"], 0.45, p.get("montee", 0.09), p.get("desaccord", 0.0025)),
                p.get("debut_accord", 0.50))
    if p.get("comble", 0):
        # nappe de relais (sans désaccord, donc sans creux de battement) qui comble la queue
        t0, n_c = 1.45, int(SR * (p["duree"] - 1.45))
        t = np.arange(n_c) / SR
        entree = np.sin(np.pi / 2 * np.clip(t / 0.25, 0, 1)) ** 2
        nappe = sum(np.sin(2 * np.pi * ton(R, i) * t + i) / (1 + k) for k, i in enumerate([0, 7, 12]))
        base.placer(s, p["comble"] * entree * np.exp(-t / 0.6) * nappe, t0)
    if p.get("souffle", 0):
        base.placer(s, souffle(1.6, p["souffle"], R), 0.15)
    # « fondamentale manquante » : on sature le grave et on ne garde que ses harmoniques (150–600 Hz),
    # que l'oreille utilise pour « reconstruire » le grave sur un haut-parleur qui ne le reproduit pas
    if p["satur"] > 0:
        for c in range(2):
            g = filtre(s[c], 140, "low")
            g = g / (np.max(np.abs(g)) + 1e-9)            # niveau connu avant saturation
            h = filtre(filtre(np.tanh(g * 4), 250, "high", 8), 1000, "low", 4)   # harmoniques seules, fondamentale exclue
            s[c] += p["satur"] * h * np.max(np.abs(s[c])) * 0.5
    s = reverb(s, p["rev_mix"], p["rev_tau"], p["rev_coupure"])
    for c in range(2):
        s[c] = filtre(s[c], 28, "high", 2)          # coupe l'infra-grave inutile (< 28 Hz)
        if p.get("creux_db", 0):
            s[c] = creux(s[c], 300, p["creux_db"])
    if "fondu_debut" in p:
        # extinction naturelle : descente régulière en dB (-60 dB à la fin), puis 30 ms jusqu'au silence
        t = np.arange(n) / SR
        t0 = p["fondu_debut"]
        u = np.clip((t - t0) / (p["duree"] - t0), 0, 1)
        g = 10 ** (-60 / 20 * u ** p.get("fondu_courbe", 1.0))   # courbe > 1 : départ en douceur
        s *= g
        f = int(0.03 * SR)
    else:
        f = int(0.45 * SR)
    s[:, -f:] *= np.linspace(1, 0, f) ** 2
    return s / np.max(np.abs(s)) * 0.6


def db(x):
    return 10 * np.log10(np.mean(x ** 2) + 1e-20)


def mesurer(s):
    m = s.mean(0)
    X = np.abs(np.fft.rfft(m)) ** 2
    f = np.fft.rfftfreq(len(m), 1 / SR)
    tel = filtre(filtre(m, 300, "high"), 8000, "low")        # haut-parleur de téléphone simulé
    h = 2205
    r = np.array([np.sqrt(np.mean(m[i:i + h] ** 2)) for i in range(0, len(m) - h, h)])
    rdb = 20 * np.log10(r / r.max() + 1e-9)
    return {
        "centroide_Hz": round(float(np.sum(f * X) / X.sum())),
        "sub_<60Hz_%": round(100 * X[f < 60].sum() / X.sum()),
        "boue_200-500_%": round(100 * X[(f > 200) & (f < 500)].sum() / X.sum(), 1),
        "perte_tel_dB": round(db(tel) - db(m), 1),
        "frappe_tel_dB": round(db(tel[: int(0.15 * SR)]) - max(db(tel[i:i + h]) for i in range(0, len(tel) - h, h)), 1),
        "presence_s": round(float(np.where(rdb > -10)[0].max() * h / SR), 2),
    }


def ecrire(s, nom):
    wav = OUT / f"{nom}.wav"
    with wave.open(str(wav), "wb") as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((s.T * 32767).astype("<i2").tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-b:a", "128k", OUT / f"{nom}.mp3"], check=True)


def lufs(nom):
    r = subprocess.run(["ffmpeg", "-hide_banner", "-i", OUT / f"{nom}.wav", "-af", "ebur128", "-f", "null", "-"],
                       capture_output=True, text=True).stderr
    return float([l for l in r.splitlines() if l.strip().startswith("I:")][-1].split()[1])


# Réglage de départ = C3 actuel (Ré2), ramené à 2 s
DEPART_C3 = dict(tonique="Ré2", duree=2.0, tau_frappe=0.45, vol_frappe=1.0, oct_perles=4, vol_perles=0.36,
              eclat=0.3, vol_accord=1.8, ouverture=0.6, declin=0.95, satur=0.0,
              rev_mix=0.35, rev_tau=0.9, rev_coupure=2200)

DEPART = {**DEPART_C3, "tonique": "Sib1", "oct_perles": 8, "vol_perles": 0.18, "creux_db": -2.5,
          "satur_frappe": 2.2, "declin": 1.6, "vol_accord": 2.2, "cible_lufs": -16}

if __name__ == "__main__":
    essais = json.loads(sys.argv[1])           # {"nom": {param: valeur, ...}, ...}
    for nom, delta in essais.items():
        p = {**DEPART, **delta}
        s = rendre(p)
        if "gain_fixe" in p:                        # même gain que la version validée : son identique
            plafond = 10 ** (-1 / 20)
            s = plafond * np.tanh(s * p["gain_fixe"] / plafond)
        elif "cible_lufs" in p:                       # limiteur doux (plafond −1 dBFS) + gain jusqu'à la cible
            brut, gain, plafond = s.copy(), 1.0, 10 ** (-1 / 20)
            for _ in range(8):
                s = plafond * np.tanh(brut * gain / plafond)
                ecrire(s, nom)
                ecart = p["cible_lufs"] - lufs(nom)
                if abs(ecart) < 0.2:
                    break
                gain *= 10 ** (ecart / 20)
            print(f"   (gain {gain:.6f} = {20*np.log10(gain):+.1f} dB, crête {20*np.log10(np.max(np.abs(s))):.1f} dBFS)")
        ecrire(s, nom)
        m = mesurer(s)
        m["LUFS"] = lufs(nom)
        print(f"{nom:24s}", "  ".join(f"{k}={v}" for k, v in m.items()))
