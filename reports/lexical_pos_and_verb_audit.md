# Era Zero lexical and part-of-speech audit

Status: **PASS — COMPLETE NONCANONICAL METADATA LAYER**

- Canonical roots audited: **324/324**
- Canonical English-index senses audited: **444/444**
- Game/story surface senses audited: **48/48**
- Verb or verb-phrase senses: **178**
- Canonical meanings changed: **0**

## Design decision

An Era Zero atom is not permanently labeled “noun,” “verb,” or “adjective.” Its address supplies an entity-, process-, or relationship-like semantic affordance. English part of speech belongs to a particular indexed sense. This prevents English grammar from silently redefining the language.

## Coverage

Every root now has its canonical title and definition, address slot, semantic affordance, indexed English sense links, ordinary-language tags, and search phrases in `lexicon/lexical_pos_audit.yaml`. Every indexed and game/story surface sense has a normalized POS, route, target, fidelity, and surface-form inventory.

## Verb policy

Existing verbs are consolidated into reviewed senses. An unfamiliar verb is never converted into a phonemic noun label. It enters the concept-intake workflow and is routed to an existing atom, existing compound, proposed compound, Semantic IR, grammar, an explicit gap, or a later-era proposal. No new root is created merely because English has another verb.

## POS counts

- `adjective`: **22**
- `adverb`: **2**
- `conjunction`: **3**
- `grammar`: **1**
- `interjection`: **1**
- `noun`: **29**
- `noun_phrase`: **252**
- `number`: **1**
- `preposition`: **2**
- `quantifier`: **1**
- `verb`: **70**
- `verb_phrase`: **108**
