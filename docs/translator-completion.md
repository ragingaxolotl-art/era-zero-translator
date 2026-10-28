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
Phonemic referents, general IR validation, browser interpretation and boundary
timing remain outstanding.

Still required: phonemic participant integration, complete compound
timing and contour scheduling, grammar-aware MIDI, and browser integration.
Formal round-trip preservation is not proof of audible semantic completeness.

Ruby MIDI export now schedules counted repetition as whole phrases. Parsed MIDI
tests verify two versus three repetitions, compound integrity, sequence order,
and bounded expansion. Browser sound plans, viseme cues, MIDI and SVG now consume
the equivalent JavaScript schedule; Ruby SVG also consumes the schedule. Cross-language
tests compare exact MIDI bytes, SVG and parsed notes. Only repetition fixture
hashes changed in the legacy presentation matrix. Negation and other scopes remain
unresolved musical-fidelity work; this does not complete general sentence playback.
