# MAT capacity and coupling: source reconciliation

Status: editorial correction under the existing applied semantic approval, not a
new atom, compound or custody definition. The custody dependency review exposed
MAT:210's normal example claiming an ownership/resource relation, contrary to its
canonical invariant and explicit exclusions.

## Authority and exact scope

`migrations/MAT_200_222_semantic_approval.yaml` is applied and pins the nine
canonical titles, invariant definitions and generated fields. The reconciliation
script checks each of these before changing anything. Nine retained normal
examples diverged from, or obscured, the narrower approval:

| Roots | Retained wording problem | Corrected distinction |
|---|---|---|
| MAT:200 | Load bearing, form retention and resistance substituted for energy-supplying work capacity | Persistent capacity to supply energy for physical change |
| MAT:201 | “Actively able” could confuse availability with exercise | Available work capacity does not assert current discharge |
| MAT:202 | Material potential and nonexpression broadened latent work capacity | The energy-supplying capacity exists but is unavailable for exercise |
| MAT:210 | Fit, ownership and resources broadened physical coupling | Established transmission relation, without custody or ownership |
| MAT:211 | Touching alone counted as active coupling | Actual transmission of physical influence to a distinct target |
| MAT:212 | Attachment, transfer and viability replaced unresolved coupling | Whether physical influence can be transmitted is unresolved |
| MAT:220 | General inputs/outputs replaced mutual constraint | Stable mutual physical constraint among parts of one system |
| MAT:221 | Resource exchange replaced reciprocal influence | Present reciprocal physical influence; one-way exchange is insufficient |
| MAT:222 | Any feasible arrangement replaced unrealized interdependence | An unrealized possible relation of mutual physical constraint |

`migrations/mat_capacity_example_reconciliation_2026_10_29.yaml` records exact
before/after text and complete authority fingerprints. Four active inventories
and the browser agree. Historical proposals, approval records, titles,
definitions, exclusions, generated fields and all existing compound records are
unchanged. Google documents and archived releases were not edited.

The compatibility validator permits only the exact nine-example reversal,
requires the complete prior fingerprint, then applies the already documented
MOV/MIN reversals. It rejects changed definitions, melodies, runtime glosses,
extra prose and unrelated fingerprints. This is not permission to bypass source
fingerprints for arbitrary editorial changes.

## Consequence for custody and receipt

MAT:210 can be an ingredient in a materially grounded custody convention, but
physical coupling does not entail control over access, custody, entitlement or
transfer. Conversely, a practical custodian may act through an agent or enclosure;
an account that requires continuous physical influence would exclude such cases.
The retained exclusion routing ownership/access to “CON or grammar” is a domain
pointer, not a definition: all 27 current CON invariants concern communication.
Neither that pointer nor a recipient role supplies material receipt.

Before approving a custody compound, specify who controls what access or handling,
which physical or mediated control readings are included, shared custody, and
what changes during transfer. Compare ownership without custody, custody without
ownership, a table supporting an object, a fan influencing it, and an unattended
object arriving beside a person. Require the same distinctions at runtime 0/1/2,
without using state 0 as relinquishment or state 2 as future receipt. No new root
family or automatic custody alias follows from this correction.

## Validation

`tests/mat_capacity_example_migration_test.rb` checks exact reversal, all active
inventories, all nine approved invariants and generated fields, and rejection of
unauthorized meaning/sound/runtime/prose changes. The existing MOV and MIN tests
continue to validate their immutable historical migrations through the chain.

The current consolidated suite passes 81 checks. An additional exploratory run of
`tools/validate_mat_200_222_canonization.rb` reports seven passes and ten failures:
that historical validator requires the intermediate 81-canonical/243-provisional
inventory, no later MIN review, and no translator implementation. Those assertions
are incompatible with the current 324-root draft. Its generated FAIL report was
retained outside the release as an execution record, not published as current
language status. Its nine approved MAT definitions and generated-field checks
passed. The new migration test checks current inventories without claiming that
the historical milestone validator passed or rewriting its original expectations.
