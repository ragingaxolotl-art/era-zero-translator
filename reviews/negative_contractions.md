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
