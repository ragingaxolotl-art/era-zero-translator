# Quantified predicates: semantic reference model

Status: executable semantics for an unfinished grammar construction. No English
coverage, musical address, dictionary meaning or canonical sound is added here.

Existing participant quantifiers do not encode the required binding of one entity
variable to both a nominal restriction and a potentially negated predicate.
Quantifying a negation node is not a substitute. The new reference model counts
unique members for which restriction(x) AND predicate(x) holds, with independent
predicate negation and whole-proposition negation. The same member identity must
be used for both evaluations; duplicate identities are rejected.

The reference model takes explicit true/false/unknown values, not runtime codes.
It never maps runtime 0 to grammatical negation or treats runtime 1 as evidence
that a real-world proposition is true. Lexical trits are likewise unrelated.
Unknown class membership and unknown property truth produce a count interval.
An incomplete domain leaves the upper bound unknown; the model returns a truth
value only where every possible completion agrees. It cannot discover real-world
membership or property truth from a noun sound label.

The independent test enumerates all completions of three-member partial domains,
filters each complete set, and compares resulting truth values for exact,
at-least and at-most counts. It covers both negation positions and thresholds
below, within and above domain size: 26,244 comparisons. Additional cases verify
the six-lamp/three-energized and four-lamp/two-energized scope counterexamples,
incomplete domains and duplicate identity rejection. These counts establish the
model's tested behavior only, not translator or language coverage.

Remaining implementation contract:

1. Add an explicit typed binder that identifies the bound participant, nominal
   restriction and predicate scope. Keep existing participant quantifiers intact.
2. Validate that the bound identity reaches the intended predicate role and does
   not escape or bind another occurrence accidentally. Nested binders need fresh
   identities, with capture and free-reference rejection.
3. Define distinct musical binder/restriction/predicate boundaries, preserving
   current root, name, scope and runtime performances. Negation must be audible
   inside or outside the binder as encoded.
4. Extend Ruby and browser rendering plus independent MIDI decoding. Verify the
   recovered binding structure against these model counterexamples.
5. Wire ordinary counted-predicate wording into the parser and expose unresolved
   scope choices. Test compound predicates, other roles, mixed scopes and novel
   combinations before claiming general quantified-language support.
