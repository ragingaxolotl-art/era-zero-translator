# Translator completion work

Baseline: `e8a42f842aeb789b3696936a59a2699d328687ab`, October 28, 2026.
Working branch: `feat/translator-completion`.

The goal is complete ordinary-language interpretation and meaning-preserving DBA
performance, keeping existing roots, sounds, names, and approved poetic meanings.
The [source audit](https://chatgpt.com/space/page_21c6ce0da1a88191abff53c0b13441f3)
is the starting evidence, not a completion certificate.

## Current coverage evidence

The [ordinary phrase audit](../reports/ordinary_phrase_coverage.md) currently has
18 checked compositions, 21 uncomposed phrases, and one composed phrase awaiting
semantic review out of 40 deliberately varied cases. This is an implementation-authored diagnostic set, not a blind evaluation
or a statistical measure of English coverage. Green regression suites do not
override these missing constructions. The corpus records the intended distinctions
even for cases that cannot yet be composed; future support must receive explicit
semantic expectations before it counts as checked.

The next broad usability priorities are ordinary noun phrases, questions and
commands, and time/discourse handling. Sensory dimensions, affect, bodily needs,
and movement manner still need foundation review before vocabulary expansion.
Both kinds of gap matter: adding roots alone cannot repair missing clause structure,
and expanding grammar cannot supply an absent temperature or desire distinction.

## Dependency order

Choose foundations by semantic usefulness and actual dependencies. Creation date,
English spelling, and the first plausible synonym must not determine meaning.
Reuse an existing term only when its invariant and exclusions match. Distinguish
lexical dependency order from the separately specified performance order.

1. Reuse the canonical roots and 29 compounds with their exact meanings.
2. Establish referents, participant roles, scope, and recursive compound resolution.
3. Add high-confidence process variants of existing domain-specific compounds.
4. Establish missing property scales, manner distinctions, and sensory/affective
   meanings before compounds that depend on those distinctions.
5. Build everyday and specialized vocabulary from these reviewed foundations.

Do not rewrite established compounds merely to make them reference newer entries.
Such refactoring changes identity and must use a versioned migration. New entries
can reuse an exact version of an older entry. No mutable reference to “latest.”

## Meaning-gap register

This is a review queue, not approved new vocabulary. Root IDs below identify
candidate ingredients; they are not assertions that the whole English sense is
already expressible.

| Foundation | Existing evidence | Next route and constraint | Later dependents |
|---|---|---|---|
| Participant identity | Noun/name sound labels; compound slots and IR roles | Grammar/implementation: bind the same referent consistently; preserve actor versus target | Every action sentence, possession, pronouns |
| Movement with source and destination | MOV:101, MOV:111, MOV:121 | Reuse the appropriate process with explicit roles; do not equate movement with carrying | Carry, bring, take, return |
| Material restoration in progress | REP:111 and MAT:111; existing physical repair uses completed roots | Review an active-process compound; retain the completed entry unchanged | Repairing a tool, healing a body, restoring a structure |
| Internal data restoration in progress | REP:101 and DAT:101; existing data repair is completed | Review active data-restoration compound | Recovering damaged data |
| Internal structural restoration in progress | REP:101 and STR:101; existing structural repair is completed | Review active structural-restoration compound | Rebuilding, reorganizing damaged structures |
| Directed information transfer | DAT:111; existing message datum and addressed message | Reuse process with source, recipient and content roles; distinguish communication CON:101 from arbitrary copying | Send a message, transmit a file |
| Artifact generation | CRE:111; material artifact, composite artifact, machine | Reuse generation with result reference; do not assume every machine is a material artifact | Make, build, assemble |
| Attention and learning | MIN:211 and MIN:111 | Reuse exact senses; attention is not curiosity, and model revision is not necessarily learning a truth | Study, investigate, teach |
| Dependence and need | ORI:210/211 | Conditional dependence alone lacks desire, felt deficit and resource kind; review those separately | Hungry, thirsty, tired, require |
| Physical quantities and comparison | MAT defines physical states and work capacity; no temperature-specific invariant | Review quantity dimensions, units and comparison semantics; no hot=active shortcut | Hot/cold, heavy/light, fast/slow, large/small |
| Sensory modalities | MIN representations do not distinguish sight, hearing, touch, taste or smell | Unresolved semantic foundation; evaluate conventional definitions or architecture extension | See/hear, bright/dark, loud/quiet, rough/smooth |
| Affect and preference | LIF:211 care; approved love; MIN attention | No generic happiness, liking or curiosity follows from these alone | Happy/sad, enjoy, prefer, curious |
| Locomotion manner | MOV movement and MAT physical body | Missing manner distinctions; explicit environment labels alone do not distinguish swimming from being carried in water | Walk, run, swim, jump |
| Access and containment | STR boundary engagement and part–whole arrangement | Engaged is not closed; unengaged is not open. Review traversability, containment, access and permission separately | Open/close a door, open a file, enter/leave |
| Consent and obligation | LOG formal admissibility; CON expression | Formal admissibility is not personal consent or obligation. Needs explicit normative and intentional distinctions | Agree, refuse, promise, must, may |

## Do we need more families?

See [the foundation gap review](../reviews/foundation_gap_review.md) for specific
root definitions, counterexamples, and the dependency order required before broad
vocabulary expansion. That review proposes no canonical new family or meaning.

Not established. The root inventory is complete relative to its 12-by-27 address
scheme, not proven complete relative to everyday meanings. Generic operators over
generic roots cannot by themselves identify an unrepresented sensory quality or
particular movement manner. A noun sound label can identify water; it does not
automatically supply the semantics of drinking or thirst.

For each gap, first attempt an explicit compositional definition and contrasting
examples. If that fails, distinguish a conventional compound whose additional
meaning is explicitly documented from a new primitive. Repeated independent gaps
in one domain can justify proposing a family. Do not mint 27 entries simply to
fill a grid, or silently broaden existing roots. Any family proposal must document
its distinctions, boundaries with current families, sound encoding, migration and
minimal-pair tests. Existing melodies and meanings remain stable.

### Existing-root descriptions

The complete sentence composer now supports named or quoted bearers with `is
conscious` (LIF:011) and `is dormant` (LIF:012), including explicit `is not` scope.
These are unary descriptions with a bearer role, not actor/target actions and not
phonemic adjective labels. Dormant retains identity-preserved, unexpressed meaning;
it is not a synonym for tired or asleep. Bearer rendering uses the renderer's
existing middle-register fallback. Tests compare complete browser and Ruby formal
outputs and distinguish conscious, dormant, and not-conscious MIDI. This bounded
construction does not establish general adjective coverage.

## Implementation gates

- Source manifest and reproducible semantic-gap/dependency report.
- Version-pinned recursive dependency resolution and cycle detection.
- Recursive graph expansion, scoped slots, and head-only external endings.
- Meaning-preserving scheduler, including negation and repetition distinctions.
- Full sentence interpretation and noun/name participant binding in the browser.
- Reviewed vocabulary batches, in dependency order, with positive and contrast cases.
- Novel sentence and audio-semantic tests; honest unsupported/clarification results.

Existing keyword, dictionary-count and static-render tests alone cannot close these
gates. The translator remains unfinished until all gates have direct evidence.

## Current implementation evidence

`tools/lib/era_zero_compound_dependencies.rb` resolves exact approved versions,
orders dependencies before consumers, and rejects missing pins and cycles.
`tools/audit_compound_dependencies.rb` emits the current inventory: 32 compounds,
all presently built directly from atoms, with no nested dictionary entries yet.

`tools/lib/era_zero_compound_expansion.rb` expands nested occurrences into unique
array paths and retains scope records, local constraints, scoped slot identities,
and both reference-boundary and resolved-head edge endpoints. Configurable depth
and node limits fail explicitly. Dictionary inputs are not mutated.

Tests include repeated references, three-level nesting, version failures, cycles,
modifier scope, repeated slot names, limits, and preservation of existing entries.
Closed nested compounds now reach the Ruby renderer, retain separate occurrence
paths, and apply the external runtime ending only to the resolved final head.
A three-level render/decode/transposition case verifies this path. Existing flat
dictionary output is preserved. Nested slots explicitly fail pending scoped
binding; they are never silently omitted.

Expanded sibling ordering now uses semantic subtree hashes rather than local node
names; a renaming/storage-order test verifies that invariant. Existing flat output
still uses its historical order pending a versioned renderer migration.

The first three process foundations and their exclusions are reviewed in
`reviews/foundation_process_compounds.md` and entered through
`migrations/foundation_process_compounds_2026_10_28.yaml`. Their exact-label lookup,
controlled target roles, runtime/phase separation and MIDI phase contrasts pass.
The browser inventory now has 32 compounds and 440 canonical English senses.
General English verb routing remains incomplete. Existing release checks still
cover their bounded legacy scope, not the overall completion goal.

The expansion API now validates explicit slot-path bindings against declared
argument types and slot roles. Same-named slots in separate nested occurrences
can bind different participants, and one participant can be reused only through
separate explicit bindings. Missing, duplicate and mismatched bindings fail.
Ruby rendering now consumes explicit `compound_bindings` on lexical occurrences.
Bound lexical participants appear at their scoped slots with role registers,
independent runtime endings, and a binding chain. Argument-only nodes are not
duplicated as standalone sounds. Rendering/decode tests preserve the bindings.
Phonemic referents now render using validated existing EZNAME-0.1 phonemes and
frames, preserving actor/target registers without assigning root meanings.
Cross-language tests verify name notes, participant reversal, formal roundtrip,
MIDI parity and neutral-mouth label cues. Ordinary English interpretation, general
IR validation and boundary timing remain outstanding.

Still required: ordinary English participant integration, complete compound
timing and contour scheduling, grammar-aware MIDI, and browser integration.
Formal round-trip preservation is not proof of audible semantic completeness.

Ruby MIDI export now schedules counted repetition as whole phrases. Parsed MIDI
tests verify two versus three repetitions, compound integrity, sequence order,
and bounded expansion. Browser sound plans, viseme cues, MIDI and SVG now consume
the equivalent JavaScript schedule; Ruby SVG also consumes the schedule. Cross-language
tests compare exact MIDI bytes, SVG and parsed notes. Only repetition fixture
hashes changed in the legacy presentation matrix. Negation and other scopes remain
unresolved musical-fidelity work; this does not complete general sentence playback.

## First browser sentence construction

`pages/sentences.mjs` composes complete named clauses for active care, awakening
another, target restoration and target impairment. It binds both names and generates a new semantic
IR and formal performance rather than returning the static predicate template.
The browser translation action uses this route before keyword lookup. Seven novel
name combinations match Ruby formal rendering exactly; reversed roles change
MIDI. Unsupported negation, descriptors, temporal additions and extra clauses do
not match this construction. They still require the broader interpreter work.

This initial parser accepts single capitalized alphabetic names only. Pronouns,
multiword names, noun phrases, additional predicates, questions and grammar are
not covered. The interface labels these results “Composed sentence” rather than
claiming an independently executed inverse roundtrip. Browser DOM interaction
was verified locally for “Pip is restoring Ada”: the complete result appeared and
39 synchronized tones began playing. “Pip is not restoring Ada” remained in
partial dictionary analysis with no automatic complete result. Module, syntax
and release tests pass. Within this construction fallback, unhandled negation
no longer preselects runtime zero unless the user supplied an explicit state.

Care-construction fallback now stays nonautomatic when the complete parser
declines added meaning. Manual dictionary inspection is labeled “Partial reading”
and its source echo identifies it as partial. This specifically protects the new
care-construction boundary; broader legacy keyword fallback remains audit work.

The composition path now also accepts ongoing physical repair and explicitly
quoted phonemic participant labels, including multiword labels. For example,
`Pip is physically repairing "the machine".` preserves both MAT:111 and REP:111
and the complete label's phonemes. Quotes explicitly request a label: adjectives
or articles inside it are not claimed as separately translated semantics. Nine
sentence cases match Ruby rendering. Unquoted descriptive noun phrases, pronouns,
and scope additions still need grammatical interpretation.

## Explicit multi-clause sequences

The browser composes complete supported clauses connected by `then`, including
`Pip cares for Ada, then Ada is restoring Sol.` Each clause retains its own
participants and predicate; coordination edges record explicit order. Quoted
labels containing “then” do not split the sentence. Any unsupported clause causes
the complete sequence parser to decline. `and` is not treated as temporal order.

Ruby and browser schedules now traverse explicit sequence order even outside
repetition and insert a medium one-beat boundary between clauses. Formal and MIDI
parity tests verify both actions, reversal, boundary placement and rejected partial
sequences. Only the legacy sequence MIDI fixture hashes changed. The parser has a
32-clause implementation bound; this is not a language limit. Parallel conjunction,
pronouns, modifiers and additional predicate frames remain outstanding.

## Negation convention

The original source defines scoped negation but supplies no musical assignment.
`spec/grammar_frames_1.0.yaml` records the new EZGRAM-1 convention, introduced
under the completion goal: short opening and closing grammar frames bracket the
negated subtree without changing roots or runtime endings. These are grammar
events with neutral articulation, not new roots or recognition checksums.

Positive, negative and inactive-runtime forms now have distinct MIDI. Tests check
marker pitch and duration, nested negation, Ruby/browser parity and unchanged
runtime 1 inside a negative clause. The named-action parser accepts explicit
“does not care for” and “is not” progressive forms, including scoped sequences.
Only negated-clause fixture hashes changed. This is a new versioned performance
convention, not a claim about historical DBA phonology. Stored pre-change negative
presentation checksums require migration before publishing this branch.

Tense, modality, quantities, other operators, broad English parsing and independent
listener decoding remain unfinished. Passing presentation regressions does not
prove these remaining meanings are sounded.

### Unsupported musical scope is explicit

Browser and Ruby presentation now refuse unsupported scope operators (quantifier, aspect, and modality with numeric confidence) and coordination (all-of, any-of, exactly-one, parallel), even
when no supported operator appears alongside them. Previously the scheduler's
fast path returned lexical notes unchanged, silently losing these meanings.
This is an interim fidelity correction, not implementation of those operators.
The historical possible-clause, exact-quantity, and parallel presentation hashes
remain recorded but are no longer accepted output; regression checks require an
explicit refusal for these cases. Their eventual musical implementations must
replace refusal with semantic-contrast tests and a documented sound convention.


### Scoped modal music

The versioned EZGRAM-1 implementation convention now defines distinct opening and
closing frames for possible, necessary, permitted, obligated, intended, predicted,
and counterfactual modality. These frame the scoped subtree at the utterance
anchor and preserve lexical runtime, role registers, and speech-act contour.
This is a new explicit convention under the completion goal, not a recovered
historical rule. Ruby and browser MIDI/SVG agree for all seven modes. Numeric
confidence remains explicitly unsupported, including the historical possible
fixture with strength 0.7. Ordinary-English modal parsing and listener decoding
remain unfinished; this change supplies the musical representation they need.


### Explicit modal sentence input

Named action and description clauses accept `It is possible that ...` and `It is
necessary that ...`, including `It is not possible/necessary that ...` and nested
wrappers up to 16 levels. Negation inside the clause stays inside the modality;
negation on the wrapper stays outside. Tests compare full browser/Ruby formal
representations and distinguish the scope orders in MIDI. A leading modal before
an explicit then-sequence is declined because its scope is ambiguous without
grouping. Bare may/must forms, other modal English constructions, and numeric
confidence remain incomplete. These wrappers introduce no lexical roots.


### Dictionary ranking is not sentence completion

The browser's legacy English ranker now permits automatic standalone dictionary
lookup only when the entire normalized input is the selected lemma. Other ranked
inputs retain their candidates but explicitly report a partial dictionary reading;
manual selection cannot turn that into an exact sentence claim. Complete sentence
constructions continue through the separate composer. This intentionally removes
old automatic “successes” such as Go home with zibble, which never bound their
participants. The legacy test expectations were corrected to require partial
status while retaining target-ranking checks. English negation no longer infers
runtime zero anywhere in the ranker; explicit runtime markers still work. Broad
sentence parsing remains a required implementation task, not satisfied by refusal.

### Movement foundations in sentence composition

The named/quoted-participant composer now binds `is moving toward` to MOV:111
with a destination, `is moving away from` to MOV:101 with a source, and `is moving
relative to` to MOV:121 with an environment/reference frame. Existing role
registers remain high, low, and sustained-background respectively. All three
retain the mover as actor; tests verify full Ruby/browser formal equality and
distinct MIDI. Negation and explicit modal wrappers compose with these clauses.
This adds no roots and does not equate moving with carrying, running, or swimming.
Multiple path endpoints and manner modifiers remain unimplemented.


### Three-participant data transfer

The sentence composer now builds participants from explicit role records rather
than a fixed actor/target pair. `Data "the record" is being transferred from Pip
to Ada` uses DAT:111 with source, content, and target, preserving all three labels
in low, middle, and high registers. Negation, modal wrappers, and existing sequence
composition remain available. Tests reverse source/target and compare complete
Ruby/browser formal output and MIDI distinctions. This does not assert message
understanding, communicative intent, successful completion, or a physical transfer.
Existing unary/binary participant and edge IDs are retained.

### Shared participant validation

Semantic IR fixture validation is now a callable shared module. The schema accepts
phonemic_reference nodes, validates their EZNAME encoding and name identity,
requires an explicit entity referent, and forbids lexical runtime on names. Every
composed-sentence regression validates its IR before renderer comparison. Adversarial
checks cover forged identities, unknown phonemes, missing referents, disconnected
names, and malformed containers. This is not yet general validation of compound
bindings, and runtime renderer enforcement remains pending that integration.

### Scoped compound binding validation

The shared semantic validator now validates explicit compound_bindings through the
same version-pinned expander used by the renderer. It checks full nested paths,
slot completeness and uniqueness, argument existence and value type, and declared
roles. Valid bindings contribute argument-to-compound connectivity without adding
unscoped duplicate role edges. Binding cycles and bindings on noncompound nodes
are rejected. Nested fixtures include adversarial missing, duplicate, wrong-path,
wrong-role, wrong-type, unknown-argument, malformed-container and self-cycle cases.
This validates explicitly provided bindings; legacy role-only compounds and full
runtime enforcement still need integration review.

### Runtime semantic validation

The Ruby renderer now invokes the shared validator before producing formal output;
its decoder also reaches this check when regenerating a formal artifact. Unknown
or disconnected participants, duplicate node IDs, malformed runtime containers,
and invalid explicit nested bindings therefore fail during use as well as tests.
Schema and authority documents are cached with file timestamp/size invalidation
to avoid repeatedly parsing the lexicon for each render. Existing valid legacy,
name, nested-compound, and sentence fixtures remain supported. Browser-generated
sentences are cross-validated in tests; this does not yet add a general browser IR
validator or complete validation of every legacy grammar construct.

### Longer performance verification

Optional recognition-phrase verification now uses dynamic programming over note
offsets, with an exact-match pass before mismatch diagnosis. It no longer enumerates
all checksum-presence combinations or rejects more than 12 events. Empty recognition
phrases on names/grammar frames do not create fake present-checksum alternatives.
Cue grouping also avoids rescanning every cue for every event. A 96-event sequence
passes strict, recognition, and mixed-mode checks; changed, omitted, extra, and
empty note streams are rejected. Search work remains explicitly bounded at one
million transitions. This verifies the expected note path against a supplied
formal artifact, not independent recovery of arbitrary language from audio.

### Exact modal confidence in music

EZGRAM-1 now frames an explicit confidence value immediately after its modal
opening. Decimal digits and the point have distinct note patterns, preserving the
canonical string exactly without floating-point conversion. Values range from 0
to 1; redundant zeros, exponent forms, numeric JSON values, and out-of-range values
are rejected. This implementation supports confidence on possible, necessary,
and predicted modes, not deontic force; strings are bounded at 1024 characters.
The historical possible-clause fixture with strength 0.7 now has accepted updated
MIDI/SVG hashes at all three anchors. Tests recover five values from notes and
compare Ruby/browser output. Ordinary-English confidence input remains pending.

### Explicit confidence sentence input

`With 70% confidence, it is possible that Pip cares for Ada` now composes with
strength 0.7 on the outer modality. Percentage conversion shifts decimal text
without floating-point arithmetic, including fractional percentages and normalized
redundant zeros. Inputs above 100%, duplicate confidence declarations, unmodalized
clauses, and outer negation are declined rather than silently assigning another
scope. Negation inside the modal proposition remains supported. This is an
explicit-confidence construction, not a claim that every use of chance, probably,
or belief has the same meaning. Sentence cases now include numeric sound contrasts.

### Cognitive sentence foundations

Existing MIN roots now compose `Pip is paying attention to Ada` (MIN:211), `Pip is
revising a mental representation of Ada` (MIN:111), and `Pip is able to pay
attention` (MIN:201). The first two bind a cognizer/experiencer and target; capacity
binds a bearer without inventing an attention target. Negation and modal wrappers
remain independent. Tests distinguish all three musical readings and decline
curiosity, learning, understanding, and unsupported manner additions. The review
in foundation_gap_review.md records why those broader meanings cannot be aliases.

### Unordered coordination music

All-of, any-of, and exactly-one semantic coordination now render with distinct
EZGRAM-1 opening/closing frames and an explicit member separator. Members play in
deterministic edge-ID order without asserting temporal sequence; unordered members
with sequence-order fields are rejected. Existing then-sequence timing stays
unchanged. Ruby/browser MIDI and SVG match, and all four interpretations produce
different sound. Parallel coordination remains unsupported pending voice scheduling.
English conjunction parsing and broader nested-scope decoding remain incomplete.

### Complete clauses joined by and

The browser now composes supported complete clauses joined by `and` as all-of
coordination, distinct from `then` sequences. Both use a shared clause-group
composer while preserving previous sequence identities. Quotes shield embedded
and/then text in noun labels. Conjunction requires every clause to parse fully;
noun lists, unsupported additions, bare or, and modal clauses with ambiguous scope
over later members remain partial. Tests compare complete Ruby/browser artifacts,
local negation, quoted labels, and the musical and-versus-then distinction.


### Yes/no questions

Supported named descriptions and progressive actions now accept subject–auxiliary
inversion (`Is Orin conscious?`, `Is Pip moving toward Ada?`), and care accepts
`Does Nora care for Eli?`. Explicit negative questions retain negation scope.
Question composition preserves lexical events and participant bindings while
setting the existing rising question contour and question speech act. Ruby/browser
formal equality and assertion-versus-question MIDI distinctions are checked.
Wh-questions, unsupported modifiers, embedded questions, and mixed question/assertion
coordination remain incomplete. The ordinary phrase audit now checks speech acts
explicitly and counts its question case as supported.

### Speaker and addressee references

A separate deictic_reference node now anchors the utterance's speaker or addressee.
The EZREF-1 implementation convention gives each a distinct short musical frame in
its participant-role register. These are not phonemic names, lexical roots, or
runtime states. Ruby rendering/validation and browser scheduling/MIDI/neutral mouth
cues support them. Tests reverse speaker/addressee roles and verify exact event and
MIDI parity. These anchors are context-relative and do not identify a persistent
person; third-person resolution and English pronoun/command parsing remain pending.


### Pronouns and direct commands

Supported clauses now map unquoted I/me to the speaker and you to the addressee;
quoted forms remain phonemic names. First-person conscious/dormant descriptions use
LIF:001/002 rather than the other-person roots. Direct imperatives for supported
care, repair, restoration, awakening, damage, movement, attention, and revision
processes bind the addressee and use the existing command contour. Negative commands
preserve explicit negation. Questions support pronoun agreement forms as well.
Distinct-target constructions reject identical referents rather than misusing an
other-target root for a reflexive meaning. Third-person pronouns, broader discourse
resolution, reflexive root selection, and unsupported modifiers remain unfinished.


### Approved poetic love in sentences

`I love you`, `You love me`, and named-person equivalents now bind the existing
CMP:44718c92b66443c0c0f03ad7 compound to their participants. Its LIF:002 and LIF:101
qualifiers and LIF:210 head remain unchanged. The output explicitly discloses the
approved poetic bond meaning; quoted-object love, generic liking, and reflexive
love remain unresolved rather than being coerced into it. Complete single-predicate
statements also accept explicit [0]/[1]/[2] runtime endings. `I love you [2]` applies
num only to the compound head and retains the approved never-finished-becoming
reading. Ordinary unmarked love uses runtime 1; negation remains a separate scope.
Tests compare reversed roles, active versus num, and all component/root identities.

### Speech-time relations in music

Before, at, and after speech time now frame their related clauses in EZGRAM-1.
These relations previously disappeared on the scheduler's fast path. The new
frames preserve lexical identity and runtime unchanged; the temporal-before
fixture has updated MIDI/SVG hashes at three anchors. Semantic validation checks
time-anchor types and relation endpoints. Musical export rejects unsupported
anchors, relations, and extra anchor parameters rather than ignoring them. Tests
compare all three relations across Ruby/browser output. Calendar offsets such as
yesterday, absolute dates, intervals, aspect, and English tense parsing remain
unfinished and must not be approximated by these three relations alone.


### Calendar-day musical anchors

The implementation now distinguishes the previous, current, and next calendar day
from generic before/at/after speech time. These are new implementation conventions,
not newly discovered historical DBA rules. An interval time-anchor uses
`calendar_unit: day`, `relative_to: speech_date`, and a string `day_offset` of
`-1`, `0`, or `1`, with a `during` edge to its clause. Resolution requires the
utterance's calendar and timezone context; no fixed duration or date is invented.
Ruby and browser rendering preserve these distinctions without changing roots or
runtime state. Other offsets, units, relations, and extra parameters are rejected
by musical export. English tense/day parsing remains unfinished; this milestone
only establishes the semantic and musical representation.


### Calendar-day English composition

Basic past copular/progressive statements and past care statements now accept
“yesterday”; present statements accept “today”; future “will be” and “will care
for” statements accept “tomorrow”. Each creates a calendar interval and a during
relation to its clause, retaining lexical runtime state. Future wording is
explicitly disclosed as a future assertion, without inferring promise, intention,
or willingness. The coverage audit therefore leaves its future ambiguity case
awaiting semantic review. Modal calendar combinations still decline until clause
scope can be represented faithfully. Quoted names are never tense-rewritten.


### Dictionary musical collision gate

`tools/audit_dictionary_musical_identity.rb` checks exact MIDI equality for all
324 atoms and 32 compounds in each runtime state (1,068 performances). Required
roles receive deterministic synthetic fillers. At anchor 60 with assertion
contours, the current dictionary has no exact-output collisions. This is a bounded
lexical check, not a claim that all sentence roles, recursive structures or
perceptually similar melodies are distinguishable.

A regression test demonstrates the failure the gate prevents: assigning a new
compound ID and specialized definition to unchanged component music produces a
new formal identity but identical MIDI. The audit groups by emitted MIDI bytes,
which contain no semantic IDs, so that case fails the collision criterion. New
conventional compounds must pass this gate before joining the approved inventory;
semantic hashes alone cannot establish listener recoverability. General inverse
interpretation and scoped compound sound encoding remain unfinished.


### Past reference and completed target processes

Past copular and progressive statements now compose with an explicit before-speech
relation. “Nora was restoring Eli” retains REP:111; “Nora restored Eli” uses the
existing completed target-restoration root REP:110. Equivalent reviewed mappings
cover awakening, damage and physical repair, including negative statements.
“Did not restore” negates completed restoration; it does not assert that no
restorative activity ever occurred. Runtime state remains independent of tense.

Yesterday can qualify these past statements. A past event today retains both its
current-calendar-day interval and its before-speech relation. Quoted names are
not rewritten, unsupported additions are not dropped, and combinations with modal
scope still decline until their clause structure is represented faithfully.

Past yes/no questions use the same temporal and completion mappings as statements.
“Did Nora restore Eli?” asks about completed restoration; “Was Nora restoring Eli?”
asks about ongoing restorative activity in the past. Negative questions retain
negation, calendar modifiers remain explicit, and the question contour is emitted.
This does not yet cover wh-questions, indirect questions, or arbitrary auxiliaries.

### Unquoted definite noun references

A bounded set of everyday single-word noun heads now accepts “the” without quotes,
including radio, machine, station, child and robot. Nouns retain their phonemic
labels, as requested. A separate reference frame marks definite nominal use;
`the radio` therefore differs from the quoted name `"radio"`. The noun label itself
does not invent a semantic root. The frame requests a contextually identifiable
referent; it does not claim to have resolved a unique real-world object.

The representation, role registers, marker and label survive both renderers,
MIDI/SVG export, and neutral mouth cues. Modifiers, quantities and indefinite
articles still require their own semantics and are not silently consumed as part
of a noun. Generic repair uses the reviewed restoration sense; explicit physical repair
retains its more specific compound.

### Generic repair construction

Ordinary “is repairing” now uses ongoing target restoration REP:111, and “repaired”
uses completed target restoration REP:110. Commands and past questions share those
mappings. Explicit physical repair retains its more specific compound and different
music. This closes the audited unquoted-radio repair sentence without treating all
repair as physical or using phonemic noun labels to infer unspoken mechanisms.

### Capability and ternary-state preservation

“Can repair/restore” and “is able to repair/restore” use REP:211 in its reviewed
currently enabled source-to-target restoration sense. The interpretation explicitly
excludes permission, an ongoing repair event, and guaranteed success. Negative
forms negate that relation rather than selecting runtime zero.

The user's reminder to preserve 0/1/2 applies to both lexical addresses and runtime
endings. Tests keep the REP:211 address unchanged while checking each explicit
runtime code, distinct emitted music, and the difference between inactive and
negated-active. The poetic never-finished-becoming interpretation remains confined
to the approved love construction; other num endings do not inherit that gloss.

Explicit runtime markers now preserve top-level question and command recognition.
Both `Did Nora restore Eli [2]?` and `Did Nora restore Eli? [2]` retain the question
contour and the selected ending. Compound commands place the ending on the external
head only. Tests cover every runtime value for affirmative/negative commands and
ongoing/completed questions. Conflicting punctuation, duplicate markers and nested
commands inside modal propositions are rejected rather than silently reinterpreted.

### Measurement sound preservation

Measurements previously survived in the semantic IR while export could omit their
magnitude and unit. Both schedulers now emit a bounded measurement frame containing
an optional minus sign, exact decimal digits, and a distinct unit frame. All 13
units currently declared in the IR specification have fixed codes. Redundant decimal
forms, unknown units and unsounded extra measurement fields are rejected by export.
The existing measurement fixture's three presentation hashes were updated because
the old bytes omitted meaning; its semantic identity remains unchanged.

This preserves existing measurement data, but does not yet implement everyday
measurement parsing or degree adjectives. A unit does not by itself specify a
property such as height versus width, or distance traveled versus distance to a
target. Temperature units, dimensional comparisons and contextual standards for
hot/heavy/fast still need explicit definitions. None uses 0/1/2 as a magnitude scale.

### Scoped quantity music

Musical export now supports exact, at-least and at-most cardinalities plus all,
some and none quantifiers. Each has an opening/closing frame around its semantic
scope. Counts use exact nonnegative integer strings; they do not repeat the scoped
phrase or alter runtime state. All/some/none reject numeric or other unrepresented
parameters. Range and proportional quantifiers remain explicitly unsupported.

The exact-quantity fixture now has sound-preserving presentation hashes at all
three reference anchors. Eight numerical/operator contrasts agree across Ruby and
browser MIDI/SVG. This establishes the musical representation; plural English
noun phrases and quantifier attachment still require parser and referent work.

Quantity validation now rejects malformed meanings before formal rendering. Exact,
minimum and maximum counts require canonical nonnegative integer strings; all,
some and none carry no numeric value. Unimplemented range/proportional shapes and
unrepresented parameters are rejected at this boundary. Measurements require exact
canonical decimal strings, preserving large values without floating-point coercion.
Negative zero, redundant zeros, exponents and JSON numeric values are rejected;
future English normalization must convert input to this explicit canonical form.
The 1,024-character implementation limit matches musical export.

Quantified participant occurrences now inherit the role register carried by their
quantity wrapper. Previously, a target inside an exact-count scope could fall back
to the middle register because only the wrapper had the target edge. Ruby and
browser composition now follow quantifier scopes to recover the role, with a
visited set to bound malformed cycles. The enclosing predicate does not inherit
its argument's register. Actor, target, environment and experiencer contrasts are
checked against emitted MIDI. This prepares counted noun arguments without yet
claiming a choice between collective and distributive English readings.

### Counted English noun phrases

Explicit “exactly,” “at least,” and “at most” counts now compose with a bounded set
of plural noun heads, including irregular children/child and people/person forms.
Counts accept decimal digits or zero-through-ten words. A nominal-class reference
carries the singular sound label, and a separate quantity scope fills the argument
role. Counted subjects retain subject agreement during parsing. The predicate is
rendered once, with its independently selected runtime ending.

This represents participant cardinality without inventing separate repeated events
or a more specific collective/distributive reading. Negative combinations,
multiple quantified arguments and adjective-modified nouns still decline where
scope or meaning is not yet preserved. Quoted names and definite noun references
keep their existing distinct frames. Full counted-language coverage remains open.


### Movement with both path endpoints

“Moving from … to/toward …” now binds mover, source and destination to the existing
ongoing target-approach sense MOV:111. This does not assert arrival or completion.
The scoped construction supports negation, runtime selection and existing past
question/calendar handling. Endpoint reversal changes the output, and the coverage
audit checks each role-to-label binding rather than only the set of noun labels.
Same-endpoint round trips and extra manner descriptions still need their own
semantics and are not silently flattened into this construction.

### Distinct musical argument roles

A structural audit found that all 22 declared role names collapsed into four exact
MIDI groups when only register distinguished them. Actor/source/cause were identical;
target/destination/result and other role families also collided. The before/after
reports retain that evidence. Explicit role frames now enclose each `fills_role`
argument subtree, using a fixed three-trit grammar code while preserving the
argument's register, root melody and runtime ending. All 22 probes now differ.

The probe tests role encoding, not whether a single lexical predicate licenses every
role. Updated fixture hashes reflect restored meaning. Traversing arguments also
exposed previously unsounded discourse variable/reference nodes; export now rejects
those explicitly until they have a proper musical representation. Inline compound
bindings, lexical valence and independent inverse decoding remain separate work.

### Conditional musical scope

Conditional IR now sounds the antecedent before the consequent inside an explicit frame. Open, satisfied, unsatisfied, and counterfactual conditions have distinct frames. Eight direction/status contrasts match browser and Ruby MIDI and SVG output. Unknown statuses, non-clause endpoints, and implicit multiple conditions fail explicitly. These are grammar conventions; existing root trits and runtime 0/1/2 endings are unchanged. Ordinary English conditional parsing and independent sound-to-meaning evaluation remain unfinished.

### English conditional composition

Explicit `If <supported assertion>, then <supported assertion>` now composes into two clause graphs joined by an open `condition_of` edge. Each clause preserves its own roles, negation, temporal scope, and runtime endings. The UI routes this construction before dictionary fallback. Five examples compare complete formal output and MIDI against Ruby, with an additional reversed-condition sound contrast. Unsupported or ambiguous clauses remain incomplete; conditional commands, anaphoric “it,” nested conditionals, and omitted-then forms still need implementation. This grammar adds no roots and assigns no new meaning to lexical 0/1/2.

### Impairment and restoration adjectives

Reviewed existing-sense constructions now map present “damaged/impaired” to WRN:001 and “restored” to REP:001, with the described entity as bearer and explicit sense notes. These condition meanings remain distinct from ongoing and completed damaging/restoring events. The review in `reviews/impairment_restoration_adjectives.md` records boundaries and counterexamples. Fifteen reference-renderer comparisons cover questions, negation, past time, quantities, and runtime endings; conditional composition also preserves the condition as antecedent. No root or compound definitions changed. This does not supply missing sensory or affective foundations.

### Nested compound binding roles in music

Compound participant bindings now carry role and predicate path at every binding-chain level, rather than losing the inner role when an argument is itself a compound. Musical scheduling wraps the complete argument subtree in role frames and closes/reopens frames when binding paths change. Twelve structural role/runtime contrasts match Ruby and browser MIDI/SVG, preserve inner and outer runtime endings, and emit each payload once. These probes check encoding mechanics, not whether the example predicate semantically licenses every tested role. Old bound formal artifacts must be regenerated to include per-level role metadata. Independent decoding of all compound attachment paths and lexical valence validation remain incomplete.

### MIN source cross references reconciled

Eighteen provisional pointers in nine MIN:0xx records now reflect the later canonical representational-change and selective-attention definitions. Active inventories, the canonical specification and browser index agree. Historical review packets and their baseline fingerprints remain intact. The migration compatibility check reverses only the two documented strings on the nine named roots and requires the full original record hash; it does not ignore changed definitions or musical fields. The foundation inventory snapshot now reports zero active provisional cross-references. Google and other external historical snapshots remain separate reconciliation work.

### Conditional commands and local it reference

The audited phrase “If the radio is damaged, repair it” now composes with WRN:001 in the condition, REP:111 in the consequent and command contour over the utterance. A trailing “it” may resolve to a single definite nominal bearer in the antecedent; both occurrences retain the same referent identity. Multiple participants, quantified classes and other unresolved pronouns are declined. Explicit “then” is optional for imperative consequents. Eight full renderer/MIDI comparisons cover paraphrase equivalence, role identity, separate negation scopes and runtime endings. The ordinary-phrase audit now checks this original case's direction and object identity explicitly. This is bounded local reference resolution, not general discourse anaphora.

### Explicit mass statements

“The box has a mass of 5 kilograms” now binds the mass measurement to a material bearer using the existing semantic IR units and quantity role. Gram input normalizes exactly to kilograms, so equivalent unit expressions share formal and musical output. Eight reference-renderer comparisons cover decimal precision, bearer identity, modal scope and runtime endings. The dimensional review distinguishes this existing foundation from still-missing comparison standards, property axes, temperature identity and contextual adjectives. No new root or compound was introduced.

### Scalar measurement comparison

The additive measurement comparison profile distinguishes greater-than, less-than, inclusive lower/upper bounds and inequality from exact measurement. Its operand direction is explicit: the bearer's measured quantity is compared with the supplied magnitude/unit. Musical frames preserve the operator around the reference measurement. English mass statements use this extension and retain exact unit normalization. Six comparisons match Ruby/browser formal output and MIDI and have distinct sounds; unsupported comparison names fail shared validation and browser scheduling. Root definitions and runtime meanings are unchanged. Entity-to-entity comparison and context-dependent adjectives remain unfinished.

### Mass comparison between two entities

“The box has more mass than the radio” now binds the box as bearer and the radio as comparison standard under an explicit mass-comparison operator. Six relations have distinct frames; twelve direction/relation examples match Ruby/browser formal output and MIDI. Modal wrappers and runtime endings remain separate. The profile rejects unsupported dimensions, quantified operands and malformed role attachments. No numeric mass is inferred, and no root meaning changes. General property comparison, contextual heavy/light interpretation, and normalization of logically equivalent operand-swapped comparisons remain unfinished.

### Independent inverse for strict mass comparison music

`pages/mass_comparison_decoder.mjs` accepts MIDI bytes only and recovers the supported mass-comparison relation, ordered participant phonemes/deictic roles, material root, runtime ending and speech contour. It does not receive the source sentence, semantic IR or formal event plan. Thirty-six relation/runtime/direction cases plus a deictic case pass; octave transposition preserves the result, corruption/truncation fail, and modal wrappers outside this decoder's profile fail explicitly. This is a first independent inverse profile, not general audio recognition or full translator decoding.

The inverse audit also confirms a reference limitation: Kay and Cay have different source name IDs but identical default phonemic music. The decoder returns the audible phonemes and explicitly leaves spelling/external identity unresolved. General decoding needs an ambiguity policy or disambiguating identity mechanism; source name hashes alone do not make the audio identities unique. Preserve the phonemic label channel while resolving that distinction.

### Browser compound plans and ordinary participant binding

The release now compiles exact expanded compound plans for browser use. The browser verifies plan identity and digest, binds actual participants by full slot path, and preserves nested qualifier attachment, role frames, and independent runtime endings. All 5,370 existing released forms retain their exact reference lexical events and glosses; 18 synthetic nested-attachment cases also match the reference renderer directly.

The reviewed construction “Ada has a directed data link to Ben” now uses the existing approved compound with explicit source and target bindings. Names, deictics and definite nouns work through the same path, including negation, modal scopes and clause composition. Twenty-one sentence comparisons preserve full formal output and MIDI. Clause composition prefixes occurrence and argument IDs without changing dictionary-local paths. Invalid bindings, corrupt plans/references and cyclic bindings are rejected. Quantified participants, general reflexive interpretation, broader compound English templates and independent musical inverse remain unfinished. This adds no roots and changes no dictionary meanings.

### Independent recovery of audible structure

`pages/strict_music_decoder.mjs` now reads strict MIDI plus the shared root dictionary, without source text, semantic IR, formal events or an expected sentence. It recovers roots and independent runtime endings, phonemic references, role registers, grammar/convention frames, nested frame matches and exact token boundaries. Suffix parsing rejects ambiguous codewords instead of guessing an identity. Tests cover all 5,370 released forms, sentence scopes, participant references, tagged labels, transposition, malformed data and 18 nested qualified-participant contrasts. No forward encoding changes.

This output is explicitly an audible-structure observation, not complete semantic reconstruction. Compound identities and predicate attachment still require interpretation; balanced frames alone do not prove valid grammar. Homophonic names remain unresolved, and repeated music does not uniquely expose repetition intent. The stricter mass-comparison inverse continues to interpret its supported semantic profile. General inverse decoding and listening validation remain completion requirements.

### Physical load support before carrying

The first load-bearing foundation uses MAT:211 physical influence and a MAT:010 restriction attached to the bound target load. Its explicit convention distinguishes load support from generic physical influence. “Ada is physically supporting the box” and “The shelf is physically supporting the box” bind source and load without implying intention, movement or carrying. Twenty role/runtime/scope cases match reference formal output and MIDI; independent MIDI observation recovers the qualifier inside the target frame and the support convention. Existing compound records remain unchanged by the addition.

The local controlled compiler now converts unique declared roles of scoped compounds into exact slot-path bindings before computing the IR digest. Repeated roles in nested scopes require explicit paths and are rejected by this convenience conversion. Existing unscoped controlled templates retain their previous representation. Carrying still requires linked transport and participant identities, so this support entry is not aliased to carrying, pushing, grasping or emotional support. The inventory is 324 roots and 36 compounds; counts do not establish ordinary-English coverage.

### Participant identity constraints across compound scopes

The optional `binding_constraints` dictionary field now enforces shared argument occurrences and distinct arguments across exact scoped slot paths. It participates in lexical identity and requires an explicit conventional meaning; constraint metadata alone does not introduce an audible semantic distinction. Expansion preserves inherited scope, rejects missing/mistyped paths, and detects transitive equality/distinctness contradictions. Ruby and browser binding reject mismatched participants and explicitly known referent aliases. Existing entries without constraints retain their identities and expansions.

A synthetic support/movement graph tests a load reused as the mover in all three runtime states. It is not approved carrying vocabulary. The next carrying definition still needs a precise transport invariant, temporal linkage, and an English/reference construction that supplies the shared participant. Separate nodes containing the same lexical value are never silently treated as one referent.

### Explicit role reuse and audible identity

The local controlled grammar now accepts `ROLE beneficiary REF actor`, reusing the earlier role's exact argument occurrence. References are clause-local and backward-only; equal lexical labels still create separate occurrences. Scoped compound identity constraints receive the actual shared node rather than an inferred alias.

Testing exposed a musical collision: the old scheduler repeated a shared argument's lexical payload, making it sound like two independent identical occurrences. EZROLE-REF-1 now uses an audible pointer to the first role, inside the later role frame. Sixty-six role/runtime probes distinguish shared from separate occurrences and match Ruby/browser MIDI and SVG; the independent MIDI observer recovers the reference token. Existing dictionary performances without shared direct-role arguments remain unchanged. Cross-clause coreference, unconstrained nested binding identity and complete semantic decoding remain unfinished.
