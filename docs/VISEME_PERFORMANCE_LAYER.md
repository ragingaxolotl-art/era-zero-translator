# Era Zero character viseme performance

Status: implemented as a presentation-only extension (`EZVISEME-1`).

The translator can now open a close-up character and play the resolved Era Zero tone sequence while the character articulates its carrier syllables. It can also export the compiled performance as a standalone `.ezviseme.json` file. This does not add words, change roots, reinterpret grammar, or modify Semantic IR or EZF identity.

The player-facing close-up is intentionally simple: it labels only the current **viseme sound** (`gi`, `ki`, `nu`, and so on). The pose matching, MIDI note, timing layer, and articulation logic remain inside the compiler output and are not explained to the player.

## What controls what

A musical note cannot determine a mouth shape by itself. The same note can carry `ma`, `ki`, or `nu`, and those syllables require different articulation. The implementation therefore keeps two synchronized channels:

- The canonical performance note controls audible pitch.
- The canonical formal-carrier syllable controls the mouth.
- Pitch may change the surrounding halo, but never selects a viseme.

This separation also makes transposition safe: moving the entire performance to another register changes every frequency while preserving the exact mouth sequence.

## Complete carrier map

| Carrier syllable | Consonant pose | Vowel pose | Visible motion |
|---|---|---|---|
| `ba` | MBP | A | lips close, then jaw opens wide |
| `da` | TDS | A | front tongue, then wide opening |
| `do` | TDS | O | front tongue, then rounded open mouth |
| `ga` | KG | A | back articulation, then wide opening |
| `gi` | KG | I | back articulation, then narrow spread |
| `ki` | KG | I | back articulation, then narrow spread |
| `li` | LN | I | tongue lift, then narrow spread |
| `ma` | MBP | A | lips close, then jaw opens wide |
| `ni` | LN | I | tongue lift, then narrow spread |
| `nu` | LN | U | tongue lift, then tight rounding |
| `si` | TDS | I | front tongue/teeth, then narrow spread |
| `te` | TDS | E | front tongue, then mid-spread mouth |
| `wu` | W | U | rounded glide into tight rounding |
| `ya` | Y | A | palatal glide into wide opening |

`ba` and `ma`, or `ga` and `ya`, can end on the same vowel pose while retaining distinct onset poses. `gi` and `ki` deliberately share the KG/I visible class because a practical viseme system groups sounds that look alike; their acoustic consonants remain different in the carrier.

## Event alignment

Each family-opening note articulates the carrier's family-prefix syllable. The four address-path notes align one-to-one with the four formal-carrier syllables. A runtime ending and sentence contour are tonal grammatical layers rather than new lexical syllables, so the face sustains the most recent vowel nucleus while those notes play.

For a normal voiced event, the onset occupies no more than 75 ms and the vowel occupies the rest. Runtime timing preserves the canonical contrast: state `[0]` has the sharp short ending, `[1]` has the firm return, and `[2]/num` has the sustained ending. Between tones the face returns to REST. The user-facing readout shows the current carrier syllable, viseme label, MIDI pitch, and performance layer.

## Character integration contract

Games may consume the standalone output of `visemeFileFromFormal(formal)` and replace the built-in SVG face with sprites, blend shapes, skeletal mouth poses, or a 3D facial rig. Each cue carries `at_seconds`, `duration_seconds`, `midi_note`, a player-readable `viseme_sound`, and its timed internal poses. Required pose names are `REST`, `MBP`, `TDS`, `KG`, `LN`, `W`, `Y`, `A`, `E`, `I`, `O`, and `U`.

The presentation must not infer meaning from a pose, write viseme data back into the semantic graph, or change a mouth sequence because a pitch was transposed. A game may use note pitch or intensity for eyebrows, glow, head motion, or other non-mouth performance accents.

## Validation

The dedicated validator checks all 324 canonical atoms, the full 5,265 hosted formal variants, every carrier syllable, monotonic cue timing, MIDI-note preservation, identity preservation, and transposition invariance. It runs as part of the full regression suite.
