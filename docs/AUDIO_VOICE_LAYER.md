# Era Zero Audio Voice Layer

Status: implemented presentation layer 1.0  
Canonical semantic changes: 0

The translator can perform the same canonical pitch, timing, runtime ending, and
sentence contour through several selectable synthesized voices:

- Era Zero tones — the original clear reference sound;
- Ocarina — a soft, nearly pure flute timbre;
- Electric piano — a rounded struck keyboard timbre;
- Synth bell — a bright electronic keyboard timbre;
- Warm organ — a sustained keyboard timbre.

The selected voice is global for canonical performances, character close-ups,
and phonemic-name playback. It changes only oscillator waveform, overtone mix,
filtering, and amplitude envelope. It never changes a note, carrier syllable,
runtime state, contour, viseme, semantic graph, formal identity, or exported
canonical MIDI file.

The browser synthesizes these voices with Web Audio so no licensed sample pack
or network download is required. They are deliberately instrument-like rather
than claims of acoustic instrument emulation.

Each profile includes a short release tail that continues into the existing
inter-note or inter-concept gap. The tail softens the audible boundary without
moving the next note or changing encoded duration. A gentle master limiter
controls overlapping harmonics on small speakers, and stopping or replaying a
performance uses a short fade instead of cutting an oscillator instantly.
