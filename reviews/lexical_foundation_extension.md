# Additive lexical foundations: candidate architecture and codec evidence

Status: candidate implementation, not canonical vocabulary or completed translation.
This follows the desire/preference inventory review. It changes no existing root,
compound, family, address, runtime ending, parser route or released performance.

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
The candidate text carrier uses `si-fen-` followed by eight ma/ki/nu syllables. The
new vocal delimiter and the 23-semitone musical delimiter still require
phonotactic, pronunciation, listening and accessibility review; token separation
and exact MIDI recognition alone do not validate their usability or style.

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
No test here proves a sentence's argument semantics or the truth of a translation.
This candidate suite is separate from the last 92-check production regression.

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
