# Recognition audio, lexical metadata, and concept intake

## Recognition phrase

`EZRP-1` adds an optional presentation-only identity checksum to each of the 324 canonical roots. It does not alter the canonical family opening, three-trit address notes, runtime ending, sentence contour, carrier, address, or meaning.

The audible order is:

```text
family opening → address path → recognition phrase → runtime ending → sentence contour
```

Strict mode omits the recognition phrase and preserves the original presentation. Recognition mode adds the normal checksum phrase. Learning mode uses the same pitches and checksum at a slower duration.

The browser can export the selected performance as Standard MIDI or a monophonic reference WAV, then import MIDI or a browser-decodable audio file to check the notes against the currently selected canonical formal. It accepts exact strict absence or a correct optional identity phrase; a wrong phrase, missing contour, or other pitch mismatch is rejected. MIDI verification is pitch-exact. Waveform verification detects distinct notes from clean one-voice audio and reports an inconclusive result if it cannot identify a tone. It is **not** a general microphone speech recognizer and does not infer semantic content from an unknown recording. The selected formal remains the sole semantic authority.

Each phrase contains 2–5 additional notes selected deterministically from a family-specific eight-degree palette. The final degree is the octave. At most one octave marker may occur in a phrase, adjacent pitches do not repeat, melodic leaps are no larger than a perfect fifth, and all 324 relative pitch signatures are unique. The decoder treats absence as a valid strict presentation and treats an incorrect present phrase as a checksum mismatch. Recognition never supplies semantic content.

Authority and validation:

- `spec/recognition_audio_1.0.yaml`
- `tools/build_recognition_audio.rb`
- `tools/validate_recognition_audio.mjs`
- `pages/performance_codec.mjs` and `pages/performance_audio.mjs`
- `reports/recognition_audio_validation.md`

## Parts of speech

English parts of speech belong to indexed English senses, not permanently to Era Zero roots. Each root instead has an address-derived semantic affordance:

- entity-like;
- process-like;
- relationship-like.

This allows one permanent semantic center to appear naturally in different English constructions without forcing English grammar into the canonical ontology. `lexicon/lexical_pos_audit.yaml` links every root to ordinary-language tags and every indexed or game/story sense to its POS, surface forms, route, and fidelity.

## DBA concept intake

An unfamiliar concept is routed in this order:

1. reviewed English surface sense;
2. existing canonical atom;
3. existing approved compound;
4. proposed compound requiring semantic review;
5. Semantic IR structure;
6. grammar;
7. explicit vocabulary gap;
8. future-era atomic semantic review.

No automatic match can canonize a root or broaden a definition. Unfamiliar nouns may receive nonsemantic phonemic labels for reference. Unfamiliar verbs and descriptors may not use that label channel to conceal missing meaning.

The website’s Dictionary includes a meaning-rich jump selector, POS-aware records, and a concept-intake checker. The sentence word-matching selector shows the target ID, canonical title, and meaning rather than an unexplained abbreviation.

The concept checker now saves a versioned **local browser review queue**. A proposal must record intended meaning, example context, and part of speech. A reviewer may record triage, semantic review, future-Era consideration, rejection, or approval of a *local English surface mapping* to an existing canonical root/compound. That narrow approval requires a reviewer name, written rationale, collision audit, and explicit confirmation that the canonical invariant definition entails the proposed usage. An approved mapping becomes available to this browser's English analyzer; reopening it deactivates that mapping. Export/import moves the queue between browsers. It does not sync to GitHub, alter source authority, create new roots, approve new compounds, or extend any invariant definition. Formal changes still require the ordinary standards review and migration process.

The phrase corpus now covers 53 new ordinary-language probes, 69 game/story cases, and 22 lore turns. The [coverage audit](../reports/ordinary_language_coverage_audit.md) lists every result and frequency of unresolved actions, descriptors, and documented gaps. These gaps remain review items, not invented roots.

Authority and validation:

- `spec/concept_intake_1.0.yaml`
- `lexicon/lexical_pos_audit.yaml`
- `examples/concept_intake_examples.yaml`
- `tools/validate_lexical_and_concept_intake.rb`
- `tools/validate_recognition_and_dictionary_ui.mjs`
- `pages/concept_intake.mjs` and `tools/validate_concept_queue.mjs`
- `tests/ordinary_language_coverage.json` and `tools/audit_ordinary_language_coverage.mjs`
