# Adding approved compounds

Compound vocabulary is extensible. Inventory counts, English labels, dictionary discovery, etymology, renderer dependencies, API metadata, and browser artifacts are derived from the approved dictionary. The 324 atomic roots remain unchanged.

1. Author the compound in `lexicon/compound_dictionary.yaml`: use one semantic head, explicit edges, existing atom IDs, a precise definition, boundaries, examples, and approval provenance. Each atom retains its meaning. Runtime state (including num) belongs to an occurrence, never the compound identity.
2. Compute its content digest with `EraZeroValidation.fingerprint(entry.slice("architecture_version", "semantic_head", "nodes", "edges", "lexical_constraints"))`. Set `compound_id` to `CMP:` plus the first 24 digest characters, and use the full digest in both digest fields. Record the matching semantic review in `reviews/gate4b_high_frequency_compounds_scored_candidates.yaml`. This is a deliberate approval step, not automatic canonization from an English word.
3. Run `ruby tools/rebuild_compound_release.rb`. It checks approval, identities, reviews and label collisions; retains existing English senses; derives each new canonical compound sense; refreshes counts, coverage, etymology and dependent fingerprints; and rebuilds browser artifacts. It does not reset the project's completed migration stages.
4. Run `ruby tools/regress_current_state.rb`, `node tools/validate_pages_release.mjs`, `node tools/audit_full_translator.mjs`, and `ruby tools/audit_project_completeness.rb`. Set `ERA_ZERO_NODE` if Node is outside PATH. Review the diff, commit, and publish normally.

New closed compounds receive all 15 speech-act/runtime variants and work in the public browser translator. Open-slot compounds remain available through the existing Ruby API; arbitrary role binding is not yet supported by the static browser. A new compound does not automatically supply every English verb inflection or sentence construction: add reviewed surface mappings when those meanings are supported.

The `love` entry is a worked example. `love [2]` uses its poetic num reading. The rebuild never turns num into an atom or rewrites its state meaning.
