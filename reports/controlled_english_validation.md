# Controlled English Compiler Validation

Status: **PASS — CONTROLLED ENGLISH CANONICAL; GENERAL ENGLISH MAY BEGIN**

- Checks passed: **13**
- Checks failed: **0**
- Controlled lexemes: **353**
- Golden valid cases: **16**
- Golden invalid cases: **17**
- Exhaustive lexical round trips: **353**
- General English authorized next: **yes**
- General English implemented: **no**

## PASS — source immutability

sense index, semantic IR, and renderer match recorded fingerprints

## PASS — controlled label partition

all and only canonical atom and compound canonical labels are controlled

## PASS — golden translations

every valid controlled input deterministically compiles, renders, and decodes to the recorded IR

## PASS — structured failures

invalid and unsupported inputs return exact stable errors without partial IR

## PASS — exhaustive lexical translation

all controlled labels resolve to their one approved atom or compound and round-trip

## PASS — restricted grammar

simple, sequence, parallel, repetition, and conditional templates are explicit and ordered

## PASS — semantic dimension separation

negation, modality, aspect, time, quantity, measurement, and runtime create distinct IR structures

## PASS — slot enforcement

slotted compounds fail without all roles and succeed with explicit source and target

## PASS — no silent guessing

boundary forbids synonyms, implicit roles, first-sense choice, and general parsing

## PASS — error inventory

documented errors cover parse, lexicon, state, operator, role, quantity, slot, and composition failures

## PASS — implementation

compiler library, CLI, spec, golden tests, and report exist

## PASS — general-English boundary

the controlled-English release itself began no general-English work

## PASS — authority integration

controlled English remains canonical after orderly downstream progression

