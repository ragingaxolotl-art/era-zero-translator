# Gate 4D Coverage and Ambiguity Report

Status: **COMPLETE — CANONICAL MEASUREMENT RELEASE**  
Version: **1.0.0**

## What the numbers mean

This report measures the approved Gate 4C index, not unrestricted English. Its benchmark contains every exact canonical atom and compound label plus 84 separately reviewed high-frequency senses. A routed sense counts as analyzed even when its implementation belongs to grammar, semantic IR, or a future vocabulary addition. A gap is never counted as expressible.

## Coverage

- Indexed senses: **445** across **428** normalized lemmas.
- Direct atom mappings: **358**.
- Direct compound mappings: **44**.
- Grammar-dependent senses: **8**.
- Semantic-IR-dependent senses: **24**.
- Explicit unsupported gaps: **11**.
- Direct lexical coverage of the full index: **90.34%**.
- Structurally routed coverage, including future grammar/IR: **97.53%**.
- Exact controlled-label coverage: **100% of 324 atoms and 100% of 37 compounds**.

The reviewed high-frequency layer has **48.81%** direct lexical coverage and **86.9%** eventual coverage after the planned grammar and semantic IR exist. Its remaining **13.1%** are honest vocabulary gaps.

## Ambiguity

- Lemmas requiring disambiguation or nonlexical routing: **41/428 (9.58%)**.
- Lemmas with more than one direct canonical target: **5**.
- Critical polysemy includes *send*, *receive*, *share*, *change*, *exist*, and similar domain-sensitive verbs.

A future translator must never select the first sense by file order. It must use a supplied controlled sense, contextual constraints, ranked candidates, or clarification. An unsupported reading must return a structured gap, not a nearby meaning.

## Known limitations

The current release does not claim unrestricted vocabulary, morphology, idioms, metaphor, tense/aspect execution, reference resolution, or discourse interpretation. The exact-label benchmark is deliberately easier than natural English; the high-frequency layer is the more realistic early signal. Gate 4E etymology remains separate, and translator implementation is still blocked on semantic IR, grammar, rendering, decoding, and conformance tests.
