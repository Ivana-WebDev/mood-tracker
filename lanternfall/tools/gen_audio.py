#!/usr/bin/env python3
"""Synthesises Lanternfall's original sound effects and music loops into ../audio/*.wav.

Everything is generated from scratch (oscillators, noise, envelopes, a convolution reverb),
so there are no third-party samples. Re-run after tweaking:  python3 tools/gen_audio.py
"""
import os, wave
import numpy as np

SR = 22050
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "audio")
rng = np.random.default_rng(7)


def t(d):
    return np.arange(int(SR * d)) / SR


def env(n, a=0.005, d=0.1, s=0.0, r=0.05, total=None):
    """ADSR envelope of n samples (sustain level s held until release)."""
    a_n, d_n, r_n = int(a * SR), int(d * SR), int(r * SR)
    s_n = max(0, n - a_n - d_n - r_n)
    e = np.concatenate([np.linspace(0, 1, a_n, endpoint=False), np.linspace(1, s, d_n, endpoint=False),
                        np.full(s_n, s), np.linspace(s, 0, r_n)])
    return np.pad(e, (0, max(0, n - len(e))))[:n]


def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12.0)


def osc(freq, d, shape="sine", phase=0.0):
    tt = t(d)
    ph = 2 * np.pi * np.cumsum(np.broadcast_to(freq, tt.shape)) / SR + phase
    if shape == "sine":
        return np.sin(ph)
    if shape == "tri":
        return 2 / np.pi * np.arcsin(np.sin(ph))
    if shape == "saw":
        return 2 * ((ph / (2 * np.pi)) % 1.0) - 1
    if shape == "square":
        return np.sign(np.sin(ph))
    raise ValueError(shape)


def lp_fft(x, cutoff):
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR)
    X *= 1 / np.sqrt(1 + (f / cutoff) ** 4)
    return np.fft.irfft(X, len(x))


def hp_fft(x, cutoff):
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR)
    X *= 1 / np.sqrt(1 + (cutoff / np.maximum(f, 1)) ** 4)
    return np.fft.irfft(X, len(x))


def reverb(x, seconds=1.6, mix=0.25, wrap=False):
    n = int(seconds * SR)
    ir = rng.standard_normal(n) * np.exp(-np.linspace(0, 6.5, n))
    ir = lp_fft(ir, 3500)
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
    L = len(x) + n
    N = 1 << int(np.ceil(np.log2(L)))
    wet = np.fft.irfft(np.fft.rfft(x, N) * np.fft.rfft(ir, N), N)[:L]
    if wrap:  # fold the tail back onto the start so a loop stays seamless
        out = wet[:len(x)].copy()
        out[:n] += wet[len(x):]
        wet = out
    else:
        x = np.pad(x, (0, n))
    return x * (1 - mix) + wet * mix * 0.6


def save(name, x, peak=0.85):
    x = np.asarray(x, dtype=np.float64)
    m = np.max(np.abs(x)) or 1.0
    x = np.clip(x / m * peak, -1, 1)
    data = (x * 32767).astype("<i2").tobytes()
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)
    print(f"{name}.wav  {len(x) / SR:.2f}s")


def mix_at(buf, x, start):
    s = int(start * SR)
    end = min(len(buf), s + len(x))
    if end > s:
        buf[s:end] += x[: end - s]


def bell(freq, d, decay=4.0):
    tt = t(d)
    partials = [(1, 1.0), (2.01, 0.45), (2.76, 0.3), (4.07, 0.18), (5.4, 0.08)]
    return sum(a * np.sin(2 * np.pi * freq * p * tt) * np.exp(-tt * decay * p ** 0.5) for p, a in partials)


def pluck(freq, d, bright=0.6):
    """Karplus-Strong plucked string."""
    n = int(d * SR)
    period = max(2, int(SR / freq))
    buf = rng.uniform(-1, 1, period) * bright + rng.uniform(-1, 1, period) * (1 - bright) * 0.3
    out = np.empty(n)
    for i in range(n):
        out[i] = buf[i % period]
        buf[i % period] = 0.5 * (buf[i % period] + buf[(i + 1) % period]) * 0.996
    return out


# ---------------------------------------------------------------- SFX

def sfx():
    # UI click: soft wooden tick
    d = 0.06
    save("click", (osc(1500, d) * 0.6 + osc(2300, d, "tri") * 0.3) * env(int(d * SR), 0.001, 0.04))
    # select (map node): pluck
    save("select", reverb(pluck(midi(76), 0.35) * env(int(0.35 * SR), 0.001, 0.3), 0.6, 0.2))
    # card play: airy whoosh (noise band sweeping up)
    d = 0.22
    n = rng.standard_normal(int(d * SR))
    sweep = hp_fft(n, 900) * env(len(n), 0.03, 0.17) + osc(np.linspace(300, 900, len(n)), d, "sine") * 0.15 * env(len(n), 0.01, 0.2)
    save("card", lp_fft(sweep, 6000))
    # draw: paper flick
    d = 0.07
    n = hp_fft(rng.standard_normal(int(d * SR)), 2500) * env(int(d * SR), 0.002, 0.06)
    save("draw", n, 0.5)
    # hit: punchy thud + crack
    d = 0.3
    body = osc(np.geomspace(190, 55, int(d * SR)), d) * env(int(d * SR), 0.001, 0.25)
    crack = lp_fft(rng.standard_normal(int(d * SR)), 3000) * env(int(d * SR), 0.0005, 0.04)
    save("hit", body + crack * 0.7)
    # hurt (player takes damage): lower, with a gritty edge
    body = osc(np.geomspace(140, 40, int(d * SR)), d, "tri") * env(int(d * SR), 0.001, 0.28)
    grit = lp_fft(rng.standard_normal(int(d * SR)), 1200) * env(int(d * SR), 0.001, 0.12)
    save("hurt", body + grit * 0.6)
    # block: metallic clink
    d = 0.45
    tt = t(d)
    clink = sum(a * np.sin(2 * np.pi * f * tt) * np.exp(-tt * k) for f, a, k in [(950, 1, 9), (1420, 0.6, 12), (2230, 0.4, 16), (3150, 0.25, 22)])
    save("block", clink * env(len(tt), 0.001, 0.4), 0.6)
    # gold: two coin chimes
    buf = np.zeros(int(0.5 * SR))
    mix_at(buf, bell(midi(88), 0.4, 9), 0.0)
    mix_at(buf, bell(midi(93), 0.4, 9), 0.08)
    save("gold", buf, 0.55)
    # potion: three rising bubbles
    buf = np.zeros(int(0.5 * SR))
    for i, f in enumerate([300, 420, 560]):
        d = 0.09
        b = osc(np.linspace(f, f * 1.9, int(d * SR)), d) * env(int(d * SR), 0.002, 0.08)
        mix_at(buf, b, i * 0.11)
    save("potion", reverb(buf, 0.4, 0.2))
    # zap (gadget): buzzy pitch drop + crackle
    d = 0.25
    z = osc(np.geomspace(1800, 220, int(d * SR)), d, "saw") * env(int(d * SR), 0.001, 0.22)
    cr = hp_fft(rng.standard_normal(int(d * SR)), 4000) * (rng.random(int(d * SR)) > 0.85) * env(int(d * SR), 0.001, 0.2)
    save("zap", lp_fft(z, 5000) * 0.7 + cr * 0.6, 0.6)
    # dice: clatter of small clicks
    buf = np.zeros(int(0.5 * SR))
    for i in range(9):
        d = 0.025
        c = hp_fft(rng.standard_normal(int(d * SR)), 1800) * env(int(d * SR), 0.0005, 0.02)
        c += osc(rng.uniform(1800, 3200), d) * env(int(d * SR), 0.0005, 0.02) * 0.6
        mix_at(buf, c * (1 - i / 12), 0.02 + i * 0.038 + rng.uniform(0, 0.02))
    save("dice", buf, 0.6)
    # flow chime: quick bright arpeggio
    buf = np.zeros(int(0.7 * SR))
    for i, m in enumerate([79, 83, 86]):
        mix_at(buf, bell(midi(m), 0.5, 7), i * 0.05)
    save("flow", reverb(buf, 0.6, 0.25), 0.5)
    # heal: soft rising shimmer
    d = 0.6
    sh = sum(osc(np.linspace(midi(m), midi(m + 5), int(d * SR)), d) for m in [72, 76, 79]) * env(int(d * SR), 0.05, 0.5)
    save("heal", reverb(sh, 0.8, 0.3), 0.5)
    # buff / debuff blips
    d = 0.18
    save("buff", osc(np.linspace(520, 1040, int(d * SR)), d, "tri") * env(int(d * SR), 0.005, 0.17), 0.45)
    save("debuff", osc(np.linspace(600, 260, int(d * SR)), d, "tri") * env(int(d * SR), 0.005, 0.17), 0.45)
    # relic: magical sparkle
    buf = np.zeros(int(1.0 * SR))
    for i, m in enumerate([84, 88, 91, 96, 91]):
        mix_at(buf, bell(midi(m), 0.6, 6) * (0.9 - i * 0.1), i * 0.07)
    save("relic", reverb(buf, 1.0, 0.35), 0.55)
    # your turn: warm bell
    save("turn", reverb(bell(midi(69), 1.2, 3.0) + bell(midi(76), 1.2, 3.5) * 0.5, 1.0, 0.3), 0.5)
    # enemy turn: low drum hit
    d = 0.5
    save("enemy_turn", reverb(osc(np.geomspace(110, 45, int(d * SR)), d) * env(int(d * SR), 0.002, 0.45), 0.8, 0.25), 0.6)
    # death of an enemy: deflating whoosh
    d = 0.5
    save("enemy_die", lp_fft(rng.standard_normal(int(d * SR)), 1500) * env(int(d * SR), 0.01, 0.45) * 0.6 +
         osc(np.geomspace(400, 80, int(d * SR)), d, "tri") * env(int(d * SR), 0.01, 0.45) * 0.5, 0.6)
    # victory jingle: major arpeggio + chord
    buf = np.zeros(int(2.2 * SR))
    for i, m in enumerate([67, 71, 74, 79]):
        mix_at(buf, pluck(midi(m), 0.6) * 0.8, i * 0.11)
    for m in [67, 71, 74, 79, 83]:
        mix_at(buf, bell(midi(m), 1.6, 2.2) * 0.35, 0.5)
    save("victory", reverb(buf, 1.4, 0.3), 0.7)
    # heartbeat: "lub-dub" of two low, muffled thumps
    buf = np.zeros(int(0.55 * SR))
    for start, f0, amp in ((0.0, 70, 1.0), (0.2, 58, 0.75)):
        d = 0.22
        th = osc(np.geomspace(f0 * 1.6, f0, int(d * SR)), d) * env(int(d * SR), 0.004, 0.18)
        th += lp_fft(rng.standard_normal(int(d * SR)), 220) * env(int(d * SR), 0.002, 0.08) * 0.5
        mix_at(buf, th * amp, start)
    save("heartbeat", lp_fft(buf, 400), 0.9)
    # defeat: descending minor, slow
    buf = np.zeros(int(2.8 * SR))
    for i, m in enumerate([69, 65, 62, 57]):
        d = 0.9
        tone = (osc(midi(m), d, "tri") * 0.7 + osc(midi(m) * 1.003, d, "saw") * 0.15) * env(int(d * SR), 0.02, 0.3, 0.4, 0.4)
        mix_at(buf, lp_fft(tone, 1800), i * 0.42)
    save("defeat", reverb(buf, 1.8, 0.35), 0.7)


# ---------------------------------------------------------------- MUSIC (dream pop, stereo)

CHORD = {"maj7": [0, 4, 7, 11], "m7": [0, 3, 7, 10], "6": [0, 4, 7, 9], "add9": [0, 4, 7, 14],
         "m9": [0, 3, 7, 10, 14], "mmaj7": [0, 3, 7, 11], "sus4": [0, 5, 7, 10], "maj9": [0, 4, 7, 11, 14],
         "madd9": [0, 3, 7, 14]}


def save_stereo(name, L, R, peak=0.8):
    m = max(np.max(np.abs(L)), np.max(np.abs(R))) or 1.0
    L, R = np.clip(L / m * peak, -1, 1), np.clip(R / m * peak, -1, 1)
    inter = np.empty(len(L) * 2)
    inter[0::2], inter[1::2] = L, R
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((inter * 32767).astype("<i2").tobytes())
    print(f"{name}.wav  {len(L) / SR:.2f}s stereo")


def mod_delay(x, base_ms, depth_ms, rate_hz, phase=0.0):
    """Chorus voice: x read through a slowly modulated delay line (linear interpolation)."""
    n = np.arange(len(x))
    d = (base_ms + depth_ms * np.sin(2 * np.pi * rate_hz * n / SR + phase)) * SR / 1000.0
    # circular read: the start of a loop continues from its end
    return np.interp(n - d, n, x, period=len(x))


def chorus(x, depth=1.0):
    """Mono in, wide stereo out."""
    L = x * 0.6 + mod_delay(x, 14, 3.5 * depth, 0.31) * 0.55 + mod_delay(x, 21, 2.5 * depth, 0.19, 1.3) * 0.35
    R = x * 0.6 + mod_delay(x, 17, 3.5 * depth, 0.27, 2.1) * 0.55 + mod_delay(x, 24, 2.5 * depth, 0.23, 0.4) * 0.35
    return L, R


def pingpong(L, R, delay_s, fb=0.45, mix=0.4, taps=7):
    """Stereo ping-pong echo; echoes alternate sides and darken as they repeat."""
    d = int(delay_s * SR)
    n = len(L)
    oL, oR = L.copy(), R.copy()
    src = (L + R) * 0.5
    g = 1.0
    for k in range(1, taps + 1):
        g *= fb
        shift = d * k
        if shift >= n:
            break
        echo = np.roll(src, shift)  # circular, so echoes from the end land on the loop start
        echo = lp_fft(echo, 5200 / (1 + k * 0.35))
        if k % 2:
            oR += echo * g * mix * 2
        else:
            oL += echo * g * mix * 2
    return oL, oR


def wrap_add(buf, x, start):
    """Adds x into a loop buffer, wrapping anything past the end back to the start."""
    s = int(start * SR) % len(buf)
    first = min(len(x), len(buf) - s)
    buf[s:s + first] += x[:first]
    rest = x[first:]
    while len(rest):
        k = min(len(rest), len(buf))
        buf[:k] += rest[:k]
        rest = rest[k:]


def stereo_reverb(L, R, seconds=3.4, mix=0.45):
    n = int(seconds * SR)
    out = []
    for ch, seed_shift in ((L, 0), (R, 1)):
        local = np.random.default_rng(11 + seed_shift)
        ir = local.standard_normal(n) * np.exp(-np.linspace(0, 5.5, n))
        ir = lp_fft(ir, 2800)
        ir[: int(0.02 * SR)] *= np.linspace(0, 1, int(0.02 * SR))  # soft pre-delay
        ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
        N = 1 << int(np.ceil(np.log2(len(ch) + n)))
        wet = np.fft.irfft(np.fft.rfft(ch, N) * np.fft.rfft(ir, N), N)[: len(ch) + n]
        loop = wet[: len(ch)].copy()
        loop[: n] += wet[len(ch):]  # wrap the tail for a seamless loop
        out.append(ch * (1 - mix) + loop * mix * 0.7)
    return out


def bandpass(x, f0, q=6.0):
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR)
    X *= 1 / (1 + (q * (f / f0 - f0 / np.maximum(f, 1))) ** 2)
    return np.fft.irfft(X, len(x))


def vocal_pad(notes, d, vowel="ah"):
    """Breathy choir-ish 'aah' / 'ooh' pad: detuned saws through vowel formants plus air."""
    formants = {"ah": [(730, 1.0), (1090, 0.6), (2440, 0.3)], "oo": [(320, 1.0), (870, 0.4), (2240, 0.15)]}[vowel]
    src = sum(osc(midi(m) * (1 + 0.004 * k), d, "saw") for m in notes for k in (-1, 1)) / (2 * len(notes))
    voice = sum(bandpass(src, f0, 5.0) * a for f0, a in formants)
    air = bandpass(rng.standard_normal(int(d * SR)), formants[1][0], 2.0) * 0.08
    return (voice + air) * env(int(d * SR), 1.2, 0.5, 0.8, 1.2)


def lush_pad(notes, d, cutoff=1600):
    x = sum(osc(midi(m), d, "saw") * 0.4 + osc(midi(m) * 1.006, d, "saw") * 0.3 + osc(midi(m) * 0.994, d, "tri") * 0.3
            for m in notes) / len(notes)
    return lp_fft(x, cutoff) * env(int(d * SR), 1.4, 0.6, 0.75, 1.4)


def glass_lead(m, d):
    tt = t(d)
    vib = 1 + 0.006 * np.sin(2 * np.pi * 5.2 * tt) * np.clip(tt / 0.4, 0, 1)
    f = midi(m) * vib
    x = osc(f, d, "sine") * 0.8 + osc(f * 2, d, "sine") * 0.18 + osc(f * 3, d, "tri") * 0.05
    return x * env(int(d * SR), 0.06, 0.3, 0.6, 0.35)


def soft_kick(d=0.4):
    return osc(np.geomspace(110, 45, int(d * SR)), d) * env(int(d * SR), 0.002, 0.35)


def dream_snare(d=0.35):
    n = lp_fft(rng.standard_normal(int(d * SR)), 4200) * env(int(d * SR), 0.002, 0.3)
    return n * 0.7 + osc(200, d, "tri") * env(int(d * SR), 0.001, 0.06) * 0.35


def shaker(d=0.07):
    return hp_fft(rng.standard_normal(int(d * SR)), 6500) * env(int(d * SR), 0.015, 0.05)


def dream_track(name, bpm, prog, bars, *, drums="none", vowel="ah", lead=None, arp_rate=8,
                pad_cut=1600, verb_mix=0.45, peak=0.78, bass="long", tremolo=0.0, dark=False,
                pedal=None, ostinato=None, gtr_oct=12, bright=0.4, warble=4.0, master_lp=3400, pump=0.35):
    beat = 60.0 / bpm
    bar = beat * 4
    n = int(bars * bar * SR)
    gtr = np.zeros(n)      # mono guitar bus -> chorus + ping-pong
    padL, padR = np.zeros(n), np.zeros(n)
    low = np.zeros(n)      # bass + kick (kept mono/centred)
    drm = np.zeros(n)      # snare/shaker -> extra reverb
    led = np.zeros(n)
    for b in range(bars):
        root, kind = prog[b % len(prog)]
        tones = [root + iv for iv in CHORD[kind]]
        st = b * bar
        # pads: lush synth (wide) + vocal 'aah'
        pd = lush_pad([m + 12 for m in tones], bar * 1.1, pad_cut)
        wrap_add(padL, pd * 0.42, st)
        wrap_add(padR, mod_delay(pd, 12, 2, 0.2) * 0.42, st)
        vp = vocal_pad([m + 12 for m in tones[:3]], bar * 1.1, vowel)
        wrap_add(padL, mod_delay(vp, 8, 2, 0.15) * 0.5, st)
        wrap_add(padR, vp * 0.5, st)
        # hypnotic ostinato: the same contour every bar, re-voiced onto each chord
        order = ostinato or [0, 2, 1, 3, 2, 4 if len(tones) > 4 else 1, 3, 2]
        step = bar / arp_rate
        for k in range(arp_rate):
            idx = order[k % len(order)]
            m = tones[idx % len(tones)] + gtr_oct + (12 if idx >= len(tones) else 0)
            g = pluck(midi(m), min(1.6, step * 4), bright) * env(int(min(1.6, step * 4) * SR), 0.004, 1.2, 0.0, 0.3)
            if tremolo:
                tt = t(min(1.6, step * 4))
                g *= 1 - tremolo * (0.5 + 0.5 * np.sin(2 * np.pi * (bpm / 60 * 2) * tt))
            wrap_add(gtr, g * (0.55 if k % 2 == 0 else 0.4), st + k * step)
        # droning pedal (root + fifth) that never changes: the hypnotic floor of the track
        if pedal is not None:
            d = bar
            dr = osc(midi(pedal), d, "sine") * 0.6 + osc(midi(pedal + 7), d, "sine") * 0.25 + osc(midi(pedal + 12), d, "tri") * 0.12
            wrap_add(low, lp_fft(dr, 300) * 0.35, st)
        # bass
        if bass == "long":
            d = bar
            wrap_add(low, lp_fft(osc(midi(root - 12), d, "sine") + osc(midi(root - 12), d, "tri") * 0.3, 400) * env(int(d * SR), 0.08, 0.4, 0.8, 0.4) * 0.55, st)
        else:  # eighth-note pulse
            for k in range(8):
                d = beat / 2
                m = root - 12 + (12 if k in (3, 7) else 0)
                tone = lp_fft(osc(midi(m), d, "saw") * 0.5 + osc(midi(m), d, "sine"), 650 if not dark else 450)
                wrap_add(low, tone * env(int(d * SR), 0.004, 0.2, 0.4, 0.06) * 0.42, st + k * d)
        # glassy lead on the second half of each 4-bar phrase
        if lead and (b % 4) >= 2:
            for off, iv, ln in lead:
                wrap_add(led, glass_lead(root + 24 + iv, ln * beat) * 0.35, st + off * beat)
        # drums
        if drums != "none":
            for k in range(16):
                pos = st + k * beat / 4
                if drums == "soft":
                    if k in (0, 10):
                        wrap_add(low, soft_kick() * 0.5, pos)
                    if k in (4, 12):
                        wrap_add(drm, dream_snare() * 0.35, pos)
                    if k % 2 == 1:
                        wrap_add(drm, shaker() * 0.12, pos)
                elif drums == "drive":
                    if k in (0, 3, 8, 10):
                        wrap_add(low, soft_kick() * 0.75, pos)
                    if k in (4, 12):
                        wrap_add(drm, dream_snare() * 0.5, pos)
                    wrap_add(drm, shaker() * (0.16 if k % 2 == 0 else 0.09), pos)
                elif drums == "dark":
                    if k in (0, 6, 8, 11, 14):
                        wrap_add(low, soft_kick(0.5) * 0.85, pos)
                    if k in (4, 12):
                        wrap_add(drm, dream_snare(0.45) * 0.55, pos)
                    if k % 2 == 0:
                        wrap_add(drm, shaker() * 0.12, pos)
    # pads "breathe" with the beat (gentle sidechain-style pump)
    if pump > 0:
        tt = np.arange(n) / SR
        ph = (tt % beat) / beat
        gain = 1 - pump * np.exp(-ph * 6.0)
        padL *= gain
        padR *= gain
    # effects
    gL, gR = chorus(gtr, 1.2)
    gL, gR = pingpong(gL, gR, beat * 0.75, 0.5, 0.45)
    lL, lR = chorus(led, 0.6)
    lL, lR = pingpong(lL, lR, beat * 1.5, 0.45, 0.5)
    L = gL * 0.8 + padL + lL + drm * 0.9 + low
    R = gR * 0.8 + padR + lR + drm * 0.9 + low
    L, R = stereo_reverb(L, R, 3.6 if not dark else 3.0, verb_mix)
    # keep the low end tight and centred after the wash, darken the top, add a slow tape warble
    L = lp_fft(hp_fft(L, 35), master_lp)
    R = lp_fft(hp_fft(R, 35), master_lp)
    if warble > 0:
        L = mod_delay(L, 12, warble, 0.37)
        R = mod_delay(R, 12, warble, 0.37, 0.4)
    xf = int(0.04 * SR)  # tiny crossfade at the seam
    ramp = np.linspace(0, 1, xf)
    for ch in (L, R):
        ch[:xf] = ch[:xf] * ramp + ch[-xf:] * (1 - ramp)
    save_stereo(name, L[:-xf], R[:-xf], peak)


def music():
    hyp = [0, 2, 4, 2, 1, 2, 4, 2, 0, 2, 4, 2, 1, 3, 4, 3]  # repeating 16-step contour
    # Title: slow, nocturnal, entrancing (A minor) over an A pedal
    dream_track("music_menu", 64, [(45, "madd9"), (41, "maj7"), (45, "madd9"), (40, "m7")], 8,
                drums="none", vowel="oo", arp_rate=16, ostinato=hyp, pedal=33, pad_cut=1100, verb_mix=0.55,
                gtr_oct=12, bright=0.35, master_lp=3000, warble=5.0, pump=0.2,
                lead=[(0, 7, 2), (2, 3, 1), (3, 2, 1)])
    # Map / events: drifting and hypnotic (D minor) over a D pedal
    dream_track("music_map", 74, [(38, "m9"), (34, "maj7"), (38, "m9"), (45, "m7")], 16,
                drums="soft", vowel="oo", arp_rate=16, ostinato=hyp, pedal=26, pad_cut=1300, verb_mix=0.5,
                gtr_oct=12, bright=0.38, master_lp=3300, warble=4.5, pump=0.3,
                lead=[(0, 3, 1), (1, 7, 1.5), (2.5, 10, 0.5), (3, 7, 1)])
    # Combat: dark, driving, trance-like (E minor) over an E pedal pulse
    dream_track("music_combat", 96, [(40, "m9"), (36, "maj7"), (40, "m9"), (47, "m7")], 16,
                drums="drive", vowel="ah", arp_rate=16, ostinato=hyp, pedal=28, pad_cut=1500, verb_mix=0.4,
                bass="pulse", tremolo=0.3, gtr_oct=12, bright=0.42, master_lp=3600, warble=3.0, pump=0.45,
                lead=[(0, 7, 0.5), (0.5, 10, 0.5), (1, 12, 1.5), (3, 10, 1)], peak=0.8)
    # Boss: ominous and spiralling, Phrygian flat-II (C minor) over a low C drone
    dream_track("music_boss", 86, [(36, "m9"), (37, "maj7"), (36, "m9"), (32, "maj7")], 16,
                drums="dark", vowel="oo", arp_rate=16, ostinato=[0, 3, 1, 3, 2, 3, 1, 3, 0, 3, 1, 3, 2, 4, 3, 1],
                pedal=24, pad_cut=1000, verb_mix=0.45, bass="pulse", dark=True, gtr_oct=12, bright=0.36,
                master_lp=2800, warble=4.0, pump=0.4,
                lead=[(0, 12, 1), (1, 13, 0.5), (1.5, 8, 1.5), (3, 7, 1)], peak=0.82)


if __name__ == "__main__":
    sfx()
    music()
