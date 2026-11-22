# Completing the DBA translator after the November 22 audit

The [audit](../reports/full_language_music_audit_2026_11_22.md) is complete. The full translator is not. This plan retains the original text → intended meaning → music → recovered meaning objective and the earlier shorter-release boundary. It reuses the current vocabulary, recursive compound library, validators, grammar, sound labels, runtime states and music renderer.

The user should be able to write a new message, resolve a genuine ambiguity in ordinary language, and add the entire interpreted message to a song. A missing verb or adjective should lead to a reusable definition that works in other sentences. The music must preserve who did what to whom, qualities and attachments, relationship, time, negation, uncertainty and scope. No requirement says that musical syntax must follow English order or that programs must have gender.

## Ordered work packages

### 1. Repair meaning loss and make readiness truthful

Fix the shared predicate-routing fallback before extending its vocabulary. Carry the already interpreted time, ability and negation scopes into all returned readings, including personal preferences. Compare *will*, *can*, *might*, *will not* and *cannot* for known special verbs, dictionary fallback verbs and personal verbs in simple sentences, questions, conditions and coordinated clauses. Respect scope order; merely copying a set of flags is insufficient.

Complete the normal sentence inverse for the approved love reading, or clearly withhold a claim of independently decodable translation until it exists. Preserve the approved compound and poetic num meaning. Have one readiness result state whether the whole line has a supported interpretation and whether its exported sound has a supported inverse. A resolved dictionary candidate must not impersonate a resolved sentence.

**Acceptance:** the audit-16 family and audit-44 preserve their frozen intentions in both arrangements; swapping roles, time, negation or speech act changes the recovered meaning appropriately. Include new examples selected after the fix. No confirmed silent loss may remain in the supported scope.

### 2. Make the normal sentence flow usable

Constrain candidate cards, labels and selects to the viewport; shorten option labels and show definitions below. Replace example-sentence confirmation buttons with the actual choice, such as “Physical pushing.” Do not offer unrelated roots as likely substitutes for a missing action. Clearly distinguish a missing definition from unsupported sentence structure and an unclear referent.

Keep Translate, the plain-language interpreted message, Play and Add to song together. Put atomic IDs, graph details and MIDI tools in optional details. On failure, identify the first unresolved span, explain what is needed, link to the builder and return to the unchanged sentence. Preserve previous songs and definitions. A saveable “this sentence / what I meant” record would provide useful future evidence.

**Acceptance:** all recorded picker cases fit 320-, 390- and 768-pixel viewports; keyboard and touch reach each action; changing input clears stale results; unknown verbs/adjectives never become phonemic names or unrelated meanings; a newly built word returns to the original sentence. Verify actual iOS/Safari behavior separately from Chromium viewport emulation.

### 3. Expand reusable meanings and their English forms together

Use this decision order for each intended sense: exact existing meaning → ordinary composition from existing meanings → explicitly defined conventional compound → grammar feature → unresolved primitive proposal. A new alias must entail the existing definition. Do not substitute lowering for dropping, dormancy for deletion, care for pleasure, or ability for permission.

| Dependency order | Work exposed by the audit | Required distinction |
|---|---|---|
| Existing state/action base | Reuse state, continuation, maintenance, pressure and displacement | State vs continuation vs caused maintenance; pressure without guaranteed movement |
| Reusable physical change | Pull; release/fall/drop; placement and destination; containment/empty/full | Force vs result, release vs controlled lowering, object vs location, property vs change |
| Description and comparison | Empty, narrow/wide, degree, comparison, ordinal and multiword modifiers | Property bearer, comparison standard/dimension, intensity, noun label vs asserted property |
| Information operations | Generalize copy, save, delete, restore and remember across subjects and tenses | Copy vs same continuing identity; retained information vs awareness; request vs execution |
| Mind and social acts | Belief/knowledge, promise/refusal, wanting/needing and chosen/compelled action | Truth commitment, intended outcome, obligation, agency, and action completion |
| Culture-specific composites | Open Keeping, continuity, witnessing, unresolved becoming, care across time | Relational/cultural commitments and exclusions beyond generic storage or access |

For every admitted word, record its definition, dependencies, head, required participants, shared-role bindings, inflections, examples, near misses, cultural interpretation and approval provenance. Reuse its identifier in later compounds. Keep private words in the saved library until separately approved for the public dictionary. Test nested words in subject and object descriptions, as predicates, under negation/modality and with all three runtime endings.

**Acceptance:** a word works in new subjects, objects and sentence patterns, not only its demonstration phrase; nested definitions expand without cycles or changed inherited meanings; import/export transfers every dependency; identical labels do not silently identify different participants. The currently passing 44 state/adjective tests remain a regression floor.

### 4. Complete the grammar around those meanings

Prioritize cardinal/ordinal quantities and *both/only/not every/no*; locations and spatial relations; adjective degree and attachment; *until/while/before/after*; relative clauses; embedded propositions and questions; requests, commitments and contrasting clauses such as *want but do not need*. Treat tense, aspect, modality, scope and runtime separately. Do not add a bespoke dictionary entry for each full sentence.

Extend dialogue context with explicit, neutral referents, same-named entities, plural/group membership, ownership and shared references across song lines. Ask only when the intended referent or sense is genuinely unclear. Do not silently choose a gender or use an English noun label as evidence of its ontology.

As construction coverage grows, consider a constrained meaning planner ahead of the current validators: it can propose a graph using the existing dictionary, flag unmapped spans and ask a focused question. It must not invent approved vocabulary or bypass graph/scope validation. A model-based planner is an option to evaluate, not an implemented dependency or a promise of unrestricted English.

**Acceptance:** minimally different sentences retain all participants, numbers, relations and scopes after independent decoding; the frozen failed manuscript lines and a new untouched manuscript set pass their intended readings. Unsupported structures remain explicitly unsupported. Evaluate any hard length, clause-count and nesting limits rather than hiding them behind a generic failure.

### 5. Shorten music where the measured cost lies

Retain current compact root chords. First prototype shorter grammar/convention frames and approved compound short forms. Then test shorter participant motifs, shared identities across lines and event-first musical serialization. Make major meaning differences arrive earlier; a statement/question pair that stays identical for 50 seconds is a poor interactive experience even when formally correct.

The isolated two-chord grammar experiment gives a median 14.4% duration reduction with sixteenths; it does not solve the whole problem. Keep its frozen alphabet/version separate from released formats. Compare eighth- and sixteenth-note forms using the same voice and messages. Preserve family/address identity, runtime tails, role bindings, scope boundaries and speech acts. Expressive rhythm, timbre and contour may vary only within a documented meaning-preserving layer.

**Acceptance:** exact notes or an explicitly defined equivalent semantic graph recover without English or original IR; every existing root/ending, compound, nested binding and role reversal survives; gains are measured on full songs and first-distinction time; listeners can compare complete examples. Do not ship an audio-unsupported profile merely because its MIDI round trip passes.

### 6. Restore the longer recorded-audio objective when ready

The faster release deliberately deferred general microphone recovery. Keep that boundary explicit. The current audit adds one clean reference-WAV check; it does not close the longer objective. A useful next audio profile should carry its version, pitch/timing calibration and references in the sound itself or in the public language specification, not in hidden source metadata.

Freeze the decoder before collecting each held-out set. Cover different speakers/microphones, rooms, distances, output levels, permitted voices, pitch offsets, speed drift, jitter, clipped onsets/endings, dropped/added notes and silence. Measure exact semantic recovery, explicit rejection and falsely accepted wrong meanings separately. Include participants, negation, quantifier/scope, runtime and long/nested compounds. A different MIDI hash is not an acoustic distinction test.

Use observed errors to decide whether resynchronization, audible checksums or limited error correction earn their duration cost. Distinguish detecting an error from correcting it. Do not let tuning for the test recordings consume the held-out set. General microphone completion remains unproven until this evidence exists.

### 7. Rebuild the songs and close the documentation loop

Once grammar and a musical profile are accepted, retranslate existing song lines from their intended meanings. Preserve line order, participants and emotional/cultural readings. Compare every changed meaning, duration and recoverability; keep the old arrangements and saved libraries available. Do not update songs solely by swapping their MIDI files or renaming the arrangement.

Record exact language/profile revisions with each released song and library. Reconcile contradictory counts and completion labels across the repository, Google source and ChatGPT plan while preserving dated history. Recover missing review/source material where possible; label unresolved provenance. Do not count a source link's existence as proof that its contents were reconciled.

**Acceptance:** a release checklist cites actual exported songs, independent meaning checks, UI behavior and the agreed audio boundary. No required item can be closed solely by inventory counts, test-file existence or a “PASS” title.

## Original seven phases: current evidence

| Original phase | Current conclusion |
|---|---|
| One baseline and accurate status | Current revisions and scope are recorded; broad historical reconciliation remains incomplete. |
| Meaning survives rendering | Strong evidence for tested profiles; the new scope-loss and love-inverse findings prevent broad closure. |
| Recursive compounds and reference binding | Working infrastructure and nested-adjective tests; broader constructions and shared dialogue references remain. |
| Complete small vertical slice | The earlier approved text-to-music release exists. This is narrower than full translation. |
| Coherent vocabulary expansion | Substantial additions exist; missing physical, descriptive, social and cultural senses remain. |
| Sentence grammar and dialogue | Many tested patterns work; the current diagnostic exposes major generalization gaps. |
| Actual-use validation and release | Implementation checks pass; fresh-intention testing, broader device/accessibility coverage and general microphone recovery remain. |

The original plan proposed at least 95% exact or correctly clarified translation within an agreed everyday/dialogue domain, with zero silent semantic losses. That is a proposed future target, not an accepted universal completion threshold or a score achieved here. A finite passing corpus cannot establish unrestricted English. Publish the actual supported domain and test results, expand them deliberately, and keep the larger objective visible.
