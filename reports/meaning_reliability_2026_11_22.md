# Sentence meaning and normal-input repairs — November 22

The identified scope-loss bug, missing love inverse and overflowing meaning picker are repaired. The full translator remains unfinished. The [original audit](full_language_music_audit_2026_11_22.md) remains an unchanged record of the earlier build; its diagnostic scores are not scores for this repair.

## What changed

- The common clause parser now reads **will**, **will not**, **can**, **cannot**, **can not**, **might** and **might not** directly. Story fallback verbs and saved dictionary choices no longer inherit a temporary “might” interpretation. Time, ability, negation, aspect, calendar time and nested necessity retain their ordered scopes. The existing ability sound is reused.
- An independent decoder recognizes the approved three-root love compound, its participants, scope and runtime ending. It requires the complete pronunciation, including both qualifiers. The approved poetic interpretation of **2** is retained; the compound and root definitions are unchanged.
- Main sentence, story and dictionary controls distinguish a composed interpretation from a score whose meaning the independent decoder can recover. A dictionary entry is identified as an entry. Unsupported inverse profiles remain playable previews with an explicit unverified status. This is a MIDI check, not a claim about microphone recordings.
- Missing actions and qualities lead with a definition prompt and the compound builder. The complete dictionary remains available under an optional section, explicitly identified as definitions to choose from. It is no longer presented as likely translations for an unknown word. Options are shorter; the complete selected definition remains visible.
- The picker fits small screens, physical-action confirmations describe the actual choice, input edits clear old controls, and technical output fields sit in optional details. The canonical HTML/CSS templates are updated so a release rebuild preserves these changes.
- The older phrase lookup report now states its actual scope instead of implying full-translator completion.

## Evidence

A clean-checkout run of **all 252 implementation checks passed** at source revision `693d2d25e12479a685850256a8a658b767d65181`. The [clean report](reliability_2026_11_22/clean-regression.json) records that revision and an empty initial working-tree status. The initial run and targeted retest are retained: its two failures came from an outdated VM fixture and hard-coded asset versions, both repaired before the clean run. All separately required release checks also passed.

- **145 sentence pairs** independently decoded in both melody and compact chords: multiple ordinary and fallback verbs, conditions, coordination, questions, nested scope, saved word choices and endings **0/1/2**. Expected scope lists are specified separately from the encoder output.
- **12 love readings** independently decoded in both arrangements, including participant reversal, negation and all endings. Altered qualifiers and truncated scores are rejected.
- The existing **216 dictionary sentence cases**, **44 state/adjective cases**, story and field regressions pass. The **972 root/ending** compact-chord checks pass.
- Browser checks cover seven missing-word cases at **320, 390 and 768 pixels**, including expanded selects and keyboard use. Editing clears the old Add to song action. A word created through the builder returns to the unchanged sentence and becomes playable. Six actual song exports recover the checked meanings without English or original IR.
- The same browser checks pass in the Lore integration. Its **196 tests** pass after merging current Lore main. Only synthetic data was used; existing user songs, definitions and backups were not edited.

The reproducible checks are [sentence scopes](../tests/sentence_scope_reliability_test.mjs), [love inverse](../tests/love_semantic_inverse_test.mjs), and [browser flow](../tools/check_sentence_flow.mjs). Browser evidence is retained in `reliability_2026_11_22/` beside this report. Broader release regression results are recorded there separately.

The deployment follow-up passed **all 259 checks** from a clean checkout at `25a01b13863c7193820d9c3e191e766f770feae1`. It fixes a stale song-control test fixture and includes every deployment sentence test in the broad runner. Both published sites passed the browser/export checks after their successful deployments. The [complete regression](reliability_2026_11_22/deployment-complete-regression.json), [live standalone](reliability_2026_11_22/live-standalone.json) and [live Lore](reliability_2026_11_22/live-lore.json) results retain this evidence.

## Remaining boundaries

This repair adds no new canonical words. Missing verbs, adjectives and sentence constructions still need the [ordered vocabulary and grammar work](../docs/full-translator-next-steps.md). Bound personal compounds do not yet support the ability enclosure; they are rejected rather than assigned an incorrect modality. Other specialized preview paths retain their own draft status and should be included as readiness checks expand.

Chromium viewport tests are not physical iOS/Safari tests. No new speaker-to-microphone study was performed. Names, grammar and compound framing retain their existing durations; experimental grammar chords remain unreleased. The broader audio, vocabulary, grammar and song-compression objectives remain open.

Existing saved scores retain their stored notes. Re-translate a line affected by the earlier scope bug to produce the corrected music; this release does not silently replace saved performances.
