# DAT:000–022 Cross-Family Collision Report

Status: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**

## Root-level collision matrix

| Root | Permanent center | Highest collision risks | Disposition |
| --- | --- | --- | --- |
| DAT:000 | persistent internal datum | MIN memory; MAT medium; STR storage | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:001 | manifest internal datum | MIN memory; MAT medium; STR storage | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:002 | dormant internal datum | MIN memory; MAT medium; STR storage | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:010 | persistent target reference | CON message addressing; LOG reference relation; STR pointer | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:011 | manifest target reference | CON message addressing; LOG reference relation; STR pointer | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:012 | dormant target reference | CON message addressing; LOG reference relation; STR pointer | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:020 | persistent shared dataset | STR database; CON shared channel; LOG schema | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:021 | manifest shared dataset | STR database; CON shared channel; LOG schema | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |
| DAT:022 | dormant shared dataset | STR database; CON shared channel; LOG schema | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |

## Family-by-family audit

- **LIF:** LIF owns living identities, biological conditions, agents, and social collectives. Data can describe a living bearer or participant, but the information object is not the life, role, health, memory bearer, or agency it represents.
- **MOV:** MOV owns position, path, displacement, and motion affordances. Data may represent a position or route, but a reference, record, or dataset neither moves nor constitutes the physical route or destination.
- **MAT:** MAT owns substance, energy, force, contact, media, and material capacities. A physical inscription or device may realize data, but DAT identifies the information object rather than its material substrate.
- **MIN:** MIN owns awareness, belief, attention, memory, intention, and subjective representation. A datum can persist or be manifest independently of whether any observer knows, believes, recalls, or understands it.
- **CON:** CON owns channels, participants, communication acts, delivery, reception, and exchange relations. A message may carry DAT content, but transmission and participant linkage are not the information object itself.
- **WRN:** WRN owns faults, hazards, adverse processes, warnings, susceptibility, and propagation. Data may describe or signal a fault, but the information object is not the adverse condition or warning act.
- **STR:** STR owns arrangements, boundaries, interfaces, schemas-as-structure, dependencies, and structural capacities. Data can encode a structure, but the information object remains distinct from the arrangement it represents.
- **REP:** REP owns restoration conditions, restorative processes, and restorative affordances. Backups and checkpoints are data objects that may support repair, but DAT does not assert restoration or recoverability.
- **LOG:** LOG owns formal constraints, evaluations, and evaluation affordances. Data can represent criteria, operands, proofs, or results, but representation is not the formal rule, evaluation, or applicability relation.
- **CRE:** CRE owns creation, transformation, generation, and productive capacities. Creating or changing data is a process distinct from the resulting information object and its manifest status.
- **ORI:** ORI owns temporal, modal, causal, and ontological qualification. Data persistence, manifestation, and dormancy do not encode past, future, possibility, necessity, probability, or origin.

## Required non-entailments and overlap rules

- An information object is not its physical medium, storage location, owner, observer, communicative act, formal interpretation, or truth value.
- A manifest datum is presently instantiated in the stated scope; it does not entail access, observation, understanding, truth, transmission, indexing, or active processing.
- A dormant datum remains maintained but unmanifest; it is not deleted, corrupted, inaccessible, forgotten, future, merely possible, or uncertain.
- An internal datum belongs within one reference entity. A target reference denotes one distinct referent. A shared dataset coordinates information objects across multiple participants in one information domain.
- Several unrelated data objects do not form one shared dataset merely because they coexist or share a medium.
- Persistent identity may co-occur with manifest or dormant status; manifest and dormant are exclusive for the same information object at one reference time.
- Runtime `[2]/num` leaves a selected assertion unresolved and never selects lexical dormancy.

**CONCLUSION: DAT:0XX STANDS ALONE ONLY FOR INFORMATION-OBJECT IDENTITY AND PRESENT MANIFESTATION; MEDIA, BELIEF, COMMUNICATION, PROCESSING, ACCESS, TRUTH, AUTHORITY, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**
