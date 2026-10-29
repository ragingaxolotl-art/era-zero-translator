# Semantic IR and Executable Grammar Validation

Status: **PASS — BOUNDED SEMANTIC IR REGRESSION**

- Checks passed: **14**
- Checks failed: **0**
- IR version: **1.0**
- Valid cases: **16**
- Invalid cases: **13**
- Canonical atoms preserved: **324**
- Canonical compounds preserved: **39**
- This fixture suite does not establish full translator completion.

## PASS — lexical immutability

atomic baseline matches directly or through exact editorial reconciliation; compound fingerprint remains unchanged

## PASS — complete required scope

IR covers every required semantic and grammar area

## PASS — dimension separation

trit, runtime, polarity, modality, time, and aspect are explicitly independent

## PASS — role inventory

core roles and typed extensions are explicit

## PASS — negation scope

negation is explicit and cannot be encoded as runtime zero

## PASS — quantity and units

canonical numbers, quantifiers, units, and none-vs-negation are specified

## PASS — modality separation

modality has named modes and is separate from runtime and lexical potential

## PASS — time and transition

reference-time relations, aspect, and explicit before/after states are specified

## PASS — composition

coordination, sequence, parallelism, repetition, recursion, and conditionals are explicit

## PASS — canonical identity

serialization defines deterministic UTT content identity and excludes surface metadata

## PASS — valid cases

all diverse valid conformance cases pass

## PASS — invalid cases

all invalid fixtures produce their required diagnostics

## PASS — later-gate boundary

the semantic-IR release itself started no renderer, decoder, or translator work

## PASS — authority integration

semantic IR remains canonical after orderly downstream progression

