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
