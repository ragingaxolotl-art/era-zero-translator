# Physical capture harness

From this folder run `python3 -m http.server 8765 --bind 127.0.0.1`, then open
http://127.0.0.1:8765 in a browser. Press Start to request microphone permission.
Select a generated WAV for optional playback, or play it from a separate device.
Stop after the full audible trailer and download the mono PCM recording.

Decode from the repository root:

```
node tools/decode_recorded_audio.mjs /path/to/era-zero-microphone.wav
```

The page does not upload audio, decode it, or label a recording as successful.
Noise suppression, echo cancellation and automatic gain are requested off; actual
browser/device settings may differ and are displayed during capture. Avoid
headphones for this physical-channel test. Keep source meaning outside the decoder;
compare recovered meaning afterward. This harness has not yet been live-tested.

For an explicitly draft cognitive performance, add `--allow-draft` to the decoder
command. The decoder loads the shared candidate registry; no source sentence or
meaning file is supplied. Canonical performances do not require this flag.
