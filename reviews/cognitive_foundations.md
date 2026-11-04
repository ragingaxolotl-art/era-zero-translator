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

## Ruby question-content validation and rendering

`EraZeroQuestionContent` now validates the draft wrapper and its content identity,
and sends the entire embedded proposition through the canonical semantic validator
and renderer. This is stronger than the browser wrapper's supplementary identity
check: invalid roles and graph semantics are checked against current authority.
It regenerates the formal proposition rather than accepting supplied performance
events. The wrapper still asserts neither answer and requires explicit opt-in.

All twelve browser content cases produce byte-identical Ruby MIDI. Default
admission, a changed assertion commitment and an invalid participant role are
rejected. The ordinary Ruby MIDI writer was extracted into a shared event writer;
the existing ten glyph/audio checks, eighteen counted-property parity cases and
counted-noun regressions pass. No root, approved compound or canonical performance
was changed. This supersedes the earlier browser-only rendering limitation.

Cognitive predicate binding and full epistemic semantic recovery remain the next
work. Musical token-tree parity does not establish that a holder knows, believes,
understands or has learned an answer. Open questions and live listening remain
unverified.

## Candidate polar-answer knowledge and typed question binding

`reviews/cognitive_foundation_candidates.json` records one separate, noncanonical
EZFOUND-1 candidate: knowledge of a polar answer, using previously unused sound
code 2. It does not modify desire/preference records, the 324-root grid or approved
compounds. Its invariant commits to knowing the correct alternative under the
contextual epistemic standard, excludes a merely correct guess, and does not
select the positive rather than negative answer. It asserts no acquisition event,
explanation, empathy, skill, current attention, communication or permanent retention.
This is the result-state dependency for a future learning construction, not a
synonym for all understanding or all learning.

Foundation type checking now admits `question` separately from `proposition`.
An embedded question clause requires intensional content and `question_kind: polar`;
it retains a single owned predicate center and cannot escape into an assertion.
The knowledge candidate requires this question argument. Existing desire still
requires a proposition: wanting to know requires a nested knowledge proposition,
not a question attached directly to desire. Question metadata on a proposition
is rejected rather than ignored. Open wh-question binding remains unsupported.

Browser/Ruby validators agree on all three runtime states and five malformed
argument/scope cases. Ruby-rendered formal documents produce byte-identical MIDI
in the browser; independent token observation recovers the candidate identity
and the polar-content frame only with the separate draft-question opt-in. The
existing 23 foundation type/scope checks and foundation preview/export checks
pass. This is typed binding and performance evidence, not a full semantic inverse
or English knows/whether admission. A contextual knowledge claim cannot be
verified as real-world knowledge from runtime, confidence or a truth bit.

Next: compose explicit knows/whether English with independent outer and inner
negation and runtime, then independently recover the holder, question proposition
and both scopes from music. Keep default canonical admission unchanged until the
candidate review and broader completion gates are satisfied.

## Opt-in English knows/whether composition

The shared foundation composer now accepts `allowCognitive: true` in addition to
the existing draft opt-in and an explicit registry containing the knowledge
candidate. This admits explicit finite knows/whether clauses, negative forms,
direct questions and negative contractions. The ordinary parser/UI route remains
unchanged; its registry does not silently acquire the candidate.

The existing content composer is reused, preserving complete inner propositions
and compound bindings. Only the selected content clause becomes a typed polar
question; outer negation still scopes the knowledge relation, and inner negation
stays inside its question. The last runtime tag describes the outer predicate;
an earlier tag inside the content describes the inner predicate. Twenty-one
cases cover all nine outer/inner runtime pairs, both outer negation choices,
questions and contractions. Full browser formal objects equal Ruby regeneration,
and MIDI bytes match. Knows-that, bare knows-a-person, learned-whether and bare
topics are not silently mapped to this sense.

This adds a draft English API, not main UI admission or proof of real-world
knowledge. Independent full semantic recovery, pronoun-field integration for the
cognitive route, acquisition/learning composition and broader cognitive meanings
remain unfinished.

## Independent knows/whether musical recovery

The foundation semantic inverse now accepts polar-content frames only under
`allowDraftQuestionContent`, separately from candidate vocabulary opt-in. It
recovers a typed intensional question with an explicit neither-answer assertion
commitment. The existing recursive predicate reader recovers the body and checks
its roles; registry argument types reject a proposition where knowledge requires
a question, or a question where desire requires a proposition. It receives MIDI
and shared dictionaries, never the expected source IR, formal plan or sentence.

The 21 knows/whether tests now check the recovered holder and content bearer
phonemes, candidate identity, inner predicate, both negation positions, all nine
inner/outer runtime pairs and matrix speech act. Two deliberately changed but
well-framed performances (desire with question content, knowledge with proposition
content) reject instead of silently becoming another reading. The existing twelve
preference inverse contrasts still pass.

This is semantic recovery for the admitted inverse constructions, not arbitrary
English or recorded-audio comprehension. The English composer can reuse ordinary
predicates outside the inverse's current whitelist; those still reject in the
inverse and are not covered by this evidence. UI admission, wider inverse support,
learning/acquisition, source reconciliation and listening validation remain open.
