# Painful treatment: semantic dependency decision

This is an author design review of the translator's vocabulary, not a clinical
account of pain. `tools/audit_pain_dependencies.mjs` extracts the exact current
compound definitions and root exclusions into `reports/pain_dependency_audit.json`.
Its literal search is evidence to inspect, not proof that every possible
composition has been ruled out.

## Reuse before extension

The approved felt-self-condition compound (convention 11) provides conscious
experience and a bound experiencer. Unpleasant felt condition (18) adds valence
but explicitly excludes inference of pain. Felt bodily need (14) adds a demand
for replenishment or maintenance, which is not interchangeable with pain.
Sadness (19) specializes a different experiential quality. WRN internal faults
require adverse classification; they do not supply pain merely by describing a
fault. Keep all these definitions, identities and sounds unchanged.

A pain-specific convention can specialize the existing experiential structure.
The first candidate should explicitly select the felt bodily-pain reading, with
an experiencer; emotional hurt and figurative “a painful task” require their own
reading decisions. Do not add injury, visible damage, a known cause, a wish,
conscious verbal report or a treatment event merely from this selected meaning.
No extra LIF/STR family is justified by the evidence so far.

## Dependency order and scope

1. Define and validate felt bodily pain, reusing the felt-condition dependency.
   Check pain versus generic unpleasantness, sadness and damage. Preserve the
   same experiencer through every nested compound and runtime 0/1/2.
2. Define a reusable relation between a stimulus/event and the experience it
   produces or is expected/disposed to produce. Bind the pain experiencer
   separately from the stimulus. Actual causation, expected outcome and general
   disposition are distinct; bare “painful treatment” may require a choice.
   An expected painful treatment must not assert that treatment or pain occurred.
3. Define intensity comparison over compatible pain experiences or outcomes.
   Specify the comparison target, experiencer/context and comparison basis.
   “More painful” must not be encoded as an extra runtime level, a louder note,
   or merely a second contextual threshold. Ordinal comparison does not require
   inventing a numerical pain score or equating different people's scales.
4. Attach the resulting restriction to each treatment reference and then bind
   those references into the existing preference meaning. Keep reference
   identity explicit: matching noun sounds do not settle whether these are two
   treatments or two descriptions of the same treatment.
5. Keep preference polarity and speech act outside the alternatives. Preferring
   A to B does not assert absolute liking, choosing A, undergoing A, or absence
   of pain. Negated preference is not reversed preference or absence of pain.

## Acceptance obligations before claiming support

- “Nora is in pain” versus “Nora feels unpleasant” versus “Nora is injured”:
  preserve the selected meaning without substituting another one.
- “The treatment is painful for Nora”: the treatment is the stimulus, Nora the
  experiencer; the treatment is not conscious by virtue of this sentence.
- “The treatment would be painful for Nora”: preserve the selected nonactual
  scope; do not assert present pain or that the treatment happened.
- “Treatment A is more painful for Nora than treatment B”: recover both
  alternatives, their order and the selected shared comparison context.
- Original acceptance: “Nora prefers the painful treatment to the more painful
  treatment.” Preserve relative preference even when both alternatives have
  negative valence. Resolve the missing comparison referent/context explicitly
  if it cannot be established; do not silently invent an experiencer.
- Reverse alternatives, negate preference and ask the corresponding question;
  verify distinct recovered meanings at each runtime 0/1/2.
- For each implemented reading, decode full generated audio without source
  English, source IR or expected-note input. Add physical recordings before
  claiming robust recorded-audio recovery.

This review allocates no convention number and admits no new canonical meaning.
Pain construction, cause/disposition structure, intensity comparison and the
original painful-treatment acceptance remain unimplemented. Heavy/light
preference support is infrastructure evidence, not satisfaction of these cases.


## Draft meaning implementation checkpoint

`pages/pain_meaning.mjs` now provides an opt-in semantic document for explicit
“in bodily pain” sentences. It pins the existing felt-self-condition identity
and version, preserves a validated reference, speech act, past/negation scopes
and independent runtime. It does not infer injury, cause, stimulus or intensity.
The bodily-pain quality is an explicit draft specialization, not a consequence
of root adjacency. Generic “in pain” remains pending reading selection.

Twenty-four meaning contrasts and rehashed contract-corruption checks pass,
including singular they resolved to an explicit experiencer. No convention
number, canonical admission, renderer, MIDI inverse, UI route or audio recovery
is implemented for this profile yet. Complete pain translation remains open.

## Draft music checkpoint

The pain profile now wraps the unchanged convention-11 felt dependency with a
separate draft specialization frame. It uses extension namespace ±39 with
subcode 1; curiosity retains subcode 0 unchanged. This keeps the existing pitch
range while making the added meaning audible. The experiencer is role-framed,
scopes surround the whole predicate, and runtime remains on the original felt
head. Default canonical decoding rejects the draft frame.

`tests/pain_music_test.mjs` checks 24 assertion/question, present/past, negation
and runtime contrasts, transposition to anchor 72, rejection as generic feeling,
and unique recovery by shared semantic dispatch without a predicate hint.
No original English, semantic document or expected notes enter the inverse.
Independent Ruby rendering, blind WAV tests, UI integration and physical audio
remain open; MIDI evidence alone does not complete the pain translation layer.


## Blind synthetic-audio checkpoint

`tests/pain_acoustic_test.mjs` now verifies two full-message clean WAV recoveries
through the shared decoder. One is a past negated question at runtime 2; the
other binds singular they to Nora before encoding at runtime 0. Only the WAV
pathname and draft opt-in enter the decoding process; no text, source meaning,
pronoun binding or expected score is supplied. The recovered reference, scope,
speech act, runtime and non-entailment of injury match the intended document.
See `reports/pain_acoustic_probe.json`. This does not establish physical recording
robustness, broad acoustic coverage or independent Ruby agreement.


## Independent renderer checkpoint

`tools/lib/era_zero_pain.rb` independently validates the draft contract and builds
its reference, felt-convention, root, runtime and scope events. Twenty-eight
performances match JavaScript MIDI exactly, including I/you, demonstrative noun
references and a quoted multiword name. The parity check caught an unintended
Ruby default pause between the conscious-self qualifier and felt head; the
Ruby renderer now explicitly preserves the established zero-gap dependency.
Default draft rejection and four rehashed semantic corruptions are checked.
This closes the bounded Ruby agreement item, not broad pain/treatment coverage.


## Preview integration checkpoint

The main Analyze route now recognizes explicit bodily-pain sentences and opens
a draft preview. It offers playback, MIDI download and complete meaning export.
Unresolved pronouns receive explicit reference fields, including number selection
for singular they. Edited input or bindings invalidate old outputs and pending
work. `tests/pain_preview_ui_test.mjs` executes the actual handler and verifies
exported MIDI meaning, scheduled playback and stale-result guards. The existing
curiosity preview tests still pass. This is not live browser layout/listening
validation, and the playback button does not yet generate calibrated transport
WAVs. Generic pain readings and treatment/comparison composition remain open.


## Stimulus relation semantic prerequisite

`pages/pain_stimulus.mjs` now provides a draft, typed composition of a stimulus
reference and the existing pain-meaning document. Callers must choose actual
causal contribution, expected outcome or contextual disposition. These meanings
are explicit conventions: the mere cause-role marker or WRN/REP roots do not
supply this general relation without their narrower harm/restoration commitments.
The treatment remains the stimulus; the nested pain document retains Nora as
experiencer. Outcome content is governed by relation and matrix scope and is not
an independent assertion, especially under questions, negation or expectation.
Outer relation runtime and nested pain runtime remain separate.

Thirty-six authored relation × speech-act × negation × runtime documents preserve
these distinctions and reject rehashed independent-assertion corruption. This
checks representation/validation, not empirical causality or complete semantic
adequacy. No English parser, music encoding/inverse, UI, actual/nonactual model
proof or audio tests exist for this relation yet. Intensity comparison and the
original painful-treatment preference acceptance remain open.


## Explicit stimulus sentence checkpoint

`pages/pain_stimulus_sentences.mjs` now composes explicit “caused bodily pain for,”
“is expected to cause bodily pain for” and “tends to cause bodily pain for”
constructions, their supported outer negations and questions. Twenty-seven
relation/form/runtime cases preserve stimulus, experiencer and past causal scope.
Explicit pronoun binding includes singular them. The nested positive pain content
uses default runtime 1 while the trailing sentence tag controls the relation;
these states are not silently copied into each other.

Bare “painful,” simple-present “causes” with unresolved event/habitual reading,
and inner negation (“expected not to cause”) remain rejected. Outer “not expected”
is not interpreted as an expectation of absence. Present first/second-person
agreement, broader clauses, musical rendering/inverse and UI for these relations
remain open. This checkpoint is meaning composition only, not complete translation.


## Stimulus music checkpoint

Three draft relation frames now use the existing ±39 extension namespace with
subcodes 2/3/4 and an explicit independent relation-runtime trit. Previous
curiosity and pain subcodes 0/1 are unchanged. Each relation contains a stimulus
reference and the full existing pain structure, including its own experiencer
and runtime. The stimulus is delimited by a content role; the enclosing relation
assigns its stimulus meaning, rather than pretending the cause role alone
supplies causation. Outer scope and contour govern the relation and nested
outcome; expectation/disposition does not become an asserted pain episode.

Twenty-seven relation × outer runtime × outcome runtime cases use actual past
assertion, negated expectation and a disposition question. They recover complete
represented meaning through shared MIDI dispatch, match after transposition and
reject without draft opt-in. Existing standalone pain tests and 28 Ruby parity
cases remain intact after extracting reusable pain events. Full relation Ruby
parity, blind WAV tests, UI, broader scope contrasts and physical audio remain
open; intensity comparison and the original preference acceptance remain open.


## Stimulus audio checkpoint

Three clean synthetic WAVs now recover actual past causation, a negated
expectation question and a disposition with explicit it/them bindings through
shared decoding. Only the WAV pathname and draft opt-in reach the decoder.
One expectation question also retains its full meaning under simulated gain/noise,
+2% speed and weak short echo. Removing a payload segment is rejected rather than
accepted as another meaning. See `reports/pain_stimulus_acoustic_probe.json`.
These authored channel probes do not establish general acoustic reliability or
physical speaker-to-microphone performance. Relation Ruby/UI work and intensity
comparison remain unfinished.

## Independent stimulus renderer checkpoint

`tools/lib/era_zero_pain_stimulus.rb` now validates the relation contract and
constructs its music independently, reusing `EraZeroPain.events` for the outcome.
All 27 relation/outer-runtime/outcome-runtime performances match JavaScript MIDI.
Default draft rejection and rehashed changes to relation, criterion, outcome
scope and runtime are rejected. The extracted pain event method retains all
28 standalone Ruby parity cases. This closes the bounded relation Ruby agreement
item; UI integration, broader scope evidence, intensity comparison and physical
recordings remain open.


## Stimulus preview checkpoint

The main Analyze route now offers draft playback, MIDI download and complete
meaning export for the supported explicit pain-stimulus sentences. The preview
explains the actual/expected/dispositional distinction and keeps separate
pronoun-occurrence fields. Its handler test decodes a downloaded negated
expectation question and verifies both participants; a second case separately
binds it and singular them. Missing number selection and changed input/bindings
cannot publish stale outputs. Standalone pain preview and stimulus sentence
regressions still pass. Live browser layout/listening remains unverified;
playback still uses the note player, not calibrated acoustic WAV transport.


## Intensity comparison semantic prerequisite

`pages/pain_comparison.mjs` now composes two existing pain-stimulus meanings into
an explicit ordinal greater/less/equal intensity comparison. Both operands must
use the same actual/expected/dispositional reading and the same experiencer;
an explicit context reference selects the comparison setting. This does not
supply a numeric score, duration/integrated burden, cross-person calibration or
absolute unpleasantness threshold. Runtime is preserved independently on the
comparison, each relation and each pain outcome.

The operands are positive unscoped content governed by comparison and matrix
scope, not separately asserted utterances. 108 authored documents cover three
relation modes, three comparisons, three comparison runtimes, questions and
negation. Direction reversal changes identity; cross-experiencer scales and
rehashed runtime-as-intensity corruption reject. A small ordinal counterexample
records that not-greater permits equality and cannot be replaced with less-than.
These are representation checks, not a complete semantic model or audio proof.
English parsing, musical transport, independent inverse/Ruby validation and UI
remain open for this comparison. The original painful-treatment preference is
still not claimed complete.


## Explicit comparative English checkpoint

The sentence composer now supports more/less painful for an explicit experiencer
than a second named/nominal alternative, and equally painful ... as. Present/past,
outer negation, questions and runtime produce 72 distinct tested meaning
documents. Callers must select actual/expected/dispositional bodily-pain outcomes
and identify a shared context; neither is inferred from the adjective. Explicit
it/them bindings preserve separate stimulus and experiencer references. Missing
experiencer and mismatched comparative connectors remain unsupported.

The nested relations and pain outcomes use their default runtime 1; a trailing
runtime tag belongs to the comparison only. This is meaning composition, not yet
musical comparison, UI interaction or full ordinary-language coverage. The
original modified preference still requires integration and missing-context
resolution before it can be claimed supported.


## Comparison music checkpoint

The comparison now has draft music frames using ±39 subcodes 5/6/7 for ordinal
greater/less/equal, with its own runtime trit. It contains an audible context
reference, a target operand and a comparison-standard operand. Both operands
reuse the complete pain-stimulus and felt-pain event structures; no existing
frame or root is reassigned. The strict inverse validates matching relation
modes and experiencers and rejects mismatched or unscoped extra content.

Twenty-seven negated-question performances cover three comparison directions,
three outcome modes and three comparison runtimes. Full shared MIDI recovery
and transposition preserve ordered stimulus references and context. Nested
runtimes in these sentence-generated cases are the default 1; broader independent
nested-runtime coverage remains to be exercised at comparison level. Existing
27 relation runtime cases and Ruby agreement remain intact. Independent comparison
Ruby rendering, blind WAV tests, UI and physical recordings remain open.


## Comparison audio and independent runtime checkpoint

Two clean synthetic comparison WAVs now recover complete represented meaning
through shared decoding: a negated greater-than expectation question at runtime
2, and reversed stimulus ordering with less-than disposition at runtime 0. The
context reference is recovered from the music, not supplied alongside the file.
See `reports/pain_comparison_acoustic_probe.json`. These are authored synthetic
examples, not physical recordings or broad acoustic validation.

Fifteen additional MIDI probes independently vary each of the five runtime
positions around a baseline: comparison, left relation/pain and right
relation/pain. They yield eleven distinct performances because the five baseline
probes coincide. Each inverse recovers all five values while the intensity
relation remains greater-than. This adds bounded comparison-level runtime
independence evidence; exhaustive combinations and broader scopes remain open.

## Independent comparison renderer checkpoint

`tools/lib/era_zero_pain_comparison.rb` validates the comparison contract and
constructs the ordered context/operand performance independently, reusing
`EraZeroPainStimulus.events`. All 42 authored comparison performances match
JavaScript MIDI, including the 15 probes of independent nested runtime positions.
Default draft use and rehashed corruption of scale, comparison basis, operand
scope and relation are rejected. All 27 underlying relation parity cases remain
intact. This adds independent implementation evidence; it does not prove broad
semantic adequacy, physical audio reliability or completion of the original
modified preference. UI integration and that preference remain open.


## Comparison preview checkpoint

Analyze now routes supported painful comparisons to a draft preview requiring
an explicit actual/expected/dispositional reading and shared-context reference.
It exports complete meaning and MIDI and schedules playback. Handler tests
verify a negated greater-than question, the recovered context and mode, missing
choice/context behavior, and invalidation after context or reading edits,
including edits during asynchronous music generation. The existing stimulus
preview test still passes. Live browser layout/listening and calibrated WAV
playback integration remain open. The original modified preference remains a
separate integration obligation, not completed by this comparative preview.


## Original modified-preference meaning checkpoint

`composePainPreference` now handles the original “Nora prefers the painful
treatment to the more painful treatment” and its reversed, negated and question
forms. Explicit options identify the pain experiencer, actual/expected/dispositional
reading, context and confirmation that more painful compares with the other
alternative. The holder is not automatically the pain experiencer. Existing
preference foundation FND:018dd25d713dff83661a76a4 is pinned unchanged; it does not
entail absolute wanting, pleasantness, happiness or objective goodness.

Two noun descriptions retain the same noun phonemes but use separate audible
instance tags. The comparison's greater-intensity operand must match the
more-painful alternative exactly; rehashed rebinding is rejected. Reference
restrictions are distinct from matrix preference polarity, so negating preference
does not invert the pain ordering. Eighteen meaning cases pass. These local
instance handles do not prove persistent external identity or inequality.

No music encoder/inverse, Ruby implementation or UI exists for this combined
profile yet. The original acceptance remains not-completed in the requirements
audit until full meaning/music evidence is integrated. Generic missing-context
resolution, projection in broader embeddings and physical recordings remain open.

### Preference musical binding checkpoint (November 5, 2026)

The original painful-treatment preference now has a gated musical encoder and
strict inverse (`pain_preference_music.mjs`). Draft frame ±39/subcode 8 identifies
the fixed preference foundation and reference-restriction scope. It reuses the
existing pain comparison, stimulus, pain, noun-label and reference encodings.
The inverse derives which alternative is more painful from the encoded reference
bindings; it receives neither the sentence nor its semantic document. Holder and
pain experiencer remain independent, gender-free references. No roots or approved
compound definitions changed.

Targeted evidence: 18 preference direction/scope/question/runtime MIDI cases pass,
including shared semantic dispatch and anchor transposition. The existing 42
independent Ruby comparison performances still match after extracting reusable
comparison events/tree reading. These are authored MIDI checks, not acoustic
proof. The combined preference still needs independent renderer validation,
blind WAV recovery, UI interpretation choices and physical speaker/microphone
validation. Original acceptance status remains incomplete; the full translator
goal is not achieved.

### Preference independent rendering and WAV checkpoint (November 5, 2026)

`EraZeroPainPreference` independently validates and renders the combined
preference. All 18 authored performances match JavaScript byte-for-byte. Default
draft rejection and rehashed foundation, restriction scope, direction-binding,
and runtime corruption are rejected. Extracting reusable Ruby comparison events
retains the 42 existing comparison parity cases.

`pain_preference_acoustic_test.mjs` recovers two complete preference meanings from
clean synthetic WAV files in separate decoder processes. One is the original
less-painful alternative preference with expected-outcome reading and runtime 0;
the other reverses the preferred alternative and uses a negated question,
disposition reading, and runtime 2. Pain experiencer Eli remains distinct from
holder Nora. Decoder inputs contain only WAV path and draft permission; context,
participants, restrictions and scope are recovered from sound. Full inverse
objects match the expected meaning, with participant/binding checks against the
source meaning document. Report: `reports/pain_preference_acoustic_probe.json`.

This is authored synthetic-audio evidence, not held-out language coverage or
physical recording evidence. UI integration, perturbation checks for this longer
profile, physical speaker/microphone tests and broader completion work remain.
The original acceptance gate stays incomplete pending its remaining requirements.

### Preference interface checkpoint (November 5, 2026)

General analysis now routes the original painful-treatment preference to a
specific draft preview before the generic foundation route. The preview requires
an explicit actual/expected/dispositional reading, pain experiencer, shared
context and confirmation that the comparison concerns the other alternative.
It does not infer that the preference holder is the pain experiencer. Gender is
not requested. It offers scheduled music playback, MIDI download and full meaning
JSON export. Changing any choice or the source sentence invalidates stale output.

The actual handler test (`pain_preference_preview_ui_test.mjs`) passes missing
choice/context handling, full export decoding, separate holder/experiencer,
negated question/runtime 2, playback scheduling and stale async-result guards.
The existing comparison preview test still passes. This is a simulated DOM test,
not a live browser or physical playback recording. This preview currently accepts
explicit reference names/deictics; automatic pronoun antecedent resolution and
other comparison targets remain outside this draft profile.

### Original acceptance reconciliation and identity validation

The executable original-requirements audit now exercises `both_unpleasant` with
explicit pain experiencer, reading, context and comparison-target choices, and
verifies that missing choices reject. It checks relative preference against the
pinned foundation, ordered treatment identity, separate experiencer and scoped
comparison after MIDI recovery. The status is deliberately separate:
`candidate_semantic_checks_pass_with_explicit_context`. Across the original 20
cases, 9 pass existing candidate checks, 1 passes with these explicit choices,
and 10 remain uncomposed. This updates stale `not_composed` evidence without
claiming automatic interpretation, canonical vocabulary approval or full completion.

A validator inconsistency discovered during reconciliation is fixed in both
JavaScript and Ruby: two preference alternatives cannot collapse to the same
reference identity. A fully rehashed malformed document (including its nested
stimulus and comparison) is rejected by both validators; otherwise encoding could
succeed while inverse binding was ambiguous. Existing 18 musical parity cases
remain passing. Local instance identity does not establish real-world inequality.
