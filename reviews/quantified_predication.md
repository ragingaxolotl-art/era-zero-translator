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

## Draft binding graph (EZCOUNT-BIND-1)

The next layer is implemented in pages/quantified_binding.mjs as binding-only
validation, without admission to canonical semantic IR or renderers. It introduces
an explicit quantified_predication scope operator with quantifier/value, exactly
one scopes edge to the predicate body, and one restricts edge from a nominal-class
phonemic reference. A quantified_reference is an entity with binder_id pointing
to that operator; it has no lexical or runtime state of its own.

Each bound reference must have at least one use as a predicate-role argument or
compound argument within the binder's body. All structural paths from every
such predicate must pass through its binder. This rejects not only an explicitly
outside use but also a predicate node shared with an outside clause. Nested
binders use separate IDs; outer variables may occur inside an inner body, while
an inner variable cannot escape into an outer predicate. Missing restrictions,
wrong reference types, free/unused bindings, duplicate IDs, malformed counts,
cycles and explicit identity-rewriting edges are rejected.

The tests check ordinary and compound argument positions, nested binding, and
14 invalid/capture/escape cases. This layer intentionally does not validate root
valence, phonemic encoding, general graph semantics or musical rendering; those
remain the responsibilities of the existing authority and pending integration.
It must be composed with those validators before any sentence is admitted.
References inside intensional clause arguments are not yet part of this binder's
traversal and need an explicit scope treatment rather than implicit capture.

Next work: equivalent Ruby binding validation; typed canonical-IR integration;
versioned musical frames and independent inverse; English composition using the
finite-model contrast obligations above. The original counted negative phrase
remains uncomposed at this checkpoint.

Ruby binding validation is now implemented in era_zero_quantified_binding.rb.
A shared graph corpus checks identical acceptance/rejection and result metadata
in both implementations. The corpus includes valid atomic/compound/nested binding
and malformed restriction, count, reference, cycle and escape structures. Each
case is additionally renamed and serialized in reverse node/edge order, proving
that incidental IDs and ordering do not change the binding verdict. All 34
cross-language cases pass. These are structural binding checks, not full semantic
IR or music validation; no unsupported English phrase is marked translated.

## Draft musical frames (EZCOUNT-MUSIC-1)

The new draft profile allocates ±27 for counted exact/at-least/at-most frames,
±28 for nominal restriction boundaries and ±29 for predicate boundaries. A -30
reference delimiter carries five ternary address digits encoding binder depth
0–127, then returns to anchor. Depth zero refers to the nearest enclosing counted
binder, depth one to the next outer binder, etc. These are structural addresses,
not new root trits or runtime values. Counts will use the existing decimal-digit
markers. All notes use the existing quarter-beat grammar timing and half-beat
boundary; existing frames and performances are unchanged.

The 138 frame paths are pairwise distinct, match the Ruby definition and do not
equal any existing grammar frame. Sixty-three transposed token/framing probes
cover each count kind and representative depth boundaries. MIDI-only token
recovery succeeds only with allowDraftQuantified enabled; the default inverse
rejects draft music. Invalid depth/marker/pitch requests reject. Empty restriction
frames in these probes are deliberately nonsemantic test scaffolding; they are
not accepted sentences or evidence of complete binding recovery.

Next integration must generate only well-typed frames from validated binder IR,
encode references by actual enclosing binder depth, and independently reconstruct
restriction/body binding from the MIDI tree. Balanced frames alone are not enough.

## Draft graph scheduling and first semantic inverse

The browser scheduler now accepts counted binder/reference nodes only when the
formal object explicitly opts in with draft_quantified. It first applies binding
validation, then emits count digits, nominal restriction, predicate boundaries
and reference depth from an actual binder stack. The existing count/negation
paths remain unchanged. This does not bypass canonical semantic-IR admission:
normal Ruby rendering and bundle validation still need integration.

The new independent quantified-property inverse recovers exact/at-least/at-most
count, nominal-class phonemes, bound bearer identity, atomic property, runtime,
predicate negation and whole-proposition negation. Its admitted predicate set is
physical energization, impairment/restoration and other-view consciousness/dormancy.
Other valences, nested counts, compounds and malformed structures reject rather
than returning a partial interpretation. The scheduler supports general binding
structure; this first inverse is explicitly limited and does not certify it all.

Twelve graph-to-MIDI cases cover both negation scopes independently across runtime
0/1/2, with twelve different performances. The tests transform known canonical
counted-property fixtures into the draft binder shape; their old formal hashes
are not claimed valid. Independent MIDI recovery is tested without the source
IR, and wrong binder identity/default-without-opt-in are rejected. Canonical
counted-noun and proposition-negation regressions continue to pass. Full typed
formal construction, Ruby rendering, nested inverse and English/UI admission
remain next work, not completed coverage.
