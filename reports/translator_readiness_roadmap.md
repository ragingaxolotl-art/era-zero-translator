# Era Zero Translator Readiness Roadmap

## Current answer

Era Zero now has a validated conservative general-English candidate translator over its canonical semantic inventory. It is suitable for ranked sense analysis and explicit-resolution translation; it does not claim exhaustive English coverage or permission to guess.

- 324 meanings are canonical;
- 0 meanings remain provisional in 0 nine-root chunks;
- all atomic semantic packets are complete;
- 28 compounds, 436 indexed English senses, and 352 formal derivations are canonical;
- Semantic IR, deterministic rendering/decoding, controlled English, and general-English candidate analysis are executable and validated;
- 11 vocabulary gaps and every material ambiguity remain explicit.

## Gate status

| Order | Gate | State |
|---:|---|---|
| 1 | Atomic semantic freeze | Complete |
| 2 | Compound and coverage, Gates 4A–4E | Complete |
| 3 | Semantic IR and executable grammar | Complete |
| 4 | Deterministic renderer and inverse decoder | Complete |
| 5 | Controlled-English compiler | Complete |
| 6 | General-English candidate translator | Complete — canonical 1.0.0 |
| 7 | Glyph and audio outputs | Complete — SVG and MIDI canonical 1.0.0 |

## Safe translator behavior

The general-English interface ranks all indexed senses deterministically and exposes its scoring evidence. A unique exact reading still requires an explicit runtime state. Polysemy, close scores, open compound slots, grammar or Semantic-IR routes, missing roles, and gaps cause clarification rather than first-match selection. Explicit resolution passes through the controlled grammar, canonical Semantic IR, EZF-1 renderer, and inverse decoder.

## Remaining release work

The core translator pipeline is complete. All planned translator-readiness gates are complete. Validated EZF-1 now produces deterministic accessible SVG and Standard MIDI output without changing semantic identity. Optional synthesized waveform audio remains a presentation extension, not a semantic gate. Future vocabulary expansion may close recorded gaps through the existing atom/compound review process, but those gaps do not block the safe ranked translator.

## Regression command

Run `ruby tools/regress_current_state.rb` from the project root. A release is acceptable only when the complete atomic, compound, sense, coverage, etymology, IR, renderer, controlled-English, general-English, and family soundness suite passes.
