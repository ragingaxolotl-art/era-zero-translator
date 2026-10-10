# Era Zero Semantic IR and Executable Grammar 1.0

Status: **CANONICAL — RENDERER/DECODER GATE MAY BEGIN**

This release defines the language's first complete proposition layer. It represents lexical occurrences, typed roles, explicit scope, negation, quantity and measurement, modality, reference time, aspect, state transitions, coordination, sequence, parallelism, repetition, finite recursion, coreference, and deterministic content identity.

## Critical separations

Lexical third trit, runtime state, negation, modality, tense, and aspect remain independent. Runtime `[0]` never means “not”; `[1]` never means present tense or truth; `[2]/num` never means future or possible modality. A root lexically ending in trit 2 retains that invariant even when its occurrence has runtime state `[0]`, `[1]`, or `[2]/num`.

## Execution boundary

“Executable” means the graph has deterministic validation, binding, scope, evaluation order, error classes, and canonical serialization. It does not mean an English parser, renderer, decoder, MIDI engine, glyph generator, or general translator has been implemented. The next gate maps this canonical IR into formal notation and back with round-trip conformance.
