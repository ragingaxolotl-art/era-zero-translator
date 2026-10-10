# Era Zero Complete Regression Run

Status: **FAIL**

Run this complete regression from the project root with:

```text
ruby tools/regress_current_state.rb
```

The command refreshes the current gap inventory, validates every active semantic authority layer, applies the reusable packet contract to the latest completed review packet (`ORI:200–222`), validates Gate 4A typed compounds, the Gate 4B canonical dictionary, and the Gate 4C English sense index, and runs full-family soundness audits for all complete canonical Creation, Data, Logic, Connection, Structure, Warning, Repair, and Origin families.

## FAIL — refresh current gap inventory

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reports/atomic_root_gaps.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/regenerate_current_gap_reports.rb:11:in `<main>'
```

## FAIL — validate current authority and translator boundary

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reports/atomic_root_gaps.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_current_state.rb:215:in `<main>'
```

## FAIL — validate latest semantic packet with reusable contract

```text
Missing packet files:
- reviews/ORI_200_222_scored_candidates.yaml
- reviews/ORI_200_222_recommended_spec.yaml
- reviews/ORI_200_222_stress_tests.yaml
- reviews/ORI_200_222_peer_review.md
- reviews/ORI_200_222_collision_report.md
```

## PASS — validate Gate 4A typed compound architecture

```text
Gate 4A validation: PASS
Checks passed: 21; checks failed: 0
Valid cases: 12; invalid cases: 23; dictionary entries: 0
```

## FAIL — validate Gate 4B high-frequency compound dictionary

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/gate4b_high_frequency_compounds_scored_candidates.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_gate4b_compound_dictionary.rb:13:in `<main>'
```

## PASS — validate Gate 4C English concept and sense index

```text
Gate 4C validation: PASS
Checks passed: 17; checks failed: 0; senses: 436; lemmas: 419
```

## FAIL — validate Gate 4D coverage and ambiguity report

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reports/gate4d_coverage_metrics.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_gate4d_coverage_report.rb:8:in `<main>'
```

## PASS — validate Gate 4E formal etymology table

```text
Gate 4E validation: PASS
Checks passed: 13; checks failed: 0
```

## PASS — validate semantic IR and executable grammar

```text
Semantic IR validation: PASS
Checks passed: 14; checks failed: 0; valid: 16; invalid: 13
```

## PASS — validate deterministic renderer and inverse decoder

```text
Renderer/decoder validation: PASS
Checks passed: 12; checks failed: 0
```

## FAIL — validate controlled English compiler

```text
Controlled English validation: FAIL
Checks passed: 12; checks failed: 1
```

```text
implementation: compiler library, CLI, spec, golden tests, and report exist
```

## FAIL — validate general-English candidate translator

```text
General English validation: FAIL
Checks passed: 15; checks failed: 1
```

```text
implementation: library, CLI, spec, tests, report, and migration exist
```

## FAIL — validate glyph and MIDI presentation

```text
Glyph/audio validation: FAIL
Checks passed: 9; checks failed: 1
```

```text
examples: three SVG/MIDI example pairs exist
```

## FAIL — validate translator workbench product application

```text
Product application audit: FAIL
Checks passed: 14; checks failed: 1
```

```text
documentation and launch: launcher, API guide, user guide, audit checklist, and source files exist
```

## PASS — validate translator workbench frontend syntax

```text
Product frontend syntax: PASS
```

## FAIL — validate translator workbench over real localhost HTTP

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/socket.rb:685:in `bind': Operation not permitted - bind(2) for 127.0.0.1 (Errno::EPERM)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/socket.rb:685:in `block in ip_sockets_port0'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/socket.rb:673:in `each'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/socket.rb:673:in `ip_sockets_port0'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/socket.rb:706:in `tcp_server_sockets_port0'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/socket.rb:757:in `tcp_server_sockets'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/webrick/utils.rb:60:in `create_listeners'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/webrick/server.rb:130:in `listen'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/webrick/server.rb:111:in `initialize'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/webrick/httpserver.rb:47:in `initialize'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/test_product_http.rb:11:in `new'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/test_product_http.rb:11:in `<main>'
```

## FAIL — validate the complete REP:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/REP_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_rep_000_222_soundness.rb:24:in `<main>'
```

## FAIL — validate the complete LOG:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/LOG_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_log_000_222_soundness.rb:24:in `<main>'
```

## FAIL — validate the complete DAT:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/DAT_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_dat_000_222_soundness.rb:24:in `<main>'
```

## FAIL — validate the complete CRE:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/CRE_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_cre_000_222_soundness.rb:24:in `<main>'
```

## FAIL — validate the complete ORI:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/ORI_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_ori_000_222_soundness.rb:19:in `block in <main>'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_ori_000_222_soundness.rb:19:in `to_h'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_ori_000_222_soundness.rb:19:in `<main>'
```

## FAIL — validate the complete CON:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/CON_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_con_000_222_soundness.rb:21:in `block in <main>'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_con_000_222_soundness.rb:19:in `to_h'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_con_000_222_soundness.rb:19:in `<main>'
```

## FAIL — validate the complete STR:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/STR_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_str_000_222_soundness.rb:24:in `<main>'
```

## FAIL — validate the complete WRN:000–222 family

```text
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `initialize': No such file or directory @ rb_sysopen - /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/reviews/WRN_000_022_recommended_spec.yaml (Errno::ENOENT)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `open'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/psych.rb:577:in `load_file'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/lib/era_zero_validation.rb:95:in `load_yaml'
	from /Users/timetravellog/Desktop/DBA Language/github_release/era-zero-translator/tools/validate_wrn_000_222_soundness.rb:24:in `<main>'
```

## Regression coverage

- all active canonical titles and invariant definitions;
- all 30 effective approval migrations and 288 selective promotions;
- all 324 deterministic records and 2,592 generated-form assertions;
- immutable 36-root source-canonical fingerprint and replication;
- live 324/0 authority counts across lexicons and specifications;
- exact provisional complement and current 0-chunk gap inventory;
- withdrawn Gate 3 isolation;
- prohibited dependencies and translator gate boundaries;
- the latest detailed semantic packet's candidates, scores, definitions, boundaries, collisions, examples, and stress tests.
- Gate 4A single-head graph structure, node and edge typing, semantic roles, scope, runtime separation, serialization, versioning, 12 valid cases, 23 invalid diagnostics, and zero dictionary entries.
- Gate 4B content-derived compound identities, graph connectivity, canonical-atom references, semantic records, three-direction scored review, atom-collision discipline, gap honesty, IR deferrals, authority integration, and atomic immutability.
- Gate 4C exact atom and compound label coverage, typed sense routes, explicit polysemy, gap/grammar/IR routing, controlled-input boundaries, index integrity, authority integration, and atomic/compound immutability.
- Gate 4D route partitioning, coverage arithmetic, family and compound coverage, high-frequency benchmarks, explicit gap and ambiguity registers, no-first-match policy, source fingerprinting, and translator boundary.
- Gate 4E complete atomic and compound derivation coverage, exact generated forms and invariant semantics, source/review provenance, compound graph and digest identity, English-label independence, and no-fictional-ancestry policy.
- semantic IR graph typing, lexical occurrence authority, runtime/polarity/modality/time separation, roles, scope, quantity, measurement, transitions, coordination, seriality, parallelism, repetition, recursion, coreference, errors, canonical identity, and later-gate isolation.
- deterministic atom and compound rendering, required compound-slot bindings, generated forms, note paths, runtime endings, role registers, speech-act and secondary contours, structural timing, literal glosses, exact inverse decoding, corruption rejection, and transposition-invariant identity.
- controlled-English grammar restriction, unique canonical sense mapping, explicit roles and scope, open compound-slot enforcement, structured unsupported-input errors, golden translations, all 352 lexical routes, and full compiler-to-renderer-to-decoder round trips.
- general-English deterministic ranking, exact-lemma recall across all 436 indexed senses, evidence and confidence, runtime alternatives, material ambiguity, structural and grammar routing, explicit gaps, role clarification, conservative auto-resolution, and selected-sense round trips.
- validated EZF-1 to accessible SVG and Standard MIDI, deterministic byte output, three-anchor transposition behavior, all 972 atom/runtime presentations, invalid-input rejection, example artifacts, and semantic-identity preservation.
- local translator API and responsive workbench, reviewed-sense evaluation corpus, conservative clarification journeys, API error paths, EZB-1 import/export integrity, SVG/MIDI download, accessibility markers, and canonical semantic immutability.
- full-family locus/process/affordance-relation separation, triplet coherence, runtime-state tailoring, collision routing, and rerun safety for `CON:000–222`.
- constituent-position/interface/composite-arrangement entities; reconfiguration/incorporation/integration processes; matching reconfigurability/incorporability/integrability affordances; triplet coherence; lexical/runtime separation; collision routing; layer non-entailment; and rerun safety for `STR:000–222`.
- intrinsic-fault/external-hazard/distributed-fault entity separation, persistence/manifestation/dormancy coherence, lexical/runtime separation, collision routing, and rerun safety for `WRN:000–022`.
- internal/target/shared restoration-condition entities; inward/target/systemic restorative processes; matching recoverability/applicability/pathway affordances; triplet coherence; lexical/runtime separation; collision routing; layer non-entailment; and rerun safety for `REP:000–222`.
- internal formal criteria, target-directed formal constraints, and shared formal regimes; persistent/operative/dormant coherence; lexical/runtime separation; collision routing; and rerun safety for `LOG:000–022`.
- internal generative patterns, generated artifacts, and shared generative repertoires as entities; internal pattern formation, outward artifact generation, and systemic co-generation as productive processes; internal pattern-forming capacities, source-artifact generative relations, and systemic co-generative capacities as affordances; triplet coherence; lexical/runtime separation; collision routing; layer non-entailment; and rerun safety for `CRE:000–222`.
- source-ground, distinct-existence, and shared-world conditions; persistent/occurrent-or-operative/latent coherence; separation from cause, time, truth, observation, substrate, and modality; lexical/runtime separation; collision routing; and rerun safety for `ORI:000–022`.
- source-ground establishment, distinct actualization, and shared-world transition processes; completed/active/nonactualized coherence; condition/process separation; nonactualization neutrality; collision routing; and rerun safety for `ORI:100–122`.
- source-grounding capacity, target-ground dependence, and shared-world constraint relations; persistent/operative/latent coherence; three-layer separation; latency neutrality; collision routing; and rerun safety for `ORI:200–222`.
