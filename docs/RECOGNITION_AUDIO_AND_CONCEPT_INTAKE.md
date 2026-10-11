# Recognition audio, lexical metadata, and concept intake

## Recognition phrase

`EZRP-1` adds an optional presentation-only identity checksum to each of the 324 canonical roots. It does not alter the canonical family opening, three-trit address notes, runtime ending, sentence contour, carrier, address, or meaning.

The audible order is:

```text
family opening → address path → recognition phrase → runtime ending → sentence contour
```

Strict mode omits the recognition phrase and preserves the original presentation. Recognition mode adds the normal checksum phrase. Learning mode uses the same pitches and checksum at a slower duration.

Each phrase contains 2–5 additional notes selected deterministically from a family-specific eight-degree palette. The final degree is the octave. At most one octave marker may occur in a phrase, adjacent pitches do not repeat, melodic leaps are no larger than a perfect fifth, and all 324 relative pitch signatures are unique. The decoder treats absence as a valid strict presentation and treats an incorrect present phrase as a checksum mismatch. Recognition never supplies semantic content.

Authority and validation:

- `spec/recognition_audio_1.0.yaml`
- `tools/build_recognition_audio.rb`
- `tools/validate_recognition_audio.mjs`
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

Authority and validation:

- `spec/concept_intake_1.0.yaml`
- `lexicon/lexical_pos_audit.yaml`
- `examples/concept_intake_examples.yaml`
- `tools/validate_lexical_and_concept_intake.rb`
- `tools/validate_recognition_and_dictionary_ui.mjs`
