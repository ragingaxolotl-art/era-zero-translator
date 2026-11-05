# DBA first-release status

Current implementation checkpoint: `ed61230`.

The user approved text → meaning → music with reusable user compounds for this
release. Recorded-audio recovery, microphone tests, exhaustive English coverage,
and exhaustive source-history reconciliation are deferred. The longer completion
log is historical: its older “pending” statements are not the current checklist.

| Requirement | Current evidence | Remaining check |
| --- | --- | --- |
| Preserve established roots and approved meanings | Dictionary identity, additive vocabulary pins, and compound validation suites | 247/247 non-acoustic checks passed at `ed61230` |
| Create ordered compounds from existing parts | Actual builder handlers exercised in `tests/local_builder_authoring_test.mjs` | Live browser interaction |
| Reuse compounds inside compounds | Same test saves a second compound using the first, checks nested music frames | Live browser interaction |
| Preserve participant identity across nesting | Explicit role connections propagate one referent through three requirements | Broader user examples |
| Save and recover definitions | Save/reload and export/import round trip, merge/conflict tests | Browser storage/download interaction |
| Use new verbs and adjectives in sentences | Local English tests cover declared verb forms, copulas, auxiliary constructions, questions, negation, and possibility | Held-out user phrases within supported grammar |
| Clarify ambiguous meanings | Explicit verb-role, tense and pronoun selection; stale-choice rejection | Live browser interaction |
| Preserve lexical/runtime 0/1/2 | Existing identity tests and local music/sentence contrasts | Broad regression and listening |
| Play and export music | Existing voice scheduler; MIDI event timing test; builder and sentence export handlers | Actual playback and download in a browser |
| Keep unsupported meaning visible | Strict local parsers reject extra unsupported text; main fallback requires sentence clarification | Exercise fallback with saved words and unfamiliar grammar |

## Remaining first-release work

1. Broader non-acoustic regression completed: 247/247 checks passed at
   `ed61230`. The supplemental 20-suite local gate also passes. These are
   implementation checks, not a full release proof.
2. Exercise held-out sentence and compound examples, including rejected input,
   role ambiguity, runtime changes, and storage failure. Check meaning and musical
   events rather than only whether a file was produced.
3. Validate the actual browser authoring → sentence → playback/export flow. Browser
   automation was unavailable in Work settings at the last check. DOM adapters
   do not establish visual usability or audible playback.
4. Update the draft PR with the verified checkpoint and remaining limitations.
   Merge and deployment have not been performed.

## Boundaries users must see

Saved definitions describe the user's intended meaning; assembling arbitrary parts
is not automatic proof that the compound expresses that meaning. The builder
preserves ordered components, the semantic head, and explicit participant links.
New meanings should reuse an existing term where its meaning fits.

English support is construction-based. Saved verbs require explicit subject/object
roles; adjectives require a bearer role. Singular gender-neutral pronouns require
a referent choice. Arbitrary plural reference, multi-clause combinations of local
predicates, and unrestricted English paraphrases are not established. Unsupported
constructions must not be presented as complete sentence translations.

Music generation is implemented. Recorded music → recovered meaning is deferred,
and these tests do not prove that inverse operation.

Additional routing evidence: `tests/local_saved_routing_test.mjs` extracts the
actual saved-word routing function from `pages/app.js` and exercises real parsers
with a DOM adapter. It checks supported adjective/pronoun routing, rejection of
unsupported clauses/modifiers/time adjuncts, stale-input suppression, and corrupt
storage preservation. The local release gate passes 20/20 suites. This added test
is supplemental to the broader run started at `ed61230`; it was not in that run's
initial test list. No production implementation changed during that run.

Musical contrast strengthening: the nested builder scenario now checks 12
participant × runtime × negation cases using parsed MIDI notes and their start/end
ticks, while verifying unchanged nested compound identities and exact meaning.
The 24 sentence-scope contrasts also compare performed notes/timing rather than
whole-file bytes. All 20 local suites pass. This does not prove audio recovery or
audible playback. Browser access was rechecked and remains disabled in Work
settings; enabling it has been requested.

Saved-adjective phrasing fix: unambiguous initial “I'm” and “you're” (straight or
curly apostrophes) now expand to their copular forms. Twenty-four tests verify
exact meaning and MIDI parity with expanded sentences, including negation and
runtime 0/1/2. Quoted names, ambiguous 's/'d forms, and unsupported trailing
constructions are not rewritten. The 20-suite local gate passes after this code
change; the earlier 247-suite broad report predates it.

The 40-phrase diagnostic now checks newer preview routes before reporting no
composition. Current result: 24 pass their declared semantic checks, 11 require
interpretation, four have previews still requiring semantic review, and one has
no composition (“Exactly three lamps are active”). The four previews cover
preference, curiosity, route learning, and understanding. Preview availability
is explicitly not counted as semantic completion. This corpus was authored
during implementation and is not a held-out or representative English benchmark.

The curiosity preview now has a separate phrase-specific review in
`reports/curiosity_phrase_review.json`, reproducible with
`tools/review_curiosity_phrase.mjs`. “Orin is curious about the map” preserves the
experiencer, definite topic, desired but unasserted information gain, and absence
of an invented answer or specific question. Existing MIDI recovery preserves the
checked meaning; four participant/negation/runtime variants change performed
notes. Explicit acceptance of the draft epistemic reading is still required.
This closes that declared-reading review, not automatic or general translation.
The 40-phrase preview-only audit deliberately does not count this as automatic
composition; its separate review supplies the conditional evidence.

`reports/interpretation_phrase_reviews.json` supplies conditional semantic review
for the other three preview-only corpus cases. Preference preserves experiencer
and ordered alternatives; reversing them changes performed notes. Route learning
distinguishes memorization, navigation, and familiarity without asserting permanent
retention. Understanding distinguishes communicated content, reasons, and
perspective without asserting the content's truth. Selected meanings survive the
existing MIDI recovery; their musical note sequences differ. Missing reading
choices reject. The reproducible tool is `tools/review_interpretation_phrases.mjs`.
These checks establish declared-reading behavior, not blind evaluation, automatic
interpretation, browser usability, or audio recovery.

Counted “active” now opens a clarification offering the existing physically
energized reading with its exclusions visible. It does not equate energy with
being switched on, operating, or emitting light, and requires a deliberate click.
The chosen reading and original input are retained in the result. Existing
counted-property scope tests (18 cases), actual handler tests, and the Pages
audit pass. The diagnostic now reports five preview cases instead of four plus
one uncomposed case; preview availability still does not prove intended meaning.

Counted interpretation provenance now survives EZB export. `createBundle` copies
the selected interpretation; verification checks that it matches the original
source's offered reading and belongs to a counted energized result. Rehashed
changes to the reading, interpreted wording, or source alone reject. This is
consistency validation, not authentication of the user's choice. The 18 counted
semantic cases and added export-provenance cases pass.

Counted-choice bundle verification now also checks semantic agreement: quantity,
noun restriction, energized predicate, runtime, speech act, and inner versus outer
negation scope. Updating both the source and choice consistently cannot conceal
a mismatch with the exported meaning. Matching variants pass; mismatched count,
noun, negation, question, and runtime variants reject. Counted tests, acquisition
bundle tests, and the Pages audit pass after the change.
