# Interpreting simple-present carrying

Bare “Pip carries the box” has no single mandatory habitual reading. It can
describe a recurring practice, an unfolding action, or one episode in narration.
The parser now recognizes the construction while retaining an unresolved viewpoint.
Composition requires an explicit `viewpoint` choice: habitual, ongoing or bounded.
No audio is produced by the choice screen until a supported reading is submitted.

The choice uses the existing aspect operator and sound frames. It adds no root,
compound or musical code. Ongoing and habitual selections have exactly the same
canonical IR, formal identity and MIDI as “is carrying” and “habitually carries”.
A bounded narrated episode does not add past time, future intention, arrival or
delivery. Context supplies its reference interval; an explicit day remains separate.
Negation, questions, modal wrappers and runtime 0/1/2 retain their independent scope.

“Pip carries the heavy box toward Ada” requires both a viewpoint and a mass
standard. These are independent parameters: choosing one cannot silently choose
the other. The existing mass restriction remains on the box. The browser provides
one form with an initially blank viewpoint and blank threshold. It discards a result
if the input, mode, viewpoint, standard or active choice card changed while loading.
Late failures from a detached form cannot overwrite a newer result.

Tests compare Ruby/browser formal and MIDI output for 63 viewpoint/state/participant/
question/modal/property combinations. They check paraphrase equivalence, absence of
arrival/future inference, missing and invalid choices, complete rejection of an
unresolved multi-clause input, and the actual UI handler's asynchronous behavior.

Still open: destination culmination and recipient interpretation for “to Ada”,
per-clause choice UI, broader present-tense verbs, discourse, perfect/future
constructions, and the full original carrying acceptance suite. Recognizing a
phrase that requires clarification does not count as an exact translation before
the choices are supplied.

Live browser verification exercised “Pip carries the heavy box toward Ada [2]”.
The blank mass threshold correctly blocked composition after selecting a recurring
practice. Supplying 20 kilograms produced the result and displayed `MOV:121 [2]
num: 69` with a level contour. This check exposed a result-panel error that sent
grammar markers into lexical checksum lookup; grammar frames now bypass that
lookup. The result labels a lexical gloss accurately and displays runtime endings,
contour, IR and glyph. An actual result-panel regression covers three sound modes
and all three runtime states. This was a visual/form check, not a listening test
or proof of full sentence semantic recovery.
