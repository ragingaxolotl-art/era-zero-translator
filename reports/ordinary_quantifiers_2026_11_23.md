# Ordinary universal and zero subjects — November 23, 2026

“Every worker waited,” “no worker waited” and “not every worker waited” now use the normal whole-sentence flow. These are reusable grammatical forms across supported predicates, rather than dictionary entries for individual example sentences. Full translation and general recorded-audio recovery remain unfinished.

## Meaning and reuse

Every/each introduces a singular common-noun class with the existing all quantifier. No accepts a singular or plural class and uses none. Not every retains all under outside negation. Class references use existing phonemic noun labels and group markers; they do not invent named individuals, exact cardinalities or gender. Noun agreement remains separate from the class/group representation.

None and not every differ: a mixed group can satisfy not every while failing none. The empty-domain cases also remain distinct under the existing classical quantifier convention. A direct negative with every/each asks whether each member satisfies the negative, or whether the positive is not true for every member. This preserves negation inside the quantified predicate or outside all, without moving a negative across a nested possibility or ability. Existing verb meanings, object descriptions, maintained-state conditions, questions, tense, modality and runtime 0/1/2 remain reusable.

Both earlier parsing passes run first, including dated sentences. This preserves names such as Every in “Every saved the file yesterday.” Thirty-six frozen performances cover earlier all-the/none-of/a-few/nobody constructions, dated states, ability scopes and proper names. The new quantified readings rely on their full interpretation instead of appending an assertion that everyone acted to a question or negative.

There are **no new roots, compounds, sense records or musical frames**: 324 roots, 124 compounds and 607 English senses remain. See the [semantic review](../reviews/ordinary_quantifiers_2026_11_23.md).

## Findings fixed before publication

Review found that a new quantified-subject pass could consume a proper name such as Every in a previously accepted dated sentence. The earlier time parser now retains priority. Twelve additional dated-name performances were frozen from the unchanged time release and added to the original 24 compatibility cases.

A fresh [indefinite-item probe](ordinary_quantifiers_2026_11_23/indefinite-scope-finding.json) exposed another ambiguity: “Every robot made a box” needs to distinguish one shared box from a box varying per robot. The initial implementation accepted one unqualified reference. The [in-progress regression](ordinary_quantifiers_2026_11_23/interrupted-regression-before-scope-fix.txt) was stopped, that construction was made explicitly unresolved, and the entire regression was rerun after the correction. The guard covers indefinite objects, destinations, alternatives and user-supplied referents. Named and definite shared items remain supported. Neither finding was published in that intermediate form.

## Executed checks

The [focused suite](ordinary_quantifiers_2026_11_23/focused-tests.txt) passes **135 independently recovered melody/chord pairs**, with separate expectations for predicate, class identity, participant roles, ordered scope, quantifier, speech act and runtime. Truth checks cover empty, all-false, mixed and all-true member sets; they do not rely solely on different MIDI hashes. All **36 frozen older performances** retain their exact melody/chord hashes and recovered meanings.

[Eight additional combinations](ordinary_quantifiers_2026_11_23/heldout-combinations.json), with a [reproducible checker](ordinary_quantifiers_2026_11_23/heldout.mjs), cover irregular noun number, perception/source roles, finding, placement destination, stored states, ability questions, object adjective attachment, creation roles and negated quantified necessity. These are post-implementation engineering combinations, not a representative language benchmark.

The clean [full implementation regression](ordinary_quantifiers_2026_11_23/implementation-regression.json) passes **288 checks** at `c00d2a855b039bbeb404db7d6d5f4dd8d6187034`. All [eight release gates](ordinary_quantifiers_2026_11_23/release-gates.json) pass at that same revision. The [Lore integration suite](ordinary_quantifiers_2026_11_23/lore-tests.txt) passes **315 tests** with the final indefinite-scope guard.

| Browser check, on each local site | Result |
|---|---|
| Layouts at 320, 390 and 768 pixels | 24 passed |
| Actual downloaded melody/chord scores independently recovered | 16 passed |
| Alternative-meaning/scope choices stay unresolved | 6 passed |
| Unsupported constructions offer no whole-song action | 15 passed |
| Keyboard scope selection and Meaning details disclosure | 3 passed |
| Changed input clears the preceding result | 24 passed |
| Visible removal clears the exported song line | 8 passed |

The [main](ordinary_quantifiers_2026_11_23/browser-primary.json) and [Lore](ordinary_quantifiers_2026_11_23/browser-lore.json) browser runs use consecutive translations and actual downloaded files. All 16 exported hashes match between sites. The decoder receives MIDI and the public dictionary, without the source English or hidden semantic graphs. The existing compact arrangement contains simultaneous pitches and is **14.23–19.67% shorter** on these examples. This is symbolic-score and Chromium viewport evidence, not microphone or physical Safari/iPhone evidence.

## Remaining boundaries and publication

The new subjects currently require one clause in one message. Restricted subjects with adjective descriptions, inherited actions or later bound references, object/cardinal quantifiers, quantified date attachment and passive quantified patients remain unsupported. Indefinite items need shared-versus-per-member binding before they can be admitted. Existing accepted constructions retain their prior conventions; this increment does not certify every earlier quantity construction or every reading of an English noun phrase. The broader [completion plan](../docs/full-translator-next-steps.md) stays open.

Published through [translator PR #36](https://github.com/ragingaxolotl-art/era-zero-translator/pull/36) and [Lore PR #36](https://github.com/ragingaxolotl-art/cyber-pet-lore/pull/36), from translator source `eee03f81d059ce8cd9131bb1c25ab11c78b1d10e`. The merged revisions are `8e6658c44007de3e0153da6e2cf19e153f213d15` and `260f959ca5456e670a55d2883ede949e789e7c90`. [Translator deployment](https://github.com/ragingaxolotl-art/era-zero-translator/actions/runs/45311989384) and [Lore deployment](https://github.com/ragingaxolotl-art/cyber-pet-lore/actions/runs/45312088648) both succeeded.

The [public translator](ordinary_quantifiers_2026_11_23/public-primary.json) and [public Lore](ordinary_quantifiers_2026_11_23/public-lore.json) repeat every check in the browser table. All 16 actual exported hashes match both local sites and both public sites. A [first main-site run](ordinary_quantifiers_2026_11_23/public-primary-first-timeout.json) timed out waiting for a result at the third viewport after 16 successful exports. A [fresh diagnostic of the same sentence](ordinary_quantifiers_2026_11_23/public-primary-diagnostic.json) succeeded without a page error, and the complete repeat passed. The original timeout remains recorded; its cause was not established. No source change or relaxed assertion was used to obtain the passing repeat.
