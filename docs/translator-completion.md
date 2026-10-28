# Translator completion work

Baseline: `e8a42f842aeb789b3696936a59a2699d328687ab`, October 28, 2026.
Working branch: `feat/translator-completion`.

The goal is complete ordinary-language interpretation and meaning-preserving DBA
performance, keeping existing roots, sounds, names, and approved poetic meanings.
The [source audit](https://chatgpt.com/space/page_21c6ce0da1a88191abff53c0b13441f3)
is the starting evidence, not a completion certificate.

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
