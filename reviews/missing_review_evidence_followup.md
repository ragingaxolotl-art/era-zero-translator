# Missing review evidence: current checks and historical limits

The November 4 follow-up searched every one of the 47 missing root-review paths
with `git log --all` in the available non-shallow repository. None appeared in
that history. This is a bounded search of local refs, not proof that the files
never existed elsewhere.

The current reusable packet validator can check 31 of those citations from the
surviving candidate, recommendation, stress-case, review and migration files.
Fresh reports are saved under `reports/packet_revalidation_2026_11_04/`; no missing
historical `reviews/` path is filled in. The remaining 16 citations refer to
scope-specific soundness audits and need separate evidence.

Older MAT, MIN:0xx and MOV:2xx scored packets explicitly select a candidate using
`recommended_winner`; newer packets use `recommended_candidate_id`. The reusable
validator now accepts either explicit field and rejects conflicting values. It
does not infer approval or a selection from the scores.

## MIN candidate duplication remains unresolved

Every root in the MIN:100–122 and MIN:200–222 scored packets repeats the selected
meaning as both `current_phase2` and the recommended alternative, with different
scores and commentary that describes an older, broader provisional meaning.
This fails the existing distinct-candidate check. The duplicate is present in
the earliest available Git version of those files (`a8737f3`).

The builders read the `current_phase2` title and definition directly from
`lexicon/atoms.yaml`, while supplying historical critique from their own text.
Running those builders after canonicalization can therefore manufacture this
inconsistency. This mechanism is evidence of a regeneration hazard, not proof
of the historical sequence that produced the committed files.

Do not fix this by renaming a duplicate, inventing an old definition, rerunning
the builder against today's lexicon, or weakening the breadth check. Recover an
attributable pre-approval snapshot and compare it with the candidate IDs,
definitions, critique and scores. Until then, retain the failed current checks.
The current canonical roots and musical identities are unchanged; the failed
review-evidence check does not by itself establish a different correct meaning.

These checks establish file and internal consistency only. Candidate counts,
score arithmetic and stored stress cases do not independently prove linguistic
soundness, historical user approval, or completion of ordinary translation.

## Current result

The fresh run completed all 31 packet checks: 24 pass and seven report failures,
without schema exceptions. Five fail candidate breadth (MAT:1xx, MAT:2xx and
MIN:0xx/1xx/2xx). MAT:0xx and MOV:2xx fail generated-field/example checks, with
MOV:2xx also failing collision coverage. Legacy field shapes may account for
some of these remaining failures; inspect the specific fields before treating
them as semantic discrepancies. All 47 historical citations remain missing.

### Generated-field follow-up

MAT:0xx and MOV:2xx include correct `family`, `address` and `family_onset`
metadata in their fixed fields. The validator now verifies these optional fields
against the root rather than rejecting their presence. Required fields remain
mandatory, and incorrect or unknown extra fields fail. Their remaining failures
are example count (five versus the validator's six) and, for MOV:2xx, only eight
of eleven cross-family comparisons. These are recorded review-coverage gaps,
not demonstrated changes in their generated sounds.
