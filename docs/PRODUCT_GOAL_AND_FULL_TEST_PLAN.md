# Era Zero Translator: Product Goal and Full Audit Plan

Status: implemented and audited through v1.11.0
Authority date: 2026-10-10

## Product goal

Build a public, English-first Era Zero language workbench that lets a person write an ordinary phrase, see how every word is handled, inspect or change the proposed semantic match, resolve supported meanings through the canonical pipeline, and hear or export the complete musical form. The same application must also provide a logically organized dictionary and a complete, traceable document library.

The workbench is an interface to the approved language. It does not acquire authority to invent missing roots, silently collapse ambiguity, or disguise an English vocabulary gap as a canonical Era Zero meaning.

## User outcomes

1. A user may enter any English phrase without learning controlled syntax first.
2. Context selects a strong primary reading automatically and visibly.
3. The next analysis box lists every input word in order and shows:
   - the recommended atom, compound, grammar route, Semantic-IR route, or documented gap;
   - every indexed alternative for that word;
   - a selector for accepting a different alternative;
   - an explicit English-function-word classification when no lexical root is asserted;
   - a deterministic EZNAME phonemic label only for genuinely unfamiliar noun referents.
4. Canonically resolvable readings display controlled English, Semantic IR, EZF-1, exact round-trip status, glyphs, MIDI, and the complete audible construction.
5. A separate Dictionary view lets the user browse by family and entry type, search by English, definition, ID, address, root, or carrier, and open a detailed record without leaving the page.
6. A Documents view exposes the authoritative specifications, lexicons, migrations, semantic reviews, reports, tests, provenance records, the original shared conversation reference, and the integrated Google document.

## Non-negotiable semantic boundaries

- The 324 canonical atomic meanings and their generated forms remain unchanged unless a separate migration is explicitly approved.
- The 28 approved compounds remain graph-defined meanings, not loose English paraphrases.
- Runtime state, lexical trits, speech act, time, modality, negation, and English inflection remain distinct.
- Structural or grammar routes are not falsely presented as atomic roots.
- Documented gaps remain gaps.
- EZNAME labels identify a surface label; they make no semantic claim.
- Unknown nouns may use EZNAME; unknown verbs and descriptors must remain unresolved semantic content and block automatic translation.
- Game/story generalizations must be entailment-preserving, visibly marked, and must state which English detail was lost.
- Word-level selections are an analysis aid. A complete multi-root utterance is emitted only when the approved Semantic IR can represent and validate it.

## Implementation plan

### A. Product structure

- Translator view: English input, word-to-meaning matching, ranked whole-utterance readings, explicit resolution, sound, glyph, and exports.
- Dictionary view: family/type navigation, searchable entry list, and a detailed entry inspector.
- Documents view: categorized, searchable project-document manifest with source provenance.

### B. Word matching

- Tokenize every lexical word while preserving order and repeated words.
- Rank exact, inflected, contextual, and indexed alternatives deterministically.
- Recommend the strongest option, without converting gaps or structural routes into roots.
- Preserve user overrides in the visible sentence map.
- Mark syntax-only English words separately instead of generating misleading name labels.
- Generate EZNAME only for unmatched content terms.

### C. Dictionary

- Include all 324 atoms, 28 compounds, indexed structural routes, grammar routes, and explicit gaps.
- Expose family, address, universal slot, canonical transliteration, compact root, carrier, harmonic signature, relative note path, invariant definition, and relevant English senses for atoms.
- Expose graph nodes, edges, definition, boundaries, and glosses for compounds.
- Link each record back to relevant authority and review material where available.

### D. Documentation availability

- Generate a release manifest for every tracked Markdown, YAML, JSON/JSONL, text, SVG, and MIDI evidence file under the authoritative project directories.
- Categorize core documentation, specifications, lexicons, migrations, reviews, reports, tests, examples, and extraction records.
- Include the original shared-conversation fingerprint and integrated Google-document link.
- Audit every manifest entry against a real repository file and public GitHub URL.

## Full test plan

### Canonical integrity

- Validate 324 unique canonical IDs and generated forms.
- Re-run source-canonical immutability checks.
- Re-run every semantic migration and family soundness audit.
- Prove 5,265 hosted variants still round-trip exactly.

### Phrase behavior

Test at least 60 phrases covering:

- Motion: leave, go, approach, arrive, move, return, cross, follow, wait, stop, continue, and transport.
- Contextual polysemy: send data/message, receive data/message, change mind/file/layout, run program/machine/route, return value/home.
- Speech acts: assertion, question, command, definition, and possibility.
- Runtime inference: ordinary positive, explicit `[0]`, `[1]`, `[2]`, and English negation.
- Atoms, compounds, grammar, Semantic IR, gaps, unfamiliar names, repeated words, punctuation, and mixed known/unknown phrases.
- Word map order, recommendation, alternative selection, syntax-only treatment, and phonemic-label stability.

### Dictionary and documents

- Confirm every atom and compound can be found by ID and title.
- Confirm every family filter returns 27 roots.
- Confirm detailed generated fields agree with the canonical lexicon.
- Confirm every document-manifest path exists and every required authority category is represented.
- Confirm provenance links and counts match the fixed source fingerprint.

### Sound and presentation

- Confirm AudioContext creation, explicit resume, running state, visible playback state, and error feedback.
- Confirm phoneme-label and full-phrase label playback.
- Run the dedicated game/story corpus across care, nourishment, rest, health, emotion, movement, discovery, arbitrary nouns, pronouns, unknown predicates, and unknown descriptors.
- Confirm resolved output includes prefix, carrier, family opening, address path, runtime ending, and sentence contour.
- Verify deterministic SVG, MIDI, and EZB-1 generation and corruption rejection.

### Interface and accessibility

- Keyboard navigation for view tabs, dictionary records, candidate meanings, and word selectors.
- Accessible names, live regions, focus behavior, color contrast, responsive desktop/mobile layout, and reduced-motion handling.
- No hidden option cutoff and no stale result after input-mode or view changes.

### Release validation

- Static syntax and deterministic build.
- Browser release audit.
- Product application audit.
- Project completeness/provenance audit.
- Complete historical regression command.
- Real localhost HTTP smoke test.
- Live GitHub Actions deployment.
- Live browser tests with representative phrases and zero site-originated warning/error logs.

## Release acceptance criteria

The goal is complete only when all automated checks pass, the live Dictionary and Documents views are navigable, word-level matching works with overrides, representative live phrases behave as specified, audio starts from a user click, the worktree is clean, and the published release matches the audited commit.
