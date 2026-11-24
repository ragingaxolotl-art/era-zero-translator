# Ordinary clause time words — November 23, 2026

Sentences such as “Nora saved the file yesterday” and “Save the file now” now compose through the normal whole-sentence flow. The parser separates the time phrase before recognizing the command or object. This extends existing verbs and descriptions; it does not add an entry for each example. The full translator and general recorded-audio recovery remain unfinished.

## Meaning and compatibility

Leading yesterday/today/tomorrow/now followed by a comma, and lowercase trailing time words, reuse the existing previous-day/current-day/next-day/speech-time frames. Supported active and passive sentences, questions, commands, descriptions, destinations and period-separated references retain their earlier predicates and roles. Yesterday resolves an otherwise ambiguous past/present put form to past. Tense, negation, ongoing aspect and runtime 0/1/2 remain separate.

New modal-time readings ask whether the date concerns the event/state or the ability, possibility or need. Both choices preserve ordered scope in the actual score. “Nora cannot save the file tomorrow” can retain negation outside ability while placing tomorrow inside the ability, or put tomorrow outside that whole negative-ability claim. The decoder independently recovers the selected order. Another relationship remains unresolved.

Every earlier accepted parse runs first. Dated stored/closed states, trailing-now actions, names such as Today, quoted names, personal meanings and existing state-change guards remain reusable. Earlier accepted modal state/day/now conventions are preserved; this does not claim to unify the time behavior of every parser. Calendar day means a day relative to speech date, not an encoded absolute date or playback date.

There are **no new roots, compounds, sense records or musical frames**: 324 roots, 124 compounds and 607 English senses remain. See the [semantic review](../reviews/ordinary_time_2026_11_23.md).

## Executed checks

The [focused suite](ordinary_time_2026_11_23/focused-tests.txt) passes **124 independently recovered melody/chord pairs**, with separate expectations for predicates, roles, references, ordered scopes, speech act and runtime. Leading and trailing placements produce identical performances for equivalent readings. Twenty-four frozen older day/state/name performances retain their exact melody/chord hashes and meanings. The existing [placement suite](ordinary_time_2026_11_23/placement-regression.txt) also passes; its earlier unsupported yesterday fixture now tests the still-unsupported yesterday morning form.

[Eight post-implementation combinations](ordinary_time_2026_11_23/heldout-combinations.json) check additional adjective attachments, maintained state, a destination description, negative ongoing passive action, ability/necessity scope and neutral references across dated sentences. Their [reproducible checker](ordinary_time_2026_11_23/heldout.mjs) takes the repository path and output path. These are engineering combinations selected after implementation, not an independently sampled language benchmark.

The clean [full regression](ordinary_time_2026_11_23/implementation-regression.json) passes **287 checks** at `bf55e20a0686149b5c7e6e7cbea968d5dee893d8`. All [eight release gates](ordinary_time_2026_11_23/release-gates.json) pass at that same revision. The [Lore integration suite](ordinary_time_2026_11_23/lore-tests.txt) passes **309 tests**, with its navigation, saved definitions and arrangement persistence preserved.

| Browser check, on each local site | Result |
|---|---|
| Layouts at 320, 390 and 768 pixels | 24 passed |
| Actual downloaded melody/chord scores independently recovered | 16 passed |
| Other-meaning/time choices remain unresolved | 6 passed |
| Unsupported constructions offer no whole-song action | 9 passed |
| Keyboard time selection and Meaning details disclosure | 3 passed |
| Changed input clears the preceding result | 24 passed |
| Visible removal clears the exported song line | 8 passed |

The [main-site](ordinary_time_2026_11_23/browser-primary.json) and [Lore](ordinary_time_2026_11_23/browser-lore.json) runs exercise consecutive translations on the same page. All 16 exported performance hashes match between sites. Decoding receives MIDI and the public dictionary, without original English or a hidden semantic graph. Compact scores have simultaneous pitches and are **12.30–19.28% shorter** on these examples using the existing arrangement. These are symbolic-score and Chromium viewport checks, not microphone or physical Safari/iPhone checks.

## Remaining boundaries and publication

New date attachment to linked clauses or quantified subjects needs a further scope decision. Multiple nested modals, multiple time phrases, precise/numeric dates, morning/evening, perfect events, unsupported complements and comparative/calendar constructions remain outside this increment. Missing objects still need their referents; extra words and unavailable meanings do not disappear to obtain a song. The broader [completion plan](../docs/full-translator-next-steps.md) remains open.

Published through [translator PR 35](https://github.com/ragingaxolotl-art/era-zero-translator/pull/35) and [Lore PR 35](https://github.com/ragingaxolotl-art/cyber-pet-lore/pull/35). The [translator deployment](https://github.com/ragingaxolotl-art/era-zero-translator/actions/runs/45307744841) and [Lore deployment](https://github.com/ragingaxolotl-art/cyber-pet-lore/actions/runs/45307793314) both succeeded on their first attempts, at merges `de8e6876e475b25db2ad8706a76e134cf4f5932a` and `653a7d3daa99ed71faa56f08a3837edb2279f523`.

The [public translator](ordinary_time_2026_11_23/public-primary.json) and [public Lore](ordinary_time_2026_11_23/public-lore.json) each passed the same 24 layouts, 16 downloads, six alternative choices, nine unsupported cases, three keyboard checks, 24 stale-result checks and eight queue removals. All 16 downloaded hashes match both local sites and one another. The final source `094df973b319b61827b8af5bdd9482ee80cd5f7d` differs from the fully tested core only in documentation, evidence and the document manifest. Final Lore integration changes only that manifest and provenance; its [six final time/cache checks](ordinary_time_2026_11_23/final-lore-integration.txt) also pass. These publication checks do not broaden the declared language or audio boundary.
