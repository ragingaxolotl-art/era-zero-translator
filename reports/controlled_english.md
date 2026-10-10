# Controlled English Compiler 1.0

Status: **CANONICAL — GENERAL-ENGLISH GATE MAY BEGIN**

This gate implements a deliberately restricted English-facing compiler. Exact quoted canonical labels combine with explicit runtime states, speech acts, roles, scope operators, speech-time relations, measurements, quantifiers, sequence, parallelism, repetition, and conditionals. Every successful compilation produces canonical Semantic IR and passes through the existing deterministic renderer and inverse decoder.

The compiler does not accept unrestricted prose, infer synonyms, recover omitted roles, choose a first sense, or equate runtime state with negation, modality, or tense. Unsupported input returns a structured error with a stable code and no partial IR. Open compound slots must be explicitly bound.

The golden suite contains 16 valid translations and 17 negative cases. Exhaustive lexical tests cover all 352 controlled canonical labels (324 atoms and 28 compounds).
