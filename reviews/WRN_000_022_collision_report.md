# WRN:000–022 Cross-Family Collision Report

Status: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**

## Root-level collision matrix

| Root | Permanent center | Highest collision risks | Disposition |
| --- | --- | --- | --- |
| WRN:000 | persistent internal fault | MAT/LIF damage; LOG invalidity; DAT evidence; MIN diagnosis | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:001 | manifest internal fault | MAT/LIF damage; LOG invalidity; DAT evidence; MIN diagnosis | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:002 | latent internal fault | MAT/LIF damage; LOG invalidity; DAT evidence; MIN diagnosis | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:010 | persistent external hazard | MOV approach; MAT contact; MIN intent; WRN exposure/attack relation | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:011 | manifest external hazard | MOV approach; MAT contact; MIN intent; WRN exposure/attack relation | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:012 | dormant external hazard | MOV approach; MAT contact; MIN intent; WRN exposure/attack relation | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:020 | persistent distributed fault | CON/DAT network; STR dependency; ORI probability; WRN propagation process | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:021 | manifest distributed fault | CON/DAT network; STR dependency; ORI probability; WRN propagation process | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |
| WRN:022 | latent distributed fault | CON/DAT network; STR dependency; ORI probability; WRN propagation process | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |

## Family-by-family audit

- **LIF:** LIF owns living identity, health state, care, harm to organisms, and social collectives. WRN may classify an adverse condition affecting life, but it does not itself assert injury, illness, fear, care, or social identity.
- **MOV:** MOV owns location, approach, traversal, redirection, and shared motion. A moving object can be hazardous, but WRN names the adverse condition rather than the displacement or route.
- **MAT:** MAT owns substance, energy, force, contact, fracture, and other physical states. WRN names the adverse significance of a condition; material damage, collision, heat, and pressure require MAT claims.
- **MIN:** MIN owns perception, belief, attention, intention, fear, and suspicion. A fault or hazard may be unknown or disbelieved and still exist; uncertainty in an observer is not lexical latency in WRN.
- **CON:** CON owns signals, alerts, messages, channels, and participant exchange. Communicating a warning does not create the adverse condition, and an uncommunicated condition may still be WRN:0xx.
- **REP:** REP owns diagnosis as restoration work, repair, recovery, replacement, and maintenance. A WRN entity may motivate repair but does not assert that repair is possible, attempted, or successful.
- **STR:** STR owns positions, interfaces, arrangements, transformations, and structural affordances. A malformed or unsafe structure needs WRN for adversity and STR for the structural fact; neither family subsumes the other.
- **LOG:** LOG owns validity, contradiction, permission, constraints, type judgments, and formal nonconformance. WRN does not make a proposition false or a value invalid merely because its consequences are dangerous.
- **DAT:** DAT owns records, error codes, evidence, measurements, schemas, and provenance. Data can describe a fault or hazard without being that condition; corrupted information requires DAT plus WRN when adversity is asserted.
- **CRE:** CRE owns generation, design, fabrication, mutation, and destruction as transformations of artifacts. A defect may result from creation or destruction, but WRN:0xx names the adverse condition after causal history is factored out.
- **ORI:** ORI owns time, existence, general possibility, necessity, and manifestation. WRN lexical stable, active, and dormant status is specific to adverse conditions and never replaces tense, probability, or unrestricted modality.

## Required non-entailments and overlap rules

- An intrinsic fault is not the entity bearing it, the material mechanism, a validity judgment, a symptom, an observer's belief, or a diagnostic record.
- An external hazard is not its approach, contact, attack, exposure relation, warning signal, target damage, or the intent of an agent.
- A distributed fault requires one correlated adverse identity across multiple participants; several unrelated faults, a dependency graph, or simultaneous symptoms do not suffice.
- A latent or dormant condition is asserted to exist without current harmful manifestation; hidden from an observer, unconfirmed, improbable, merely possible, or scheduled for the future are different claims.
- A manifest condition does not entail detection, communication, attribution, severity, successful harm, containment, repairability, or causal propagation.
- Each persistent `...0` root is neutral about the present `...1`/`...2` condition and may co-occur with either. Only manifest `...1` and dormant `...2` are mutually exclusive for one condition at one reference time.
- Runtime `[2]/num` leaves a selected assertion unresolved and never selects the lexical latent or dormant root.

**CONCLUSION: WRN:0XX STANDS ALONE ONLY FOR ADVERSE-CONDITION IDENTITY AND MANIFESTATION; BEARERS, MECHANICS, EVIDENCE, BELIEFS, SIGNALS, RULES, PROCESSES, RELATIONS, PROBABILITY, SEVERITY, AND REPAIR REMAIN SEPARATE OR COMPOUNDED.**
