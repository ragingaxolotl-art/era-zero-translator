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

## Desired-drinking semantic integration

The new draft `desired_drinking.mjs` composes the pinned existing desire foundation
with the validated drinking content. Infinitival subject control binds “wants to
drink” to the desire holder; an explicit different drinker remains separate. Outer
negation/question/runtime and inner drinking negation are independent, and the
outcome is intensional, desired rather than asserted. Twelve meaning contrasts
pass, and rehashed false subject-control bindings reject. Simple infinitival
activity still requires an explicit viewpoint; no bounded amount is guessed.

This is semantic integration only. Joint musical transport, independent rendering,
blind audio, object-desire clarification and UI routing remain unfinished. Existing
standalone drinking music is reusable; canonical definitions have not changed.

## Desired-drinking musical composition checkpoint

The desired-drinking renderer reuses drinking events inside the existing
intensional proposition frame, with explicit holder and control binding. Draft
±39 subcodes 12/13 distinguish controlled versus explicit content subjects; outer
runtime is separate from the nested drinking frame. The strict reader now supports
scope traversal over a supplied subtree, allowing the same drinking inverse to
validate standalone and nested content. No original text or IR enters decoding.

Twenty-four subject-control × outer/inner-negation × runtime question contrasts
recover through unique shared dispatch and transposition. Standalone drinking's
18 independent Ruby comparisons remain passing after event/reader extraction.
Combined independent rendering, blind audio and UI integration remain unfinished.

## Desired-drinking blind audio checkpoint

Two authored clean synthetic WAVs now recover complete desired-drinking meaning
in independent processes given only WAV path and draft permission. The first
binds the drinker to the desire holder with outer runtime 0 and inner runtime 1.
The second is a negated question with a different explicit drinker, separately
negated drinking content, outer runtime 2 and inner runtime 0. Full inverse
structures agree; additional checks preserve intensional/nonasserted status,
participant identity, binding mode and both scope/runtime positions.

Evidence is `reports/desired_drinking_acoustic_probe.json`; the acoustic regression
runner includes the new test. This is not physical-recording or held-out-language
proof. Combined independent Ruby rendering, desired-drinking UI, object-desire
clarification integration, and broader outcome coverage remain pending.

## Desired-drinking independent renderer checkpoint

The Ruby renderer now composes validated desire-holder references, the intensional
content boundary and reusable drinking events. All 24 controlled/explicit-subject,
outer/inner-negation and runtime performances match JavaScript byte-for-byte.
Independent validation rejects default draft use and rehashed false subject
control, changed desire foundation, asserted-content status or outcome commitment.
All 18 standalone drinking comparisons remain passing after event extraction.

These checks complement the two clean synthetic WAV recoveries. They do not close
UI, object-desire clarification integration, broad discourse or physical recording
requirements. Existing approved root and compound definitions remain unchanged.

## Desired-drinking preview integration

General analysis routes supported desired-drinking sentences before generic
foundation preview. The existing drinking preview now selects the combined
composer/renderer for desire, preserving its complete document and MIDI export.
The description explicitly distinguishes desired content from actual drinking and
explains holder versus drinker. Material and unresolved viewpoint choices remain
required; exports use a distinct desired-drinking filename.

Actual handler tests recover a negated question with a different drinker, nested
negation and outer/inner runtime 2/0 from exported MIDI, and check complete meaning
JSON. Changed choices invalidate old downloads and pending async results. Existing
standalone and neutral drinking preview checks remain passing. Live browser/audio
recording, desired-drinking pronoun binding and “wants tea” clarification integration
remain unfinished; this does not close broad translator coverage.

## Desired-drinking neutral reference checkpoint

Desired drinking now reuses explicit pronoun bindings in both the composer and
preview. Nine pronoun/runtime cases match their fully named meaning documents and
MIDI, including singular-they subject control and a different explicit drinker.
Missing bindings and plural groups reject; no gender or name-based inference is
used. The actual preview handler resolves “They want to drink it” and verifies the
holder is the controlled drinker in its complete export. Automatic antecedent and
plural-group support remain unfinished; this does not default the object-desire
reading to drinking.

## Explicit object-desire drinking clarification

`composeObjectDesiredDrinking` now connects a user-supplied drinking proposition
to an original object desire, reusing the existing clarification input resolver.
It verifies the original noun label and explicit nominal mode against the consumed
material, preserves outer scope/runtime and checks the shared musical inverse.
It returns the unchanged validated meaning plus clarification provenance separately.
Drinking and its viewpoint/material reading remain explicit choices, never defaults.

Nine assertion/negation/question × runtime cases pass full MIDI recovery, including
independent inner runtime 0. Missing choices, unrelated materials and proximal/
distal substitution reject. The test exposed an existing parser loss: “wants that
tea” dropped the demonstrative as if it were a clause connector. Bare two-word
`that` nominals are now retained; finite that-clauses remain supported. This API
still needs interface routing and its own blind-audio evidence; broader reference
and outcome coverage remains open.
