# Preference between propositions

The existing candidate comparative-preference definition accepts entity, kind
and proposition arguments. Its English route previously exposed only entity and
kind labels. This change connects complete finite propositions to the already
typed target and comparison-standard roles; it adds no meaning, root or code.

The explicit form is “Nora prefers that Eli is happy rather than that Eli is
tired.” Each alternative must have its own subject and a supported predicate.
Both are intensional content clauses, not additional assertions of happiness or
fatigue. The preference holder does not become either alternative's subject.
Relative preference does not imply that the favored alternative is absolutely
wanted, pleasant or chosen.

Compound bindings and nested desire references are copied with distinct node
prefixes for each alternative. This preserves compounds of compounds and prevents
two alternatives from overwriting each other's participants. An inner controlled
desire subject still refers to its immediate desire holder. Explicit alternatives
retain their subjects, even when labels repeat.

Outer preference tense, negation and runtime remain separate from each content
clause. A day at the end of the second alternative belongs to that proposition;
it is not moved to the outer preference. Question wording preserves question
contour. Multiple unbracketed “rather than that” boundaries are rejected because
their attachment is unresolved.

The new test verifies 27 independent outer/left/right runtime combinations with
Ruby/browser rendering parity and MIDI-only recovery. Additional contrasts cover
reversal, nested desire, separate negation, outer past, differing content days and
past negative questions. The original twenty-case acceptance audit remains at
eight candidate passes and twelve uncomposed cases: this extension does not make
painful-treatment modifiers, object desire, curiosity or choice available.

Candidate opt-in and all existing admission gates remain. Full English preference
syntax, general comparative attachment, mixed kinds/propositions, ellipsis,
and listening tests are not established by this suite. The subsequent full
111-check regression at `9a6ae06` passes with no reruns; it does not supply those
missing scope or listening claims.
