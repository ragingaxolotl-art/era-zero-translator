"""Read quarter-beat pitch groups from a recording of the translator's reference voice.
Input is mono or stereo PCM audio only. The browser's reference tempo is 120 BPM.
"""
import argparse
import json
import math
import wave

import numpy as np
from scipy.signal import resample_poly

RATE = 12000
STEP = RATE // 8
PITCHES = np.arange(25, 113)
FREQUENCIES = 440 * 2 ** ((PITCHES - 69) / 12)


def read_pcm(path):
    with wave.open(path, 'rb') as audio:
        rate = audio.getframerate()
        channels = audio.getnchannels()
        frames = audio.getnframes()
        if audio.getsampwidth() != 2 or channels not in (1, 2) or not 8000 <= rate <= 192000 or frames > rate * 300:
            raise ValueError('Use a 16-bit mono or stereo PCM WAV under five minutes')
        x = np.frombuffer(audio.readframes(frames), dtype='<i2').reshape(-1, channels).mean(axis=1) / 32768
    gcd = math.gcd(rate, RATE)
    return resample_poly(x, RATE // gcd, rate // gcd)


def pitch_frames(path, sensitivity):
    signal = read_pcm(path)
    block = 60
    rms = np.sqrt(np.mean(np.pad(signal, (0, -len(signal) % block)).reshape(-1, block) ** 2, axis=1))
    floor = np.quantile(rms, .12)
    loud = np.quantile(rms, .90)
    if loud < max(.0001, floor * 2):
        raise ValueError('A clear pitched performance could not be isolated')
    activity = rms > max(loud * .15, floor * 3)
    sustained = np.correlate(activity.astype(int), np.ones(6), mode='valid')
    if not np.any(sustained == 6):
        raise ValueError('No sustained note onset')
    start = max(0, int(np.argmax(sustained == 6)) * block - int(RATE * .012))
    # Sample the stable middle of each beat subdivision, away from attacks and room tails.
    left, right = round(.032 * RATE), round(.118 * RATE)
    width = right - left
    time = np.arange(width) / RATE
    window = np.hanning(width)
    phase = 2 * np.pi * FREQUENCIES[:, None] * time
    basis = np.stack((np.cos(phase), np.sin(phase)), axis=1)
    projections = basis * window
    norms = np.linalg.inv(projections @ basis.transpose(0, 2, 1))
    # Small loudspeakers attenuate the deepest boundary notes. A triangle wave also
    # puts energy at 3f and 5f. Require both partials above measured room noise.
    low_midi = np.arange(28, 49)
    low_hz = 440 * 2 ** ((low_midi - 69) / 12)
    partials = np.exp(-2j * np.pi * np.outer(np.r_[3*low_hz, 5*low_hz], time)) * window
    def harmonics(z):
        return (np.abs(partials @ z) * 2 / window.sum()).reshape(2, -1)
    samples = [signal[i:i+width] for i in range(0, max(0, start-width), width//2)]
    background = np.quantile([harmonics(z) for z in samples], .80, axis=0) if samples else np.zeros((2,len(low_midi)))
    frames = []
    threshold = max(.000035, floor * 2.4, loud * .035)
    for at in range(start, len(signal) - right, STEP):
        fragment = signal[at + left:at + right].copy()
        fragment -= fragment.mean()
        level = np.sqrt(np.mean(fragment ** 2))
        selected = []
        if level > threshold * sensitivity[0]:
            initial = None
            for _ in range(3):
                dots = projections @ fragment
                coeff = (norms @ dots[:, :, None])[:, :, 0]
                scores = np.sum(dots * coeff, axis=1)
                if selected:
                    scores[[i for i, _ in selected]] = 0
                i = int(scores.argmax())
                amp = float(np.linalg.norm(coeff[i]))
                if initial is None:
                    initial = amp
                if amp < max(threshold * 1.05, initial * .24):
                    break
                selected.append((i, amp))
                fragment -= coeff[i] @ basis[i]
        frames.append(sorted(int(PITCHES[i]) for i, _ in selected))
        if not frames[-1] and floor > loud * .02 and level > threshold * .25:
            measured = harmonics(signal[at+left:at+right])
            excess = np.maximum(0, measured - background)
            evidence = np.minimum(excess[0], sensitivity[1] * excess[1])
            peak = int(evidence.argmax())
            if evidence[peak] > max(.000045, floor * sensitivity[2]):
                frames[-1] = [int(low_midi[peak])]
    while frames and not frames[-1]:
        frames.pop()
    return {'profile': 'EZ-COMPACT-REFERENCE-AUDIO-1', 'unit_seconds': STEP / RATE,
            'onset_seconds': start / RATE, 'frames': frames}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('recording')
    args = parser.parse_args()
    results = []
    for settings in [(1.0, 1.8, .25), (.80, 2.5, .20)]:
        candidate = pitch_frames(args.recording, settings)
        if candidate not in results:
            results.append(candidate)
    print(json.dumps(results))
