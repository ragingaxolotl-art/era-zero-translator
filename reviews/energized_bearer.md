# Energized bearers and counted participants

The unresolved phrase “Exactly three lamps are active” has two separable issues.
The existing exact-cardinality grammar already binds a nominal class as a bearer;
“active” lacks a single meaning appropriate to every context. Energized physical
substrate, switched-on configuration, functioning operation and light emission
must not be silently equated. No new root is justified by this example alone.

The explicit phrase “Exactly three lamps are physically energized” now uses
MAT:001, whose canonical meaning is a focal entity's material substrate in a
presently energized physical state. The quantified lamp class fills bearer. It
does not repeat one lamp assertion three times. The noun remains a sound label.
Neither lamp functioning nor visible illumination is inferred. Runtime 0/1/2
remains separate from the root's lexical address and from the cardinality.

Twenty-one new cases check definite and counted bearers, three runtime states,
exact/minimum/maximum cardinality, negation on an unquantified bearer, question
contour and possibility. Independent MIDI decoding checks the root, runtime,
count markers and one noun label; complete formal output and MIDI match Ruby.
The existing counted-nominal checks pass. Quantified negation remains unresolved
because its scope needs a separate treatment. The ambiguous “active” diagnostic
is deliberately still unresolved; this addition does not close that audit case.

Explicit proposition negation is now supported: “It is not the case that exactly
three lamps are physically energized.” Negation encloses the complete predicate
and counted bearer. This means the energized-lamp count is not three, not that
three lamps satisfy a negative property. Fifteen cases recover the full nested
scope tree from strict MIDI, including possible-not versus not-possible, double
negation and all runtime states, and match Ruby formal/MIDI output. Questions or
commands embedded under this proposition wrapper are rejected. Bare quantified
predicate negation remains unresolved; it must not be approximated by this rule.
The wrapper currently excludes embedded calendar/speech-time clauses because
those time anchors attach to the clause and need a separate scope treatment.

## Participant counting versus predicate binding

Inspection found that both validators allowed a quantifier to scope another
scope operator, contrary to the declared quantity contract. Ruby validation and
browser scheduling now reject that shape. Existing participant-count and
whole-proposition-negation music still pass. This prevents treating arbitrary
quantifier/negation nesting as a completed translation of counted negative
properties.

The remaining representation must bind an entity variable across a nominal
restriction (lamp) and a truth-valued predicate (not energized), then apply the
count to the set of satisfying entities. It needs explicit identity binding and
separate musical boundaries for restriction, predicate and quantifier. Existing
participant-count recordings must keep their current meaning and sound; a new
binding construction must not reinterpret them. Negation outside this entire
construction must remain distinguishable from negation inside its predicate.

Acceptance requires finite-domain counterexamples, not just different MIDI:
with six lamps, three energized, “exactly three are not energized” is true while
“not exactly three are energized” is false. With four lamps, two energized,
the first is false and the second true. Runtime 0/1/2 must not stand in for either
negation. Unknown domain membership must remain unknown rather than defaulting
to a closed-world count. Mixed participant roles, nested modal scope and bound
identity recovery from music are additional obligations before admission.
