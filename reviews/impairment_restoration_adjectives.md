# Present impairment and restoration adjectives

Decision: existing-sense sentence mappings, not new roots or compounds. Delegated
under the translator-completion goal. Root definitions and all 0/1/2 values remain
unchanged. Source: runtime `lexicon/atoms.yaml`, definitions pinned in
`reports/foundation_inventory_audit.json`.

`WRN:001` defines an intrinsic adverse condition presently producing harmful
deviation from the reference entity's accepted state. The adjective construction
“the radio is damaged/impaired” binds that radio as bearer. This selects the
present adverse-condition sense, not a historical damaging event, a purely
cosmetic alteration without adverse deviation, or a specific physical mechanism.
The translator displays that sense explicitly. A phonemic noun label does not
supply a material qualifier. “Damaged by Ada” requires an additional event/agent
analysis and must not be silently accepted by this construction.

`REP:001` defines an internal acceptable condition presently realized as the
reference entity's restored state. “The radio is restored” binds the radio as
bearer of that condition. It does not assert who restored it, that it is currently
being repaired, or that every possible aspect of it is perfect. The restoration
standard remains context-dependent, as in the source definition.

The focal bearer here is the entity whose internal condition is described; it is
not implicitly the speaker. REP:011 instead treats a distinct reference target;
this mapping does not need to posit a source/target restoration relation.

Contrasts required before release:

- Present damaged condition (WRN:001) versus ongoing damaging (WRN:111), and
  completed damaging (WRN:110). An event may have finished while its result remains.
- Present restored condition (REP:001) versus ongoing restoration (REP:111), and
  completed restoration (REP:110). Completion alone does not guarantee the state
  still holds at a later reference time.
- Negating either condition uses scoped negation, never runtime [0].
- Runtime [0], [1], [2] changes the occurrence ending, never its lexical address.
- Conditional antecedents keep these states local to the antecedent, without
  asserting their truth unconditionally.

This does not solve temperature, mass, sensory intensity, affect, or bodily need.
Those meanings remain separate foundation work.
