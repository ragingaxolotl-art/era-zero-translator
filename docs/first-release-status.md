# DBA first-release status

Production checkpoint: `59263391f600aff6f7043ced2afd795c2a5b4d09`.
The branch is pushed to draft PR #1. Nothing has been merged or deployed.

## Approved scope

Text → meaning → music, with user-created reusable compounds and compounds of
compounds. Preserve 324 roots, approved meanings and musical style, noun/name
sound labels, and lexical/runtime 0/1/2. Recorded-audio recovery, microphone tests,
exhaustive English coverage, exhaustive historical-source reconciliation, and
duplicate implementation expansion are deferred by the user's approval.

## Implemented and checked

- Ordered compound authoring, semantic heads, explicit participant links, nested
  reuse, local saving, merge-safe import/export, and sentence examples.
- Saved verb/adjective sentence composition, declared verb spellings, role choices,
  questions, tense, negation, possibility, and explicit singular neutral pronouns.
- Playback scheduling through the existing voice, MIDI export, and meaning bundles.
- Nested meaning checks and actual MIDI note/timing contrasts for participants,
  scope and runtime. This does not prove audio decoding or audible playback.
- Counted “active” requests explicit selection of the existing physically energized
  reading. It does not imply switching, operation, or light emission. Exported
  choice provenance is checked against quantity, noun, scope, speech act and runtime.

Evidence:

- `reports/translator_completion_regression.json`: 247/247 non-acoustic checks
  passed at `ed61230`; this predates the later contraction and counted-choice fixes.
- `reports/local_compound_release.json`: 20/20 suites pass at the current production
  checkpoint, covering 133 browser modules. UI checks use DOM adapters.
- Latest targeted checks: counted sentence meaning/export tests, quantified preview
  handlers, acquisition bundle tests, and Pages audit pass. Pages audit reports
  11,171 checks and preserves 5,370 canonical variants.
- `reports/curiosity_phrase_review.json` and
  `reports/interpretation_phrase_reviews.json`: conditional reviews of curiosity,
  preference, route learning and understanding after explicit draft interpretation.
- `reports/ordinary_phrase_coverage.json`: 24 declared semantic checks pass,
  11 cases require interpretation, and five have interpretation previews. This
  implementation-authored corpus is not a representative or held-out benchmark.

## Remaining acceptance work

Local browser use is disabled in Work settings, confirmed again after the latest
implementation. Enabling it has been requested. No live browser, visual, listening,
or download validation is claimed. Do not mark the release or full goal complete.

Once browser access is available:

1. Open the branch build, search existing meanings, create a verb or adjective,
   connect participant roles, save, reload, and use its sentence example.
2. Create a second compound from the first. Check the displayed meaning, role
   choices, and reuse after export/import without losing existing saved words.
3. Play and stop each generated performance. Change participant, negation and
   runtime 0/1/2; confirm the selected result plays and stale output is unavailable.
4. Download MIDI and meaning bundles and verify the files, original wording,
   selected interpretation, and reusable definitions.
5. Try user-supplied phrases that previously failed, including one newly coined
   compound. Record intended meaning before translation, compare the result, and
   fix concrete mismatches. Additional invented examples are not held-out evidence.
6. Review remaining limitations and release readiness before merge/deployment.

## Limits that remain visible

English support is construction-based. Unknown words and unsupported constructions
must remain explicit gaps. Arbitrary plural reference, multi-clause combinations
of local predicates, and unrestricted English paraphrases are not established.
Assembling parts preserves the authored structure but does not automatically prove
that an arbitrary new compound expresses the user's intended concept. Reuse
existing meanings where they fit and review new definitions explicitly.

The full historical work remains in `docs/translator-completion.md` and Git history.
The active first-release scope above governs sequencing; deferred work is preserved.
