# Ordinary requirements — November 23, 2026

“Must not open” now preserves a requirement not to open; “does not have to open” preserves the absence of a requirement. These were separate unmet intentions in the original audit (audit-11 and audit-12). The normal sentence flow now composes these forms across supported verbs and states. Full translation remains unfinished.

## Meaning and reuse

Must and have/has/had to reuse the existing predicate grammar. Before producing a score, an ordinary-language choice distinguishes a rule, duty or commitment from practical/logical necessity. Another meaning stays unresolved. The selected obligation or necessity is independent of runtime 0/1/2, tense, negation and the action's lexical meaning. Existing need-to sentences retain their prior necessary mode and exact performances.

The negation in must not is inside the requirement; the negation in does not have to is outside. Past/future locate the requirement, without asserting that its action was fulfilled. Might have to preserves possibility outside the requirement. Active verbs, supported states, ongoing aspect, object descriptions, placement, maintained-state conditions, questions and existing neutral references remain reusable. Date and direct negative quantity choices retain the selected requirement mode. Multiple sentences may select a separate mode for each requirement.

The existing modality_obligated and modality_necessary musical frames already encode this distinction. No roots, compounds, sense records or musical frames were added: the dictionary remains at 324 roots, 124 compounds and 607 senses. A fourth parsing pass runs only after the previous three fail. The [review](../reviews/ordinary_requirements_2026_11_23.md) specifies exact scope and exclusions.

Review also caught a personal-meaning routing gap in the new requirement pass: a saved verb meaning could leave its whole sentence without a result. Marking the complete requirement as a supported construction preserves that selected predicate and its roles. The focused tests exercise personal meanings in both duty and necessity readings.

## Executed checks

The [focused suite](ordinary_requirements_2026_11_23/focused-tests.txt) passes **165 independent melody/chord pairs**, with separately specified predicates, roles, ordered scopes, speech acts and runtime. Source-free readback distinguishes the selected duty or necessity. Counterexamples over admissible situations distinguish required non-opening from optional opening; different MIDI hashes alone are not the semantic evidence. **24 frozen older need-to performances** retain exact melody/chord hashes and decoded meanings.

[Eight additional combinations](ordinary_requirements_2026_11_23/heldout-combinations.json), with a [checker](ordinary_requirements_2026_11_23/heldout.mjs), cover placement, negated requirements with deictics, plural references, future obligations with an event date, none under a negative requirement, quantified questions, lowering and mixed-modal discourse references. These are post-implementation engineering cases, not a representative language benchmark.

The clean [implementation regression](ordinary_requirements_2026_11_23/implementation-regression.json) passes **289 checks**, and all [eight release gates](ordinary_requirements_2026_11_23/release-gates.json) pass at `c5cfd46d4522d5cb1a7e51141307c3ee93431a08`. The [Lore integration suite](ordinary_requirements_2026_11_23/lore-tests.txt) passes **322 tests**.

| Browser check, on each local site | Result |
|---|---|
| Layouts at 320, 390 and 768 pixels | 24 passed |
| Actual melody/chord exports independently recovered | 16 passed |
| Other requirement/time meanings remain unresolved | 6 passed |
| Unsupported constructions offer no whole-song action | 15 passed |
| Keyboard choice and Meaning details disclosure | 3 passed |
| Changed input clears the preceding result | 24 passed |
| Visible removal clears the exported song line | 8 passed |

The [translator](ordinary_requirements_2026_11_23/browser-primary.json) and [Lore](ordinary_requirements_2026_11_23/browser-lore.json) exported all 16 matching scores. Compact scores are **14.41–21.20% shorter** on these examples and expand to the same independently recovered meaning. The decoder receives MIDI and the shared public dictionary, without original English or hidden semantic graphs. This is symbolic-score and Chromium viewport evidence, not speaker-to-microphone or physical iPhone/Safari evidence.

## Remaining boundaries and publication

Newly required linked clauses need explicit scope over their relationship and remain unresolved. Perfect must-have, should/ought, passive requirements naming an agent, extra adverbs/complements and some adjective profiles remain open. Stored and closed without an agent retain their supported state readings. Inverted mustn't questions, the source or force of a rule, permission, promised action, fulfillment and general epistemic reasoning have not been inferred. Quantified indefinite items, restricted classes and nested-modal dates retain the earlier guards. See the open [completion plan](../docs/full-translator-next-steps.md).

Published from source `26af8aa5818dd8d8f65c53f324205b23ec4303bd` through [translator PR #37](https://github.com/ragingaxolotl-art/era-zero-translator/pull/37) and [Lore PR #37](https://github.com/ragingaxolotl-art/cyber-pet-lore/pull/37). Merged revisions are `d203b1ec2de32fccefd6e9f44dddc1658e1baee9` and `e7e2b388c77895e102210dc95f47a223668446f2`. [Translator deployment](https://github.com/ragingaxolotl-art/era-zero-translator/actions/runs/45314869646) and [Lore deployment](https://github.com/ragingaxolotl-art/cyber-pet-lore/actions/runs/45315136327) succeeded.

Both [public translator](ordinary_requirements_2026_11_23/public-primary.json) and [public Lore](ordinary_requirements_2026_11_23/public-lore.json) repeat every browser-table check, with all 16 exports matching both local sites. The public checker explicitly waits for the dictionary picker before testing sentences. A [first Lore run](ordinary_requirements_2026_11_23/public-lore-first-timeout.json) timed out at that loading prerequisite before testing a sentence. A [fresh diagnostic](ordinary_requirements_2026_11_23/public-lore-diagnostic.json) observed the correct version, 449 picker entries, the expected requirement choice and no page error; the unchanged full checker then passed. The cause of that first timeout was not established. Its evidence remains recorded. This sentence check does not certify startup reliability under every network condition; the separately reproduced early-click loading problem has its own repair and fault-injection checks.
