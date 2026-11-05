# Desire, preference and curiosity: dependency and primitive-gap review

Status: reviewed requirements and rejected candidate derivations, not new canonical
vocabulary. Reviewed against the runtime authority at revision b5efa837e90f6395637494f91c7a4808aca29c35:
324 roots and 50 compounds. The existing root grid, conventions 0–17, approved love,
lexical trits and runtime endings are unchanged. The source inventory is pinned in
`reports/foundation_inventory_audit.json`; the specific candidates and acceptance
requirements are recorded in `tests/desire_preference_requirements.json`.

## Decision

The felt-condition batch does not supply wanting or comparative preference.
Do not make preference a subtype of pleasant feeling, care or attention. Desire
and preference are separate foundational relations: wanting something does not
require ranking it against a stated alternative, and ranking one alternative above
another does not mean either is wanted in absolute terms. Curiosity depends on an
epistemic orientation, not on attention alone. This changes the dependency plan:
review desire and comparative preference independently, then combine the relevant
relation with an information/knowledge objective for curiosity.

The reviewed inventory has no direct invariant for these relations. This is a
primitive semantic gap in the current vocabulary, not proof that a new 27-root
family is necessary. An explicit lexical convention could introduce the distinction,
but it must not require an existing root predicate that the ordinary sense does not
entail. A conventional label cannot erase the commitments of its component roots.

## Full inventory assessment

| Family | Available commitment | Why it does not supply desire or preference |
|---|---|---|
| LIF | Identity, consciousness, viability, awakening, care and living relations | A caring action can conflict with what its actor wants; living identity does not determine an ordering of alternatives. |
| MOV | Position, displacement, routes and positional relations | A destination may guide actual movement without being desired; wanting can concern a nonspatial or impossible outcome. |
| MAT | Material bodies, physical-state change, energy capacity and coupling | Resource dependence and physical capacity can hold without any desire; preference can concern abstract alternatives. |
| MIN | Representations, their changes and selective attention | Mental representation does not select a motivational attitude. Attention can be captured by a rejected alternative. |
| CON | Communicative endpoints, expression, uptake and participation | A request expresses something, but expression alone does not establish sincere wanting; a private preference need not be communicated. |
| STR | Positions, arrangements, incorporation and structural eligibility | A formal arrangement or eligibility relation does not establish a cognizer's preference. |
| WRN | Adverse conditions, impairment and susceptibility | A person can want a harmful outcome; aversion is not identical to objective impairment. |
| REP | Restoration standards, restoration and restorative applicability | An acceptable restoration state is not necessarily wanted by the bearer or a particular observer. |
| LOG | Formal constraints, admissibility evaluation and applicability | Admissibility is not preference; a preference need not involve an explicit rule, complete ordering, transitivity or rational deliberation. |
| DAT | Information objects, transfer, transformation and alignment | A stored ordering may describe a preference without being anyone's actual preference. |
| CRE | Production patterns, artifacts, productive transformations and capacity | A production specification does not assert a desire, voluntary choice or intention. |
| ORI | Ontological obtaining, grounding, transitions and dependence | Dependence is not wanting, and the objects of desire need not actually obtain. |

The 50 current compound invariants add artifact/system types, repair, registration,
physical support/carrying/custody, poetic love and felt conditions. None establishes
an independent desire relation or a comparative preference relation. Felt hunger
and thirst explicitly exclude figurative wanting; felt pleasure explicitly excludes
preference. Reusing those compounds does not remove their exclusions.

## Candidate failures that must remain visible

- **MIN:210/211 as preference:** preferential cognitive processing is attention,
  not favoring an outcome. A hated noise can capture more attention than a preferred
  quiet room. The word “preferentially” in the definition is not a sufficient alias.
- **MIN:010 as a neutral representation anchor:** this root commits to persistence
  across cognitive episodes. A newly formed, fleeting preference need not have that
  history. MIN:011 instead commits to present manifestation; a standing preference
  can hold while attention is elsewhere. Runtime 0 or 2 cannot undo either lexical
  commitment to manufacture a state-neutral representation root.
- **Felt condition plus target representation:** this only supports a consciously
  felt, currently represented subtype. Broad wanting/preference also includes
  dispositions that are not presently felt. That subtype must not replace the
  ordinary requested sense merely because it fits the current renderer.
- **Pleasant condition plus a second pleasant condition:** a person may prefer one
  painful treatment to another while finding neither pleasant. Preference does not
  entail positive valence, satisfaction or happiness.
- **LOG ordering plus MIN:** the LOG roots specify admissibility constraints, not
  arbitrary orderings. This also risks adding deliberation, completeness or
  transitivity absent from a local comparative preference.
- **Two generic existence roots as padding:** do not satisfy the dictionary's
  two-expanded-root minimum with redundant or irrelevant existence claims. Targets
  may be hypothetical; adding real-world existence would be a meaning error.

## Required semantic interfaces

**Desire:** a holder has a motivational orientation toward a specified outcome or
object under an intended relation (having, drinking, meeting, or another explicit
reading). No action, plan, permission, pleasant feeling, benefit, achievable outcome
or actual target existence follows. An object-directed surface such as “wants tea”
needs an explicit context-sensitive reading; its noun alone must not force drinking,
ownership or immediate consumption. Desired propositions require intensional
content, not an asserted subordinate clause.

**Comparative preference:** a holder favors alternative A over alternative B in a
contextual respect. Direction and both alternatives must be represented. It asserts
neither actual selection nor wanting either alternative absolutely, nor pleasure,
objective superiority or a complete/transitive ordering over other alternatives.
The alternatives can be kinds, individuals, actions or propositions. A first
implementation must keep those types explicit and cannot relabel every alternative
as an existing physical entity. “Nora prefers tea to coffee” may concern beverage
kinds in context; neither noun is a person's proper name or a particular cup.

**Curiosity:** an orientation toward gaining information or understanding about a
topic. This requires a reviewed epistemic objective and appropriate content binding;
not every desire for information is curiosity (instrumental requests can be distinct
readings). It does not assert current attention, asking, exploration, learning,
truth of an answer or successful understanding. Do not derive it until those
commitments and counterexamples are resolved.

## Implementation consequences

The compound identity validator currently requires at least two expanded roots
(`EraZeroCompoundConventions.distinct_dictionary_graph?`), and the graph schema's
root references point into the existing 324-root inventory. That is a real
architectural constraint, not evidence that two suitable semantic ingredients exist.
Do not weaken it as an incidental vocabulary patch or add filler meanings.

Next, compare an explicitly versioned minimal lexical-foundation extension with a
sparse new root-family proposal. The decision must specify semantic independence,
address and musical collision behavior, lexical/runtime 0/1/2, typed/intensional
participants, reference and dependency compatibility, migration, dictionary discovery
and inverse decoding. Preserve all current IDs and performances. Prefer the smallest
coherent extension that expresses the full requested senses; neither filling 27
slots nor inventing many unrelated convention codes is an acceptance criterion.
This review does not approve either architecture or assign new sound codes.

Meanwhile, reference, clause-scope and content-type work can proceed independently.
There is no need to stop the translator goal while these lexical foundations are
being designed. The requirement corpus must later run through the actual parser,
formal validation and independent musical decoder; its existence is not a pass.

## Object-desire clarification implementation checkpoint (November 5, 2026)

`pages/object_desire.mjs` recognizes object-directed desire and requires an explicit
desired proposition. It does not select drinking, ownership, consumption, or a
custodian. The composed clarification preserves the outer holder, negation,
question, time and runtime, and requires the original object label to occur in a
content reference. An unrelated desired outcome rejects. The selected proposition
is retained as explicit user clarification; generic object desire remains unresolved
without it. This mechanism does not yet resolve pronouns or modified objects, and
has not been connected to the interface or original acceptance pass count.

An end-to-end probe exposed an existing asymmetry: custody could be encoded inside
desire but not decoded. The foundation inverse now reuses the strict custody tree
reader, preserving its no-ownership commitments inside intensional content. Nine
clarified desire MIDI cases recover assertion/negation/question and runtime 0/1/2.
The standalone custody inverse checks and 39 existing foundation English/Ruby
parity cases plus 3 embedded compound formal checks remain passing. No new root,
compound meaning or musical address was introduced. Blind WAV and interface
validation for this clarification path remain unfinished.

## Object-desire independent performance and audio checkpoint

The nine clarified object-desire assertion/negation/question × runtime cases now
also match independent Ruby MIDI rendering of their semantic IR. Two additional
checks preserve outer previous-day/before-speech time separately from negation of
the desired custody outcome.

`tests/object_desire_acoustic_test.mjs` passes two clean synthetic WAV recoveries
through an independent process receiving only WAV path and draft opt-in. The
original sentence, explicit clarification, semantic document and expected notes
are not decoder inputs. The first case wants custody with runtime 0; the second
asks about a negated desire for a separately negated custody outcome with runtime
2. Full recovered structures match, preserve intensional status and retain the
custody convention's explicit no-ownership commitment. Evidence is recorded in
`reports/object_desire_acoustic_probe.json` and included in the acoustic regression
runner. This is authored synthetic audio, not physical speaker/microphone proof,
held-out ordinary-language coverage or support for drinking/ownership semantics.
Interface integration remains pending and original acceptance counts are unchanged.

## Object-desire interface checkpoint

The existing foundation preview now recognizes object-directed desire and asks
for the intended outcome in a complete sentence. No outcome is preselected. The
same preview and resolution/export path handles the composed result, preserving
the original input and explicit clarification. A changed clarification during an
async load/composition cannot replace newer output. Unsupported outcome predicates
continue to reject rather than being reduced to labels.

The actual preview handler test now covers missing outcome, real custody-content
composition under negated question/runtime 2, strict MIDI inverse, candidate
bundle verification and stale clarification rejection. Existing knowledge and
foundation-pronoun handler tests receive the new dependencies and remain passing.
This is simulated DOM evidence, not a live browser check. Automatic resolution of
object-desire pronouns, broad desired-outcome predicates and physical recorded
audio remain unfinished. No acceptance count or canonical vocabulary promotion
is inferred from this UI integration.

## Object-desire reference and runtime scope correction

Adversarial checks found that matching only normalized object labels could allow
`this tea` to become `that tea`, or the noun `the tea` to become the proper name
`Tea`. Clarification now preserves explicit reference mode as well as label;
an initially bare noun permits an explicitly chosen nominal reference but not a
proper-name replacement. This remains local reference preservation, not external
identity proof.

A second gap allowed an outcome's trailing runtime marker to be read as the outer
desire marker when the original desire had no explicit marker. The resolver now
serializes the original outer runtime explicitly and verifies holder, speech act,
negation and time against the source parse. Desired-content runtime remains inside
the content. All nine outer/inner runtime pairs pass strict MIDI recovery, as does
the implicit outer-state-1 / explicit inner-state-2 case. Reference substitution
rejections and the existing independent Ruby and preview checks pass. No vocabulary
or musical convention changed.

## Original object-reading acceptance and remaining outcome coverage

The original `object_reading` case now executes missing-clarification rejection
and the explicitly selected outcome `Eli has physical custody of the tea.` through
full MIDI recovery. Its status is `candidate_semantic_checks_pass_with_explicit_context`,
not unconditional translation. Original 20-case totals are 9 candidate checks,
2 checks with explicit context, and 9 uncomposed cases. Desired custody remains
intensional and does not assert ownership; the different holder Eli is explicit.

The executable `tools/audit_object_desire_outcomes.mjs` records eight authored
outcome probes in `reports/object_desire_outcome_coverage.json`. Custody has an
inverse. Acquisition of custody and carrying exposed nested musical inverse gaps;
drinking, ownership, availability, the tested delivery wording and making failed
composition. These are remaining implementation obligations, not evidence those
meanings should be removed from the goal. The object-desire composer now requires
shared inverse acceptance before presenting a ready translation. This prevents
unsupported nested outcomes from silently appearing complete while their inverse
work remains pending. An inverse alone is not proof of semantic fidelity; the
case-specific checks and audio evidence are still required.

## Desired carrying and custody acquisition inverse extension

The two musical inverse gaps identified by the outcome audit are now implemented.
The foundation inverse recognizes convention 8/7 custody acquisition using an
extracted strict custody-acquisition tree reader, and convention 4/3 physical
carrying using a strict tree reader that checks the actor is the same load as the
nested physical support target. Existing roots, frames and meanings are reused.
Both remain within intensional content; no actual outcome follows from desire.

Eighteen authored cases (two outcomes × assertion/negation/question × runtime)
recover their distinct commitments and match independent Ruby MIDI. Acquisition
retains no-custody-before/custody-at-culmination, without ownership, object creation
or continued custody afterward. Carrying retains physical support/shared load and
translation without destination or arrival. The existing 36 standalone acquisition
cases and prior object-desire tests pass. The outcome coverage report now records
three available inverses; five tested outcomes remain composition failures. These
two new nested outcomes still require blind audio and broader held-out checks.

## Nested outcome blind-audio checkpoint

The object-desire acoustic suite now covers four clean synthetic WAVs, adding
carrying and custody acquisition to the two custody cases. The carrying question
uses outer runtime 2, inner runtime 0, ongoing aspect and a proximal `this tea`
reference. The negated acquisition desire uses outer runtime 0, inner runtime 2
and before-speech time on the desired acquisition. Independent processes receive
only WAV path and draft permission, with no source sentence, clarification,
semantic document or expected notes.

All four full inverse structures match. Additional assertions check intensional
status, independent scope/runtime, proximal reference, shared carrying load,
absence of arrival/ownership claims, and acquisition's absent-before/present-at-
culmination custody without persistence afterward. Updated evidence is in
`reports/object_desire_acoustic_probe.json`. These are authored clean synthetic
recordings; physical speaker/microphone validation and channel perturbations for
these new nested outcomes remain pending. Full translator completion is unproven.
