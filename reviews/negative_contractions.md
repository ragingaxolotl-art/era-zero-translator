# Negative auxiliary contractions

Ordinary negative auxiliary contractions now expand before construction parsing,
including straight and curly apostrophes. Negative questions move the expanded
“not” after the subject, preserving the existing question construction. Quoted
sound labels are never rewritten. Ambiguous possessive/auxiliary 's and 'd are
not expanded. An expansion only succeeds when the complete resulting sentence
already has a supported meaning; it does not add capability, obligation,
permission, tense or event meanings that are not represented.

Thirty-three cases across runtime 0/1/2 cover swimming, habits, repair capacity,
past repair, negative commands/questions and energized bearers. Each contraction
has identical formal representation and MIDI to its explicit expanded sentence;
the original source input remains available. A mixed conjunction also preserves
both clauses. Existing proposition-negation, speech-act/runtime and conditional
command checks pass. This improves ordinary input access to existing meanings;
it does not resolve missing vocabulary or the quantified negative-predicate gap.

Local conditional reference resolution now recognizes both apostrophe forms of
“don't carry it toward/to …”, in addition to “do not carry …”. Previously the
local-reference pass ran before contraction expansion and missed the embedded
“it” when a destination followed. Twelve full cases compare contracted wording
with explicit-reference wording across runtime states and both destination
forms, with Ruby/MIDI parity. Quantified, multi-participant and unresolved
antecedents still fail instead of guessing an identity. The existing contraction
and conditional-command regression checks also pass.

Negative auxiliary expansion is now shared with the candidate desire/preference
parser through contractions.mjs. Candidate expansion runs after runtime suffix
handling, preserving negative question inversion and both punctuation placements.
Twenty-one candidate cases compare complete formal/MIDI output against expanded
paraphrases and recover speech act/runtime independently. They include outer
negation, past preference, desire, questions and negated preference alternatives.
An explicit pronoun-binding example composes equivalently to named references.
Main-parser contraction, contracted conditional-reference, candidate binding and
question/runtime tests continue to pass. This does not promote draft vocabulary.
