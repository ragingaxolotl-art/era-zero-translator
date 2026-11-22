# DBA language and music audit — November 22, 2026

**Audit complete. Full translator incomplete.** The existing vocabulary, compound builder, sentence grammar and musical forms are reusable. The next work is to preserve meaning consistently across sentence constructions, expand those constructions and missing senses in dependency order, and shorten repeated musical structure. Adding more English aliases alone cannot do that.

This audit changes documentation and the inventory report's misleading completion labels, and adds evidence and an isolated musical experiment. It does not change the deployed translator, its 324 roots, 107 approved compounds, 560 indexed English senses, saved definitions or existing musical profiles. The [implementation plan](../docs/full-translator-next-steps.md) states the work and acceptance evidence still required.

## What was inspected

- Translator `0e90475565a5fe39f0cacf4c0281a48cee3cec65` and Lore `e4c50f5351a86bf903f3d8b3caa289bcab8a10dc`, in separate SSD worktrees. Lore vendors translator implementation `0c33bcb100f457987c0c7c30a492202d9ce33115` with its integration changes.
- The [Google language reference](https://docs.google.com/document/d/1btnSrT37YJt1aD4gXGtJBO8e3ZRG6COYmFLaRkykHA8), [CPP Lore](https://docs.google.com/document/d/1yoUj86AxJ_yy_Qiddgyov2nBLA8ObSNoDV3rXJVuyi8), [Stories Archive](https://docs.google.com/document/d/1Wp4V6hFuBwC-Fw7MBAPFL2rGFvUFAPjBFBFql_vdhnM), the [original ChatGPT audit](https://chatgpt.com/space/page_21c6ce0da1a88191abff53c0b13441f3), relevant prior chat decisions, current specifications, semantic reviews, source reconciliation records, release documentation and test implementations. Targeted Drive and Pages searches were also checked. Revision identifiers are in the [source inventory](full_audit_2026_11_22/source_inventory.json).
- Whole English input through the actual browser controls at 390 pixels, downloaded melody and compact-chord MIDI, independently recovered meanings, exact pitches/timing, one fresh clean synthesized WAV, and a separate proposed musical profile.

This is a comprehensive project audit, not an assertion that every private historical conversation, deleted document, English construction, device or room has been examined. The broad historical recovery and unrestricted-language goals remain open. The 47 review documents absent at their cited paths remain absent after checking all 198 cited paths. This does not revoke accepted roots or justify fabricating approval records. See [provenance audit](root_review_provenance_audit.json).

## Sentence evidence

The [58 intended readings](../tests/full_audit_2026_11_22_intentions.json) were written before running them: 46 authored probes and 12 verbatim manuscript excerpts. They cover states, actions, adjectives, role reversal, tense, negation, modality, questions, conditionals, temporal relations, quantification, reference, location, new vocabulary, information operations and culturally important expressions. Expected meanings did not enter the decoder. Clarification answers came from the recorded intentions and manuscript context.

These are deliberately difficult diagnostic examples, not a representative sample of English. Six exact inputs already appear in baseline material; the remaining 52 lack an exact whole-input match in the checked baseline directories. This does not make them independently held-out semantic tests. Engineering adjudication was performed after observation against the frozen intentions. [Overlap check](full_audit_2026_11_22/baseline_overlap.json) · [Raw browser observations](full_audit_2026_11_22/initial.json) · [Clarifications](full_audit_2026_11_22/clarified.json) · [Every case and finding](full_audit_2026_11_22/case_ledger.md)

| Outcome | Cases |
|---|---:|
| Intended meaning recovered directly | 13 |
| Intended meaning recovered after clarification | 3 |
| Appropriate unresolved-pronoun question | 1 |
| Undefined verb/adjective correctly requires a definition | 2 |
| Whole intended meaning unsupported | 37 |
| Song carries a changed meaning | 1 |
| Song produced but general meaning decoder cannot recover it | 1 |

The two passing manuscript excerpts are existing supported examples. The nine manuscript inputs without an exact baseline match all stop. This is evidence of limited generalization, not a percentage estimate for all stories. [Adjudication and explicit positive checks](full_audit_2026_11_22/adjudication.json)

The retained **250 implementation checks passed**. Separately, the recent **44 state/adjective sentence readings** passed in melody and chords, and **all 324 roots × 3 endings** retained 972 distinct compact performances with exact note/timing inversion. The refreshed dictionary identity audit covers **431 identities × 3 endings = 1,293 performances**, with no exact collisions at its declared anchor and contour. The recent sentence checks are included in the deployment workflow, even though they are separate from the 250-command runner. These are valuable implementation guarantees; they do not establish general language coverage. [Regression results](full_audit_2026_11_22/regression.json) · [Dictionary identity results](dictionary_musical_identity.json)

## Highest-priority findings

1. **A fallback can lose modality, time and negation.** “If Nora opens the hatch, Mira will leave” becomes a conditional possible departure. Directed follow-up also turns “will not leave” and “cannot leave” into possible departure, losing the negative. Waiting and lifting preserve those distinctions. `predicate()` in `pages/story_readings.mjs` creates a temporary “might” phrase, corrects `syntax.scopes`, then its dictionary fallback returns the fallback's scopes. The fix must cover that routing class, including preferences, rather than special-case one sentence. Four failures were reproduced in a separate 24-probe follow-up; four simple leaving probes were not composed by that particular parser, so they are not classified as whole-UI failures. [Scope probes](full_audit_2026_11_22/scope_followup.json)
2. **Playable does not always mean independently decodable.** “I love you. [2]” offers Add to song and exports music, but the shared general meaning decoder reports no unique supported interpretation. The approved love entry and poetic num reading still exist. The missing part is verified whole-sentence recovery through the normal path. Do not redefine love or num to make the check pass. [Case audit-44](full_audit_2026_11_22/initial.json)
3. **Vocabulary and grammar do not generalize together.** “The tired worker lowered the empty box” stops at *empty*. “The program remembers the route,” “Nora copied the record” and “Nora deleted the record” stop despite related existing vocabulary or specialized constructions. “Both workers,” “only Nora,” the third room, *until*, embedded knowledge/belief and several common modification patterns also stop. The current dictionary is not a whole-sentence parser.
4. **Unknown words invite unrelated substitutions.** Pulling and dropping offer find/search/see/care. Undefined *glimmerwise* offers sleep/awake/well/sick. Automatic invention is correctly blocked, but these choices make it easy to replace the intended meaning. Physical-action confirmation buttons also use another sentence as their label (“Mira pushed the gate”), even when the input has different participants.
5. **The narrow phone view really breaks.** Seven diagnostic pickers widen a 390-pixel document to 803–813 pixels. The long native select expands its candidate card. This reproduces the narrow content with a large empty area visible in the user's screenshot. Fix the layout and use concise options with a separate explanation. [Measured layout](full_audit_2026_11_22/mobile-layout.json) · [Screenshot](full_audit_2026_11_22/mobile-picker.png)
6. **Completion documents can overstate their evidence.** The older “Full Project Completeness” PASS is an inventory/manifest and migration-stage check. It even reported planned gates complete while the broader translator plan explicitly left its seven phases open. This audit corrects that report and its generator to say **Release Inventory and Source-Reference Consistency**, and explicitly excludes full-translator certification. The original Google reference, the ChatGPT first-release page and some repository counts also describe different dated releases. Use the current audit and explicit release boundaries.

## Why the music repeats and takes so long

Roots already have two compact chords: one for the family, one for the address, followed by the appropriate ending. That makes distinct roots shorter. It does not shorten all the surrounding material:

- The story profile declares its participants before its events. The complete name/noun sound label is played before the main action root.
- Fixed grammar markers remain sequences of four to eight sixteenth notes plus boundaries.
- Conventional compounds carry repeated 11-note identity frames around expanded components. Personal-word frames can have 36 notes per boundary. Nested words therefore retain considerable framing and expansion cost.
- The question contour comes at the end, and some event relationships are serialized after the events. A meaningful distinction can be audible very late.

In this diagnostic, the first root begins **23.625 seconds** into “Nora kept the hatch closed,” and **37.75 seconds** into the Latch two-sentence passage. Those timings precede the first root, not necessarily the first meaning: participant and grammar information is already being played. “Nora kept the hatch closed” and its question share **50.75 seconds** before their first differing attack. The *before/after* pair shares **58.25 seconds**. Happy/sad differs after **0.875 seconds**, so repetition is not uniform across all words. [Measurements](full_audit_2026_11_22/music_summary.json)

## Musical experiment and decisions

A research profile replaces each of **539 fixed grammar frames** with two four-voice chords: a major or minor triad with a doubled root. A short audible header identifies the experimental profile. Existing root chords, names, compound markers, runtime tails and the final contour remain intact. Its decoder gets the performed MIDI and a frozen public alphabet, expands it back to the original notes, and uses the existing meaning decoder. It receives no English, expected meaning or original score metadata. This is an isolated experiment, absent from the deployed player and decoder.

Both sixteenth-note and eighth-note chord attacks were tested. All **3,234 alphabet cases** (539 frames, three anchors, two rhythms) restore exactly. On **18 actual sentence performances**, both variants restore the original pitches, timings and rests; the 17 meanings supported by the existing inverse also restore. The love performance still lacks a supported general semantic inverse. Four selected note deletion/detuning/duration/truncation corruptions were rejected. This is not a general error-correction guarantee. [Experiment code](../experiments/frame_chords.mjs) · [Frozen alphabet](../experiments/frame_chords_v1.json) · [Results](full_audit_2026_11_22/music_experiment.json)

| Input | Original melody | Current compact chords | Experimental sixteenth-note frames |
|---|---:|---:|---:|
| The hatch stayed closed. | 47.375 s | 34.875 s | 29.875 s |
| Nora kept the hatch closed. | 66.000 s | 51.000 s | 43.875 s |
| Nora is happy. | 27.000 s | 22.000 s | 21.125 s |
| Latch found the result. It found the context. | 75.750 s | 65.750 s | 54.375 s |

The median reduction relative to current chords is **14.4%** with sixteenths and **5.1%** with eighths. At the present 120 BPM, a quarter note lasts 500 ms, an eighth 250 ms and a sixteenth 125 ms. Existing grammar already uses sixteenths; using that word alone does not identify a new encoding. Rhythm and chords must have explicit, nonconflicting roles.

Full listening examples of “The hatch stayed closed”: [original melody](full_audit_2026_11_22/audio/hatch-melody.wav), [current chords](full_audit_2026_11_22/audio/hatch-chords.wav), [experimental grammar chords](full_audit_2026_11_22/audio/hatch-frame-16th.wav). These use the current reference voice, with the same per-tone gain for comparison; WAVs include one second of rendering margin. They are synthesized examples, not room recordings or a listener-preference study.

| Technique | Decision from this audit |
|---|---|
| Existing family/address chords | Keep. Their identities and inversion are verified; preserve all current roots and endings. |
| Short grammar chords and rhythm | Promising candidate, not ready to deploy. Modest overall saving; new audio decoding and more corruption tests are required. |
| Short participant motifs and shared introductions | High-value next experiment. Preserve the first full identity and audible reference bindings; define reset/random-access behavior across song lines. Never depend on hidden English to recover identity. |
| Short forms for approved compounds | Investigate before adding more layers. A versioned dictionary reference could avoid repeatedly playing a full nested definition, provided the complete identity, required roles and scope remain recoverable. Keep the existing expanded form available. |
| Event-first musical syntax; earlier speech-act cues | Investigate to make the important distinction arrive earlier. English word order is unnecessary. Forward references and scope need a verified new serialization, not decorative reordering. |
| Phrase boundaries and calibration | Preserve current boundaries. A compact version/anchor/tempo preamble and resynchronization points may help future recorded audio; test the overhead and recovery benefit. |
| Checksum or error correction | Add only after measuring actual confusions. An audible checksum can detect errors; it does not itself correct them. Current four mutation tests are insufficient. |
| Different instruments, dynamics, ornaments | Use as expression only while they remain meaning-neutral. Do not make essential meaning depend on a timbre or loudness the microphone cannot reliably recover. |
| More overlapping voices or faster subdivisions | Defer without evidence. Sixteenth-note four-voice frames already require a new detector. Global speed-up or denser chords are not proven solutions. |

## Audio evidence and its boundary

One fresh **clean Web Audio WAV** of the current compact hatch sentence was decoded using only its WAV path and public language/reference-voice rules. Afterwards, all **183 notes and their timing**, and the recovered meaning, matched the separately exported MIDI. This is a real waveform-to-meaning check, but it is not a speaker-to-microphone test. [Recovered audio meaning](full_audit_2026_11_22/audio_current_decoder.json) · [Comparison](full_audit_2026_11_22/music_summary.json)

The current audio decoder **rejects the new experimental grammar-chord WAV**. That is expected for an unsupported profile and is a reason not to deploy it yet. Exact MIDI inversion does not establish audio decoding. The earlier [room report](field_repair_room_audio.json) records four laptop speaker-to-microphone performances, two used in development and two held out in that session. Its captures were kept local and were not freshly replayed in this audit. Multiple devices, rooms, voices, transposition, tempo drift, interruption and general recorded-audio recovery remain unverified. The earlier user-approved first release deferred that wider work; the current audit preserves it in the longer plan.

## Keeping DBA's language and style

The language source fixes family identity, ternary addresses and separate runtime 0/1/2. The lore describes precise semantic content with expressive performance layers, identity, relationship, memory, permission and unresolved possibility. Open Keeping is specifically more than storage or access permission. Love's approved unfinished-becoming reading must remain attached to that cultural meaning; it is not a universal reinterpretation of every [2]. These are constraints on translation, not decorations to add after reducing the message.

Keep neutral participant identities and references; grammatical gender is not required. Preserve distinct desire, need, permission, ability, uncertainty and agency. A dormant lexical meaning can be validly asserted at runtime [1]. Never use the three runtime states as low/medium/high, good/neutral/bad, or past/present/future.

**No additional 27-root family is justified by this audit.** Most demonstrated failures need grammar, better use of existing approved meanings, or defined conventional compounds. For any genuinely missing distinction, first show that current roots and accepted conventions cannot express it; then review a primitive proposal with contrasts and compatibility evidence. Build reusable meanings before dependent compounds, and reuse those compounds by their stable definitions. Arbitrary nesting cannot create a meaning that was never defined. The [ordered plan](../docs/full-translator-next-steps.md) applies that rule to the failures above.

## Reproduction

Use Node 22+ and a Playwright/Chromium installation. Set `PLAYWRIGHT_MODULE` and `CHROME_PATH` if they are outside the normal runtime. For WAV decoding, Python needs NumPy and SciPy. Serve `pages/` at `http://127.0.0.1:8766/` in a separate terminal.

```sh
python3 tools/validate_translator_completion.py --node /path/to/node --report reports/full_audit_2026_11_22/regression.json
node tests/state_adjective_sentences_test.mjs
node tests/compact_song_chords_test.mjs
node tools/audit_full_language_2026_11_22.mjs
node tools/audit_full_language_2026_11_22.mjs http://127.0.0.1:8766/ audit-05,audit-06,audit-32,audit-35,audit-48 tests/full_audit_2026_11_22_answers.json
node tools/grade_full_audit_2026_11_22.mjs
node tools/audit_scope_routing_2026_11_22.mjs
node tools/audit_frame_music_2026_11_22.mjs
node tools/render_audit_examples_2026_11_22.mjs
node tools/decode_compact_recording.mjs reports/full_audit_2026_11_22/audio/hatch-chords.wav
node tools/decode_compact_recording.mjs reports/full_audit_2026_11_22/audio/hatch-frame-16th.wav
```

The last command currently fails with “The recording does not give one complete, supported musical reading.” The frozen corpus and alphabet preparation scripts deliberately refuse to overwrite an existing version. Keep the original intentions intact when repairing the implementation; add fresh, independently intended examples before claiming broader coverage.
