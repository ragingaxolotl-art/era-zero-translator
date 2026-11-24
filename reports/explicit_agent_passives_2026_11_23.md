# Explicit-agent passive sentences — November 23, 2026

Sentences such as The file was saved by Nora now compose through the normal whole-sentence flow. This is reusable grammar for 31 reviewed participles, rather than a new dictionary entry for that example. Unrestricted English and general recorded-audio recovery remain unfinished.

## What changed

The parser identifies the initially mentioned participant before the by-participant, then binds them to the existing predicate's correct roles. The file is still the target; Nora is still the actor. Perception, causation, requests and creation retain their existing experiencer/source/cause/result distinctions. The music keeps its existing canonical role order, while numbered references preserve mention order for later pronouns and descriptions.

The supported family includes pushing/displacement/lifting/lowering, filling/emptying/closing/shutting, pulling/holding/releasing/dropping, information deletion/copying/saving/storing, recalled/remembered retrieval, repeating/noticing/spotting/finding/checking/inspecting/rechecking, requesting/opening/reopening, hearing/seeing and making. It reuses each approved meaning and its existing ambiguity choices. It does not supply new senses of those verbs.

Present and past passives, supported questions, future, possibility, ability, negation and already supported ongoing forms preserve their ordered scopes. Patient agreement is checked independently of the by-participant. Runtime states 0/1/2 remain separate from tense and aspect. Nouns keep their existing sound labels; neutral pronouns remain available.

The file was stored retains its earlier stored-information state. The file was stored by Nora uses the existing saving action. The gate was closed retains its state, while The gate was closed by Nora uses caused closing. Changing-state descriptions still require before/after phase. A conflicting personally selected verb keeps its chosen meaning and receives an unsupported-construction explanation. An ambiguous by-noun asks whether it identifies the acting participant or a location/other relationship.

There are **no new roots, compounds, sense records, convention codes or musical frames**: 324 roots, 124 compounds and 607 English senses remain. See the [semantic review](../reviews/explicit_agent_passives_2026_11_23.md) for the admission boundary.

## Executed verification

The [focused suite](explicit_agent_passives_2026_11_23/focused-tests.txt) passes **588 independently decoded melody/chord pairs** across all 31 participles, roles, ordered scopes and all three runtime states. It covers subsequent pronouns, conditions, before relationships, participant descriptions, ongoing aspect, state/action differences and explicit ambiguity. Twenty-four frozen active/state performances retain their exact melody/chord hashes and recovered meanings. The active and passive versions of the same claim recover equivalent predicates, participants and roles after resolving their different numbered declaration orders.

[Eight additional combinations](explicit_agent_passives_2026_11_23/heldout-combinations.json), with a [reproducible check](explicit_agent_passives_2026_11_23/heldout.mjs), chosen after implementation, cover contextual adjectives, plural targets, deictics, supplied neutral referents, repeated passive references and an inanimate cause. Their recovered properties, identities, scopes, question and temporal relationship were checked. This finite set is not an unrestricted-language score.

The clean [full implementation regression](explicit_agent_passives_2026_11_23/implementation-regression.json) passes **286 checks** at `356cb60c8109c7e1b54fe1d0d752ba1584bacae1`. All [eight release gates](explicit_agent_passives_2026_11_23/release-gates.json) pass at `00acaa737c075c632463ee7f1316b65d9320f686`. The only intervening changes record the preceding comparison release's public evidence; semantic runtime and dictionary files remain identical. Existing [storage](explicit_agent_passives_2026_11_23/storage-regression.txt) and [closing](explicit_agent_passives_2026_11_23/closing-regression.txt) suites also pass.

| Local browser check, on each site | Result |
|---|---|
| Layouts at 320, 390 and 768 pixels | 24 passed |
| Downloaded melody/chord songs independently recovered | 16 passed |
| Other-meaning choices stay unresolved | 6 passed |
| Unsupported constructions have no whole-song action | 9 passed |
| Keyboard Meaning details disclosure | 3 passed |
| Changed input clears the prior result | 24 passed |
| Visible removal clears the exported song line | 8 passed |

See [primary browser evidence](explicit_agent_passives_2026_11_23/browser-primary.json) and [Lore browser evidence](explicit_agent_passives_2026_11_23/browser-lore.json). Several translations are tested consecutively in each browser session. The decoder receives exported MIDI and the public dictionary, without original text or semantic graphs. Compact scores contain simultaneous pitches and are **11.82–20.24% shorter** on this set. These are symbolic-score and Chromium viewport checks, not speaker-to-microphone or physical Safari/iPhone checks.

Lore passes [304 integration tests](explicit_agent_passives_2026_11_23/lore-tests.txt) after its [build](explicit_agent_passives_2026_11_23/lore-build.txt). The [vendor record](explicit_agent_passives_2026_11_23/vendor-implementation.json) identifies the exact imported implementation. Navigation, shared preferences, arrangement persistence and backups are retained.

## Fixture corrections

Two earlier primary tests deliberately listed saved-by and closed-by sentences as unsupported. They now use has-been-saved/closed forms, which still require unsupported perfect grammar. The new positive family is independently covered rather than merely deleting those checks.

The [first Lore run](explicit_agent_passives_2026_11_23/initial-lore-fixture-failures.txt) had 299 passes and five failures: its two equivalent obsolete negative fixtures, and three runtime variants of a new test that assumed F–AY–L for file. The frozen earlier output establishes F–IH–L under the existing noun sound system. The test was corrected against that baseline; production noun sounds were not changed. The complete 304-test rerun passes. Failed runs are not counted as passes.

## Remaining boundaries

Agentless actions, perfect/get-passives, quantified passive patients, unsupported complements, inherited passive verb phrases, unreviewed verb shapes and conflicting personal-verb passive constructions remain open. Existing no-agent state readings remain valid. General calendar-adverb combinations, broader grammar and shared dialogue identity still need work. The [completion plan](../docs/full-translator-next-steps.md) remains open; this release does not close the full translator.

Public deployment and browser evidence will be recorded separately after publication.
