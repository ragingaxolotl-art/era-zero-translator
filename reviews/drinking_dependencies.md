# Drinking: dependency review and implementation order

The executable audit `tools/audit_drinking_dependencies.mjs` pins current meanings
in `reports/drinking_dependency_audit.json`. No new root or approved compound is
created by this review.

The ordinary desired outcome “Nora drinks the tea” remains unsupported. Thirst is
already defined as a felt demand for water and explicitly does not assert drinking.
Bodily replenishment need is likewise a feeling. Neither should be reused as the
action. Generic physical entry provides useful movement/region structure, but a
liquid entering a body or container does not by itself identify a drinking action.
The noun label “tea” identifies a referent; it is not proof of liquid composition,
a particular portion, ownership, or consumption of an entire amount.

The next reusable meaning must bind a drinker and consumed material under an
explicit literal-drinking action convention. It must distinguish ongoing activity
from a completed amount/event and habitual activity, with time, negation, modality,
and runtime independent. It must not add thirst, conscious intention, pleasure,
nutrition, ownership or successful relief merely because the action is drinking.
A material reference inside desire must not become an assertion of an actual event.

Before selecting a compound structure, resolve how material/portion typing and the
consumption route are represented. Reuse the existing motion and material structure
only if its full commitments fit; do not attach arbitrary roots as padding. The
existing entry compounds are dependency candidates, not an automatic derivation.
No evidence here justifies a new LIF, STR or other root family.

Required contrast cases include thirst without drinking, drinking without a thirst
claim, pouring into a container, non-drinking material entry, ongoing versus bounded
consumption, a negated drink versus wanting not to drink, and two differently bound
drinkers/materials. Each needs a complete meaning and independently recovered sound.
Add the interface choice only after its meaning/renderer/inverse agree. Keep
“wants tea” unresolved until the intended outcome is explicitly supplied; drinking
is one possible reading and must never be its default.

## Material-reference prerequisite checkpoint

`pages/material_reference.mjs` now supplies a gated, validated reference document
for a material kind or a contextually identified portion. It reuses existing noun
sound labels and nominal-class/definite/proximal/distal reference modes. A bare
noun can be explicitly selected as a kind; a portion requires the/this/that.
Neither liquid classification nor amount, whole-portion consumption or independent
existence is asserted. Existence follows the enclosing content's commitments.

Eight tea/water × kind/definite/proximal/distal cases retain distinct identities.
Validation rejects rehashed invented quantity, classification, total-consumption
and existence claims. Implicit portion selection, unknown reading, modified nouns
and unimplemented quantity forms reject. No roots, approved compounds or musical
addresses changed. This is a semantic prerequisite only: it is not yet wired into
a drinking action, musical transport or the interface. The next work is the
consumption action contract with explicit participant binding, followed by joint
meaning/rendering/inverse integration and blind-audio checks.

## Literal action meaning checkpoint

`drinking_meaning.mjs` now provides an explicit draft convention for oral intake
of liquid as drink. The action identifies the drinker and material independently;
the material label alone still does not classify every referent bearing that name
as liquid. The action's classification is inside its scoped content. No thirst,
ownership, pleasure, benefit, intention or consumption of a whole portion follows.
This is a declared semantic extension, not a deduction from generic entry or thirst.

Viewpoint is required: ongoing activity does not assert a completed amount;
bounded drinking presents a whole event with some intake but no total portion;
habitual drinking does not assert an occurrence at speech time. Thirty-six
viewpoint × assertion/question × negation × runtime cases pass strict meaning
validation, alongside participant contrast and rehashed contract rejection. Runtime
is independent of amount, aspect and negation. The material-reference prerequisite
is reused without altering its identity or quantity commitments.

The document remains draft. There is no English route, allocated musical frame,
independent renderer or audio inverse yet. Those must be implemented together with
participant-binding and contrast tests before drinking can count as translated.

## English interpretation checkpoint

`drinking_sentences.mjs` interprets progressive, past bounded and explicitly
habitual drinking sentences, including questions, negation, I/you, and runtime
0/1/2. Simple present requires an explicit viewpoint instead of silently treating
all present drinking as habitual. Literal-drinking interpretation and material
kind/portion readings are explicit API choices. A caller cannot override an
expressed progressive or habitual viewpoint with a conflicting choice.

Twenty-four authored tense/scope/runtime cases pass meaning checks. Agreement
errors, missing choices and contradictory viewpoints reject. This is not yet
connected to the main preview or desire composer: musical encoding and inverse
must exist before it becomes an offered translation. Pronoun antecedents,
quantities, modified materials and additional tense/aspect forms remain open.

## Musical encoding checkpoint

Draft ±39 subcodes 9/10/11 encode ongoing/bounded/habitual drinking with a
separate runtime trit. Existing nominal modes and participant sounds carry drinker
and material. The renderer's reference adapter uses its existing entity-valued
carrier API while retaining the nominal-class marker; the inverse recovers kind
versus contextual portion from that audible marker, not metadata. No source
English or semantic document is accepted by the inverse. Shared draft dispatch
requires a unique accepted profile.

Eighteen viewpoint/runtime/material-reading contrasts recover participants,
negated question scope and amount noncommitments, also under transposition.
Default draft rejection remains enforced. Independent Ruby rendering, corruption
checks, blind WAV, UI and desired-drinking integration remain unfinished. This
adds draft conventions only and does not change canonical root sounds.

## Blind synthetic-audio checkpoint

`tests/drinking_acoustic_test.mjs` now generates and decodes three clean WAVs:
past negated ongoing question with proximal material/runtime 2, bounded past
water intake/runtime 0, and habitual speaker-referenced tea-kind drinking/runtime
1. Separate decoder processes receive only WAV path and draft permission, never
original English, selected reading, semantic document or expected notes.

Full recovered structures agree, with additional assertions for viewpoint,
kind/portion, deictic speaker, proximal reference, past/negation scope and runtime.
No thirst or whole-portion consumption claim is introduced. Evidence is recorded
in `reports/drinking_acoustic_probe.json` and the acoustic regression runner.
These are authored synthetic cases, not physical recordings, channel-perturbation
proof or held-out language coverage. Independent renderer, interface and desired-
drinking integration remain pending.

## Independent renderer checkpoint

`tools/lib/era_zero_drinking.rb` independently validates the drinking and material
contracts, participant references and document identities, then renders the
existing noun/role sounds and draft viewpoint frames. All 18 authored
viewpoint/runtime/kind-or-portion performances match JavaScript byte-for-byte.
Default draft use and rehashed action, viewpoint, total-consumption and runtime
alterations reject. Material kind is checked independently of its rendering
adapter, so the class marker cannot silently become a portion.

The earlier three clean synthetic WAV checks remain separate evidence. Interface,
desired-drinking integration, broader reference/quantity coverage and physical
speaker/microphone testing remain unfinished. No canonical vocabulary is admitted.

## Drinking preview checkpoint

General analysis now routes supported drinking wording to a draft preview. It
requires a material reading and, for simple present, a viewpoint. Explicit
progressive/past/habitual wording constrains the available viewpoint. The user
selects literal drinking through the labeled preview action. Music playback,
MIDI download and complete meaning JSON reuse existing output mechanisms.

The actual handler test passes missing-choice gating, real negated-question
composition, decoded export checks and stale export invalidation. An incompatible
portion reading for a bare noun rejects. Live browser/playback recording, neutral
pronoun binding for this new profile, and desired-drinking integration remain open.

## Neutral pronoun binding checkpoint

Drinking now reuses explicit personal-pronoun resolution in composition and the
preview. Nine singular-they present/past/question × runtime cases produce identical
meaning and MIDI to their named-reference counterparts. Material `it` can resolve
to a contextual portion without changing its nominal mode. Number is required for
they/them; plural groups still reject rather than becoming one individual. No gender
field is needed. Preview tests cover missing number and successful two-reference
resolution; the existing 24 neutral sentence cases still pass. Automatic antecedent
resolution and general plural drinking remain unfinished.

## Ordinary wording and neutral agreement checkpoint

Drinking now applies the shared negative-contraction normalizer, including curly
apostrophes and inverted questions. Shared singular-they substitution also handles
`habitually` before the supported drinking/movement verbs, preserving the adverb
and changing only agreement. Four neutral habitual/contracted contrasts produce
the same full meaning and MIDI as explicit named wording. Twelve named contracted
scope/runtime cases, existing 21 neutral-contraction cases and preview checks pass.
This fixes ordinary wording failures without adding aliases for missing meanings.
