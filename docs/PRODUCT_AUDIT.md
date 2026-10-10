# Era Zero Product Release Audit

Status is earned only when both commands pass:

```text
ruby tools/validate_product_application.rb
ruby tools/regress_current_state.rb
```

## Required evidence

- Canonical general-English and presentation fingerprints match the product specification.
- The product migration contains no lexical or semantic changes.
- All nine API routes return their documented content types and statuses.
- Invalid JSON, missing fields, oversized bodies, unknown routes, invalid methods, corrupted EZF, and corrupted EZB-1 are rejected safely.
- Every reviewed noncanonical indexed sense is recalled by its exact lemma through the public API.
- `go`, `change`, `food`, `home`, `build`, `and`, and the directed data-link template preserve their ambiguity, gap, structural, grammar, and role requirements.
- Successful explicit resolutions decode exactly to their source Semantic IR.
- SVG and MIDI endpoints accept only validated EZF-1.
- EZB-1 imports verify content digest and presentation manifests.
- The browser surface contains labeled controls, keyboard candidate selection, live regions, responsive breakpoints, and reduced-motion behavior.
- JavaScript and Ruby syntax checks pass.
- A real localhost HTTP smoke test reaches the health endpoint and static workbench.
- The complete historical language regression passes after product files are installed.

## Manual interaction checklist

1. Analyze `leave [1]`; confirm automatic resolution and exact round-trip indicator.
2. Analyze `go [1]`; confirm spatial and abstract-transition readings are both visible and no automatic choice occurs.
3. Analyze `change represented information content [1]`; confirm Data ranks first while clarification remains required.
4. Analyze `food [1]`; confirm the vocabulary gap is visible and resolution is disabled.
5. Analyze `directed data link [1]`; confirm source and target fields appear.
6. Resolve a direct sense; inspect Meaning, Glyph, Semantic IR, and EZF-1 views.
7. Download SVG and MIDI.
8. Export EZB-1, re-import it, and confirm successful verification.
9. Corrupt the bundle and confirm rejection.
10. Test keyboard navigation and a narrow viewport.

## Recorded browser QA — 2026-10-10

- `go [1]` exposed both the abstract-transition and spatial-movement readings and required an explicit selection.
- Selecting `MOV:121` produced canonical Semantic IR, EZF-1, an exact round trip, SVG notation, and enabled SVG/MIDI export.
- Controlled mode compiled `QUESTION "active destination" [1].` to question IR targeting `MOV:011`.
- A stale-view defect discovered during QA was fixed: switching modes now isolates drafts, clears old results, changes the examples, and opens controlled results directly on Semantic IR.
- Keyboard-selectable candidate behavior was exercised; static responsive and reduced-motion contracts are enforced by the audit.
- Frontend syntax, 15 product checks, and real localhost HTTP smoke tests pass before canonical promotion.

## Release decision

Failures block release. Audit checks may be updated only when the underlying contract intentionally changes and the change is recorded in a new versioned migration. They may not be weakened merely to make a failing build pass.
