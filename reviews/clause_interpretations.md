# Interpretation choices belong to individual clauses

Sequence, conjunction and conditional composition now accept one explicit options
object per clause. Viewpoint, spatial-destination reading, adjective standard and
future-statement interpretation are passed to that clause's normal composer.
No choice is copied to another clause. Wrong option counts, unknown option fields,
missing choices and unsupported readings reject the whole composition.

The browser shows the recognized clauses in separate fieldsets with numbered
labels. It displays only each clause's required choices, starts viewpoint,
destination, future-reading and threshold fields empty, and generates no result
until all clauses compose. Result explanations identify their clause. Changed
fields, source input, mode or detached forms invalidate asynchronous results and
errors. The composition API snapshots caller options before awaiting templates.

“If the box is heavy, carry it to Ada” uses the existing bounded local-reference
rule: “it” refers to the single definite nominal bearer in the antecedent. The
new destination preposition does not loosen that rule. The mass threshold belongs
to the condition; the command's spatial reading belongs to the consequent. The
condition's runtime and the command's runtime remain independent, as do command
contour, negation and the carrying event's endpoint. A condition is not asserted
as true merely because its threshold has been selected.

The APIs `composeSentenceSequence`, `composeSentenceConjunction` and
`composeSentenceConditional` take an optional third argument, an array of clause
option objects. Existing callers without choices retain their formal meanings and
performances. `clauseInterpretationPlan` exposes recognized clause text and parsed
requirements for the form. Interpretation choices are metadata; their semantic
effects remain represented in the scoped IR and music.

Fifteen sequence/conjunction/conditional/runtime combinations match Ruby formal
and MIDI output. Tests keep different mass thresholds, viewpoints and runtime
states attached to their own clauses, combine temperature and future readings,
check bounded local “it”, and inspect audible role/property/state frames. Actual
form-handler tests cover missing choices and stale asynchronous results/errors.
The destination-carrying semantic inverse still rejects whole multi-clause input;
these tests are not a claim of independent full multi-clause meaning recovery.

No roots, compounds, noun sound labels or existing musical conventions change.
Mixed ungrouped conjunction/sequence attachment, arbitrary nested clauses,
ambiguous pronouns, unsupported recipient/delivery readings and broader grammar
remain incomplete. All original completion gates remain open.

A live browser check of “If the box is heavy [0], carry it to Ada [2]”
blocked the complete sentence while clause 2 lacked its destination choice.
After selecting a 12-kilogram standard and the spatial reading, the result
displayed separate `MAT:010 [0]` and `MOV:110 [2]` endings and a conditional
command interpretation. This verifies form/render behavior, not listening.

The final error-path audit also checks a shared rejected template: each clause
wraps its failure independently, preserving the original error and avoiding
racing clause labels or indices. The targeted group suites were rerun after
that error-handling correction following the full regression run.
