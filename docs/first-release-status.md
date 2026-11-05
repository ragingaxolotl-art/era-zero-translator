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
