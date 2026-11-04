# Surface texture before rough/smooth adjectives

Status: author semantic review, not a new approved meaning or working translation.
Reviewed against the current 324-root runtime index and the 50-entry compound
dictionary at `cf343ac`. This resolves the next design step for the uncomposed
ordinary case “The stone is rough.” It does not claim exhaustive impossibility
over every graph that could be constructed from the inventory.

## Existing meanings and failed substitutions

| Ingredient | Actual commitment | Why it does not yet express surface roughness |
|---|---|---|
| MAT:000 / MAT:010 | Focal material substrate / distinct bounded material body | Material identity does not select a surface, its texture, or a roughness judgment. |
| STR:010 | Boundary locus identified for engagement by an external target | A physical surface need not be a structural engagement locus. The word boundary is not sufficient entailment. |
| STR:020 / STR:021 | Identified / realized part–whole arrangement | Constituent arrangement does not specify surface irregularity or its scale. |
| MOV:220 | Positional configuration in a shared frame | Positions alone do not define which surface, sampling scale or texture property is asserted. |
| WRN:001 | Internal adverse condition producing harmful deviation | Roughness can be desired or harmless. Rough does not mean damaged. |
| MIN:011 / MIN:211 | Manifest target representation / active attention | Neither entails physical texture, touch, or felt roughness. |
| Sensory-registration compounds | Transduction of information, with optical/acoustic specializations | A device's registration is not a surface-property assertion or a tactile experience. |
| Felt-self-condition compound | Conscious experience of one's own condition | This supplies experience, but not a tactile channel, external surface target or roughness quality. |

The dictionary's reviewed support, carrying, custody, repair and felt-condition
compounds do not supply the missing surface-texture invariant. Adding a second
unrelated root to satisfy the compound validator's two-expanded-root minimum
would introduce an unsupported claim. Recursive compounds must reuse true
dependencies; recursion itself cannot supply the absent distinction.

## Proposed invariant and dependency order

1. Define a physical surface-texture property of a specified material bearer and
   contextual surface region. The texture concerns local surface irregularity at
   the relevant contextual scale, not arbitrary whole-object shape, damage,
   friction, hardness, sharpness or the existence of an observer.
2. Establish an explicit texture comparison/context convention. Rough means
   sufficiently irregular under that selected interpretation; smooth means
   sufficiently even under its selected interpretation. Neither is defined merely
   as logical negation of the other. Do not invent a numeric threshold, unit,
   measuring instrument, reference class or universal scale from the adjective.
3. Add rough/smooth descriptions, negation, state and tense using that invariant.
   Comparatives must bind both bearers and a shared comparison context; two local
   roughness judgments do not automatically establish an ordering.
4. Add tactile appearance only after a separately specified experiencer, tactile
   channel and content binding. “Feels rough to Nora” must not silently assert the
   same thing as an observer-independent physical texture description.
5. Only then build textured-object noun modifiers and compounds of compounds.
   A noun's sound label supplies identity, not the omitted adjective semantics.

## Encoding decision still to implement

Prefer an additive property/context profile for the physical reading, reusing the
material-bearer mechanism and the existing scope/music machinery. This is the same
architectural category as explicit mass/temperature/luminance properties, but it
must not reuse one of their dimension codes. It needs its own versioned semantic
contract, local-scale context and independent MIDI inverse. No numerical metrology
claim is made here. An explicitly conventional compound is an alternative only if
its expanded components all remain true; the present nearest-root proposal fails
that condition. A whole new STR/LIF-sized root family is not warranted by this gap.

The proposed property profile is not approved or encoded by this review. Do not
count the original rough-stone case as translated, assign a sound code, or add an
English alias until the missing meaning and context are actually represented.

## Required contrast evidence

- The stone is rough / the stone is smooth / the stone is not rough: three meanings.
- Rough stone / damaged stone / hard stone: no substitution among predicates.
- Rough stone / rough plan / rough journey: select senses rather than phonemically
  labeling the adjective or applying the physical sense to every noun.
- The stone feels rough to Nora / it feels rough to Eli: preserve experiencer.
- One rough surface region / the entire object: do not infer universal coverage.
- Rough at one scale / smooth at another: preserve the context without contradiction.
- The stone is rough [0], [1], [2]: retain one lexical property with three separate
  runtime endings; none becomes smooth or grammatical negation.
- The stone was rough / is rough: time remains separate from runtime state.
- This surface is rougher than that surface / the reverse: recover direction and
  distinct referents from the music, with the shared property context intact.

These are acceptance obligations, not passing tests. Physical/tactile/figurative
scope and missing comparison context must remain visible in the product.
