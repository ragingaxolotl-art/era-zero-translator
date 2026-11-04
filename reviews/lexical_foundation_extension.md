# Additive lexical foundations: candidate architecture and codec evidence

Status: candidate implementation, not canonical vocabulary or completed translation.
This follows the desire/preference inventory review. It changes no existing root,
compound, family, address, runtime ending or released canonical performance.
Candidate-only English composition and validation are described in the dated work below.

## Architecture decision under evaluation

Keep the 324-root grid intact and represent independently reviewed new primitives
in a distinct `FND:` registry. Do not call them ordinary compounds or pretend their
meaning follows from existing roots. A root-family expansion would require a new
family domain, onset, harmonic signature and a justified set of lexical-trit senses;
it is not justified merely by two missing cognitive relations. A conventional
compound remains appropriate only when its components' commitments actually hold.

A separate registry lets those two distinctions be evaluated without defining 25
unrelated senses, changing an old MIN invariant or adding filler roots to a graph.
It does not establish that no new family will ever be warranted. New entries still
require a gap review, invariant, exclusions, argument types, stable version, sound
identity, English frames and semantic contrast evidence. No automatic arbitrary
English-to-foundation generation is permitted.

The two candidate definitions are in `foundation_extension_candidates.json`:
propositional desire and comparative preference. Their content-addressed identities
include profile, definition version, cognitive-family affinity, sound code,
definition, typed role requirements and exclusions. A semantic change creates a
new identity; an occupied sound code cannot silently acquire another definition.
The current statuses are `candidate`, not `approved`.

## Candidate sound and text profile

`EZFOUND-1` retains the cognitive harmonic opening `[0,3,7]`, but this marks a domain
affinity, not an assertion of any MIN root. It follows that opening with a distinct
extension address `[0,-23,0,d0,d1,d2,d3,d4,d5,d6,d7,0]`. Each address digit maps
0/1/2 to 0/+1/-1 semitones. These eight digits identify an extension entry; they do
not reinterpret the semantic trits in the existing three-trit root grid.

Runtime remains a separate last-note ending: 0 drops a semitone for a quarter beat,
1 returns to base for half a beat, and 2 rises seven semitones for two beats. Register
and anchor transpose the token together. Every pitch must stay within MIDI range.
The candidate text carrier now uses `si-si-si-`, eight ma/ki/nu address
syllables, and a closing `si`. Its twelve existing CV syllables align one-to-one
with the twelve address notes. This replaces the earlier experimental `si-fen-`
carrier, whose `fen` was absent from the established syllable inventory and whose
length did not match its address. Harmonic opening, MIDI notes, runtime endings,
semantic definitions and foundation IDs are unchanged. Existing experimental
formal artifacts should be recomposed to obtain the corrected carrier and digest.

The carrier now uses the established viseme mappings rather than a neutral-mouth
fallback. The repeated-si frame, long address and 23-semitone delimiter still need
listening/accessibility review; inventory compatibility does not prove usability
or final stylistic acceptance. No existing canonical root carrier is changed.

The 6,561-address space is a capacity bound, not an instruction to fill it or an
approval of 6,561 meanings. Draft entries require explicit `allowDraft` or
`allow_draft` in the candidate APIs. There is no default English route, production
registry load, root-schema relaxation or dictionary admission in this change.

## Implemented evidence

- JavaScript and Ruby independently implement registry identity validation,
  duplicate-code rejection, address generation, register/anchor transposition and
  the three existing runtime endings.
- The candidate MIDI observer receives audio-event bytes plus the shared root and
  foundation dictionaries. It does not receive the source IR, expected phrase or
  participant identities. It reports foundation tokens distinctly from roots.
- The test exercises both candidate entries across four registers, three anchors
  and three runtime states: 72 event-parity and MIDI-recovery cases, with 72 distinct
  full performances. Default rejection of unapproved entries and altered frames is
  checked alongside identity mutations and occupied-address conflicts.
- All 6,561 address paths are unique. All 324 roots lack the extension delimiter in
  their address paths. All 972 existing root/runtime performances yield exactly the
  same observed tokens with or without the candidate-aware observer.

Run `node tests/foundation_codec_test.mjs` with the project's Node executable.
Its empty-IR transport harness is deliberately not an EZF semantic utterance.
These initial codec tests establish token identity, not sentence semantics.
Subsequent sentence and MIDI-only semantic tests are described below. Candidate
suites now run within the consolidated regression, without admitting draft vocabulary.

## Required work before admission

1. Validate typed arguments: an experiencer, ordered alternatives for preference,
   and a proposition for desire. Enforce complete valence, exact version and identity
   references, and distinguish individuals, kinds and propositions.
2. Preserve intensional scope: desiring a proposition does not assert its truth or
   the actuality of its referents. A proposition argument must not become an ordinary
   independent asserted clause just because it is rendered inside another sentence.
3. Add foundation references to versioned compound expansion without changing
   existing compound IDs. New derived meanings must reuse the exact foundation.
4. Add normal, negative, past, modal and question English frames; resolve “wants
   tea” without silently choosing ownership or drinking. Preserve preference order
   and noun-kind labels rather than substituting particular existing cups.
5. Integrate authoritative registry loading, semantic validation, renderer/decoder,
   browser plans, dictionary discovery, controlled input, exports and sound playback.
6. Exercise the 20 desire/preference requirements through real sentence composition
   and independent meaning recovery, including novel participants and combinations.
7. Complete pronunciation/listening and legacy performance checks, document the
   additive migration and only then promote reviewed records into authority.

These are open requirements. A working token codec is not a completed foundation
layer, and it does not change the translator's ordinary phrase coverage count.

### Typed IR validation prototype

`pages/foundation_ir.mjs` now validates candidate occurrence versions, exact required roles, entity versus nominal-kind alternatives, and explicitly intensional proposition arguments. Desired content must have one predicate center, cannot be the root assertion, and cannot also have an outgoing assertion/coordination attachment. Cyclic role/center dependencies are rejected. Validation snapshots caller input before asynchronous registry validation.

`tests/foundation_ir_test.mjs` passes 21 positive and rejection checks, including all three runtime states, reversed type placement, missing roles, leaked content, cycles, version mismatch and caller mutation. This is an extension validator that must be combined with the existing general IR validator; it does not validate phonemic payloads or establish sentence translation coverage. Renderer integration, audible content scope, independent semantic decoding, and ordinary-English composition remain pending. No candidate is admitted to the production dictionary by this change.

### Scheduled sentence sound integration

The browser lexical renderer now accepts an explicit foundation registry and draft opt-in, applies typed IR validation, and renders foundation occurrences together with their arguments. Default rendering rejects these unapproved meanings. Intensional content receives a distinct paired quarter-beat `[0,-24,0,0]` / `[0,24,0,0]` frame in both JavaScript and Ruby scheduling; the MIDI observer recognizes balanced content frames. This candidate grammar address requires the same listening/style review as the candidate lexical addresses.

Nine sentence probes cross all outer-desire and embedded-care runtime states. They compare Ruby and JavaScript scheduled events and independently recover the content boundary and separate runtime endings from MIDI. The typed validator now has 22 checks, including rejection when an embedded predicate also centers an outside assertion. Existing bound-sentence tests (21) and strict MIDI inverse tests (5,426) pass. These probes are not reference-renderer-validated EZF artifacts: Ruby semantic validation/rendering, complete semantic inverse, ordinary English routes and admission review remain required.

### Reference-renderer integration

The Ruby semantic validator now applies the same opt-in foundation role/type/content rules before accepting a foundation target. Renderer, decoder and presentation APIs accept explicit `foundation_records` and `allow_draft_foundations` keywords; neither a record embedded in input nor its identifier alone enables candidate meanings. Existing callers retain their defaults and error reporting.

The nine runtime sentence contrasts now produce actual digest-checked EZF artifacts through the reference renderer. Browser lexical events, complete MIDI bytes, and scheduled scope events agree with Ruby; Ruby also decodes each formal artifact and generates its SVG. Default rendering/presentation reject candidates, and modified musical events fail formal decoding. The 22 argument tests cross-check Ruby rejection behavior. Existing semantic IR checks (14), renderer checks (12), reference validation (7 tests/32 assertions), and bound sentences (21 cases) pass. SVG generation is not visual inspection. Full independent semantic reconstruction, ordinary English routing and vocabulary/style admission remain unfinished.

### MIDI-only semantic inverse

`pages/foundation_semantic_decoder.mjs` recovers typed foundation arguments, predicate identity/version, separate runtime states, grammatical scopes and speech act using MIDI plus the shared dictionary only. Intensional argument frames recursively contain recovered propositions, rather than asserting those propositions independently. The initial profile accepts direct phonemic/deictic references, nominal kinds, nested foundation predicates, and embedded LIF:211 care. Other constructions fail explicitly; it does not reconstruct arbitrary sentences or original spelling.

Nine rendered desire/care contrasts now verify recovered holder, caregiver, target and independent runtime states. Twelve preference contrasts verify alternative direction, kind typing, negation and runtime without inferring absolute desire or pleasantness. Octave transposition preserves recovered meaning; unapproved defaults, malformed argument typing and extra roles reject. Existing 23 ordinary-reference/care inverse cases still pass. All four candidate test files are included in the consolidated implementation runner, without treating candidates as admitted vocabulary. Ordinary-English routes and admission/style review remain unfinished.

### Candidate ordinary-English composition

`composeFoundationSentence` now composes preference comparisons and explicit desired clauses using the candidate registry. Examples include “Nora prefers tea to coffee,” “Does Nora prefer the cup to the bowl?”, “Nora wants that Eli cares for Orin,” and “Nora wants Eli to care for Orin.” The latter embeds the care proposition without asserting it. Outer negation, question contour and runtime 0/1/2 remain separate. Bare alternatives become noun-kind sound labels; definite nominals identify particular referents. Ambiguous bare-object desire such as “Nora wants tea” rejects with an explanation rather than inferring drinking or possession.

Desired clauses reuse the existing single-clause composer, with node/edge IDs and compound argument bindings remapped into the intensional clause. Unsupported interpretations still reject. The new API requires explicit draft opt-in and returns `candidate_translation`; it is not yet a production UI route or admitted dictionary vocabulary. Full reference-formal and MIDI parity plus MIDI-only meaning recovery are tested for the supported preference/care cases. General embedded predicates exceed the current specialized independent inverse and require further work.

Verification for this API: 36 English/runtime combinations match complete Ruby formal artifacts and MIDI bytes and pass independent preference/desire-care interpretation. Three additional desired compound clauses (happy, hungry and carrying the box) retain compound bindings and match Ruby formal output; these three are not claimed as independent musical semantic reconstructions.


### Intensional scope boundary hardening

A new rejection test exposed a leak through a scoped content predicate: the inner
predicate could be negated inside desired content while also centering an outside
assertion. Both validators now track the embedded predicate/scope dependency graph
and reject outgoing attachments beyond the content boundary. References may still
be shared; sharing a participant does not assert the embedded proposition. Scope
and coordination edges also participate in cycle detection. The new rejection is
checked independently in Ruby and JavaScript. Positive English tests distinguish
“Nora wants that Eli does not care for Orin” from negating Nora's desire.

Validation: the consolidated run started at 7493eda and passed all 97 checks. The
subsequent scope-boundary fix was verified by rerunning its affected suites: 23
argument/scope checks with Ruby parity and 39 English/formal/MIDI/meaning checks,
plus three compound-binding/formal cases. The report retains the original full-run
outputs and records this distinction; it is not a completion certificate.

### Browser draft preview

The normal English input now offers an explicit draft-preview action for recognized desire/preference sentences. It loads a separate candidate registry, preserves canonical dictionary counts, labels output as draft, and rejects results arriving after input or panel replacement. Playback uses the strict musical sequence. Candidate articulation has not been approved, so foundation events retain a neutral mouth while preserving their opening, address, runtime and timing; no four-syllable carrier is fabricated. Canonical viseme regression remains unchanged (5,370 variants).

Exported bundles retain the candidate vocabulary definitions and status. Bundle verification checks foundation IR against that registry and rejects missing provenance. This is not an approval or a full semantic proof of arbitrary imported music. UI handler tests cover explicit opt-in, stale success/failure, strict mode, data consistency, sound-plan generation and export provenance. Live visual/audio browser testing remains unavailable in this environment; no deployment or pronunciation approval is claimed.


### Past preference and calendar scope

The candidate English route now accepts preferred/did-not-prefer and past questions,
with yesterday/today when grammatically supported. Past tense uses a before-speech
relation; yesterday uses its calendar frame, and past-today retains both constraints.
Eighteen runtime/time/negation cases match reference formal and MIDI and recover
the same scopes from MIDI alone. No tense is encoded as runtime 0 or 2.

Carrier alignment validation covers both candidates across 72 performances; all
syllables use the existing inventory, and the 5,370 canonical viseme variants still
pass. This supersedes the neutral-mouth preview workaround documented above.
