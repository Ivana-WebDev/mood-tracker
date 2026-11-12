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
    # defeat: descending minor, slow
    buf = np.zeros(int(2.8 * SR))
    for i, m in enumerate([69, 65, 62, 57]):
        d = 0.9
        tone = (osc(midi(m), d, "tri") * 0.7 + osc(midi(m) * 1.003, d, "saw") * 0.15) * env(int(d * SR), 0.02, 0.3, 0.4, 0.4)
        mix_at(buf, lp_fft(tone, 1800), i * 0.42)
    save("defeat", reverb(buf, 1.8, 0.35), 0.7)


# ---------------------------------------------------------------- MUSIC

def pad_chord(notes, d, shape="saw", cutoff=1400):
    x = sum(osc(midi(m), d, shape) * 0.5 + osc(midi(m) * 1.004, d, shape) * 0.5 for m in notes) / len(notes)
    return lp_fft(x, cutoff) * env(int(d * SR), 0.6, 0.4, 0.75, 0.8)


def kick(d=0.35):
    return osc(np.geomspace(150, 42, int(d * SR)), d) * env(int(d * SR), 0.001, 0.3)


def hat(d=0.05, bright=7000):
    return hp_fft(rng.standard_normal(int(d * SR)), bright) * env(int(d * SR), 0.0005, 0.045)


def snare(d=0.18):
    n = lp_fft(rng.standard_normal(int(d * SR)), 5000) * env(int(d * SR), 0.001, 0.15)
    return n * 0.8 + osc(190, d, "tri") * env(int(d * SR), 0.001, 0.08) * 0.5


def track(name, bpm, bars, chords, arp_pattern, arp_oct, bass_style, drums, pad_cutoff, verb, lead=None, peak=0.8):
    beat = 60.0 / bpm
    bar = beat * 4
    length = bars * bar
    n = int(length * SR)
    buf = np.zeros(n + int(4 * SR))  # room for tails; folded back for a seamless loop
    for b in range(bars):
        root, quality = chords[b % len(chords)]
        tri = [root, root + (3 if quality == "m" else 4), root + 7]
        start = b * bar
        mix_at(buf, pad_chord([m + 12 for m in tri] + [root + 24], bar * 1.05, cutoff=pad_cutoff) * 0.55, start)
        # bass
        if bass_style == "drone":
            mix_at(buf, lp_fft(osc(midi(root - 12), bar, "tri"), 600) * env(int(bar * SR), 0.2, 0.3, 0.8, 0.4) * 0.5, start)
        elif bass_style == "pulse":
            for k in range(8):
                d = beat / 2
                m = root - 12 + (7 if k in (3, 7) else 0)
                tone = lp_fft(osc(midi(m), d, "saw"), 700) * env(int(d * SR), 0.003, 0.18, 0.3, 0.05)
                mix_at(buf, tone * 0.55, start + k * d)
        elif bass_style == "walk":
            for k, iv in enumerate([0, 0, 7, 5]):
                d = beat
                tone = lp_fft(osc(midi(root - 12 + iv), d, "tri"), 900) * env(int(d * SR), 0.005, 0.3, 0.4, 0.1)
                mix_at(buf, tone * 0.5, start + k * beat)
        # arpeggio
        steps = len(arp_pattern)
        step_d = bar / steps
        for k, idx in enumerate(arp_pattern):
            if idx is None:
                continue
            m = tri[idx % 3] + 12 * (arp_oct + idx // 3)
            mix_at(buf, pluck(midi(m), min(1.2, step_d * 3), 0.7) * 0.32, start + k * step_d)
        # optional lead melody (list of (beat_offset, semitone over root, length_beats)) on odd bars
        if lead and b % 2 == 1:
            for off, iv, ln in lead:
                d = ln * beat
                m = root + 24 + iv
                tone = (osc(midi(m), d, "tri") + osc(midi(m) * 2, d, "sine") * 0.2) * env(int(d * SR), 0.02, 0.2, 0.5, 0.15)
                mix_at(buf, tone * 0.22, start + off * beat)
        # drums
        if drums:
            for k in range(16):
                pos = start + k * beat / 4
                if drums == "combat":
                    if k in (0, 6, 8, 11):
                        mix_at(buf, kick() * 0.85, pos)
                    if k in (4, 12):
                        mix_at(buf, snare() * 0.45, pos)
                    if k % 2 == 0:
                        mix_at(buf, hat() * 0.22, pos)
                elif drums == "boss":
                    if k in (0, 3, 6, 8, 10, 11, 14):
                        mix_at(buf, kick() * 0.9, pos)
                    if k in (4, 12):
                        mix_at(buf, snare() * 0.55, pos)
                    mix_at(buf, hat(0.04, 8000) * (0.25 if k % 2 == 0 else 0.12), pos)
                elif drums == "soft":
                    if k in (0, 10):
                        mix_at(buf, kick(0.3) * 0.35, pos)
                    if k % 4 == 2:
                        mix_at(buf, hat(0.06, 6000) * 0.12, pos)
    # fold tails into the start, then add a looping reverb
    body = buf[:n].copy()
    body[: len(buf) - n] += buf[n:]
    body = reverb(body, 2.2 if verb else 1.0, 0.32 if verb else 0.15, wrap=True)
    save(name, loop_xfade(body), peak)


def loop_xfade(x, seconds=0.04):
    """Crossfade the end of a loop into its start and trim, so playback wraps with no click."""
    m = int(seconds * SR)
    ramp = np.linspace(0, 1, m)
    y = x[: len(x) - m].copy()
    y[:m] = x[:m] * ramp + x[len(x) - m:] * (1 - ramp)
    return y


def music():
    # Title: slow, wistful (D minor), music-box arpeggio over pads
    track("music_menu", 68, 8, [(50, "m"), (46, ""), (41, ""), (45, "")],
          [0, None, 1, 2, None, 1, 3, None], 1, "drone", None, 1100, True,
          lead=[(0, 7, 1.5), (1.5, 5, 0.5), (2, 3, 2)], peak=0.75)
    # Map / events: hopeful wandering (A minor -> C)
    track("music_map", 88, 16, [(45, "m"), (41, ""), (48, ""), (43, "")],
          [0, 1, 2, 1, 3, 2, 1, 2], 1, "walk", "soft", 1500, True,
          lead=[(0, 4, 1), (1, 7, 1), (2, 9, 1), (3, 7, 1)], peak=0.75)
    # Combat: driving (E minor), pulse bass + kit
    track("music_combat", 124, 16, [(40, "m"), (36, ""), (43, ""), (38, "")],
          [0, 1, 2, 3, 2, 1, 0, 1, 0, 1, 2, 3, 4, 3, 2, 1], 0, "pulse", "combat", 1800, False,
          lead=[(0, 7, 0.5), (0.5, 10, 0.5), (1, 12, 1), (2.5, 10, 0.5), (3, 7, 1)], peak=0.8)
    # Boss: dark and heavy (C minor with a flat-six lift)
    track("music_boss", 136, 16, [(36, "m"), (32, ""), (36, "m"), (35, "")],
          [0, 3, 1, 3, 2, 3, 1, 3, 0, 3, 1, 3, 2, 4, 3, 1], 0, "pulse", "boss", 1300, False,
          lead=[(0, 12, 0.75), (0.75, 11, 0.25), (1, 8, 1), (2, 7, 2)], peak=0.82)


if __name__ == "__main__":
    sfx()
    music()
