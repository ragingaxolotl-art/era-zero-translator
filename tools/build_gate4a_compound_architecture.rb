#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "fileutils"
require_relative "lib/era_zero_validation"

include EraZeroValidation

VERSION = "1.0.0"
STATUS = "canonical_gate4a_architecture"
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atomic_fingerprint = EraZeroValidation.fingerprint(atoms_doc.fetch("atoms"))

role_inventory = {
  "actor" => { "semantic_function" => "entity initiating or controlling a process", "register" => "low", "source_status" => "fixed_core_role" },
  "source" => { "semantic_function" => "origin endpoint, input, or grounding referent", "register" => "low", "source_status" => "fixed_core_role" },
  "cause" => { "semantic_function" => "separately asserted cause of a process or relation", "register" => "low", "source_status" => "fixed_core_role" },
  "experiencer" => { "semantic_function" => "entity undergoing a mental, sensory, or affective state", "register" => "low", "source_status" => "typed_gate4a_extension" },
  "bearer" => { "semantic_function" => "entity in which a condition, property, or state inheres", "register" => "low", "source_status" => "typed_gate4a_extension" },
  "predicate" => { "semantic_function" => "process or relationship serving as semantic center", "register" => "middle", "source_status" => "fixed_core_role" },
  "target" => { "semantic_function" => "distinct entity toward which a process or relation is directed", "register" => "high", "source_status" => "fixed_core_role" },
  "result" => { "semantic_function" => "state, entity, or value produced as the semantic result", "register" => "high", "source_status" => "fixed_core_role" },
  "destination" => { "semantic_function" => "endpoint of directed movement or transfer", "register" => "high", "source_status" => "fixed_core_role" },
  "instrument" => { "semantic_function" => "means used by an actor without becoming the actor or result", "register" => "sustained_background", "source_status" => "typed_gate4a_extension" },
  "material" => { "semantic_function" => "substance or informational content from which a result is constituted", "register" => "sustained_background", "source_status" => "typed_gate4a_extension" },
  "location" => { "semantic_function" => "spatial or model-relative setting of a process or entity", "register" => "sustained_background", "source_status" => "typed_gate4a_extension" },
  "environment" => { "semantic_function" => "shared setting that remains backgrounded across the compound", "register" => "sustained_background", "source_status" => "fixed_core_role" },
  "condition" => { "semantic_function" => "condition under which the head relation or process is applicable", "register" => "sustained_background", "source_status" => "fixed_core_role" },
  "persistent_condition" => { "semantic_function" => "background condition maintained across the relevant reference span", "register" => "sustained_background", "source_status" => "fixed_core_role" }
}.freeze

architecture = {
  "metadata" => {
    "title" => "Era Zero Gate 4A Typed Compound Architecture",
    "version" => VERSION,
    "status" => STATUS,
    "architecture_version" => "1.0",
    "atomic_lexicon" => "lexicon/atoms.yaml",
    "atomic_lexicon_fingerprint" => atomic_fingerprint,
    "atomic_authority" => "324 canonical roots; 0 provisional roots",
    "authority_basis" => "User instruction to perform the next translator-readiness stage after atomic semantic completion",
    "generated_fields_changed" => false,
    "atomic_meanings_changed" => false,
    "compound_dictionary_started" => false,
    "english_index_started" => false,
    "semantic_ir_started" => false,
    "translator_started" => false
  },
  "scope" => {
    "owns" => [
      "the machine-readable shape of a compound definition",
      "explicit semantic-head selection",
      "modifier attachment and scope",
      "typed argument binding",
      "coordination inside a lexical compound template",
      "nesting by versioned compound reference",
      "canonical compound serialization and identity",
      "surface-order and performance defaults for compounds",
      "validation and change-control rules"
    ],
    "does_not_own" => [
      "any approved lexical compound meaning",
      "an English word-to-compound mapping",
      "etymology or conventional shortening",
      "clause-level negation, modality, tense, quantity, or discourse scope",
      "the general utterance IR or executable grammar",
      "renderer, decoder, or translator implementation"
    ]
  },
  "source_grounded_invariants" => {
    "describer_before_head" => "A describing root is realized before the main root.",
    "modifier_timing" => "A no-gap boundary marks modifier attachment inside a compound.",
    "argument_timing" => "A short gap separates a typed argument from its predicate or relation head.",
    "head_role_contour" => "Only the semantic head normally receives the compound's external noun-role contour.",
    "independent_roots" => "Every component root retains its own atomic meaning and may be separately emphasized.",
    "register_roles" => { "low" => %w[actor source cause], "middle" => %w[process relationship], "high" => %w[target result destination], "sustained_background" => %w[environment persistent_condition] },
    "atomic_immutability" => "Composition never changes a root's canonical ID, lexical definition, generated forms, or third-trit meaning.",
    "runtime_separation" => "Runtime state belongs to an utterance occurrence and is never stored as part of a lexical compound identity."
  },
  "definition_model" => {
    "required_fields" => %w[architecture_version compound_key definition_version status semantic_head nodes edges serialization],
    "compound_key_policy" => "Draft keys use DRAFT:<namespace>:<slug>. Approved dictionary entries will receive a content-derived CMP identifier during Gate 4B.",
    "statuses" => %w[draft proposed approved deprecated superseded],
    "semantic_head" => "Exactly one root or approved compound reference is the semantic center. A slot or coordination node cannot be the head.",
    "graph_shape" => "A finite connected directed acyclic graph. Every non-head node must have a directed path to the semantic head.",
    "lexical_center_rule" => "A compound expresses one compositional semantic center. Multiple independent assertions belong in the later utterance IR, not in one lexical compound.",
    "open_template_rule" => "A proposed dictionary item may expose typed slot nodes, but every slot must bind through one explicit fills_role edge.",
    "no_silent_inference" => "Machine meaning comes from explicit nodes, edges, roles, and scope—not from English gloss order or adjacency alone."
  },
  "node_types" => {
    "root" => { "required" => %w[node_id kind root_id], "rule" => "root_id must name one of the 324 canonical atoms" },
    "compound_ref" => { "required" => %w[node_id kind compound_id definition_version], "rule" => "reference must resolve to an approved, non-superseded dictionary entry; unavailable during Gate 4A fixtures" },
    "slot" => { "required" => %w[node_id kind slot_name slot_type], "slot_types" => %w[entity process relation condition value location time quantity], "rule" => "slots are typed variables, not lexical meanings" },
    "coordination" => { "required" => %w[node_id kind operator], "operators" => %w[all_of any_of exactly_one], "rule" => "coordination groups members but cannot itself be the semantic head" }
  },
  "edge_types" => {
    "qualifies" => { "direction" => "descriptor_to_described", "role_allowed" => false, "performance" => "descriptor immediately precedes its target with no gap", "semantic_effect" => "narrows or classifies the target without asserting an independent event" },
    "fills_role" => { "direction" => "argument_to_predicate", "role_required" => true, "allowed_roles" => role_inventory.keys, "performance" => "argument uses its role register and a short argument boundary unless simultaneous realization is explicitly selected later" },
    "member_of" => { "direction" => "member_to_coordination", "role_allowed" => false, "performance" => "members use the fixed enumeration pulse when rendered as one group", "semantic_effect" => "collects alternatives or conjunctive members under an explicit coordination operator" }
  },
  "role_inventory" => role_inventory,
  "attachment_and_scope" => {
    "explicit_target" => "Every qualifies or fills_role edge names exactly one target node.",
    "nearest_surface_attachment" => "Surface adjacency is a rendering consequence of the graph; it never overrides the explicit target.",
    "modifier_scope" => "A modifier affects only its target and descendants contained in that referenced compound, never an adjacent sibling by implication.",
    "argument_scope" => "An argument fills one named role of one predicate head. Reuse across heads requires separate edges.",
    "coordination_scope" => "The coordination operator applies only to nodes connected by member_of edges.",
    "external_attachment" => "A containing compound attaches to a referenced compound as a single node unless the referenced definition explicitly exposes a slot."
  },
  "head_selection" => {
    "entity_center" => "Use the entity or condition whose subtype is being named as head.",
    "process_center" => "Use the process whose participants or circumstances are being bound as head.",
    "relation_center" => "Use the relation or affordance whose endpoints or conditions are being bound as head.",
    "tie_breaker" => "If two roots would each remain independent predicates, reject the lexical compound and route the expression to the later utterance IR.",
    "surface_default" => "Qualifiers are emitted before the head; the head is emitted last within its modifier chain."
  },
  "compound_classes" => {
    "attributive" => "one head with one or more qualifies edges",
    "relational" => "a relationship or affordance head with typed endpoint or condition roles",
    "eventive" => "a process head with typed actor, target, result, destination, or background roles",
    "configurational" => "an entity or condition head with multiple separately attached facets",
    "template" => "any of the above with one or more typed slot nodes"
  },
  "surface_realization" => {
    "formal_notation" => "Graph notation is authoritative; a linear performance is one deterministic realization of it.",
    "modifier_order" => "Render modifier subtrees before their target with no gap. More deeply nested modifiers render before less deeply nested modifiers.",
    "sibling_order" => "Sort same-target qualifiers by canonical expanded-graph hash, then by canonical root or compound ID.",
    "head_marking" => "Apply the compound's external role contour to the semantic head only unless a later grammar rule explicitly scopes a contour to another node.",
    "argument_realization" => "Render arguments in their assigned register with a short gap from the predicate; simultaneous arguments may occupy parallel voices only under a later utterance rule.",
    "state_realization" => "Runtime [0], [1], or [2]/num is supplied by the utterance occurrence. It is omitted from the dictionary identity and content hash.",
    "statement_boundary" => "Medium or long gaps terminate compound binding and therefore cannot occur inside one lexical modifier chain."
  },
  "canonical_serialization" => {
    "encoding" => "UTF-8 JSON",
    "unicode" => "NFC",
    "object_keys" => "lexicographic order",
    "arrays" => {
      "nodes" => "canonical node_id order",
      "edges" => "edge_type rank, target node_id, role rank, source node_id",
      "other_sets" => "lexicographic order unless the schema declares sequence semantics"
    },
    "canonical_node_ids" => {
      "h" => "semantic head",
      "qNN" => "qualifier nodes in canonical sibling order",
      "a-ROLE-NN" => "argument nodes grouped by canonical role order",
      "gNN" => "coordination nodes",
      "sNN" => "slot nodes when not already an argument"
    },
    "excluded_from_identity" => %w[display_title english_gloss translation_candidates examples notes approval_history runtime_state contour register absolute_pitch],
    "content_identity" => "SHA-256 over the canonical semantic payload; approved compound ID is CMP:<first-24-lowercase-hex>, with the full digest retained.",
    "semantic_payload" => %w[architecture_version semantic_head nodes edges lexical_constraints],
    "versioning" => "A semantic-payload change creates a new definition version and content digest. Editorial metadata may change without semantic migration."
  },
  "change_control" => {
    "approval_required" => "Every Gate 4B dictionary entry requires explicit or delegated semantic approval plus validation.",
    "atomic_collision_check" => "Reject a compound that merely duplicates one atomic invariant unless its additional compositional distinction is explicit.",
    "semantic_change" => "Changing head, nodes, edges, roles, scope, slot types, or lexical constraints requires a versioned migration.",
    "deprecation" => "Never silently rewrite an approved compound. Mark it deprecated or superseded and identify its successor.",
    "english_independence" => "English labels and glosses are indexing metadata, never compound identity or proof of meaning."
  },
  "reserved_for_later_gates" => {
    "gate4b" => ["approved compound entries", "high-frequency compound dictionary", "compound-specific collisions and coverage"],
    "gate4c" => ["English sense index", "sense disambiguation", "ordinary-language coverage"],
    "semantic_ir" => ["clause structure", "negation scope", "tense and aspect", "quantity and measurement", "modality", "conditionals", "coreference", "discourse binding", "parallel and serial assertions"],
    "renderer" => ["absolute pitch", "voice allocation", "timing values", "MIDI", "glyph layout", "round-trip decoder"],
    "translator" => ["English parsing", "ranking", "clarification", "unsupported-input behavior"]
  }
}

schema = {
  "metadata" => { "title" => "Gate 4A compound graph schema", "version" => VERSION, "status" => STATUS },
  "definition" => {
    "architecture_version" => { "type" => "string", "const" => "1.0" },
    "compound_key" => { "type" => "string", "pattern" => "\\ADRAFT:[a-z0-9_-]+:[a-z0-9_-]+\\z" },
    "definition_version" => { "type" => "string", "pattern" => "\\A[0-9]+\\.[0-9]+\\.[0-9]+\\z" },
    "status" => { "enum" => %w[draft proposed approved deprecated superseded] },
    "semantic_head" => { "type" => "node_reference", "canonical_node_id" => "h" },
    "nodes" => { "type" => "array", "minimum" => 2, "unique_by" => "node_id", "allowed_kinds" => %w[root compound_ref slot coordination] },
    "edges" => { "type" => "array", "minimum" => 1, "unique_by" => "edge_id", "allowed_types" => %w[qualifies fills_role member_of] },
    "lexical_constraints" => { "type" => "array", "items" => "string", "default" => [] },
    "serialization" => { "type" => "object", "required" => %w[canonical_format content_digest] }
  },
  "forbidden_lexical_fields" => %w[runtime_state contour register absolute_pitch statement_type tense negation quantity probability english_word timing],
  "node_rules" => architecture.fetch("node_types"),
  "edge_rules" => architecture.fetch("edge_types")
}

def root(node_id, root_id)
  { "node_id" => node_id, "kind" => "root", "root_id" => root_id }
end

def slot(node_id, name, type)
  { "node_id" => node_id, "kind" => "slot", "slot_name" => name, "slot_type" => type }
end

def group(node_id, operator)
  { "node_id" => node_id, "kind" => "coordination", "operator" => operator }
end

def edge(edge_id, type, from, to, role = nil)
  value = { "edge_id" => edge_id, "type" => type, "from" => from, "to" => to }
  value["role"] = role if role
  value
end

def definition(key, nodes, edges, head: "h", extra: {})
  { "architecture_version" => "1.0", "compound_key" => "DRAFT:test:#{key}", "definition_version" => "0.1.0", "status" => "draft", "semantic_head" => head, "nodes" => nodes, "edges" => edges, "lexical_constraints" => [], "serialization" => { "canonical_format" => "EZC-JSON-1", "content_digest" => "test-fixture" } }.merge(extra)
end

valid = [
  ["simple_modifier", definition("simple-modifier", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h")])],
  ["multiple_qualifiers", definition("multiple-qualifiers", [root("q01", "MAT:000"), root("q02", "CRE:020"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h"), edge("e02", "qualifies", "q02", "h")])],
  ["nested_qualifier", definition("nested-qualifier", [root("q01", "MAT:000"), root("q02", "STR:020"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "q02"), edge("e02", "qualifies", "q02", "h")])],
  ["event_target", definition("event-target", [root("a-target-01", "LIF:010"), root("h", "MOV:110")], [edge("e01", "fills_role", "a-target-01", "h", "target")])],
  ["event_actor_destination", definition("event-actor-destination", [root("a-actor-01", "LIF:010"), root("a-destination-01", "MOV:010"), root("h", "MOV:110")], [edge("e01", "fills_role", "a-actor-01", "h", "actor"), edge("e02", "fills_role", "a-destination-01", "h", "destination")])],
  ["relation_source_target", definition("relation-source-target", [root("a-source-01", "LIF:010"), root("a-target-01", "LIF:010"), root("h", "CON:210")], [edge("e01", "fills_role", "a-source-01", "h", "source"), edge("e02", "fills_role", "a-target-01", "h", "target")])],
  ["background_condition", definition("background-condition", [root("a-condition-01", "LOG:010"), root("h", "ORI:210")], [edge("e01", "fills_role", "a-condition-01", "h", "condition")])],
  ["open_target_slot", definition("open-target-slot", [slot("a-target-01", "target", "entity"), root("h", "CON:210")], [edge("e01", "fills_role", "a-target-01", "h", "target")])],
  ["coordinated_materials", definition("coordinated-materials", [root("q01", "MAT:000"), root("q02", "DAT:210"), group("g01", "all_of"), root("h", "STR:020")], [edge("e01", "member_of", "q01", "g01"), edge("e02", "member_of", "q02", "g01"), edge("e03", "fills_role", "g01", "h", "material")])],
  ["qualified_argument", definition("qualified-argument", [root("q01", "MAT:000"), root("a-target-01", "LIF:010"), root("h", "MOV:110")], [edge("e01", "qualifies", "q01", "a-target-01"), edge("e02", "fills_role", "a-target-01", "h", "target")])],
  ["same_root_distinct_roles", definition("same-root-distinct-roles", [root("a-source-01", "LIF:010"), root("a-target-01", "LIF:010"), root("h", "ORI:210")], [edge("e01", "fills_role", "a-source-01", "h", "source"), edge("e02", "fills_role", "a-target-01", "h", "target")])],
  ["alternative_instrument", definition("alternative-instrument", [root("q01", "MAT:010"), root("q02", "DAT:210"), group("g01", "any_of"), root("h", "MAT:100")], [edge("e01", "member_of", "q01", "g01"), edge("e02", "member_of", "q02", "g01"), edge("e03", "fills_role", "g01", "h", "instrument")])]
]

base = definition("invalid", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h")])
invalid = [
  ["missing_head", base.merge("semantic_head" => "missing"), ["head_missing"]],
  ["head_not_h", base.merge("semantic_head" => "q01"), ["head_id_not_canonical"]],
  ["slot_as_head", definition("slot-head", [slot("h", "x", "entity"), root("q01", "LIF:010")], [edge("e01", "qualifies", "q01", "h")]), ["invalid_head_kind"]],
  ["coordination_as_head", definition("group-head", [group("h", "all_of"), root("q01", "LIF:010")], [edge("e01", "member_of", "q01", "h")]), ["invalid_head_kind"]],
  ["unknown_root", definition("unknown-root", [root("q01", "FAK:999"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h")]), ["unknown_root"]],
  ["duplicate_node", definition("duplicate-node", [root("q01", "MAT:000"), root("q01", "LIF:010"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h")]), ["duplicate_node_id"]],
  ["duplicate_edge", definition("duplicate-edge", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h"), edge("e01", "qualifies", "q01", "h")]), ["duplicate_edge_id"]],
  ["self_edge", definition("self-edge", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "q01"), edge("e02", "qualifies", "q01", "h")]), ["self_edge"]],
  ["missing_endpoint", definition("missing-endpoint", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "qualifies", "ghost", "h")]), ["edge_endpoint_missing"]],
  ["cycle", definition("cycle", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h"), edge("e02", "qualifies", "h", "q01")]), ["cycle"]],
  ["disconnected", definition("disconnected", [root("q01", "MAT:000"), root("q02", "DAT:210"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h")]), ["disconnected_node"]],
  ["unknown_edge_type", definition("unknown-edge", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "means", "q01", "h")]), ["unknown_edge_type"]],
  ["role_missing", definition("role-missing", [root("a-target-01", "LIF:010"), root("h", "MOV:110")], [edge("e01", "fills_role", "a-target-01", "h")]), ["role_required"]],
  ["role_forbidden", definition("role-forbidden", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h", "target")]), ["role_forbidden"]],
  ["unknown_role", definition("unknown-role", [root("a-target-01", "LIF:010"), root("h", "MOV:110")], [edge("e01", "fills_role", "a-target-01", "h", "owner")]), ["unknown_role"]],
  ["member_target_not_group", definition("bad-member", [root("q01", "MAT:000"), root("h", "LIF:010")], [edge("e01", "member_of", "q01", "h")]), ["member_target_not_coordination"]],
  ["empty_coordination", definition("empty-group", [group("g01", "all_of"), root("h", "STR:020")], [edge("e01", "fills_role", "g01", "h", "material")]), ["coordination_too_small"]],
  ["bad_operator", definition("bad-operator", [root("q01", "MAT:000"), root("q02", "DAT:210"), group("g01", "xor"), root("h", "STR:020")], [edge("e01", "member_of", "q01", "g01"), edge("e02", "member_of", "q02", "g01"), edge("e03", "fills_role", "g01", "h", "material")]), ["unknown_coordination_operator"]],
  ["unbound_slot", definition("unbound-slot", [slot("s01", "target", "entity"), root("h", "CON:210")], [edge("e01", "qualifies", "s01", "h")]), ["slot_not_role_bound"]],
  ["runtime_in_definition", base.merge("runtime_state" => 1), ["forbidden_lexical_field"]],
  ["contour_in_node", definition("node-contour", [root("q01", "MAT:000").merge("contour" => "level"), root("h", "LIF:010")], [edge("e01", "qualifies", "q01", "h")]), ["forbidden_node_field"]],
  ["bad_key", base.merge("compound_key" => "water pet"), ["invalid_compound_key"]],
  ["medium_gap_internal", base.merge("timing" => "medium_gap"), ["forbidden_lexical_field"]]
]

tests = {
  "metadata" => { "title" => "Gate 4A compound architecture conformance cases", "architecture_version" => VERSION, "valid_cases" => valid.length, "invalid_cases" => invalid.length, "dictionary_entries_created" => 0 },
  "valid_cases" => valid.map { |name, value| { "case_id" => "G4A-V-#{name}", "definition" => value, "expected" => "valid" } },
  "invalid_cases" => invalid.map { |name, value, errors| { "case_id" => "G4A-I-#{name}", "definition" => value, "expected" => "invalid", "expected_errors" => errors } }
}

review = <<~MARKDOWN
  # Gate 4A Typed Compound Architecture

  Status: **CANONICAL ARCHITECTURE — COMPOUND DICTIONARY NOT STARTED**

  Gate 4A defines how canonical Era Zero atoms may be composed without approving any particular compound meaning. It preserves all 324 atomic meanings and all generated forms.

  ## Core decision

  A compound is a typed, connected, acyclic semantic graph with exactly one explicit semantic head. Root order is never allowed to stand in for machine meaning. `qualifies`, `fills_role`, and `member_of` are the only Gate 4A edge types.

  The source-grounded performance rule remains intact: describing material precedes its head with no gap, arguments use short-gap role binding, and only the semantic head normally carries the compound's external role contour. Runtime state, contour, register, tense, negation, quantity, and probability are occurrence-level or later-grammar data and are excluded from compound identity.

  ## Why this architecture is necessary

  A linear sequence such as three roots can be ambiguous about which root is the head, which root modifies which, and whether a root fills a source, target, material, or condition role. The explicit graph removes that ambiguity while still producing the accepted modifier-first performance order.

  ## Node and edge model

  - `root`: one canonical Era Zero atom.
  - `compound_ref`: a versioned reference to a future approved Gate 4B entry.
  - `slot`: a typed open argument in a reusable compound template.
  - `coordination`: an explicit `all_of`, `any_of`, or `exactly_one` group.
  - `qualifies`: descriptor → described node.
  - `fills_role`: argument → predicate or relationship head, with one typed role.
  - `member_of`: member → coordination group.

  ## Safety boundaries

  - No English word or gloss identifies a compound.
  - No compound may alter, merge, or override an atomic definition.
  - No runtime state or grammatical contour is stored in lexical compound identity.
  - Multiple independent assertions are not compounds; they belong in the later utterance IR.
  - Compound references must be versioned and acyclic.
  - Semantic changes require a new version and migration; approved entries are never silently rewritten.

  ## Gate boundary

  Gate 4B may now create and review high-frequency compound entries under this architecture. It must not begin English translation, executable grammar, or renderer implementation. Gate 4A itself creates **zero** dictionary entries.

  Machine-readable specifications:

  - `spec/compound_architecture_1.0.yaml`
  - `spec/compound_graph_schema.yaml`
  - `tests/gate4a_compound_cases.yaml`
MARKDOWN

FileUtils.mkdir_p(File.join(ROOT, "tests"))
EraZeroValidation.write("spec/compound_architecture_1.0.yaml", YAML.dump(architecture))
EraZeroValidation.write("spec/compound_graph_schema.yaml", YAML.dump(schema))
EraZeroValidation.write("tests/gate4a_compound_cases.yaml", YAML.dump(tests))
EraZeroValidation.write("reports/gate4a_compound_architecture.md", review)

puts "Built Gate 4A compound architecture #{VERSION}: #{valid.length} valid and #{invalid.length} invalid conformance cases; 0 dictionary entries."
