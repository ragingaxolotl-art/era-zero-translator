# Era Zero Translator Workbench

Public browser release: **https://ragingaxolotl-art.github.io/era-zero-translator/**

This repository contains both the full canonical Ruby application/API and a deterministic browser-native GitHub Pages release.

## Hosted release

The Pages build runs entirely in the browser. Its default interface accepts ordinary English sentences—no state brackets or controlled syntax required—and infers inflections, questions, commands, negation, and the ordinary positive state. Genuine polysemy is surfaced for the user instead of guessed. It includes all 436 indexed senses and precomputed canonical resolution artifacts for all 324 atoms and every closed approved compound: 351 direct targets × 3 runtime states × 5 speech acts = 5,265 exact variants. Semantic IR, EZF-1, SVG, MIDI, reference-tone preview, and integrity-checked EZB-1 exchange are available without a server.

Strong contextual cues choose the applicable indexed sense automatically—for example, spatial `go` in “Go home,” data transfer in “Send the file,” and communicative expression in “Send the message.” A resolved result exposes and plays its complete sound construction: family prefix/opening, full carrier, address path, optional recognition checksum, runtime ending, and sentence contour. Recognition and slower-learning modes add a deterministic 2–5-note root identity phrase; strict mode preserves the original canonical performance byte-for-byte.

The **EZVISEME-1** character view turns that same canonical performance into a synchronized close-up. Its downloadable `.ezviseme.json` rig has a fixed head layer, an independently selectable happy/sad/angry eye layer, and a timed mouth-sound layer. Changing the eyes never changes the sound or mouth sequence. The player sees only the current viseme sound. The rig is presentation-only and does not participate in Semantic IR or formal identity. See [docs/VISEME_PERFORMANCE_LAYER.md](docs/VISEME_PERFORMANCE_LAYER.md).

One approved compound has open semantic slots. Because its arguments are arbitrary canonical lexical occurrences, the static release reports that boundary explicitly and routes full role binding to the Ruby API rather than fabricating or constraining an argument. Advanced controlled-English structural templates also remain in the full local compiler.

The browser also includes the experimental **EZNAME-0.1** channel for unfamiliar nouns and proper names. It estimates an editable phoneme sequence, maps every phoneme to a framed deterministic tone pair, and can add an optional instance signature so two specific objects with the same label remain distinct. EZNAME is a nonsemantic label and never creates or modifies a canonical Era Zero meaning.

The Dictionary now includes a meaning-rich root/compound selector and DBA concept-intake checker. Every root and indexed/game-story sense is covered by the lexical/POS audit: English senses carry parts of speech, while roots retain entity-, process-, or relationship-like semantic affordances. See [docs/RECOGNITION_AUDIO_AND_CONCEPT_INTAKE.md](docs/RECOGNITION_AUDIO_AND_CONCEPT_INTAKE.md).

The **Game and Story profile 0.1** adds conservative routes for Cyber Pet and narrative language without changing the canonical lexicon. Unknown nouns may retain EZNAME labels, pronouns become participant references, and unknown verbs or descriptors now block automatic translation instead of being disguised as names. Narrow English words such as `found`, `hungry`, `tired`, `feed`, and `hurt` may use an existing broader canonical center only with the lost detail shown explicitly. Emotion, play, ingestion, and game-meter concepts remain honest gaps where Era Zero has no approved meaning. See [docs/GAME_STORY_TRANSLATION_PROFILE.md](docs/GAME_STORY_TRANSLATION_PROFILE.md).

Rebuild and audit the Pages artifact:

```sh
ruby tools/build_pages_release.rb
node tools/validate_pages_release.mjs
node tools/validate_viseme_performance.mjs
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

Run the focused 60-phrase game/story audit with the configured Node runtime:

```text
node tools/audit_game_story_translation.mjs
```

The product audit covers API contracts, error paths, all reviewed indexed senses, ambiguity, gaps, compound roles, exact round trips, SVG/MIDI output, exchange-bundle corruption, UI accessibility markers, and canonical fingerprints. See `docs/PRODUCT_AUDIT.md` for the release checklist.

## Scope

This is a deterministic indexed translator, not a statistical paraphrase model. English outside the 436-sense index may return no candidate. Structural and grammar senses can require a future richer composition UI. Those outcomes are honest limitations, not failures to be hidden by guessing.
