# Spatial arrival before completed carrying

This implementation reuses approved MOV:110: completion of a mover's displacement
to a target position. MOV:111 instead denotes ongoing displacement toward that
position. MOV:010 identifies a destination; it does not assert travel or arrival.
MOV:210 establishes a positional relation without asserting the displacement event.
These distinctions are recorded in the current foundation inventory and the MOV
process approval. No new root, alias, compound or musical address is introduced.

“Ada arrived at the gate” assigns Ada as actor and the gate as destination, with
MOV:110 and a separate before-speech time relation. Definite nouns and proper names
retain sound labels. Arrival does not entail continued presence at speech time,
deliberate travel, carriage of a load, transfer of possession or a recipient.
“Did not arrive” negates the completed arrival rather than asserting an approach
that failed. Questions ask about the same proposition. Today/yesterday retain their
calendar scopes. Runtime 0/1/2 applies independently to the completed-arrival root;
lexical completion is not runtime 0, and past time is not runtime 2.

The implementation covers explicit past spatial arrival, its negation and questions,
and existing single nominal mass restrictions. It does not yet cover progressive
arrival, arriving at a conclusion, unmarked present, perfect aspect, quantified
destinations or added manner. Unsupported variants stay incomplete rather than
falling back to a dictionary word as the whole sentence.

## Dependency decision for carrying to a destination

The available roots cover arrival. They do not by themselves establish that a
carried load arrived through the same carrying episode. A conjunction of carrying
and arrival can describe unrelated episodes; matching noun spellings do not prove
identity. The next completed-carrying construction must bind the load as mover,
the destination as endpoint, and the carrying support and movement to one event
whose culmination is that arrival. Preserve the existing ongoing carrying compound
unchanged. A separately versioned definition may depend on that compound and the
arrival root, with explicit event/endpoint semantics and audible scope.

Progressive “is carrying the box to Ada” does not entail successful arrival. A
bounded completed reading cannot simply replace its movement root with MOV:110.
Habitual carrying to a destination also requires scoped endpoint structure rather
than one asserted present arrival. “To Ada” may identify Ada's contextual location
or a recipient; the phonemic proper name does not decide. Receipt/possession must
be audited separately before a delivery reading is accepted. Neither approach nor
arrival automatically establishes handing over, ownership, acceptance or benefit.

These are requirements for the remaining original carrying milestone, not claims
that this arrival implementation completes it. No new atom family is justified by
this gap: the immediate gaps are event composition and interpretation, with the
possession foundation still requiring implementation. The separate
[receipt/possession review](receipt_possession_foundation.md) records candidate
failures, counterexamples and the dependency order; it approves no new meaning.

## Evidence

`tests/arrival_sentence_test.mjs` checks 27 participant, question, negation, calendar,
nominal-property and runtime combinations against Ruby formal and MIDI rendering.
The independent MIDI decoder observes MOV:110 versus MOV:111, runtime, actor and
destination roles, negation and time markers; it verifies the mover's sound label.
It does not yet recover a general sentence meaning independently or constitute a
held-out English benchmark. No listening test is claimed.
