"""Sons de splash UniStream (originaux, synthétisés) — 2 variantes.

A « Perles »  : trois notes de kalimba qui montent (une par perle) puis un accord doux à l'apparition du nom.
B « Impact »  : une frappe grave feutrée, puis les trois notes en scintillement aigu et l'accord.
Gamme pentatonique de ré majeur (ré, fa#, la) : couleur « Asie de l'Est » sans cliché.
"""
import subprocess, pathlib
import numpy as np
from scipy.signal import fftconvolve, butter, sosfilt

SR = 44100
OUT = pathlib.Path(__file__).parent / "sortie"
OUT.mkdir(exist_ok=True)
rng = np.random.default_rng(7)


def t_(dur):
    return np.arange(int(SR * dur)) / SR


def kalimba(f, dur=1.2, vol=1.0, eclat=1.0):
    t = t_(dur)
    att = np.minimum(t / 0.003, 1)
    corps = np.sin(2 * np.pi * f * t) * np.exp(-t / 0.38)
    h2 = 0.25 * eclat * np.sin(2 * np.pi * 2 * f * t) * np.exp(-t / 0.12)
    lame = 0.18 * eclat * np.sin(2 * np.pi * 5.4 * f * t) * np.exp(-t / 0.025)   # « tic » métallique de la lame
    return vol * att * (corps + h2 + lame)


def nappe(freqs, dur=1.4, vol=1.0, montee=0.06):
    t = t_(dur)
    env = np.minimum(t / montee, 1) * np.exp(-t / 0.55)
    s = sum(np.sin(2 * np.pi * f * (1 + d) * t) for f in freqs for d in (-0.002, 0.002))
    return vol * env * s / (2 * len(freqs))


def frappe(dur=0.6, vol=1.0):
    t = t_(dur)
    f = 48 + (110 - 48) * np.exp(-t / 0.07)          # balayage 110 → 48 Hz
    phase = 2 * np.pi * np.cumsum(f) / SR
    corps = np.sin(phase) * np.exp(-t / 0.22)
    bruit = sosfilt(butter(2, 900, "low", fs=SR, output="sos"), rng.standard_normal(len(t))) * np.exp(-t / 0.015) * 0.6
    return vol * (corps + bruit)


def placer(piste, son, debut, pan=0.0):
    son = son.copy()
    i = int(debut * SR)
    f = int(0.04 * SR)                                # fondu de fin : évite le clic d'une coupure nette
    son[-f:] *= np.linspace(1, 0, f) ** 2
    n = min(len(son), piste.shape[1] - i)
    if n < len(son):
        son[n - f:n] *= np.linspace(1, 0, f) ** 2
    g, d = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
    piste[0, i:i + n] += son[:n] * g
    piste[1, i:i + n] += son[:n] * d


def reverb(piste, mix=0.22, tau=0.55, coupure=5000):
    t = t_(1.6)
    out = piste.copy()
    for c in range(2):
        ir = rng.standard_normal(len(t)) * np.exp(-t / tau)
        ir = sosfilt(butter(2, coupure, "low", fs=SR, output="sos"), ir)
        ir /= np.sqrt(np.sum(ir ** 2))
        out[c] = (1 - mix) * piste[c] + mix * fftconvolve(piste[c], ir)[: piste.shape[1]]
    return out


def finir(piste, nom, fondu=0.12):
    n = int(fondu * SR)                                # fondu de sortie
    piste[:, -n:] *= np.linspace(1, 0, n)
    piste /= np.max(np.abs(piste)) / 0.6              # crête à ~ -4,4 dBFS : présent sans agresser
    wav = OUT / f"{nom}.wav"
    import wave
    with wave.open(str(wav), "wb") as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((piste.T * 32767).astype("<i2").tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-b:a", "128k", OUT / f"{nom}.mp3"], check=True)


# C — Grave : une seule frappe profonde, trois notes graves qui montent, accord grave qui s'ouvre
def frappe_grave(dur=0.9, vol=1.0, haut=92, bas=38, tau=0.32):
    t = t_(dur)
    f = bas + (haut - bas) * np.exp(-t / 0.09)       # balayage haut → bas (Hz)
    ph = 2 * np.pi * np.cumsum(f) / SR
    # harmoniques 2 et 3 : sans elles, un haut-parleur de téléphone (< ~200 Hz) n'entendrait rien
    corps = (np.sin(ph) + 0.55 * np.sin(2 * ph) * np.exp(-t / 0.18) + 0.3 * np.sin(3 * ph) * np.exp(-t / 0.10))
    corps *= np.exp(-t / tau)
    feutre = sosfilt(butter(2, [160, 800], "band", fs=SR, output="sos"),
                     rng.standard_normal(len(t))) * np.exp(-t / 0.015) * 0.45
    return vol * np.minimum(t / 0.002, 1) * (corps + feutre)


def eclosion(freqs, dur=1.1, vol=1.0, ouverture=1.0, nmax=8, declin=0.5, pic=0.22):
    """Accord riche dont la brillance s'ouvre puis se referme (filtre simulé harmonique par harmonique)."""
    t = t_(dur)
    k = 1.4 - ouverture * np.exp(-((t - pic) / (0.16 + pic / 3)) ** 2)  # k bas = brillant ; minimum à 0,22 s
    env = np.minimum(t / 0.09, 1) * np.exp(-t / declin)
    s = np.zeros_like(t)
    for f in freqs:
        for n in range(1, nmax + 1):
            if f * n > 6000:
                break
            for d in (-0.0025, 0.0025):
                s += np.sin(2 * np.pi * f * n * (1 + d) * t) / n * np.exp(-(n - 1) * k)
    return vol * env * s / (2 * len(freqs))


RE, FAD, LA = 587.33, 739.99, 880.0
RE2, LA2, RE3, FAD3, LA3, RE4, FAD4, LA4 = 73.42, 110.0, 146.83, 185.0, 220.0, 293.66, 369.99, 440.0
FA3, FA4 = 174.61, 349.23   # fa naturel : tierce mineure de ré, couleur sombre

if __name__ == "__main__":
    # A — Perles (1,5 s)
    a = np.zeros((2, int(SR * 1.5)))
    for k, (f, pan) in enumerate([(RE, -0.3), (FAD, 0.0), (LA, 0.3)]):
        placer(a, kalimba(f, vol=0.8), 0.02 + k * 0.13, pan)
    placer(a, nappe([RE / 2, LA / 2, RE, FAD], vol=1.1), 0.42)
    placer(a, kalimba(RE * 2, vol=0.35), 0.42, 0.15)
    finir(reverb(a), "splash_A_perles")

    # B — Impact (1,7 s)
    b = np.zeros((2, int(SR * 1.7)))
    placer(b, frappe(vol=1.3), 0.0)
    for k, (f, pan) in enumerate([(RE * 2, -0.4), (FAD * 2, 0.0), (LA * 2, 0.4)]):
        placer(b, kalimba(f, vol=0.45), 0.16 + k * 0.07, pan)
    placer(b, nappe([RE / 2, LA / 2, RE, FAD, LA], vol=1.2, montee=0.12), 0.36)
    finir(reverb(b, mix=0.28, tau=0.7), "splash_B_impact")

    # C — Grave (1,5 s)
    c = np.zeros((2, int(SR * 1.5)))
    placer(c, frappe_grave(vol=1.4), 0.0)
    for k, (f, pan) in enumerate([(RE4, -0.35), (FAD4, 0.0), (LA4, 0.35)]):
        placer(c, kalimba(f, dur=1.0, vol=0.55), 0.16 + k * 0.11, pan)
    placer(c, eclosion([RE2, LA2, RE3, FAD3, LA3], vol=1.5), 0.40)
    finir(reverb(c, mix=0.3, tau=0.6), "splash_C_grave")

    # C2 — Sombre (1,5 s) : plus grave, ré mineur, moins de brillance
    c2 = np.zeros((2, int(SR * 1.5)))
    placer(c2, frappe_grave(dur=1.0, vol=1.15, haut=78, bas=33, tau=0.40), 0.0)
    for k, (f, pan) in enumerate([(RE4, -0.35), (FA4, 0.0), (LA4, 0.35)]):
        placer(c2, kalimba(f, dur=1.0, vol=0.32, eclat=0.45), 0.18 + k * 0.12, pan)
    placer(c2, eclosion([LA2 / 2, RE2, LA2, RE3, FA3], vol=1.5, ouverture=0.75, nmax=6), 0.44)
    finir(reverb(c2, mix=0.32, tau=0.65, coupure=2800), "splash_C2_sombre")

    # C3 — Sombre et long : pleine présence jusqu'à ~1,5 s, extinction jusqu'à 2,3 s
    c3 = np.zeros((2, int(SR * 2.3)))
    placer(c3, frappe_grave(dur=1.4, vol=1.0, haut=74, bas=31, tau=0.45), 0.0)
    for k, (f, pan) in enumerate([(RE4, -0.35), (FA4, 0.0), (LA4, 0.35)]):
        placer(c3, kalimba(f, dur=1.6, vol=0.36, eclat=0.3), 0.20 + k * 0.15, pan)
    placer(c3, eclosion([LA2 / 2, RE2, LA2, RE3, FA3], dur=1.8, vol=1.8, ouverture=0.6, nmax=6,
                        declin=0.95, pic=0.45), 0.50)
    finir(reverb(c3, mix=0.35, tau=0.9, coupure=2200), "splash_C3_sombre_long", fondu=0.5)
