# Cognitive foundations: dependency review

Status: proposed semantic contracts and acceptance requirements, not canonical
vocabulary, new musical addresses, or implemented English support. Evidence is
pinned in `reports/cognitive_foundation_review.json`; authored contrast obligations
are in `tests/cognitive_meaning_requirements.json`. Neither artifact is a passing
translation test or a held-out evaluation.

## Decision and dependency order

Do not add curiosity, learning or understanding as aliases of attention, revision
or data receipt. Do not introduce a new 27-root family to fill these gaps. Preserve
all 324 roots, 55 approved compounds and the existing candidate desire/preference
identities. Begin with typed cognitive content and a narrowly defined epistemic
state, then its acquisition; only then compose curiosity using the existing desire
candidate where its definition fits. This follows the earlier desire/preference
review rather than introducing another wanting primitive.

1. **Content and question types.** Keep an entity/topic, a proposition, an expressed
   message and an open question distinct. A name such as “map” identifies a topic;
   it does not supply “who made the map?” or “how to read the map?”. A question is
   content here, not the speech act of the whole sentence. Existing proposition
   content can be reused, but open-question binding and contextual content
   resolution are unfinished grammar dependencies.
2. **Epistemic result states.** Separate grasping communicated content, grasping an
   explanatory relation, possessing information, memorization and practical
   know-how. They do not entail each other. A proposed comprehension state needs
   a cognizer, content and a contextual adequacy criterion; this criterion cannot
   be replaced by confidence or a runtime trit. Whether this belongs in a new
   candidate foundation or an explicit lexical convention remains a design choice.
   Existing roots cannot be used as padding if their additional commitments are
   not entailed by the intended sense.
3. **Acquisition.** Build a transition into a selected epistemic result state with
   the same cognizer and content at culmination. Reuse the established transition
   machinery only after checking that its roles can refer to this state and that
   the nested state is a result, not an independent assertion at speech time.
   Acquisition may be incremental; a bounded “learned” event need not assert
   permanent retention, conscious effort, a teacher, or perfect mastery.
4. **Curiosity.** Reuse desire for acquisition of information about the selected
   question where that reading is intended. Desire alone may also describe purely
   instrumental information seeking; ordinary curiosity adds an epistemic-interest
   reading that requires an explicit definition. Do not declare the bare desire
   composition equivalent to all curiosity until contrast cases justify it.

## What the current definitions actually establish

The four directly relevant root families (108 exact definitions) were inspected,
alongside the current compound sense definitions. This is a targeted entailment
review, not a formal proof that no expression in the entire language could work.

| Existing ingredient | Established commitment | Counterexample to the proposed shortcut |
|---|---|---|
| MIN:210/211 | Established/current allocation of attention to a target | Listening carefully to an unfamiliar language need not yield comprehension. |
| MIN:010/011/012 | Persistent/manifest/latent target representation | A representation can be mistaken, uninterpreted or unhelpful for action. |
| MIN:110/111 | Completed/ongoing target-model revision | Revision can introduce error; not every change is learning. |
| DAT:110/111 | Completed/ongoing information transfer | A device may receive encoded content without interpreting it. |
| CON:110/111 | Completed/ongoing communicative uptake | Taking up an expression does not establish the intended meaning was grasped. |
| LOG:110/111 | Evaluation of admissibility under a specified constraint | Passing a formal criterion does not by itself establish truth, knowledge or comprehension. |
| Sensory registration compounds | Physical registration with specified channels | Their definitions explicitly exclude comprehension and recognition. |
| Felt pleasure and attention compounds | Experiential tone or cognitive selection | Curiosity may be unpleasant and need not be attended to at the moment. |

Do not repair these failures by changing the root definitions. A conventional
compound may add an explicit meaning, but must retain every commitment of its
components. For example, persistent representation is too strong for a fleeting
comprehension episode, and conscious feeling is too strong for all standing
curiosity. A smaller subtype must not silently replace the requested broad sense.

## Interpretation obligations for the current failed phrases

- **“Nora learned the route.”** Distinguish memorizing route information, acquiring
  practical navigation knowledge and becoming familiar with the route. Do not
  infer actual travel, a correct map, or current retention from a noun label.
- **“Eli understands Nora.”** Resolve communicated content, motives/reasons or an
  empathetic reading. A person label cannot supply an unstated message. Preserve
  an unresolved contextual content argument when clarification is needed.
- **“Orin is curious about the map.”** Preserve the topic without inventing the
  specific question. The intended epistemic interest does not assert discovery,
  success, pleasure, attention or action.

“Learned that P” ordinarily brings a factive commitment that memorizing a claim
or learning how to do something does not share. This distinction must also survive
negation, embedded desire and questions; no general rule should assert embedded
content merely because it has a proposition node. Projection behavior needs its
own explicit semantic contract before those forms are admitted.

## Implementation and evidence required next

Implement typed open-question/contextual-content arguments and a reviewed result
state contract before composing its acquisition. Reuse the desire candidate for
appropriate epistemic aims; do not mint a second desire sense. Require participant
identity through each nested layer, explicit state/transition scope, independent
negation and runtime states, and audible content-kind distinctions. Candidate
sound codes must be allocated only after the contract is settled and must preserve
all existing melodies.

The ten authored contrast cases are future acceptance requirements. Completion
requires actual sentence interpretation, validated IR, browser/Ruby performance
agreement and independent musical recovery of the distinguishing commitments.
No cognitive phrase is newly supported by this review alone. Source reconciliation,
root-family admission and full translator completion remain open.

## First implementation: polar content documents

`pages/question_content.mjs` implements an opt-in EZQUESTION-CONTENT-1 document.
It embeds the complete existing proposition IR under a polar question wrapper,
whose explicit assertion commitment is neither answer. This reuses existing
participant, compound, negation and runtime representations. Its content digest
and ID include both the wrapper and proposition. It accepts explicit “whether P”
content through existing sentence composition; bare topics and unsupported
propositions do not invent an epistemic question.

This is a reusable content document, not a new canonical IR node. Its validator
checks the wrapper contract and embedded semantic identity; it supplements rather
than replaces ordinary IR validation. It does not prove arbitrary imported IR
well-formed merely from a recomputed digest. Other draft grammars are not admitted
inside it yet. Existing canonical composers generate the tested proposition IR.

Twelve compositions preserve complete proposition graphs across runtime 0/1/2,
including negation, repair and swimming. Tests distinguish positive/negative/unknown
logical answer alternatives without interpreting runtime numbers as truth. Rehashed
wrapper tampering and stale embedded identities are rejected. These are semantic
content checks, not musical inverse checks or claims of English cognitive coverage.

Next: define musical framing for question content distinct from matrix question
speech acts and asserted propositions, then bind it to reviewed epistemic state
and acquisition relations. Open wh-questions, contextual topics, factive projection,
Ruby content validation and broad cognitive sentence composition remain unfinished.

## Draft standalone question-content music

EZQUESTION-MUSIC-1 now uses explicit polar-content opening/closing frames around
the unchanged scheduled proposition events. The neutral final contour closes this
standalone content audition; the wrapper explicitly means neither answer is
asserted. It is distinct from a matrix direct-question contour. Draft decoding
requires its own opt-in and the two paths do not collide with existing strict
grammar or counted-predicate frames. No canonical sound is reassigned.

Twelve full predicate performances preserve their independently decoded token
trees inside the new wrapper, including participants, registers, negation,
compound structure and runtime. Frame-index metadata is normalized for comparison;
actual tree nesting is retained. Empty content and ordinary direct-question
performances are rejected by the content reader. The reader recovers structure,
not the full epistemic meaning of arbitrary predicates. Formal/content identity
is checked before scheduling, but this is not a general formal regeneration
validator. Inputs are snapshotted across asynchronous validation.

The shared MIDI writer was extracted without changing the ordinary formal route.
The 5,429-performance strict inverse regression, counted-property browser/Ruby
parity, existing foundation preview/export checks and counted-frame checks pass.
This remains browser-only standalone content audition: Ruby question-content
validation/rendering, cognitive predicate binding, full semantic inverse, live
listening and canonical admission remain open.
