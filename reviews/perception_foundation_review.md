# Perception foundations: inventory review and dependency decision

Status: design review, not a canonical lexicon extension. Existing meanings and
sounds are unchanged. Evidence is pinned in
[the complete inventory snapshot](../reports/foundation_inventory_audit.json),
covering all 324 runtime roots and all 32 approved compounds. Regenerate with
`ruby tools/audit_foundation_inventory.rb`; check freshness with `--check`.
The snapshot makes the scope reproducible; its hashes are not semantic proof.

## Finding

No reviewed root definition identifies a sensory modality. The present inventory
also does not directly define sensory experience or perceptual access. Mental
representation, attention, information transfer, consciousness, and physical
influence are useful ingredients but are not interchangeable with perception.
This review supports an explicit new lexical distinction. It does **not** establish
that a new 27-root family is the best way to introduce that distinction.

A conventional compound could carry an explicitly documented new sense while
preserving the existing root grid. That would be a lexical extension, not a claim
that the current components already logically entail that sense. Pure composition
and conventional specialization must remain separately identified in the registry.

## Authority reconciliation

Nine MIN:0xx entries previously retained two historical cross-references each, saying that
perception/learning belong to provisional MIN:1xx and belief/uncertainty belong to
provisional MIN:2xx. The later reviewed MIN:1xx definitions specify representational
change; MIN:2xx specifies selective attention. In particular:

- MIN:111 excludes perception when no representational change is asserted, and
  does not entail perception when change is asserted.
- MIN:211 explicitly excludes sensory stimulation and consciousness from its
  attentional meaning.
- MIN:011 denotes a manifest mental representation, including cases without
  present sensory input.

The earlier pointers are not approval to translate “see” as MIN:111, “believe” as
MIN:210, or “uncertain” as MIN:212. Preserve their historical provenance, but resolve
runtime senses from the later invariant definitions. The editorial migration in `migrations/min_cross_reference_reconciliation_2026_10_28.yaml`
now corrects those pointers across active inventories, the canonical specification
and browser index. Historical review packets remain intact. The compatibility
validator reverses exactly the documented edits and requires the complete original
record fingerprint; changes to other fields cannot pass as this migration.

## Full-family review

Each row covers all 27 definitions in that family, including the entity, process,
and capacity/relation variants. The counterexample concerns the family's ability
to supply a missing sensory distinction, not every possible use of its roots.

| Family | What the reviewed definitions supply | Why that does not select perception or modality |
|---|---|---|
| LIF | Identity, consciousness, development, viability, care, living relations | A conscious being can remember or imagine; consciousness alone does not select seeing or hearing. |
| MOV | Position, displacement, routes and positional capacities/relations | Movement can propagate a signal but also occur without any perceiver. |
| MAT | Material bearers, physical change, work capacity and physical influence | A signal can physically affect an unconscious body or a device. No definition selects light, acoustic pressure, or sensory registration. |
| MIN | Representations, representational change, selective attention | Remembering and imagining can satisfy these predicates without current perceptual access. Attention is neither a sensory channel nor a guarantee of perception. |
| CON | Communication endpoints, expression uptake, shared exchange | Hearing thunder need not be communicative; message uptake need not be auditory or visual. |
| STR | Constituents, interfaces, arrangements and incorporation | A receptor's structure does not assert its sensory function or experience. |
| WRN | Adverse conditions, impairment and susceptibility | Injury can occur without pain; unpleasant perception need not be injury. |
| REP | Restoration standards, restorative change and pathways | Recovery of a sensor does not assert a particular perceptual episode. |
| LOG | Formal constraints, evaluation and applicability | Evaluation of a sensory classification does not itself constitute sensory access. |
| DAT | Information objects, transfer, transformation and synchronization | A copied record can satisfy information transfer without observation or experience; physical medium and observation are explicitly excluded. |
| CRE | Generative patterns, products and production | Production can create a stimulus or a model, but does not assert perception; subjective imagination is also explicitly excluded. |
| ORI | Existence, grounding, ontological transitions and dependence | Grounding does not select causal sensory access; observation and evidence are explicitly excluded. |

All 32 approved compound invariants were also inspected. They cover artifacts,
living/material systems, repair, information/communication structures, formal
relations, hazards, and the approved poetic love meaning. None adds sensory
modality or a sensory-experience relation. This is a review of their definitions,
not a keyword-based claim about all possible future compounds.

## Candidate compositions and counterexamples

| Candidate ingredients | What they can assert | Counterexample to the intended perceptual meaning |
|---|---|---|
| MIN:011 + LIF:011 | A conscious other with a manifest target representation, with explicit participant binding | Ada consciously remembers Pip in a dark, silent room. This is not present seeing or hearing. |
| MIN:111 + DAT:111 | A target representation changes while information is received | Ada receives a stored text description. This does not establish direct perception of the described target. |
| MIN:211 + MAT:211 | Attention toward a target plus physical influence, with the relations explicitly linked | Ada attends to a remembered person while that person's unattended device warms her chair. Even causal linkage alone would not select sensory channel. |
| CON:111 + MIN:011 | Communicative uptake associated with a mental representation | Ada reads a silent message. It cannot be called hearing merely because uptake occurred. |
| MIN:111 + CRE:101 | Representational change associated with generative-pattern production | Designing an external pattern does not necessarily assert imagination or a sensory experience. |
| MIN:011 + WRN:001 | A representation associated with an adverse condition | An unnoticed injury and a remembered injury do not assert felt pain. |

Adding more levels of these same compounds does not, by itself, name a channel.
Conversely, this table is not a formal impossibility proof over every legal graph.
Any new candidate must identify its additional assumption and pass the contrasts.

## Foundational concepts to define before specialized words

These are definition requirements, not assigned DBA addresses or approved glosses.

1. **Sensory registration:** an agent or system registers an input through an
   identified sensory channel. Required roles: receiver, input, channel. This
   does not alone assert conscious experience, object identification, truth, or
   attention. Decide explicitly whether a device and a living perceiver share
   this sense or have separate senses.
2. **Sensory experience:** an experiencer has a sensory appearance with content
   and modality. This does not guarantee an external matching object. Keep the
   experience/content distinction explicit so hallucination is not silently
   treated as successful access to an existing target.
3. **Perceptual access:** a perceiver has sensory access to an actual target via
   a specified channel. This needs an explicit target-access relation, not just
   an unrelated experience plus an existence assertion. It does not entail
   recognizing, understanding, remembering, or paying attention to that target.
4. **Channel identities:** establish visual, auditory, tactile, olfactory and
   gustatory senses independently; leave room for other senses. “Touch” as an
   action/contact relation must stay separate from tactile experience. A sound
   label for a noun such as “light” identifies a referent; it does not, by itself,
   establish a visual sensory mechanism.
5. **Derived vocabulary:** after the relevant foundations are stable, define
   seeing/hearing, attentive looking/listening, sensory qualities and degrees,
   then recognition, interpretation and specialized perception compounds.
   Recognition also needs identity matching; understanding needs its own success
   criterion. Neither is merely increased attention or representational change.

Registration, experience and access are related but not one mandatory linear
chain. Channel identities can be reviewed alongside them. Specialized terms depend
on the subset their definitions actually require. This prevents early loose
“see = think” mappings from contaminating later compounds of compounds.

## Release decision and next work

Preserve the 324-root inventory while defining explicitly conventional compounds
for these foundations. The implemented extension in
`spec/conventional_compounds_1.0.yaml` records additional meaning in compound
identity and gives it a distinct ternary frame around its exact expanded scope.
Nested dependency reuse, argument bindings and runtime endings are tested. No
sensory convention has yet been approved; see
`reviews/conventional_compound_foundations.md` for the definition and contrast work
that must precede seeing/hearing vocabulary. A compound must not silently gain a
new sense merely through an English alias.

Compare that design against a small primitive extension only after the exact
missing distinctions are specified. Do not invent an entire family to fill 27
slots. Either route requires a versioned sound/meaning contract and contrast tests:

- sees / hears / remembers / imagines the same target;
- senses / attends to / understands the same input;
- physical contact / tactile experience;
- a device registers a signal / a person experiences a signal;
- experiences an appearance / perceives an actual matching target.

The general translator cannot be declared complete until these common meanings
have actual representations and survive musical export and inverse interpretation.
