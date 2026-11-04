# Spatial entry before “may enter”

Status: semantic audit and implementation contract; entry is not implemented by
this review. Inspected at revision 5a5a427 (324 roots, 58 compounds). Preserve all
root definitions, existing conventions and lexical/runtime 0/1/2 distinctions.

## Evidence and rejected substitutions

The source of root definitions is lexicon/all_atoms.yaml; compound meanings are
in lexicon/compound_dictionary.yaml. Inspection covered all MOV root definitions,
STR boundary/interface exclusions, all compound titles and the exact material-route
and swimming-across definitions. A full-inventory definition keyword scan found
no direct inside/outside/containment primitive. This is candidate evidence, not a
proof that no possible composition can express entry.

- MOV:110 means completed displacement to a target position. Arrival at the
  archive doorstep is a counterexample to equating arrival with entry.
- MOV:111 means ongoing target approach. Approaching from outside without crossing
  the threshold is not completed entry. A target could also be approached inside.
- MOV:100 means completed source departure. Leaving one position does not specify
  which region is entered, or even that any region boundary is crossed.
- MOV:210/211 relate a mover to a target position; MOV:220/221 supply positional
  configurations. None selects a region interior or an outside-to-inside transition.
- STR:010–012 explicitly exclude physical inside/outside regions and movement.
  Structural engagement cannot supply spatial containment. STR part–whole roots
  likewise do not turn occupying a room into being a constituent of its structure.
- Material route CMP:919b714e6201a462756224a2 requires an established material route.
  Entry need not follow a road, corridor or other established route.
- Swimming-across CMP:a900dd73c9816ed6cbad29f0 already binds a spatial region, but
  contributes swimming and opposed-side traversal. Walking into an archive need
  entail neither. Reuse its region-binding discipline, not its lexical meaning.

The archive noun label identifies a referent; its phonemes do not assert building,
room, interior, threshold or entry. “Enter the data”, “enter a competition” and
“enter a discussion” need distinct senses, not a physical-entry alias.

## Dependency order and proposed meaning contract

1. Establish a reusable spatial region/interior relation. Bind located participant
   and region, with a contextual criterion for what counts as inside. A body may
   straddle a boundary; outside, boundary and inside must not collapse into two
   exhaustive Boolean states. Do not silently invent geometry or a body-center
   criterion from a noun label. Keep structural membership and custody separate.
2. Define completed physical entry: displacement of the same participant crosses
   from outside the selected region to inside it during the same event, under the
   same region and inclusion criterion. Intermediate boundary contact is allowed.
   Being inside throughout, a region expanding around a stationary participant,
   arriving at the exterior doorstep, or unrelated departure and arrival events
   do not meet this selected displacement sense. Later exit does not undo entry.
3. Define ongoing entry independently of successful culmination. It must not
   assert completed entry. Simple-present viewpoint, past time and runtime state
   remain separate; runtime 0 or 2 does not substitute for outside or approaching.
4. Compose manner-specific entry only after these meanings exist: running into,
   carrying into, swimming into. Bind the same actor, region and event rather than
   asserting unrelated running plus entry. Do not impose swimming or running on
   the base entry concept.
5. Compose modal entry last. “Nora may enter the archive” requires an explicit
   choice between permitted entry and possible entry. Neither asserts actual
   entry, physical ability, future certainty or successful arrival.

Prefer a versioned spatial relation profile or an explicitly conventional
specialization whose component entailments remain true. The missing interior
criterion cannot be manufactured by recursive depth. No new 27-root family is
justified by this isolated gap. Select an encoding after reviewing its reusable
state and event bindings; this review reserves no root or sound address.

## Modal machinery already present

spec/semantic_ir_1.0.yaml and spec/grammar_frames_1.0.yaml distinguish possible
and permitted, with different frames. pages/strict_semantic_reader.mjs recognizes
both. pages/sentences.mjs currently routes explicit possible/necessary wrappers,
but does not implement ordinary “may enter”. Permission is not a confidence
score; the existing confidence parser appropriately excludes permitted mode.
Do not add a new modal atom merely because this English route is missing.

Required modal contrasts: possible entry while forbidden; permitted entry while
physically impossible; permitted but not performed; not permitted to enter versus
permitted not to enter. Scope must survive musical recovery independently of the
English wording. A permitting authority or epistemic source, when supplied in
English, must be represented rather than dropped.

## Acceptance evidence required before counting this phrase as translated

- Outside→boundary→inside entry contrasts with outside→doorstep, inside→inside,
  inside→outside exit, and stationary enclosure. Same participant and region are
  mandatory; unrelated transitions must fail the entry condition.
- Completed entry followed by exit retains the historical entry claim; ongoing
  entry need not culminate. Entry does not entail intention, permission, ownership,
  custody, a prescribed route, or continued presence.
- The two “may” readings, both negation scopes, tense, questions and runtime 0/1/2
  need full-sentence checks and independent recovery from MIDI. Reject dropped
  arguments and verify swapped regions and actors are musically distinguishable.
- Existing roots, poetic meanings and sound labels remain unchanged. Compound
  dependencies must be versioned and cycle-free, with old outputs preserved.
- The original ordinary-English diagnostic remains unresolved until the complete
  selected sentence meaning is composed and performed. This document is not a
  passing translation result or completion evidence for the overall translator.
