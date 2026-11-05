# Drinking: dependency review and implementation order

The executable audit `tools/audit_drinking_dependencies.mjs` pins current meanings
in `reports/drinking_dependency_audit.json`. No new root or approved compound is
created by this review.

The ordinary desired outcome “Nora drinks the tea” remains unsupported. Thirst is
already defined as a felt demand for water and explicitly does not assert drinking.
Bodily replenishment need is likewise a feeling. Neither should be reused as the
action. Generic physical entry provides useful movement/region structure, but a
liquid entering a body or container does not by itself identify a drinking action.
The noun label “tea” identifies a referent; it is not proof of liquid composition,
a particular portion, ownership, or consumption of an entire amount.

The next reusable meaning must bind a drinker and consumed material under an
explicit literal-drinking action convention. It must distinguish ongoing activity
from a completed amount/event and habitual activity, with time, negation, modality,
and runtime independent. It must not add thirst, conscious intention, pleasure,
nutrition, ownership or successful relief merely because the action is drinking.
A material reference inside desire must not become an assertion of an actual event.

Before selecting a compound structure, resolve how material/portion typing and the
consumption route are represented. Reuse the existing motion and material structure
only if its full commitments fit; do not attach arbitrary roots as padding. The
existing entry compounds are dependency candidates, not an automatic derivation.
No evidence here justifies a new LIF, STR or other root family.

Required contrast cases include thirst without drinking, drinking without a thirst
claim, pouring into a container, non-drinking material entry, ongoing versus bounded
consumption, a negated drink versus wanting not to drink, and two differently bound
drinkers/materials. Each needs a complete meaning and independently recovered sound.
Add the interface choice only after its meaning/renderer/inverse agree. Keep
“wants tea” unresolved until the intended outcome is explicitly supplied; drinking
is one possible reading and must never be its default.

## Material-reference prerequisite checkpoint

`pages/material_reference.mjs` now supplies a gated, validated reference document
for a material kind or a contextually identified portion. It reuses existing noun
sound labels and nominal-class/definite/proximal/distal reference modes. A bare
noun can be explicitly selected as a kind; a portion requires the/this/that.
Neither liquid classification nor amount, whole-portion consumption or independent
existence is asserted. Existence follows the enclosing content's commitments.

Eight tea/water × kind/definite/proximal/distal cases retain distinct identities.
Validation rejects rehashed invented quantity, classification, total-consumption
and existence claims. Implicit portion selection, unknown reading, modified nouns
and unimplemented quantity forms reject. No roots, approved compounds or musical
addresses changed. This is a semantic prerequisite only: it is not yet wired into
a drinking action, musical transport or the interface. The next work is the
consumption action contract with explicit participant binding, followed by joint
meaning/rendering/inverse integration and blind-audio checks.

## Literal action meaning checkpoint

`drinking_meaning.mjs` now provides an explicit draft convention for oral intake
of liquid as drink. The action identifies the drinker and material independently;
the material label alone still does not classify every referent bearing that name
as liquid. The action's classification is inside its scoped content. No thirst,
ownership, pleasure, benefit, intention or consumption of a whole portion follows.
This is a declared semantic extension, not a deduction from generic entry or thirst.

Viewpoint is required: ongoing activity does not assert a completed amount;
bounded drinking presents a whole event with some intake but no total portion;
habitual drinking does not assert an occurrence at speech time. Thirty-six
viewpoint × assertion/question × negation × runtime cases pass strict meaning
validation, alongside participant contrast and rehashed contract rejection. Runtime
is independent of amount, aspect and negation. The material-reference prerequisite
is reused without altering its identity or quantity commitments.

The document remains draft. There is no English route, allocated musical frame,
independent renderer or audio inverse yet. Those must be implemented together with
participant-binding and contrast tests before drinking can count as translated.
