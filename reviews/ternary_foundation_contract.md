# Ternary meanings in the translator expansion

This review records existing source rules and implementation obligations. It does
not rename a root, approve a new family, or change an existing sound. It follows
the user's explicit reminder to preserve 0, 1 and 2.

## Two distinct layers

The three digits in `REP:112` select a lexeme. The separate `[2]` in
`REP:112 [2]` qualifies a token of that lexeme. The trailing lexical digit and the
runtime ending are not substitutions for each other.

The canonical runtime ranges in `spec/canonical_spec.yaml` are:

| Ending | Source meaning range | Musical ending |
|---|---|---|
| `[0]` | inactive, false, ended, unavailable, or inaccessible | Descend one semitone and stop sharply |
| `[1]` | active, valid, expressed, or executing | Return firmly to the phrase starting pitch |
| `[2]` / num | dormant, pending, remembered, possible, or unresolved | Rise a perfect fifth and sustain |

These ranges are contextual. The grammar must not silently choose one specific
English reading merely from the digit. In particular, a num token alone does not
determine whether a speaker means a memory, a pending event, or a possibility.
Those distinctions require additional semantics where the source sentence makes
them. Likewise, an inactive/false token is not a replacement for a scoped negative
proposition in the current explicit-negation grammar.

The root definitions remain authoritative for lexical digits. Do not assign every
lexical zero the meaning “off,” every lexical one “present,” or every lexical two
“future.” For example, the final trit has these reviewed contrasts:

| Triplet | 0 | 1 | 2 |
|---|---|---|---|
| REP:110 / 111 / 112 | Completed target-restoration process | Ongoing target-restoration process | Nonactualized target-restoration process |
| REP:210 / 211 / 212 | Persistent source-to-target restorative applicability, independently of present operation | Presently operative restorative applicability | Existing applicability not presently enabling restoration |

The core architecture explicitly excludes planning, intention, scheduling,
permission, readiness, probability, future time and certainty from lexical `1x2`
as such. “Can restore” uses the reviewed applicability sense REP:211; it is not
implemented by turning REP:111 into REP:112 or adding runtime `[2]`.

## Evidence and its limits

The current dictionary MIDI audit contains all nine combinations of REP:110,
REP:111 and REP:112 with runtime states 0, 1 and 2. All nine have distinct exact
MIDI output at the tested anchor. The normal renderer tests cover all 324 roots
in all three runtime states. Specific sentence tests also preserve all three
states in capability statements, questions and compound commands.

These checks prove preservation of selected identities and their musical
contrasts. They do not prove that every combination has an unambiguous natural
English gloss. The translator must not fabricate one. Sentence tense, negation,
modality and participants remain independent parts of the semantic graph.

## Consequences for new foundations

Before admitting a new conventional compound or proposing a primitive, record:

1. Its invariant meaning and exclusions, independently of runtime status.
2. Each dependency's exact ID and definition version, including all lexical trits.
3. Which distinctions are ordinary composition and which are newly conventional.
4. What each runtime ending qualifies, and any contextual ambiguity it leaves.
5. Which additional operators express negation, time, modality, degree or quantity.
6. The meaningful contrasts with nearby existing terms and their audible output.

For compounds of compounds, retain the inner lexical addresses and scoped
bindings. The outer runtime ending attaches to the external semantic head.
Do not replace every internal third trit with the selected runtime digit or add
an independent ending to each qualifier. Bound participant occurrences retain
their own explicitly specified runtime states.

## Foundation-specific exclusions

- **Temperature and other dimensions:** 0/1/2 must not be repurposed as
  cold/warm/hot, small/medium/large, or low/medium/high. Dimension identity,
  magnitude and comparison need their own semantics.
- **Sensory channels:** the digits must not become sight/hearing/touch merely
  because three values are available. Registration, experience, access and channel
  identity are distinct from the status of a selected perception lexeme.
- **Feelings and desire:** negative/neutral/positive valence is not identical to
  runtime 0/1/2. Wanting is not lexical potentiality, and a pending token does not
  by itself assert intention or preference.
- **Bodily needs:** tired is not automatically dormant, hungry is not simply an
  inactive life token, and thirst needs its own deficit distinction.
- **Movement:** a potential movement is not an intended journey; fast/slow and
  running/swimming must not be inferred from the runtime ending.

These constraints guide dependency ordering: establish the missing distinction
first, then its reusable compounds, then specialized compounds that reuse them.
The 324-root inventory remains unchanged while those designs are reviewed.
