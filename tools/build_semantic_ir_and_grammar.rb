#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "fileutils"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation
VERSION = "1.0.0"
DATE = "2026-10-09"

atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
atomic_fp = EraZeroValidation.fingerprint(atoms_doc.fetch("atoms"))
compound_fp = EraZeroValidation.fingerprint(compounds_doc.fetch("entries"))

roles = %w[actor source cause experiencer bearer predicate target result destination instrument material content recipient location environment condition persistent_condition time manner quantity comparison_standard beneficiary]

spec = {
  "metadata" => {
    "title" => "Era Zero Semantic IR and Executable Grammar", "version" => VERSION,
    "status" => "canonical", "ir_version" => "1.0", "grammar_version" => "1.0",
    "atomic_lexicon_fingerprint" => atomic_fp, "compound_dictionary_fingerprint" => compound_fp,
    "renderer_started" => false, "decoder_started" => false, "translator_started" => false
  },
  "design_principles" => {
    "meaning_before_performance" => "The IR represents semantic structure independently of note choice, voice allocation, timing values, glyph layout, or English word order.",
    "lexical_immutability" => "Atom and compound occurrences reference canonical targets without altering their definitions or generated forms.",
    "explicit_scope" => "Negation, modality, quantification, time, aspect, conditionals, and repetition name an exact scope node.",
    "dimension_separation" => "Lexical third trit, occurrence runtime state, polarity, modality, reference time, and aspect are independent fields and never substitute for one another.",
    "finite_graph" => "Every utterance is a finite connected directed acyclic graph with one root clause.",
    "no_silent_inference" => "Roles, attachment, coreference, order, and coordination are explicit; a renderer or translator may not infer them from adjacency."
  },
  "document_model" => {
    "required_fields" => %w[ir_version utterance_id root_clause speech_act nodes edges serialization],
    "utterance_id_pattern" => "UTT:<24 lowercase hexadecimal digits>",
    "root_clause" => "Exactly one clause node is the external semantic root.",
    "graph" => "All non-root nodes must have a directed path to root_clause. Cycles are prohibited, including through embedded clauses and coreference.",
    "semantic_payload" => %w[ir_version root_clause speech_act nodes edges discourse_constraints],
    "nonidentity_metadata" => %w[english_source literal_gloss natural_rendering notes confidence renderer_plan absolute_pitch midi svg audio]
  },
  "node_types" => {
    "clause" => { "required" => %w[node_id kind clause_type], "clause_types" => %w[predication relation definition conditional comparison transition], "rule" => "A clause contains one predicate or operator center and may embed other clauses." },
    "lexical_occurrence" => { "required" => %w[node_id kind target_type target_id runtime_state], "target_types" => %w[atom compound], "rule" => "References exactly one canonical lexical target; runtime state describes this occurrence only." },
    "literal" => { "required" => %w[node_id kind datatype value], "datatypes" => %w[boolean integer decimal string datetime duration unit symbol], "rule" => "Literal values carry no unstated lexical meaning." },
    "variable" => { "required" => %w[node_id kind variable_id value_type], "value_types" => %w[entity process relation condition value location time quantity proposition], "rule" => "Variables are locally bound or explicitly discourse-bound." },
    "reference" => { "required" => %w[node_id kind referent_id], "rule" => "A reference resolves to one declared discourse referent; unresolved reference is an error, not a guess." },
    "scope_operator" => { "required" => %w[node_id kind operator], "operators" => %w[negation modality quantifier aspect repetition], "rule" => "Every operator has exactly one scopes edge." },
    "coordination" => { "required" => %w[node_id kind operator], "operators" => %w[all_of any_of exactly_one sequence parallel], "rule" => "Members are explicit; sequence requires integer order, parallel forbids order." },
    "time_anchor" => { "required" => %w[node_id kind anchor_type], "anchor_types" => %w[speech_time reference_time absolute_time interval], "rule" => "Time is an occurrence relation, never inferred from lexical trit or runtime state." },
    "measurement" => { "required" => %w[node_id kind magnitude unit], "rule" => "Magnitude is numeric or a quantity variable and unit is a controlled symbol." },
    "state_snapshot" => { "required" => %w[node_id kind bearer state_value], "rule" => "Used only as before or after state of an explicit transition clause." }
  },
  "edge_types" => {
    "centers" => { "direction" => "predicate_or_operator_to_clause", "cardinality" => "exactly one incoming center per clause" },
    "fills_role" => { "direction" => "argument_to_lexical_or_clause_center", "roles" => roles, "cardinality" => "at most one per singular role unless coordinated" },
    "scopes" => { "direction" => "scoped_node_to_operator", "cardinality" => "exactly one incoming per scope operator" },
    "member_of" => { "direction" => "member_to_coordination", "attributes" => ["order"], "cardinality" => "at least two members" },
    "qualifies" => { "direction" => "descriptor_to_described", "rule" => "Lexical qualification only; propositional modification uses a clause or scoped operator." },
    "time_relation" => { "direction" => "time_anchor_to_clause", "relations" => %w[before at after during starts ends overlaps], "cardinality" => "explicit relation required" },
    "condition_of" => { "direction" => "condition_clause_to_consequent_clause", "attributes" => ["condition_status"], "condition_statuses" => %w[open satisfied unsatisfied counterfactual] },
    "before_state" => { "direction" => "state_snapshot_to_transition_clause", "cardinality" => "exactly one for transition" },
    "after_state" => { "direction" => "state_snapshot_to_transition_clause", "cardinality" => "exactly one for transition" },
    "corefers_with" => { "direction" => "reference_to_declared_referent", "cardinality" => "exactly one" },
    "grounds" => { "direction" => "supporting_clause_to_supported_clause", "rule" => "Discourse/evidential dependency, not lexical ORI grounding unless ORI is explicitly used." }
  },
  "role_system" => {
    "roles" => roles,
    "core_register_defaults" => { "low" => %w[actor source cause], "middle" => %w[predicate], "high" => %w[target result destination], "sustained_background" => %w[environment persistent_condition] },
    "typed_extensions" => { "experiencer" => "cognitive or affective bearer", "bearer" => "entity in which a state inheres", "content" => "communicated or represented information", "recipient" => "participant receiving possession or benefit rather than merely a target", "instrument" => "means used", "material" => "constituent input", "location" => "spatial/model setting", "time" => "temporal argument", "manner" => "mode of occurrence", "quantity" => "cardinality or measure", "comparison_standard" => "reference for comparison", "beneficiary" => "entity for whose benefit an occurrence is performed" },
    "selection_rule" => "Lexical invariants constrain plausible roles, but the IR never invents a missing participant. Required role profiles are defined by controlled-English templates and later translator rules."
  },
  "runtime_state" => {
    "codes" => {
      0 => "inactive, false, ended, unavailable, or inaccessible as specifically interpreted for the lexical target",
      1 => "active, valid, expressed, or executing as specifically interpreted for the lexical target",
      2 => "dormant, pending, remembered, possible, or unresolved as specifically interpreted for the lexical target"
    },
    "representation" => { "code" => "0, 1, or 2", "num" => "the fixed name of code 2, not a numeric parameter or extra value" },
    "separations" => ["runtime 0 is not propositional negation", "runtime 1 is not present tense or truth", "runtime 2/num is not future tense, modality, or lexical third trit 2", "runtime state never changes compound identity"]
  },
  "polarity_and_scope" => {
    "positive" => "absence of a negation operator over the relevant scope",
    "negative" => "one explicit negation scope_operator with one scopes edge",
    "double_negation" => "two nested negation operators remain structurally distinct; no automatic cancellation in canonical IR",
    "scope_targets" => %w[clause lexical_occurrence coordination scope_operator],
    "prohibition" => "Do not encode not-X as runtime [0] or as a dormant/pending lexical root."
  },
  "quantity_and_measurement" => {
    "quantifiers" => %w[exact at_least at_most range all some none proportional],
    "number_format" => "Canonical finite decimal string; no exponent; -0 normalizes to 0; leading and trailing redundant zeros removed.",
    "units" => { "dimensionless" => "1", "time" => %w[second minute hour day], "length" => %w[meter kilometer], "mass" => %w[gram kilogram], "angle" => %w[degree radian], "information" => %w[bit byte] },
    "scope" => "A quantifier scopes exactly one variable, reference, lexical occurrence, or coordination. Measurement binds through quantity or another explicit semantic role.",
    "none_vs_negation" => "Quantifier none over a participant set is not identical to negating the entire clause."
  },
  "modality" => {
    "modes" => %w[possible necessary permitted obligated intended predicted counterfactual],
    "strength" => "Optional canonical decimal from 0 through 1 for epistemic confidence only; deontic force uses the mode name, not a probability.",
    "scope" => "A modality operator scopes exactly one proposition or predicate occurrence.",
    "separation" => "possible modality is not runtime [2], potential lexical third trit, or fall-then-rise contour; those layers may co-occur independently."
  },
  "time_and_aspect" => {
    "reference_time" => "Every tense interpretation is a time_relation between a clause and speech_time, another reference_time, an absolute_time, or an interval.",
    "relations" => %w[before at after during starts ends overlaps],
    "aspects" => %w[bounded ongoing habitual iterative perfect prospective],
    "separation" => "Completed/active/pending lexical meanings and runtime state do not determine reference time or grammatical aspect.",
    "state_transition" => "A transition clause has exactly one before_state and one after_state; a lexical process occurrence may center it but does not silently supply either snapshot."
  },
  "composition" => {
    "coordination" => { "all_of" => "all members asserted", "any_of" => "one or more alternatives", "exactly_one" => "one alternative", "sequence" => "members execute or occur in explicit order", "parallel" => "members occur without serial ordering" },
    "seriality" => "Sequence members have unique contiguous order integers beginning at 1.",
    "parallelism" => "Parallel members have no order attribute; performance overlap is derived later.",
    "repetition" => "Repetition scopes one clause or coordination and specifies exactly one of finite count, while-condition, or until-condition.",
    "recursion" => "Clause embedding and compound references may recurse structurally only through a finite acyclic expanded graph. Self-reference requires an explicit reference node and never creates an infinite lexical graph.",
    "conditionals" => "A conditional clause contains explicit condition_of structure; modality and counterfactual status remain separately encoded."
  },
  "discourse" => {
    "referent_declaration" => "Entity occurrences and variables may declare stable referent_id values within a discourse context.",
    "coreference" => "Reference nodes resolve by exact referent_id through one corefers_with edge; pronoun form and salience are later surface decisions.",
    "unresolved_reference" => "Must produce an error or clarification request.",
    "ellipsis" => "Not canonical IR; omitted content must be recovered before serialization."
  },
  "execution_semantics" => {
    "validation_order" => ["schema and identifier validation", "target authority resolution", "graph connectivity and acyclicity", "node and edge cardinality", "scope and binding", "quantity/unit normalization", "time and transition consistency", "canonical serialization"],
    "evaluation_order" => "Dependencies and embedded scopes evaluate before their containing clause; sequence order is explicit; parallel members are unordered relative to one another; assertions do not mutate lexicon authority.",
    "questions" => "Return the value or truth status of the scoped clause without asserting it.",
    "commands" => "Request execution of the scoped process; permission and obligation remain explicit modality.",
    "definitions" => "Bind a symbol or variable to a proposition, value, or type within an explicit context.",
    "errors" => %w[unknown_target invalid_runtime_state missing_role_target unknown_role invalid_scope cycle disconnected_node unresolved_reference invalid_quantity invalid_unit invalid_time_relation invalid_transition invalid_coordination invalid_repetition forbidden_surface_field]
  },
  "canonical_serialization" => {
    "encoding" => "UTF-8 JSON", "unicode" => "NFC", "object_keys" => "lexicographic", "numbers" => "canonical decimal strings",
    "node_order" => "lexicographic node_id", "edge_order" => "edge type rank, target, role/relation, source, then canonical attributes",
    "content_identity" => "SHA-256 over the canonical semantic payload; utterance_id is UTT:<first 24 lowercase hexadecimal digits>.",
    "excluded" => %w[english_source literal_gloss natural_rendering notes confidence renderer_plan absolute_pitch midi svg audio],
    "versioning" => "A payload-semantic change produces a new utterance identity. Editorial metadata never changes identity."
  },
  "surface_contract_for_later_renderer" => {
    "speech_act_to_contour" => { "assertion" => "level", "question" => "rising", "command" => "sharply_falling", "definition" => "rise_then_return", "possibility" => "fall_then_rise" },
    "role_to_register" => { "actor/source/cause" => "low", "predicate" => "middle", "target/result/destination" => "high", "environment/persistent_condition" => "sustained_background" },
    "timing" => { "qualifies" => "no_gap", "fills_role" => "short_gap", "next_instruction" => "medium_gap", "statement_end" => "long_gap", "parallel" => "overlap", "repetition" => "repeated_pulse" },
    "boundary" => "These mappings constrain the next gate but contain no absolute pitch, voice allocation, MIDI, glyph, or audio implementation."
  }
}

schema = {
  "metadata" => { "title" => "Era Zero semantic IR schema", "version" => VERSION, "status" => "canonical" },
  "required_document_fields" => spec.dig("document_model", "required_fields"),
  "node_kinds" => spec.fetch("node_types").keys,
  "edge_types" => spec.fetch("edge_types").keys,
  "roles" => roles,
  "speech_acts" => %w[assertion question command definition possibility],
  "forbidden_semantic_fields" => spec.dig("document_model", "nonidentity_metadata"),
  "identifier_patterns" => { "utterance" => "\\AUTT:[0-9a-f]{24}\\z", "node" => "\\An[0-9]{3}\\z", "edge" => "\\Ae[0-9]{3}\\z", "referent" => "\\Ar:[a-z][a-z0-9_-]*\\z", "variable" => "\\Av:[a-z][a-z0-9_-]*\\z" }
}

def node(id, kind, extra = {})
  { "node_id" => id, "kind" => kind }.merge(extra)
end

def edge(id, type, from, to, extra = {})
  { "edge_id" => id, "type" => type, "from" => from, "to" => to }.merge(extra)
end
def ir(name, nodes, edges, root: "n001", speech_act: "assertion", discourse: {})
  payload = { "ir_version" => "1.0", "root_clause" => root, "speech_act" => speech_act, "nodes" => nodes, "edges" => edges, "discourse_constraints" => discourse }
  digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
  { "ir_version" => "1.0", "utterance_id" => "UTT:#{digest[0, 24]}", "root_clause" => root, "speech_act" => speech_act, "nodes" => nodes, "edges" => edges, "discourse_constraints" => discourse, "serialization" => { "canonical_format" => "EZIR-JSON-1", "content_digest" => digest }, "test_name" => name }
end

lex = ->(id, target, state = 1) { node(id, "lexical_occurrence", { "target_type" => target.start_with?("CMP:") ? "compound" : "atom", "target_id" => target, "runtime_state" => { "code" => state } }) }
clause = ->(id, type = "predication") { node(id, "clause", { "clause_type" => type }) }

valid = []
valid << ir("assertion", [clause.call("n001"), lex.call("n002", "LIF:001")], [edge("e001", "centers", "n002", "n001")])
valid << ir("question", [clause.call("n001"), lex.call("n002", "MOV:211")], [edge("e001", "centers", "n002", "n001")], speech_act: "question")
valid << ir("command_with_actor_target", [clause.call("n001"), lex.call("n002", "REP:111"), lex.call("n003", "LIF:011"), lex.call("n004", "MAT:011")], [edge("e001", "centers", "n002", "n001"), edge("e002", "fills_role", "n003", "n002", { "role" => "actor" }), edge("e003", "fills_role", "n004", "n002", { "role" => "target" })], speech_act: "command")
valid << ir("negated_clause", [clause.call("n001"), lex.call("n002", "MOV:121"), node("n003", "scope_operator", { "operator" => "negation" })], [edge("e001", "centers", "n003", "n001"), edge("e002", "scopes", "n002", "n003")])
valid << ir("possible_clause", [clause.call("n001"), lex.call("n002", "MOV:122", 2), node("n003", "scope_operator", { "operator" => "modality", "mode" => "possible", "strength" => "0.7" })], [edge("e001", "centers", "n003", "n001"), edge("e002", "scopes", "n002", "n003")], speech_act: "possibility")
valid << ir("exact_quantity", [clause.call("n001"), lex.call("n002", "LIF:021"), node("n003", "scope_operator", { "operator" => "quantifier", "quantifier" => "exact", "value" => "3" })], [edge("e001", "centers", "n003", "n001"), edge("e002", "scopes", "n002", "n003")])
valid << ir("measurement", [clause.call("n001"), lex.call("n002", "MOV:210"), node("n003", "measurement", { "magnitude" => "5", "unit" => "kilometer" })], [edge("e001", "centers", "n002", "n001"), edge("e002", "fills_role", "n003", "n002", { "role" => "quantity" })])
valid << ir("temporal_before", [clause.call("n001"), lex.call("n002", "MOV:100"), node("n003", "time_anchor", { "anchor_type" => "speech_time" })], [edge("e001", "centers", "n002", "n001"), edge("e002", "time_relation", "n003", "n001", { "relation" => "before" })])
valid << ir("conditional", [clause.call("n001", "conditional"), clause.call("n002"), lex.call("n003", "LOG:101"), clause.call("n004"), lex.call("n005", "CRE:111")], [edge("e001", "centers", "n004", "n001"), edge("e002", "centers", "n003", "n002"), edge("e003", "centers", "n005", "n004"), edge("e004", "condition_of", "n002", "n004", { "condition_status" => "open" })])
valid << ir("sequence", [clause.call("n001"), node("n002", "coordination", { "operator" => "sequence" }), lex.call("n003", "MOV:100"), lex.call("n004", "MOV:110")], [edge("e001", "centers", "n002", "n001"), edge("e002", "member_of", "n003", "n002", { "order" => 1 }), edge("e003", "member_of", "n004", "n002", { "order" => 2 })])
valid << ir("parallel", [clause.call("n001"), node("n002", "coordination", { "operator" => "parallel" }), lex.call("n003", "CON:101"), lex.call("n004", "DAT:101")], [edge("e001", "centers", "n002", "n001"), edge("e002", "member_of", "n003", "n002"), edge("e003", "member_of", "n004", "n002")])
valid << ir("finite_repetition", [clause.call("n001"), node("n002", "scope_operator", { "operator" => "repetition", "mode" => "count", "count" => 3 }), lex.call("n003", "MOV:120")], [edge("e001", "centers", "n002", "n001"), edge("e002", "scopes", "n003", "n002")])
valid << ir("transition", [clause.call("n001", "transition"), lex.call("n002", "STR:101"), node("n003", "state_snapshot", { "bearer" => "r:x", "state_value" => "old" }), node("n004", "state_snapshot", { "bearer" => "r:x", "state_value" => "new" })], [edge("e001", "centers", "n002", "n001"), edge("e002", "before_state", "n003", "n001"), edge("e003", "after_state", "n004", "n001")], discourse: { "declared_referents" => ["r:x"] })
valid << ir("coreference", [clause.call("n001"), lex.call("n002", "MIN:211"), node("n003", "variable", { "variable_id" => "v:observer", "value_type" => "entity", "referent_id" => "r:observer" }), node("n004", "reference", { "referent_id" => "r:observer" })], [edge("e001", "centers", "n002", "n001"), edge("e002", "fills_role", "n003", "n002", { "role" => "experiencer" }), edge("e003", "corefers_with", "n004", "n003")], discourse: { "declared_referents" => ["r:observer"] })
valid << ir("compound_occurrence", [clause.call("n001"), lex.call("n002", compounds_doc.fetch("entries").first.fetch("compound_id"))], [edge("e001", "centers", "n002", "n001")])
valid << ir("state_two_num", [clause.call("n001"), node("n002", "lexical_occurrence", { "target_type" => "atom", "target_id" => "MOV:212", "runtime_state" => { "code" => 2 } })], [edge("e001", "centers", "n002", "n001")])

invalid = [
  ["unknown_target", ir("bad", [clause.call("n001"), lex.call("n002", "FAK:999")], [edge("e001", "centers", "n002", "n001")]), ["unknown_target"]],
  ["bad_runtime", ir("bad", [clause.call("n001"), lex.call("n002", "LIF:001", 3)], [edge("e001", "centers", "n002", "n001")]), ["invalid_runtime_state"]],
  ["num_wrong_state", ir("bad", [clause.call("n001"), node("n002", "lexical_occurrence", { "target_type" => "atom", "target_id" => "LIF:001", "runtime_state" => { "code" => 1, "num" => 2 } })], [edge("e001", "centers", "n002", "n001")]), ["invalid_runtime_parameter"]],
  ["missing_center", ir("bad", [clause.call("n001"), lex.call("n002", "LIF:001")], [edge("e001", "fills_role", "n002", "n001", { "role" => "actor" })]), ["clause_center_cardinality"]],
  ["double_center", ir("bad", [clause.call("n001"), lex.call("n002", "LIF:001"), lex.call("n003", "MOV:001")], [edge("e001", "centers", "n002", "n001"), edge("e002", "centers", "n003", "n001")]), ["clause_center_cardinality"]],
  ["scope_missing", ir("bad", [clause.call("n001"), node("n002", "scope_operator", { "operator" => "negation" })], [edge("e001", "centers", "n002", "n001")]), ["scope_cardinality"]],
  ["unknown_role", ir("bad", [clause.call("n001"), lex.call("n002", "MOV:121"), lex.call("n003", "LIF:011")], [edge("e001", "centers", "n002", "n001"), edge("e002", "fills_role", "n003", "n002", { "role" => "owner" })]), ["unknown_role"]],
  ["sequence_gap", ir("bad", [clause.call("n001"), node("n002", "coordination", { "operator" => "sequence" }), lex.call("n003", "MOV:100"), lex.call("n004", "MOV:110")], [edge("e001", "centers", "n002", "n001"), edge("e002", "member_of", "n003", "n002", { "order" => 1 }), edge("e003", "member_of", "n004", "n002", { "order" => 3 })]), ["invalid_coordination"]],
  ["parallel_ordered", ir("bad", [clause.call("n001"), node("n002", "coordination", { "operator" => "parallel" }), lex.call("n003", "MOV:100"), lex.call("n004", "MOV:110")], [edge("e001", "centers", "n002", "n001"), edge("e002", "member_of", "n003", "n002", { "order" => 1 }), edge("e003", "member_of", "n004", "n002", { "order" => 2 })]), ["invalid_coordination"]],
  ["bad_unit", ir("bad", [clause.call("n001"), lex.call("n002", "MOV:210"), node("n003", "measurement", { "magnitude" => "5", "unit" => "furlong" })], [edge("e001", "centers", "n002", "n001"), edge("e002", "fills_role", "n003", "n002", { "role" => "quantity" })]), ["invalid_unit"]],
  ["transition_missing_after", ir("bad", [clause.call("n001", "transition"), lex.call("n002", "STR:101"), node("n003", "state_snapshot", { "bearer" => "r:x", "state_value" => "old" })], [edge("e001", "centers", "n002", "n001"), edge("e002", "before_state", "n003", "n001")], discourse: { "declared_referents" => ["r:x"] }), ["invalid_transition"]],
  ["unresolved_reference", ir("bad", [clause.call("n001"), lex.call("n002", "MIN:211"), node("n003", "reference", { "referent_id" => "r:missing" })], [edge("e001", "centers", "n002", "n001"), edge("e002", "fills_role", "n003", "n002", { "role" => "experiencer" })]), ["unresolved_reference"]],
  ["surface_field", ir("bad", [clause.call("n001"), lex.call("n002", "LIF:001").merge("absolute_pitch" => 60)], [edge("e001", "centers", "n002", "n001")]), ["forbidden_surface_field"]]
]

cases = { "metadata" => { "version" => VERSION, "valid_cases" => valid.length, "invalid_cases" => invalid.length }, "valid_cases" => valid.map { |x| { "case_id" => x.delete("test_name"), "ir" => x } }, "invalid_cases" => invalid.map { |id, x, errors| x.delete("test_name"); { "case_id" => id, "ir" => x, "expected_errors" => errors } } }

report = <<~MD
  # Era Zero Semantic IR and Executable Grammar 1.0

  Status: **CANONICAL — RENDERER/DECODER GATE MAY BEGIN**

  This release defines the language's first complete proposition layer. It represents lexical occurrences, typed roles, explicit scope, negation, quantity and measurement, modality, reference time, aspect, state transitions, coordination, sequence, parallelism, repetition, finite recursion, coreference, and deterministic content identity.

  ## Critical separations

  Lexical third trit, runtime state, negation, modality, tense, and aspect remain independent. Runtime `[0]` never means “not”; `[1]` never means present tense or truth; `[2]/num` never means future or possible modality. A root lexically ending in trit 2 retains that invariant even when its occurrence has runtime state `[0]`, `[1]`, or `[2]/num`.

  ## Execution boundary

  “Executable” means the graph has deterministic validation, binding, scope, evaluation order, error classes, and canonical serialization. It does not mean an English parser, renderer, decoder, MIDI engine, glyph generator, or general translator has been implemented. The next gate maps this canonical IR into formal notation and back with round-trip conformance.
MD

migration = { "migration_id" => "semantic_ir_and_grammar_1.0", "date" => DATE, "status" => "applied", "from" => { "semantic_ir_and_grammar" => "not_started" }, "to" => { "semantic_ir_and_grammar" => "complete", "version" => VERSION, "valid_cases" => valid.length, "invalid_cases" => invalid.length }, "atomic_fingerprint" => atomic_fp, "compound_fingerprint" => compound_fp, "lexical_changes" => [], "next_gate" => "deterministic_renderer_and_decoder" }

File.write(File.join(EraZeroValidation::ROOT, "spec/semantic_ir_1.0.yaml"), YAML.dump(spec))
File.write(File.join(EraZeroValidation::ROOT, "spec/semantic_ir_schema.yaml"), YAML.dump(schema))
File.write(File.join(EraZeroValidation::ROOT, "tests/semantic_ir_cases.yaml"), YAML.dump(cases))
File.write(File.join(EraZeroValidation::ROOT, "reports/semantic_ir_and_grammar.md"), report)
File.write(File.join(EraZeroValidation::ROOT, "migrations/semantic_ir_and_grammar_1.0.yaml"), YAML.dump(migration))

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["last_completed_gate"] = "semantic_ir_and_grammar"
version["next_gate_authorized"] = "deterministic_renderer_and_decoder"
version["semantic_ir_status"] = "canonical"
version["semantic_ir_version"] = VERSION
version["semantic_ir"] = "spec/semantic_ir_1.0.yaml"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["next_authorized_gate"] = "deterministic_renderer_and_decoder"
gate = readiness.fetch("required_gates").find { |g| g["gate"] == "semantic_ir_and_grammar" }
gate["status"] = "complete"
gate["artifact"] = "spec/semantic_ir_1.0.yaml"
gate["validation"] = "reports/semantic_ir_validation.md"
readiness["semantic_ir"] = { "status" => "complete_and_canonical", "version" => VERSION, "spec" => "spec/semantic_ir_1.0.yaml", "schema" => "spec/semantic_ir_schema.yaml", "conformance" => "tests/semantic_ir_cases.yaml", "renderer_started" => false }
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["semantic_ir"] = { "status" => "canonical", "version" => VERSION, "path" => "spec/semantic_ir_1.0.yaml", "schema" => "spec/semantic_ir_schema.yaml" }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Semantic IR and executable grammar — #{DATE}")
  status << "\n## Semantic IR and executable grammar — #{DATE}\n\n- Status: **canonical #{VERSION}**.\n- Defines complete proposition graphs, typed roles, explicit scope, negation, quantity, modality, time, transitions, coordination, seriality, parallelism, repetition, recursion, coreference, errors, and canonical serialization.\n- Lexical authority is unchanged. Next authorized work: **deterministic renderer and inverse decoder**.\n"
  File.write(status_path, status)
end

puts "Built semantic IR and grammar: #{valid.length} valid / #{invalid.length} invalid conformance cases"
