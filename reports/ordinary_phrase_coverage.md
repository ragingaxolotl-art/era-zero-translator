# Ordinary phrase coverage audit

Fresh phrase coverage audit authored during implementation; not a blind or representative English benchmark.

Full translator completion: **not established**. 18 of 40 cases pass their declared semantic checks; 21 have no complete composition. These counts do not estimate coverage of English generally.

| Area | Checked compositions | Cases |
|---|---:|---:|
| participants | 2 | 2 |
| scope | 2 | 2 |
| adjectives | 1 | 1 |
| compounds | 1 | 1 |
| movement | 3 | 3 |
| cognition | 1 | 4 |
| coordination | 2 | 3 |
| quantity | 1 | 2 |
| noun_phrases | 1 | 2 |
| discourse | 0 | 1 |
| time | 1 | 2 |
| speech_act | 2 | 2 |
| sensory_dimensions | 0 | 4 |
| affect | 0 | 2 |
| bodily_need | 0 | 3 |
| movement_manner | 0 | 2 |
| comparison | 0 | 1 |
| conditional | 0 | 1 |
| modality | 0 | 1 |
| poetic_meaning | 1 | 1 |

## Unfinished cases

- **She cares for him.** — Resolve both pronouns from discourse or request referents (not_composed)
- **Nora will care for Eli tomorrow.** — Preserve future time and commitment ambiguity (composed_needs_semantic_review)
- **Nora cares for Eli and Orin.** — Both objects belong to the care relation (not_composed)
- **The radio is hot.** — Temperature is not generic activity (not_composed)
- **The radio is heavy.** — Mass or weight must not collapse into size (not_composed)
- **The lamp is bright.** — Express visual intensity (not_composed)
- **The stone is rough.** — Express surface texture (not_composed)
- **Nora is happy.** — Express positive felt affect, not care behavior (not_composed)
- **Nora prefers tea to coffee.** — Preserve preference direction and both alternatives (not_composed)
- **Eli is hungry.** — Distinguish food deficit from thirst and dormancy (not_composed)
- **Eli is thirsty.** — Express water-related bodily need (not_composed)
- **Orin is tired.** — Distinguish fatigue from dormant identity (not_composed)
- **Orin is curious about the map.** — Interest in knowing is not merely attention (not_composed)
- **Nora learned the route.** — Represent learning and its result without equating every revision with truth (not_composed)
- **Eli understands Nora.** — Preserve interpretation or understanding beyond receiving communication (not_composed)
- **Nora runs to the gate.** — Running manner is not any fast movement (not_composed)
- **Eli swims across the river.** — Propulsion and medium interaction are not passive transport (not_composed)
- **Exactly three lamps are active.** — Quantify three bearers, not repetitions of one assertion (not_composed)
- **This lamp is brighter than that lamp.** — Bind comparison direction, dimension, and both referents (not_composed)
- **If the radio is damaged, repair it.** — Preserve conditional scope and object coreference (not_composed)
- **Nora may enter the archive.** — Disambiguate permission versus possibility (not_composed)
- **Nora cares for Eli or Orin is conscious.** — Resolve inclusive versus exclusive interpretation (not_composed)
