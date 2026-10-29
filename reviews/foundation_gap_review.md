# Foundation gap review

Status: noncanonical semantic review. No roots, aliases, compounds, or musical
addresses are approved by this document. Reviewed against the runtime authority
loaded by `EraZeroRenderer.load_authority` (324 roots), 2026-10-28.

## Decision

Do not build a large compound dictionary before resolving the distinctions below.
The existing inventory provides useful general processes, but its definitions do
not yet establish several everyday sensory and affective distinctions. This is
evidence for a foundation review, not proof that a particular new 27-root family
is necessary. Preserve all current meanings and melodies.

An English alias is sufficient only when the existing definition entails the
requested sense. A recursive compound can reuse established meaning; depth alone
does not introduce a missing distinction. A conventional compound may introduce
a documented specialized sense, but that addition must be explicit and reviewed.

## Evidence and contrast obligations

| Foundation | Closest existing definitions | Missing distinction | Required contrasting examples | Dependency priority |
|---|---|---|---|---|
| Perceptual modality | MIN:011 manifest target representation; MIN:111 active target-model revision; MIN:211 active target attention | A representation or attention can occur through sight, hearing, another sense, memory, or imagination. None of these definitions selects a sensory channel or establishes perception. | Ada sees Pip / Ada hears Pip / Ada imagines Pip. Attention to Pip must not decide among them. | Establish perception and modality before bright, loud, rough, taste, or smell compounds. |
| Measurable dimensions | MAT:011 energized material object; MAT:111 ongoing target physical-state change; MOV:121 ongoing movement relative to a frame | Energized does not select temperature; physical change does not select mass, length, or speed. Movement alone supplies neither elapsed duration nor rate. | The pump is hot / the pump is active; the box is heavy / the box is large; Pip moves fast / Pip moves far. | Establish dimension identity, quantity, and comparison before degree adjectives or acceleration compounds. |
| Affective valence | MIN:001 manifest self-representation; MIN:211 active attention; LIF:211 care | Awareness and attention do not specify pleasant or unpleasant experience. Care is an action toward another, not a positive feeling. | Ada enjoys the sound / Ada attends to the sound; Ada feels happy / Ada cares for Pip. | Establish felt valence before pleasure, distress, enjoyment, and more specialized emotions. |
| Desire and preference | MIN:210 established attention relation; ORI:211 operative dependence | Preferential allocation of processing is not preference for an outcome. Dependence does not entail wanting, intention, or subjective need. | Ada wants water / Ada depends on water; Ada prefers Pip / Ada watches Pip. | Establish wanting and comparative preference before curiosity, motivation, and voluntary choice. |
| Bodily deficit | LIF:200 stable viability; MAT:201 available work capacity; ORI:211 operative dependence | Viability, energy capacity, and dependence do not specify a felt shortage, its bodily kind, or its relief. | Ada is hungry / Ada needs water; Ada is tired / Ada is dormant. | Review deficit and replenishment after desire/experience; keep hunger, thirst, fatigue distinct. |
| Locomotion manner | MOV:121 ongoing shared-frame movement; MAT:000 material body | These do not specify support, propulsion, contact cycle, or medium interaction. A medium's noun label does not express the manner. | Ada swims / Ada is carried through water; Ada runs / Ada moves quickly. | Establish manner ingredients before named locomotion compounds. |

These are entailment failures of the listed candidate ingredients, not a formal
proof that no graph over the entire lexicon can express each concept. Every
proposed definition still requires a search of the full inventory and approved
compounds, followed by counterexamples. Do not use keyword absence as that proof.

## Order of work

1. Separate lexical foundations from grammar: bearer/experiencer roles, comparison,
   degree, negation, quantities, and clause scope need explicit representations.
2. Review perception/modality, dimensions, felt valence, and desire independently.
   They are parallel foundations, not synonyms or one mandatory new family.
3. For each proposed foundation, write its invariant, exclusions, argument roles,
   and the contrasts above. Attempt a meaning-preserving existing-root definition.
4. Classify the result as an existing sense, an ordinary compositional compound,
   an explicitly conventional compound, a grammar feature, or an unresolved
   primitive candidate. Record the additional meaning of any convention.
5. Only then decide whether coherent unresolved primitives warrant a family or an
   architecture extension. Do not invent 27 meanings to fill an address grid.
   Any proposal must include sound-address compatibility and a versioned migration.
6. Establish accepted reusable concepts before dependent words. Track dependencies
   by versioned concept IDs; reject cycles and silently changed definitions.
7. Test novel sentences and audible contrasts. Different English strings or
   different semantic hashes alone do not prove the musical distinction survives.

## Immediate implementation boundary

Existing-root sentence composition can continue while this review is unresolved:
it does not require inventing new meanings. Vocabulary expansion that depends on
the missing distinctions must wait for their definitions. In particular, do not
map hot to active, liking to care, curiosity to attention, or tired to dormant.
Noun and proper-name sound labels remain identifiers, not substitute meanings for
verbs or adjectives.

## Cognitive meanings that do not need new primitives

The reviewed MIN definitions support three separate sentence foundations:

- MIN:211: presently directing cognitive processing toward a target → paying
  attention to that target. The cognizer fills experiencer, and the object of
  attention fills target.
- MIN:111: actively changing a mental representation of a target → revising a
  mental representation of that target. This does not entail learning a truth,
  understanding it, or correcting an error.
- MIN:201: presently available capacity to allocate processing selectively →
  being able to pay attention. This does not assert that attention is currently
  directed to any particular target.

These mappings reuse definitions and add sentence composition, not new roots.
Curiosity, learning, and understanding remain distinct review items. In particular,
attention plus a target alone supplies neither a desire to know nor a truth or
success condition. The broader cognitive compounds must be built only after those
additional ingredients are established.

## Full perception inventory review

The [perception foundation review](perception_foundation_review.md) now checks all
324 current root definitions and 32 compound invariants. It identified 18 stale
provisional cross-references in nine MIN entries (now editorially reconciled), distinguishes their historical
wording from later approved definitions, and specifies registration, experience,
access and channel identities before derived perception vocabulary. The pinned
inventory report supports reproducibility, not an automatic expressibility proof.

## Generic repair versus physical repair

The ordinary repair construction now reuses REP:111 for ongoing target restoration
and REP:110 for completed target restoration. Its intended sense is bringing a
target back toward its applicable acceptable condition. It does not select a
material, structural, data, biological or social mechanism. The noun label supplies
the referenced target without inventing a mechanism from the label's spelling.

Explicit “physically repairing” continues to use its more specific MAT-qualified
compound. General repair must not acquire physical specificity merely because the
target is called a radio, nor should its use require the speaker to add an adjective
that was not in the source sentence. Inspection, maintenance, replacement and
planning remain excluded by the REP definitions unless restoration is also asserted.
This is an existing-sense sentence mapping, not a new primitive or compound.


## Ternary preservation requirement

The [ternary foundation contract](ternary_foundation_contract.md) records the full
source ranges for runtime 0/1/2 and distinguishes them from lexical trits. New
foundations must keep sensory channel, magnitude, valence, desire and tense separate
from those states; compound dependencies retain their original addresses.

## Dimension review refinement

The [dimensional foundation review](dimensional_foundations.md) distinguishes the existing IR unit conventions from missing lexical roots. Explicit mass statements now use the existing mass units and quantity role with a material bearer; this needs no new primitive. Property axes, ratios, comparisons and contextual adjectives remain separate dependencies. Absence of a root gloss is not proof that the broader language lacks the dimension.
