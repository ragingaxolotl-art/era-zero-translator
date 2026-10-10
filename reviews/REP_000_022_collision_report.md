# REP:000–022 Cross-Family Collision Report

Status: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**

## Root-level collision matrix

| Root | Permanent center | Highest collision risks | Disposition |
| --- | --- | --- | --- |
| REP:000 | persistent internal restoration condition | LIF health; MAT integrity; LOG correctness; DAT baseline record | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:001 | manifest internal restoration condition | LIF health; MAT integrity; LOG correctness; DAT baseline record | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:002 | dormant internal restoration condition | LIF health; MAT integrity; LOG correctness; DAT baseline record | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:010 | persistent target restoration condition | LIF patient/care; CRE replacement; REP restoration process; LOG target criterion | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:011 | manifest target restoration condition | LIF patient/care; CRE replacement; REP restoration process; LOG target criterion | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:012 | dormant target restoration condition | LIF patient/care; CRE replacement; REP restoration process; LOG target criterion | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:020 | persistent shared restoration condition | CON coordination; STR system configuration; DAT service record; ORI transition history | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:021 | manifest shared restoration condition | CON coordination; STR system configuration; DAT service record; ORI transition history | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |
| REP:022 | dormant shared restoration condition | CON coordination; STR system configuration; DAT service record; ORI transition history | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |

## Family-by-family audit

- **LIF:** LIF owns living identity, biological health, injury, illness, care roles, and social collectives. REP can identify a restoration condition for a living participant, but it does not define physiology, subjective well-being, or social identity.
- **MOV:** MOV owns position, return, approach, traversal, and shared motion. Returning to a place can participate in restoration, but REP names an acceptable restored condition rather than a displacement or route.
- **MAT:** MAT owns substance, energy, physical integrity, force, contact, fracture, and shape. REP adds restoration-relative acceptability; an intact material object need not be restored, and a restored condition need not be physical.
- **MIN:** MIN owns belief, memory, attention, intention, satisfaction, and perceived normality. A restoration condition may be unknown or disputed and still remain identified; observer uncertainty is runtime or MIN, not lexical dormancy.
- **CON:** CON owns care communication, service requests, coordination, and participant exchange. Communicating or coordinating repair does not constitute a restored condition.
- **WRN:** WRN owns faults, hazards, degradation, impairment, propagation, susceptibility, exposure, and adverse pathways. A dormant REP restoration condition does not assert damage or danger; WRN must separately state the adverse condition or process.
- **STR:** STR owns positions, interfaces, arrangements, transformations, and structural affordances. A restoration condition may include structural facts, but REP does not replace the arrangement or topology itself.
- **LOG:** LOG owns correctness, validity, rule satisfaction, permission, and constraints. A logically valid state need not be the restoration condition, and restoration-relative acceptability may be contextually defined without becoming formal truth.
- **DAT:** DAT owns baselines, checkpoints, backups, records, measurements, schemas, and provenance. A record may describe or preserve a restoration condition but is not the condition itself.
- **CRE:** CRE owns generation, fabrication, replacement, reconstruction, and destruction as transformations. A new or recreated artifact may realize restoration, but creation is not identical to the acceptable condition achieved.
- **ORI:** ORI owns time, prior states, manifestation, possibility, and necessity. REP persistent, manifest, and dormant statuses are restoration-specific and never encode pastness, futurity, probability, or unrestricted modality.

## Required non-entailments and overlap rules

- A restoration condition is not the entity bearing it, the material or biological constitution that realizes it, the rule accepting it, or the record describing it.
- An inward restoration condition is not self-repair, health, correctness, absence of every fault, or confidence that the entity is restored.
- A target restoration condition identifies the acceptable condition of one distinct target; it does not identify a remedy source, caregiver, repair queue, or target-directed restoration process.
- A shared restoration condition requires one correlated acceptable condition across multiple participants; several unrelated restored entities, a dependency graph, or simultaneous repairs do not suffice.
- A dormant condition is identified but unrealized; it does not entail damage, impossibility, recoverability, hiddenness, uncertainty, scheduling, or future realization.
- A manifest condition does not entail a completed or ongoing repair process, permanence, recognition, documentation, or absence of every adverse condition.
- Each persistent `...0` root is neutral about the present `...1`/`...2` condition and may co-occur with either. Only manifest `...1` and dormant `...2` are mutually exclusive for one condition at one reference time.
- Runtime `[2]/num` leaves a selected assertion unresolved and never selects the lexical dormant root.

**CONCLUSION: REP:0XX STANDS ALONE ONLY FOR RESTORATION-CONDITION IDENTITY AND PRESENT REALIZATION; BEARERS, DOMAIN FACTS, DAMAGE, RECORDS, RULES, BELIEFS, PROCESSES, AFFORDANCES, RESOURCES, TIME, AND CAUSATION REMAIN SEPARATE OR COMPOUNDED.**
