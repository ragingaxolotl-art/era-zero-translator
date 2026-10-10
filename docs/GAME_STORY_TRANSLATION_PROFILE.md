# Game and Story Translation Profile

Status: implemented translator profile 0.1.0  
Authority date: 2026-10-10  
Canonical semantic changes: 0

## Purpose

This profile makes the English interface useful for Cyber Pet dialogue and story
sentences while preserving the Era Zero semantic boundary. It does not add roots,
change definitions, or claim that one broad canonical root contains every detail
of an English word.

The profile is defined in
`lexicon/game_story_surface_routes.yaml` and tested by
`tests/game_story_translation_cases.json`.

## Required word policy

1. Known predicates and descriptors use an indexed canonical meaning.
2. A narrower English predicate may use a broader existing Era Zero meaning only
   when the English statement entails that meaning. The interface labels this as
   a generalization and states which detail was lost.
3. Unknown verbs and descriptors are unresolved semantic content. They block
   automatic translation and never become phonemic names.
4. Unknown common nouns and proper names may receive deterministic EZNAME labels.
5. If a noun's broad class is known, the semantic class and phonemic label remain
   separate. `programmer`, for example, may be treated as a labeled person without
   asserting the occupation.
6. A documented noun gap may retain a phonemic label for reference, but the gap
   remains visible. A tone label for `food` identifies the referent and does not
   define food.
7. Pronouns are participant references. They do not become roots or EZNAME labels.

## Important generalized routes

| English surface | Existing Era Zero center | Preserved meaning | Detail intentionally lost |
|---|---|---|---|
| find, found, discover, locate | MIN:110 | completed change to the finder's target-model | search method and physical location |
| search, seek | MIN:211 | active preferential attention to a target | search method |
| see, notice | MIN:011 | a target representation is manifest in cognition | sensory channel |
| need, require | ORI:211 | present target-ground dependence | desire, urgency, and exact resource |
| hungry | ORI:211 | acceptable condition depends on nourishment | hunger physiology |
| thirsty | ORI:211 | acceptable condition depends on hydration | thirst physiology |
| tired | ORI:211 | acceptable functioning depends on restoration | energy scale and sleep pressure |
| care, help, feed, support | LIF:211 | active support or sustenance of another being | particular care action |
| rest, recover | REP:101 | active internal restoration | sleep and Energy-meter mechanics |
| treat, clean | REP:111 | active restoration of a target | medicine or washing method |
| sleep, asleep | LIF:002 | preserved self without present conscious expression | distinction from other nonresponsive states |
| awake | LIF:001 | presently conscious and responsive self | alertness level |
| sick | WRN:001 | manifest internal adverse condition | diagnosis and symptoms |
| hurt, injured | approved physical-injury compound | internal fault in a material substrate | pain, cause, and body location |
| lost | MOV:212 | unresolved target-relative position | reason for being lost |
| file | DAT:000 | persistent bounded information object | format, filename, path, and storage medium |
| folder, directory | STR:020 | persistent part–whole organization | filesystem implementation, path, and permissions |
| inside, within | STR:001 | present occupation of an internal structural position | exact coordinates, path syntax, and enclosure mechanism |

For example, `I need the file that is inside the folder` now selects `ORI:211`
as its predicate center and separately recognizes `DAT:000`, `STR:001`, and
`STR:020`; those words no longer fall back to phonemic labels. This remains a
predicate-centered analysis until the clause composer can bind the four meanings
into one validated graph.

## Deliberate gaps

The profile does not force the following concepts into unrelated roots:

- happiness, sadness, anger, fear, affection, and preference;
- recreational play as such;
- ingestion as such;
- food, water, toys, and care objects as semantic classes;
- game-specific Energy, Fullness, Cleanliness, Health, Stamina, and Focus measures;
- thresholds such as dirty, full, or safe when the threshold schema is absent.

Noun gaps may still be referenced by label. Predicate and descriptor gaps remain
untranslated until a later approved compound, measurement schema, or semantic
extension exists.

## What “I need food” can currently say

The current safe reading is:

> The speaking being's acceptable condition has an operative dependence on a
> labeled nutritive referent.

The canonical audible center is ORI:211. `I` is a speaker reference. `food` is
still a documented noun gap and may receive an EZNAME label. The current direct
formal output therefore represents the generalized dependence predicate; it is
not yet a complete bound subject–predicate–ground Semantic IR graph.

For a player-facing request that is intentionally broader, the game may instead
use the command reading of LIF:211 and subtitle it as “Please care for me.” This
asks for active care without asserting food specifically.

## Cyber Pet integration contract

The game should not send arbitrary display text to the translator every frame.
It should select a stable dialogue intent from authoritative game state and then
request a prevalidated Era Zero performance.

Suggested first intent set:

| Game intent | Trigger example | Era Zero route | Suggested subtitle |
|---|---|---|---|
| `care_request` | any care meter requires attention | LIF:211 command | Please care for me. |
| `nourishment_dependence` | low Fullness | ORI:211 assertion | I need nourishment. |
| `rest_dependence` | low Energy | ORI:211 assertion | I need restoration. |
| `active_recovery` | resting or healing | REP:101 assertion | I am recovering. |
| `target_treatment` | player begins treatment or cleaning | REP:111 assertion/command | Restore me. |
| `manifest_injury` | active injury | physical-injury compound | I am injured. |
| `manifest_internal_problem` | active illness or malfunction | WRN:001 assertion | Something is wrong inside me. |
| `awake` | responsive care-room state | LIF:001 assertion | I am awake. |
| `asleep` | sleeping state | LIF:002 assertion | I am asleep. |
| `greeting` | care-room entry | CON:100 assertion | Hello. |
| `target_found` | Memory pair or story target found | MIN:110 assertion | I found it. |
| `target_search` | seeking a story or game target | MIN:211 assertion | I am looking for it. |

Each intent record should store:

- intent key;
- English subtitle;
- selected surface sense ID;
- canonical target ID;
- speech act;
- runtime state;
- eye-expression presentation choice;
- optional noun-label data;
- the generated EZB-1 or EZVISEME-1 artifact fingerprint.

The semantic result should be generated during content building or cached on
first use. Gameplay should play the validated formal/viseme artifact, not invent
a root mapping independently.

## Remaining implementation boundary

Profile 0.1.0 improves recognition, classification, and safe predicate-centered
rendering. Complete free-form translation still requires a clause composer that
binds subject, object, target, ground, and coreference nodes into one validated
Semantic IR graph. Until that exists, the interface must describe direct output
as a generalized canonical center plus participant and noun-label analysis—not
as a lossless translation of every word.

Run the focused audit with:

```text
node tools/audit_game_story_translation.mjs
```

The audit writes `reports/game_story_translation_audit.md`.
