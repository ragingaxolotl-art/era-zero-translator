# Era Zero Translator Workbench

Public browser release: **https://ragingaxolotl-art.github.io/era-zero-translator/**

This repository contains both the full canonical Ruby application/API and a deterministic browser-native GitHub Pages release.

## Hosted release

The Pages build runs entirely in the browser. Its default interface accepts ordinary English sentences—no state brackets or controlled syntax required—and infers inflections, questions, commands, negation, and the ordinary positive state. Genuine polysemy is surfaced for the user instead of guessed. It includes all 436 indexed senses and precomputed canonical resolution artifacts for all 324 atoms and every closed approved compound: 351 direct targets × 3 runtime states × 5 speech acts = 5,265 exact variants. Semantic IR, EZF-1, SVG, MIDI, reference-tone preview, and integrity-checked EZB-1 exchange are available without a server.

Strong contextual cues choose the applicable indexed sense automatically—for example, spatial `go` in “Go home,” data transfer in “Send the file,” and communicative expression in “Send the message.” A resolved result exposes and plays its complete sound construction: family prefix/opening, full carrier, address path, optional recognition checksum, runtime ending, and sentence contour. Recognition and slower-learning modes add a deterministic 2–5-note root identity phrase; strict mode preserves the original canonical performance byte-for-byte.

The workbench is organized into Translator, Conversation, Dictionary, and Documents views. All 436 indexed options remain present rather than being hidden behind a candidate cutoff. The Dictionary exposes all 324 roots, 28 compounds, structural and grammar routes, and documented gaps through family/type filtering, a meaning-rich jump selector, and a detailed generated-form inspector. Its DBA concept-intake checker routes unfamiliar concepts without silently creating meanings. The Documents view indexes every tracked specification, lexicon, migration, semantic review, report, test, example, and source-provenance record.

Any English phrase may be entered. The word-matching panel preserves every word in order, recommends the strongest indexed atom, compound, grammar route, Semantic-IR route, or gap, and allows the user to choose another indexed reading. English-only function words make no atomic claim. Unfamiliar content terms are preserved as deterministic EZNAME phonemic labels and are never silently dropped or promoted into fake canonical meanings.

One approved compound has open semantic slots. Because its arguments are arbitrary canonical lexical occurrences, the static release reports that boundary explicitly and routes full role binding to the Ruby API rather than fabricating or constraining an argument. Advanced controlled-English structural templates also remain in the full local compiler.

The browser also includes the experimental **EZNAME-0.1** channel for unfamiliar nouns and proper names. It estimates an editable phoneme sequence, maps every phoneme to a framed deterministic tone pair, and can add an optional instance signature so two specific objects with the same label remain distinct. EZNAME is a nonsemantic label and never creates or modifies a canonical Era Zero meaning.

Every canonical root and indexed/game-story English sense is covered by the lexical/POS metadata audit. English senses carry noun, verb, adjective, or other syntactic tags; canonical roots retain entity-, process-, or relationship-like semantic affordances rather than being forced into one English part of speech. See `docs/RECOGNITION_AUDIO_AND_CONCEPT_INTAKE.md`.

Rebuild and audit the Pages artifact:

```sh
ruby tools/build_pages_release.rb
node tools/validate_pages_release.mjs
node tools/audit_full_translator.mjs
```

GitHub Actions reruns the browser audit, the canonical product audit, and then deploys `pages/`.

The workbench is the local, user-facing release of the canonical Era Zero translator. It analyzes ordinary English conservatively, displays ranked senses and ambiguity evidence, collects explicit runtime/speech-act/role choices, and resolves the selected reading through controlled English, Semantic IR, EZF-1, accessible SVG, and Standard MIDI.

## Start

From the project root:

```text
bin/era-zero-workbench
```

Open `http://127.0.0.1:8787`. Set `ERA_ZERO_PORT` to choose another port. The server binds to localhost by default and sends no telemetry.

## What the interface guarantees

- It never silently chooses the first English sense.
- Runtime state, lexical meaning, modality, negation, aspect, and time remain separate.
- Documented gaps remain visible.
- Open compound roles must be filled explicitly.
- Successful resolution visibly confirms exact decoder round trip.
- Every export bundle is integrity checked and versioned.

The workbench provides an English-first mode plus optional advanced exact syntax, ranked candidate inspection, plain-language truth and speech-act controls, dynamic compound-role fields, Semantic IR/EZF inspection, reference-tone preview, SVG/MIDI download, and EZB-1 import/export.

## Command-line interfaces

```text
ruby tools/translate_general_english.rb 'leave [1]'
ruby tools/compile_controlled_english.rb 'QUESTION "active destination" [1].'
ruby tools/generate_presentation.rb formal.json output/utterance
```

## Audit

Run the product audit and the complete language regression:

```text
ruby tools/validate_product_application.rb
ruby tools/regress_current_state.rb
```

The product audit covers API contracts, error paths, all reviewed indexed senses, ambiguity, gaps, compound roles, exact round trips, SVG/MIDI output, exchange-bundle corruption, UI accessibility markers, and canonical fingerprints. The full translator audit adds a broad phrase matrix, word-matching invariants, complete dictionary fields, document-manifest integrity, source links, and phonemic-label determinism. See `docs/PRODUCT_AUDIT.md` and `docs/PRODUCT_GOAL_AND_FULL_TEST_PLAN.md` for the release criteria.

## Scope

This is a deterministic indexed translator, not a statistical paraphrase model. English outside the 436-sense index is retained through the nonsemantic phonemic-label channel, but that fallback is not presented as a semantic translation. Structural and grammar senses can require a future richer composition UI. Those outcomes are honest limitations, not failures to be hidden by guessing.

Source and conversation provenance is recorded in `docs/SOURCE_PROVENANCE.md` and `spec/source_provenance.yaml`.
