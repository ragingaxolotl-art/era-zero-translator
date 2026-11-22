# Known words and unsupported sentences — November 22

The translator previously offered a new-word definition picker for **deleted** in “The file was deleted” and “Nora deleted the file from the folder,” and for **copied** in “Nora copied the file to the folder.” Those words already had meanings; the requested voice or additional relationship lacked a composer. Selecting an unrelated root could hide the actual missing work.

Recognition now distinguishes an existing verb/adjective sense from a supported argument construction. When a known predicate lacks a complete sentence reading, the generic alias picker is withheld. The submitted sentence and an explanation appear before the detailed word map. Unfamiliar predicates still offer the reusable word builder. An explicit saved personal definition remains usable only when its form, participant roles and part of speech match. Malformed inflections do not count as newly supported words.

This change preserves every vocabulary meaning, musical encoding and stored song. It does not implement passive voice, perfect aspect, extra source/destination phrases or “only.” These remain visibly unsupported rather than being silently discarded.

## Evidence

- Focused tests cover 14 known unsupported constructions, five missing/malformed words, supported recognition, saved meanings and refreshing the personal lexicon.
- The clean regression at `ccd9e12b31c6a00bc1e590409c3bbc08904df7fa` ran 265 checks: 264 passed, and the asset-version assertion still expected 1.23.0 instead of the new 1.24.0. Its [initial result](sentence_diagnostics_2026_11_22/initial-clean-regression.json) is retained. The version assertion was aligned with the generated release; all [eight release gates](sentence_diagnostics_2026_11_22/release-gates.json), including that audit, subsequently passed at `7cd02888c8ae72e9440d86b9daf9105c202838ea`. No runtime defect or sentence expectation was suppressed to fix that check.
- Each final local browser run passed 21 unsupported-structure layouts, nine missing-word checks and four independently decoded melody/chord song exports at 320/390/768 pixels. The explanation precedes the word map, and editing the input removes stale song controls.
- A separate builder flow passed 21 picker layouts, keyboard interaction, builder save/return, stale-input invalidation and six exported meaning checks.
- Lore passed its catalog build and 210 tests, plus the same final browser checks. The first attempted build command used a nonexistent script; the documented catalog command was then run successfully. This was a command-path error, not an application defect.

Chromium viewport tests do not establish physical iOS/Safari behavior. This UI/parser guard adds no recorded-audio claim. Broader grammar, adjective meanings and ordinary-English coverage remain open in the [completion plan](../docs/full-translator-next-steps.md).
