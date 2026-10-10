# Gate 4C English Concept and Sense Index

Status: **CANONICAL CORE RELEASE**  
Version: **1.0.0**

## Inventory

- Canonical atom-label senses: **324**
- Canonical compound-label senses: **28**
- Reviewed high-frequency senses: **84**
- Total sense records: **436**
- Normalized English lemmas: **419**

## Design result

The index separates an English surface form from its intended sense. A sense may route to one atom, one approved compound, grammar, semantic IR, or an explicit vocabulary gap. Exact canonical labels form the deterministic controlled vocabulary. Common polysemous words such as *go*, *move*, *run*, *return*, *send*, *share*, *change*, *know*, *exist*, *have*, and *home* require sense selection rather than first-match lookup.

No unsupported reading is silently mapped to a nearby root. Water, food, friendship, safety thresholds, truth values, generic thought, possession, and dwelling senses remain explicit gaps where the current atomic inventory lacks the necessary invariant distinction.

## Critical separation examples

- *send* separates communicative expression (`CON:101`) from active target data transfer (`DAT:111`).
- *receive* separates participant uptake (`CON:111`) from completed data transfer (`DAT:110`).
- *change* separates material, mental, structural, and data transformations; domain-unspecified change routes to semantic IR.
- *exist* separates persistent distinct-existence (`ORI:010`) from completed distinct actualization (`ORI:110`).
- *run* separates locomotion, program execution, and machine operation; all require later IR because the existing atoms do not lexicalize those full occurrences.
- tense words do not masquerade as lexical third-trit values; *past* and *future* route to semantic IR.

## Boundary

This release is a sense inventory and routing contract, not an English parser. Gate 4D must measure expressibility and ambiguity. Etymology, semantic IR, executable grammar, renderer, decoder, and translator remain unstarted.
