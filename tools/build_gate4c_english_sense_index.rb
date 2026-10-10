#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "fileutils"
require "set"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atoms = atoms_doc.fetch("atoms")
compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
compounds = compounds_doc.fetch("entries")

def normalize(text)
  text.downcase.strip.gsub(/[[:space:]]+/, " ").gsub(/[“”‘’]/, "'")
end

def sense_id(payload)
  "ENS:#{Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))[0, 24]}"
end

def make_sense(lemma:, pos:, key:, route:, target: nil, definition:, cues:, excludes:, confidence:, controlled: false, provenance:)
  payload = { "lemma" => normalize(lemma), "part_of_speech" => pos, "sense_key" => key, "route" => route, "target_id" => target, "definition" => definition }
  {
    "sense_id" => sense_id(payload), "lemma" => normalize(lemma), "display_form" => lemma,
    "part_of_speech" => pos, "sense_key" => key, "route" => route, "target_id" => target,
    "definition" => definition, "selection_cues" => Array(cues), "excluded_readings" => Array(excludes),
    "confidence" => confidence, "controlled_input_allowed" => controlled, "provenance" => provenance
  }.compact
end

senses = atoms.map do |atom|
  first = atom.fetch("address")[0]
  pos = first == "1" ? "verb_phrase" : "noun_phrase"
  make_sense(
    lemma: atom.fetch("title"), pos: pos, key: "canonical_atom_label", route: "atom", target: atom.fetch("canonical_id"),
    definition: atom.fetch("core_definition"), cues: ["exact canonical label", "family domain #{atom.fetch('family')}", "universal slot #{atom.fetch('universal_slot')}"],
    excludes: ["broader everyday readings not entailed by the invariant definition"], confidence: "authoritative", controlled: true,
    provenance: "lexicon/atoms.yaml"
  )
end

senses.concat(compounds.map do |entry|
  make_sense(
    lemma: entry.fetch("display_title"), pos: "noun_phrase", key: "canonical_compound_label", route: "compound", target: entry.fetch("compound_id"),
    definition: entry.fetch("invariant_definition"), cues: ["exact approved compound label", "all component restrictions are intended"],
    excludes: [entry.dig("boundaries", "excludes")], confidence: entry.fetch("confidence"), controlled: true,
    provenance: "lexicon/compound_dictionary.yaml"
  )
end)

manual = []
add = lambda do |lemma, pos, key, route, target, definition, cues, excludes, confidence = "high", controlled = false|
  manual << make_sense(lemma: lemma, pos: pos, key: key, route: route, target: target, definition: definition, cues: cues, excludes: excludes, confidence: confidence, controlled: controlled, provenance: "Gate 4C reviewed routing")
end

# High-frequency direct readings.
[
  ["self", "noun", "continuous_identity", "atom", "LIF:000", "The speaker's identity understood as continuous across time.", "identity continuity is foregrounded", "a grammatical first-person pronoun alone"],
  ["person", "noun", "identified_other", "atom", "LIF:010", "A particular being identified as distinct from the speaker.", "one non-speaker individual is identified", "the speaker, an indefinite human class, or a legal person"],
  ["community", "noun", "living_collective", "atom", "LIF:021", "A population of living beings currently interacting as a collective.", "living interaction is asserted", "a communication channel or mere geographic area"],
  ["destination", "noun", "movement_endpoint", "atom", "MOV:010", "A stable location identified as the endpoint of movement.", "endpoint is defined", "approaching or arriving"],
  ["route", "noun", "ordered_positions", "atom", "MOV:020", "A stable sequence of positions connecting locations.", "path structure is intended", "movement through it"],
  ["leave", "verb", "active_departure", "atom", "MOV:101", "To be undergoing displacement away from a source position.", "departure is in progress", "completed departure or abandonment as a social act"],
  ["depart", "verb", "completed_departure", "atom", "MOV:100", "To have completed displacement away from a source position.", "completion is asserted", "preparing to leave"],
  ["approach", "verb", "active_target_approach", "atom", "MOV:111", "To be undergoing displacement toward a target position.", "motion toward target is active", "socially addressing a person"],
  ["arrive", "verb", "completed_target_arrival", "atom", "MOV:110", "To complete displacement to a target position.", "endpoint has been reached", "mere nearness"],
  ["body", "noun", "living_material_substrate", "compound", nil, "A material substrate constituting an identified living being.", "living bearer is intended", "a generic material body or celestial body"],
  ["tool", "noun", "physical_work_artifact", "compound", nil, "A generated artifact with enduring capacity to produce physical change.", "physical implement is intended", "software utility or grammatical instrument"],
  ["machine", "noun", "engineered_mechanism", "compound", nil, "A generated composite artifact with enduring physical work capacity.", "organized physical work device", "abstract state machine"],
  ["program", "noun", "stored_executable_specification", "compound", nil, "A stored formal generative specification prior to execution.", "instructions or software definition", "a schedule or running process"],
  ["message", "noun", "channel_scoped_datum", "compound", nil, "A bounded datum maintained as content within a communicative channel.", "information object is intended", "the act of sending"],
  ["injury", "noun", "physical_internal_fault", "compound", nil, "A persistent internal fault in a material substrate.", "physical adverse condition", "an insult, legal injury, or hazard"],
  ["backup", "noun", "restoration_dataset", "compound", nil, "A dormant shared dataset maintained for systemic restoration.", "recovery copy is intended", "a substitute person or traffic congestion"],
  ["danger", "noun", "external_hazard", "atom", "WRN:010", "A distinct external condition capable of adversely affecting a target.", "external harmful potential", "an already manifested internal fault"],
  ["repair", "verb", "completed_target_restoration", "atom", "REP:110", "To have completed restoration of a distinct target.", "restoration has completed", "maintenance or attempted repair"],
  ["create", "verb", "active_artifact_generation", "atom", "CRE:111", "To be actively generating a distinct artifact.", "an outward product is being generated", "internal planning or systemic co-generation"],
  ["rule", "noun", "target_formal_constraint", "atom", "LOG:010", "A persistent formal constraint assigned to a distinct target.", "one target is governed", "a shared regime or empirical regularity"],
  ["data", "noun", "bounded_information_object", "atom", "DAT:000", "A persistent bounded information object maintained within one bearer.", "one internal datum is intended", "a shared dataset or transfer"],
  ["attention", "noun", "target_attention_relation", "atom", "MIN:210", "An established relation directing a cognizer's processing toward a target.", "selective cognitive priority toward a target", "awareness in general"],
  ["origin", "noun", "source_ground", "atom", "ORI:000", "A persistent source-ground condition for one reference entity.", "ontological ground is intended", "a movement starting position"],
  ["law", "noun", "formal_world_constraint", "compound", nil, "A shared-world constraint organized as a shared formal regime.", "formal constraint on co-instantiation", "statute, policy, or observed regularity"],
].each { |row| add.call(*row) }

# Resolve the compound target IDs by display title after authoring readable rows.
compound_by_title = compounds.to_h { |entry| [entry.fetch("display_title"), entry.fetch("compound_id")] }
manual.each do |sense|
  next unless sense["route"] == "compound" && sense["target_id"].nil?
  title = { "body" => "living body", "tool" => "physical tool", "program" => "program definition", "message" => "message datum", "injury" => "physical injury", "backup" => "backup dataset", "law" => "shared-world law" }.fetch(sense["lemma"], sense["lemma"])
  sense["target_id"] = compound_by_title.fetch(title)
end

# Polysemy and scope-sensitive readings.
[
  ["go", "verb", "spatial_movement", "atom", "MOV:121", "Undergo active change of position in a shared frame.", "literal spatial displacement", "permission, functioning, future auxiliary, or abstract transition"],
  ["go", "verb", "abstract_transition", "semantic_ir", nil, "Enter another nonspatial state through a context-specific transition.", "go dark, go silent, go wrong", "literal spatial movement"],
  ["move", "verb", "spatial_displacement", "atom", "MOV:121", "Undergo active shared-frame positional change.", "physical or model-relative position", "emotional effect or proposal"],
  ["move", "verb", "cause_target_displacement", "semantic_ir", nil, "Cause a distinct target to undergo movement.", "transitive moved the box", "intransitive self movement"],
  ["move", "verb", "emotional_effect", "gap", nil, "Cause an affective response.", "moved by the story", "spatial displacement"],
  ["run", "verb", "locomotion", "semantic_ir", nil, "Move by a gait convention not atomically distinguished in Motion.", "human or animal gait", "program execution or machine operation"],
  ["run", "verb", "program_execution", "semantic_ir", nil, "Instantiate an occurrence that executes a program definition.", "software context", "stored program object"],
  ["run", "verb", "machine_operation", "semantic_ir", nil, "Maintain a machine in active operation.", "device context", "locomotion"],
  ["stop", "verb", "cessation", "semantic_ir", nil, "Terminate an active occurrence or movement.", "an activity ceases", "arrive at a place"],
  ["pause", "verb", "temporary_suspension", "semantic_ir", nil, "Suspend an occurrence while preserving the possibility of continuation.", "temporary interruption", "completed cessation"],
  ["wait", "verb", "deferred_action", "semantic_ir", nil, "Remain without actualizing a pending process until a condition holds.", "delay pending condition", "dormant route or latent capacity"],
  ["continue", "verb", "persistence_of_occurrence", "semantic_ir", nil, "Maintain an occurrence across a later interval.", "same event persists", "repeat a completed event"],
  ["return", "verb", "movement_to_prior_position", "semantic_ir", nil, "Move to a position previously occupied or treated as origin.", "prior-position reference", "give an object back or function result"],
  ["return", "verb", "function_result", "semantic_ir", nil, "Produce a value as the result of a computational occurrence.", "programming context", "spatial movement"],
  ["follow", "verb", "trajectory_tracking", "semantic_ir", nil, "Move while maintaining a relation to another mover or route.", "spatial tracking", "understand, obey, or occur afterward"],
  ["cross", "verb", "boundary_traversal", "semantic_ir", nil, "Move from one side of a boundary locus to another.", "route plus boundary", "become angry or hybridize"],
  ["transport", "verb", "caused_target_movement", "semantic_ir", nil, "Cause a distinct target to move through a route toward a destination.", "carrier and cargo roles", "data transfer alone"],
  ["send", "verb", "communicative_expression", "atom", "CON:101", "Actively make a communicative expression available from a source endpoint.", "communication is foregrounded", "physical transport or completed data receipt"],
  ["send", "verb", "data_transfer", "atom", "DAT:111", "Actively transfer information toward a distinct target.", "information delivery is foregrounded", "mere expression without transfer"],
  ["receive", "verb", "communicative_reception", "atom", "CON:111", "Actively take up a communicative expression at a target endpoint.", "participant uptake", "physical acquisition or data transfer as system event"],
  ["receive", "verb", "data_transfer_completion", "atom", "DAT:110", "Complete a bounded information transfer to a distinct target.", "system-level information arrival", "understanding a message"],
  ["share", "verb", "shared_distribution", "atom", "CON:121", "Actively make a communicative expression available across a shared channel.", "broadcast or distribution", "ownership division or data synchronization"],
  ["share", "verb", "data_synchronization", "atom", "DAT:121", "Actively align information state across multiple participants.", "replicated data alignment", "mere broadcast"],
  ["change", "verb", "material_change", "atom", "MAT:101", "Undergo an active inward physical-state change.", "material bearer and physical state", "mental, structural, data, or ontological change"],
  ["change", "verb", "mental_revision", "atom", "MIN:101", "Actively revise the cognizer's self-model.", "self-understanding changes", "physical change"],
  ["change", "verb", "structural_reconfiguration", "atom", "STR:101", "Actively reconfigure one structure internally.", "part-position arrangement changes", "material phase or information content"],
  ["change", "verb", "data_transformation", "atom", "DAT:101", "Actively transform represented information within one bearer.", "information content changes", "transfer to another target"],
  ["change", "verb", "generic_state_transition", "semantic_ir", nil, "Transition between context-selected states without enough domain information to choose an atom.", "domain is unspecified", "a specified MAT, MIN, STR, DAT, CRE, WRN, REP, or ORI process"],
  ["make", "verb", "generate_artifact", "atom", "CRE:111", "Actively generate a distinct artifact.", "product creation", "cause a state, force someone, or earn money"],
  ["build", "verb", "generate_composite_artifact", "semantic_ir", nil, "Generate an artifact while establishing its composite arrangement.", "construction and assembly", "generic creation without structure"],
  ["break", "verb", "target_impairment", "atom", "WRN:111", "Actively cause a distinct target to enter a less acceptable condition.", "harm to target is foregrounded", "separate physically without impairment or pause"],
  ["fix", "verb", "target_restoration", "atom", "REP:111", "Actively cause a distinct target to enter its restoration condition.", "repair is ongoing", "attach, decide, or set a value"],
  ["know", "verb", "stable_target_representation", "atom", "MIN:010", "Maintain a persistent mental representation of a distinct target.", "stored target model is intended", "truth-entailing epistemic knowledge"],
  ["know", "verb", "truth_entailing_knowledge", "gap", nil, "Possess justified or truth-entailing knowledge.", "truth or justification is essential", "mere persistent representation"],
  ["remember", "verb", "manifest_latent_representation", "semantic_ir", nil, "Bring a previously latent representation into manifest cognition.", "retrieval transition", "a representation that merely persists"],
  ["forget", "verb", "lose_access_to_representation", "semantic_ir", nil, "Cease manifest access to or preservation of a representation.", "memory loss or retrieval failure", "ordinary dormancy alone"],
  ["think", "verb", "generic_cognition", "gap", nil, "Engage in cognition not limited to model revision or attention.", "generic thought", "specific revision or attention relation"],
  ["exist", "verb", "distinct_actualization", "atom", "ORI:110", "Complete the actualization of a distinct entity as existent.", "coming into distinct existence", "continued existence or grammatical copula"],
  ["exist", "verb", "continued_existence", "atom", "ORI:010", "Remain a persistent distinct-existence condition.", "ongoing ontological status", "becoming actual"],
  ["be", "verb", "copular_predication", "grammar", nil, "Link a referent to a predicate or identity assertion.", "English copula", "ontological existence"],
  ["become", "verb", "generic_transition", "semantic_ir", nil, "Enter a context-selected state.", "result state is supplied", "distinct ontological actualization specifically"],
  ["have", "verb", "possession", "gap", nil, "Stand in a possession or control relation.", "ownership or possession", "capacity, part-whole, or existence auxiliary"],
  ["have", "verb", "perfect_auxiliary", "grammar", nil, "Mark perfect aspect in English input.", "followed by participle", "possession"],
  ["home", "noun", "physical_dwelling", "gap", nil, "A structure conventionally serving as a habitual dwelling.", "building or residence", "homeland, family attachment, or destination"],
  ["home", "noun", "affective_social_center", "gap", nil, "A socially or affectively anchored place of belonging.", "belonging or attachment", "mere structure"],
  ["water", "noun", "chemical_substance", "gap", nil, "The substance H2O under ordinary reference conditions.", "chemical or everyday substance", "generic matter"],
  ["food", "noun", "nutritive_material", "gap", nil, "Material conventionally suitable for consumption to support life.", "nutrition and consumption", "matter that merely supports a biosystem indirectly"],
  ["friend", "noun", "social_friendship", "gap", nil, "A person standing in a socially recognized friendship relation.", "friendship convention", "any established life-bond"],
  ["safe", "adjective", "acceptable_risk", "gap", nil, "Below a contextually acceptable risk threshold.", "risk assessment", "absence of a manifest fault"],
  ["true", "adjective", "truth_value", "gap", nil, "Satisfying a truth condition.", "proposition evaluation", "formal admissibility"],
  ["cause", "noun", "semantic_role", "grammar", nil, "Mark or introduce the cause role of an occurrence.", "role binding", "an Origin ground or Creation source"],
  ["not", "adverb", "negation", "grammar", nil, "Negate a scoped proposition, predicate, or participant relation.", "logical negation", "dormancy or nonactualization"],
  ["and", "conjunction", "coordination_all", "grammar", nil, "Coordinate all listed expressions conjunctively.", "all conjuncts intended", "compound internal coordination without utterance scope"],
  ["or", "conjunction", "coordination_any", "grammar", nil, "Coordinate alternatives disjunctively.", "one or more alternatives", "uncertainty about word sense"],
  ["if", "conjunction", "conditional", "semantic_ir", nil, "Make one proposition conditional on another.", "if–then structure", "lexical condition role inside a compound"],
  ["before", "preposition", "temporal_order", "semantic_ir", nil, "Order one occurrence earlier than another.", "time or sequence", "spatial front relation"],
  ["after", "preposition", "temporal_order", "semantic_ir", nil, "Order one occurrence later than another.", "time or sequence", "spatial following"],
  ["one", "number", "quantity_one", "grammar", nil, "Specify cardinal quantity one.", "count or cardinality", "runtime state [1]"],
  ["many", "quantifier", "plural_quantity", "grammar", nil, "Specify contextually large cardinality.", "quantity scope", "systemic/shared second trit"],
  ["past", "adjective", "reference_time_before_now", "semantic_ir", nil, "Locate an occurrence before the reference present.", "tense or time", "completed lexical third trit"],
  ["future", "adjective", "reference_time_after_now", "semantic_ir", nil, "Locate an occurrence after the reference present.", "tense or time", "pending or latent lexical third trit"],
].each { |row| add.call(*row) }

# Canonical labels already carry their exact sense. Do not create a second
# English sense record merely to restate the same lemma-to-target mapping.
exact_direct = senses.map { |s| [s["lemma"], s["route"], s["target_id"]] }.to_set
manual.reject! { |s| exact_direct.include?([s["lemma"], s["route"], s["target_id"]]) }

senses.concat(manual)
senses.sort_by! { |s| [s["lemma"], s["sense_key"], s["sense_id"]] }

index = senses.group_by { |s| s.fetch("lemma") }.sort.to_h do |lemma, records|
  direct = records.select { |r| %w[atom compound].include?(r["route"]) }
  [lemma, {
    "sense_ids" => records.map { |r| r.fetch("sense_id") },
    "requires_disambiguation" => records.length > 1 || records.any? { |r| !%w[atom compound].include?(r["route"]) },
    "direct_target_count" => direct.length,
    "routes" => records.map { |r| r.fetch("route") }.uniq.sort
  }]
end

schema = {
  "metadata" => { "title" => "Era Zero English sense-index schema", "version" => VERSION, "status" => "canonical_gate4c" },
  "normalization" => { "case" => "Unicode lowercase", "whitespace" => "trim and collapse", "punctuation" => "curly apostrophes normalize to ASCII; other punctuation remains tokenization input" },
  "routes" => {
    "atom" => "one canonical atomic root", "compound" => "one approved Gate 4B compound",
    "grammar" => "later executable grammar, not a lexical root", "semantic_ir" => "later occurrence/proposition IR",
    "gap" => "meaning currently unsupported; must not be guessed"
  },
  "required_sense_fields" => %w[sense_id lemma display_form part_of_speech sense_key route definition selection_cues excluded_readings confidence controlled_input_allowed provenance],
  "target_rule" => "target_id is required exactly for atom and compound routes and forbidden for grammar, semantic_ir, and gap routes",
  "lookup_rule" => "A surface lemma never selects a target without a sense decision. Multiple senses require contextual disambiguation or clarification.",
  "controlled_input_rule" => "Only exact canonical labels marked controlled_input_allowed may resolve without contextual ranking in the future controlled-English compiler.",
  "no_silent_guess" => "An unsupported or unresolved reading returns its recorded route; it never falls back to a semantically nearby atom."
}

document = {
  "metadata" => {
    "title" => "Era Zero Gate 4C English Concept and Sense Index", "version" => VERSION, "status" => "canonical_core_release",
    "sense_count" => senses.length, "lemma_count" => index.length,
    "canonical_atom_senses" => atoms.length, "canonical_compound_senses" => compounds.length,
    "reviewed_high_frequency_senses" => manual.length,
    "scope" => "Exact canonical labels plus a reviewed high-frequency polysemy and routing layer; not an exhaustive English dictionary.",
    "atomic_lexicon_fingerprint" => EraZeroValidation.fingerprint(atoms_doc.fetch("atoms")),
    "compound_dictionary_fingerprint" => EraZeroValidation.fingerprint(compounds_doc.fetch("entries")),
    "semantic_ir_started" => false, "translator_started" => false
  },
  "senses" => senses,
  "lemma_index" => index
}

tests = {
  "metadata" => { "version" => VERSION, "sense_count" => senses.length, "lemma_count" => index.length },
  "exact_atom_labels" => atoms.map { |a| { "input" => a["title"], "expected_route" => "atom", "expected_target" => a["canonical_id"] } },
  "exact_compound_labels" => compounds.map { |c| { "input" => c["display_title"], "expected_route" => "compound", "expected_target" => c["compound_id"] } },
  "polysemy_tests" => %w[go move run return send receive share change know exist have home].map { |lemma| { "input" => lemma, "expected" => "requires_disambiguation", "minimum_senses" => 2 } },
  "gap_tests" => %w[water food friend safe true].map { |lemma| { "input" => lemma, "expected_route" => "gap" } },
  "grammar_tests" => %w[not and or one many cause].map { |lemma| { "input" => lemma, "expected_route" => "grammar" } },
  "ir_tests" => ["wait", "pause", "stop", "continue", "transport", "before", "after", "past", "future"].map { |lemma| { "input" => lemma, "expected_route" => "semantic_ir" } }
}

report = <<~MD
  # Gate 4C English Concept and Sense Index

  Status: **CANONICAL CORE RELEASE**  
  Version: **#{VERSION}**

  ## Inventory

  - Canonical atom-label senses: **#{atoms.length}**
  - Canonical compound-label senses: **#{compounds.length}**
  - Reviewed high-frequency senses: **#{manual.length}**
  - Total sense records: **#{senses.length}**
  - Normalized English lemmas: **#{index.length}**

  ## Design result

  The index separates an English surface form from its intended sense. A sense may route to one atom, one approved compound, grammar, semantic IR, or an explicit vocabulary gap. Exact canonical labels form the deterministic controlled vocabulary. Common polysemous words such as *go*, *move*, *run*, *return*, *send*, *share*, *change*, *know*, *exist*, *have*, and *home* require sense selection rather than first-match lookup.

  No unsupported reading is silently mapped to a nearby root. Water, food, friendship, safety thresholds, truth values, generic thought, possession, and dwelling senses remain explicit gaps where the current atomic inventory lacks the necessary invariant distinction.

  ## Critical separation examples

  - *send* separates communicative expression (`CON:101`) from active target data transfer (`DAT:111`).
  - *receive* separates participant uptake (`CON:111`) from completed data transfer (`DAT:110`).
  - *change* separates material, mental, structural, and data transformations; domain-unspecified change routes to semantic IR.
  - *exist* separates persistent distinct-existence (`ORI:010`) from completed distinct actualization (`ORI:110`).
  - *run* separates locomotion, program execution, and machine operation; all require later IR because the existing atoms do not lexicalize those full occurrences.
  - tense words do not masquerade as lexical third-trit values; *past* and *future* route to semantic IR.

  ## Boundary

  This release is a sense inventory and routing contract, not an English parser. Gate 4D must measure expressibility and ambiguity. Etymology, semantic IR, executable grammar, renderer, decoder, and translator remain unstarted.
MD

ambiguity = <<~MD
  # Gate 4C Ambiguity and Gap Audit

  Status: **PASS — POLYSEMY IS EXPLICIT; UNSUPPORTED READINGS ARE NOT FORCED**

  The index contains #{senses.length} senses across #{index.length} normalized lemmas. #{index.count { |_k, v| v["requires_disambiguation"] }} lemmas require disambiguation because they are polysemous or route outside direct lexical lookup.

  ## Hard gaps retained

  - chemical substance identity (*water*);
  - nutrition and consumption suitability (*food*);
  - socially conventional friendship;
  - contextual safety thresholds;
  - truth values and truth conditions;
  - generic cognition beyond model revision and attention;
  - ownership/possession;
  - physical and affective senses of *home*.

  ## Reserved for grammar or semantic IR

  Negation, coordination, cardinality, conditionals, temporal order, reference time, cessation, pausing, waiting, continuation, repetition, caused transport, program execution, and message-sending events require scope and role structure. They are indexed now but are not prematurely lexicalized.

  ## Collision policy

  Exact canonical labels may be controlled inputs. All other words require a sense ID or later contextual ranking. Equal spellings never justify choosing the first record. Gap records must return an unsupported-meaning result, not a nearest-neighbor guess.
MD

migration = {
  "migration_id" => "gate4c_english_sense_index_1.0", "date" => DATE, "status" => "applied",
  "from" => { "gate4c_status" => "not_started", "sense_records" => 0 },
  "to" => { "gate4c_status" => "complete", "sense_records" => senses.length, "lemmas" => index.length, "version" => VERSION },
  "atomic_lexicon_fingerprint" => document.dig("metadata", "atomic_lexicon_fingerprint"),
  "compound_dictionary_fingerprint" => document.dig("metadata", "compound_dictionary_fingerprint"),
  "atomic_changes" => [], "compound_changes" => [], "next_gate" => "gate4d_coverage_and_ambiguity_report"
}

FileUtils.mkdir_p(File.join(EraZeroValidation::ROOT, "lexicon"))
File.write(File.join(EraZeroValidation::ROOT, "spec/english_sense_index_schema.yaml"), YAML.dump(schema))
File.write(File.join(EraZeroValidation::ROOT, "lexicon/english_sense_index.yaml"), YAML.dump(document))
File.write(File.join(EraZeroValidation::ROOT, "tests/gate4c_sense_index_cases.yaml"), YAML.dump(tests))
File.write(File.join(EraZeroValidation::ROOT, "reports/gate4c_english_sense_index.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "reports/gate4c_ambiguity_and_gap_audit.md"), ambiguity)
File.write(File.join(EraZeroValidation::ROOT, "migrations/gate4c_english_sense_index_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "gate4c_english_concept_and_sense_index"
version["next_gate_authorized"] = "gate4d_coverage_and_ambiguity_report"
version["gate4c_status"] = "canonical"
version["english_sense_index_version"] = VERSION
version["english_sense_records"] = senses.length
version["english_lemmas"] = index.length
version["english_sense_index"] = "lexicon/english_sense_index.yaml"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = "gate4d_coverage_and_ambiguity_report"
gate2 = readiness.fetch("required_gates").find { |g| g["gate"] == "compound_and_coverage" }
g4c = gate2.fetch("subgates").find { |g| g["gate"] == "gate4c_english_concept_and_sense_index" }
g4c["status"] = "complete"
g4c["senses"] = senses.length
g4c["lemmas"] = index.length
readiness["gate4c"] = { "status" => "complete_and_canonical", "index" => "lexicon/english_sense_index.yaml", "schema" => "spec/english_sense_index_schema.yaml", "senses" => senses.length, "lemmas" => index.length, "validation" => "reports/gate4c_validation.md", "general_english_translation" => false }
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["english_sense_index"] = { "status" => "canonical_core_release", "version" => VERSION, "path" => "lexicon/english_sense_index.yaml", "senses" => senses.length, "lemmas" => index.length, "translator_authorized" => false }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Gate 4C English concept and sense index")
  status << "\n## Gate 4C English concept and sense index — #{DATE}\n\n- Status: **canonical core release #{VERSION}**.\n- Indexed senses: **#{senses.length}** across **#{index.length}** normalized English lemmas.\n- Every canonical atom and approved compound has one exact controlled-label sense. High-frequency polysemy routes explicitly to atoms, compounds, grammar, semantic IR, or gaps.\n- Atomic and compound meanings are unchanged. General-English translation remains unauthorized.\n- Next authorized work: **Gate 4D coverage and ambiguity report**.\n"
  File.write(status_path, status)
end

roadmap_path = File.join(EraZeroValidation::ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path)
unless roadmap.include?("Gate 4C completion — #{DATE}")
  roadmap << "\n## Gate 4C completion — #{DATE}\n\nGate 4C is complete as a canonical core sense index with **#{senses.length} senses** across **#{index.length} English lemmas**. The index preserves polysemy and explicit gaps instead of using first-match lookup. Gate 4D coverage and ambiguity analysis is next; no translator implementation is authorized yet.\n"
  File.write(roadmap_path, roadmap)
end

puts "Built Gate 4C sense index: #{senses.length} senses / #{index.length} lemmas"
