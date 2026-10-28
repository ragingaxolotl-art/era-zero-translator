# General-English Candidate Translator Validation

Status: **PASS — CORE TRANSLATOR PIPELINE CANONICAL**

- Checks passed: **16**
- Checks failed: **0**
- Indexed senses: **443**
- Analysis fixtures: **13**
- Resolution fixtures: **4**
- Exact-lemma sense recall: **443/443**
- Silent first-match selection: **no**
- Next authorized gate: **glyph and audio**

## PASS — source immutability

sense index, controlled English, and Semantic IR match recorded fingerprints

## PASS — ranking contract

ranking weights, deterministic tie break, confidence, and ambiguity margin are explicit

## PASS — analysis fixtures

all recorded analyses are byte-for-byte deterministic

## PASS — explicit resolution

selected lexical readings resolve through controlled English, IR, EZF-1, and exact decode; structural misuse fails

## PASS — indexed-sense recall

every indexed sense is returned for its exact lemma

## PASS — conservative auto-resolution

unique exact direct sense plus explicit runtime may auto-resolve and round-trip

## PASS — runtime clarification

a unique lexical sense still exposes three IR state alternatives and asks for runtime

## PASS — polysemy clarification

go and change expose competing senses instead of selecting file order

## PASS — contextual evidence

selection-cue and definition evidence ranks the data-transformation sense first but preserves clarification

## PASS — gap honesty

single and polysemous vocabulary gaps remain explicit with no invented IR

## PASS — structural routing

semantic-IR and grammar senses request structure instead of collapsing to lexical atoms

## PASS — open-slot clarification

slotted compounds expose required roles and no premature candidate IR

## PASS — structured failure

unknown input and invalid runtime markers return stable errors without translation

## PASS — no silent first match

auto-resolution policy and implementation prohibit material ambiguity, missing state, missing roles, structural routes, gaps, and nonexact matches

## PASS — implementation

library, CLI, spec, tests, report, and migration exist

## PASS — authority integration

general English remains canonical and its migration records the glyph/audio handoff

