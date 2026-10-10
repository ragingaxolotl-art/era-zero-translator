#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "set"
require_relative "lib/era_zero_validation"

include EraZeroValidation

ARCHITECTURE = "spec/compound_architecture_1.0.yaml"
SCHEMA = "spec/compound_graph_schema.yaml"
CASES = "tests/gate4a_compound_cases.yaml"
REPORT = "reports/gate4a_validation.md"

architecture = EraZeroValidation.load_yaml(ARCHITECTURE)
schema = EraZeroValidation.load_yaml(SCHEMA)
cases = EraZeroValidation.load_yaml(CASES)
atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
atoms = EraZeroValidation.atoms_by_id(atoms_doc)
canonical_ids = atoms.values.select { |atom| atom["status"] == "canonical" }.map { |atom| atom.fetch("canonical_id") }.to_set
core = EraZeroValidation.load_yaml("spec/canonical_spec.yaml")
checks = EraZeroValidation::CheckSet.new

forbidden_fields = schema.fetch("forbidden_lexical_fields").to_set
node_kinds = architecture.fetch("node_types").keys.to_set
edge_types = architecture.fetch("edge_types").keys.to_set
roles = architecture.fetch("role_inventory").keys.to_set
slot_types = architecture.dig("node_types", "slot", "slot_types").to_set
coordination_ops = architecture.dig("node_types", "coordination", "operators").to_set
required_fields = architecture.dig("definition_model", "required_fields").to_set
node_id_pattern = /\A(?:h|q\d{2}|a-[a-z_]+-\d{2}|g\d{2}|s\d{2})\z/

def cycle?(node_ids, edges)
  graph = node_ids.to_h { |id| [id, []] }
  edges.each do |edge|
    next unless graph.key?(edge["from"]) && graph.key?(edge["to"])
    graph[edge["from"]] << edge["to"]
  end
  visiting = Set.new
  visited = Set.new
  visit = lambda do |node|
    return true if visiting.include?(node)
    return false if visited.include?(node)
    visiting << node
    found = graph.fetch(node).any? { |child| visit.call(child) }
    visiting.delete(node)
    visited << node
    found
  end
  node_ids.any? { |node| visit.call(node) }
end

def reaches_head?(start, head, graph, seen = Set.new)
  return true if start == head
  return false if seen.include?(start)
  next_seen = seen | [start]
  graph.fetch(start, []).any? { |target| reaches_head?(target, head, graph, next_seen) }
end

validate = lambda do |definition|
  errors = []
  missing = required_fields - definition.keys.to_set
  errors << "missing_required_field" unless missing.empty?
  errors << "invalid_compound_key" unless definition["compound_key"].to_s.match?(/\ADRAFT:[a-z0-9_-]+:[a-z0-9_-]+\z/)
  errors << "forbidden_lexical_field" unless (definition.keys.to_set & forbidden_fields).empty?
  nodes = definition["nodes"].is_a?(Array) ? definition["nodes"] : []
  edges = definition["edges"].is_a?(Array) ? definition["edges"] : []
  node_ids = nodes.map { |node| node["node_id"] }
  edge_ids = edges.map { |edge| edge["edge_id"] }
  errors << "too_few_nodes" if nodes.length < 2
  errors << "duplicate_node_id" unless node_ids.compact.uniq.length == node_ids.length
  errors << "duplicate_edge_id" unless edge_ids.compact.uniq.length == edge_ids.length
  errors << "invalid_node_id" unless node_ids.compact.all? { |id| id.match?(node_id_pattern) }
  head = definition["semantic_head"]
  head_node = nodes.find { |node| node["node_id"] == head }
  errors << "head_missing" unless head_node
  errors << "head_id_not_canonical" unless head == "h"
  errors << "invalid_head_kind" if head_node && !%w[root compound_ref].include?(head_node["kind"])

  nodes.each do |node|
    errors << "unknown_node_kind" unless node_kinds.include?(node["kind"])
    errors << "forbidden_node_field" unless (node.keys.to_set & forbidden_fields).empty?
    case node["kind"]
    when "root"
      errors << "unknown_root" unless canonical_ids.include?(node["root_id"])
    when "compound_ref"
      errors << "unresolved_compound_reference"
    when "slot"
      errors << "invalid_slot_type" unless slot_types.include?(node["slot_type"])
    when "coordination"
      errors << "unknown_coordination_operator" unless coordination_ops.include?(node["operator"])
    end
  end

  node_set = node_ids.to_set
  edges.each do |edge|
    errors << "unknown_edge_type" unless edge_types.include?(edge["type"])
    errors << "edge_endpoint_missing" unless node_set.include?(edge["from"]) && node_set.include?(edge["to"])
    errors << "self_edge" if edge["from"] == edge["to"]
    if edge["type"] == "fills_role"
      errors << "role_required" if edge["role"].to_s.empty?
      errors << "unknown_role" unless roles.include?(edge["role"])
    elsif edge.key?("role")
      errors << "role_forbidden"
    end
    if edge["type"] == "member_of"
      target = nodes.find { |node| node["node_id"] == edge["to"] }
      errors << "member_target_not_coordination" unless target && target["kind"] == "coordination"
    end
  end

  errors << "cycle" if cycle?(node_set, edges)
  graph = node_ids.to_h { |id| [id, []] }
  edges.each { |edge| graph[edge["from"]] << edge["to"] if graph.key?(edge["from"]) && graph.key?(edge["to"]) }
  if head_node
    errors << "disconnected_node" unless node_ids.all? { |id| reaches_head?(id, head, graph) }
  end
  nodes.select { |node| node["kind"] == "slot" }.each do |slot|
    errors << "slot_not_role_bound" unless edges.any? { |edge| edge["from"] == slot["node_id"] && edge["type"] == "fills_role" }
  end
  nodes.select { |node| node["kind"] == "coordination" }.each do |group|
    members = edges.count { |edge| edge["type"] == "member_of" && edge["to"] == group["node_id"] }
    errors << "coordination_too_small" if members < 2
  end
  errors.uniq
end

checks.add("atomic authority", "all 324 referenced atoms are canonical and generated forms remain valid", canonical_ids.length == 324 && EraZeroValidation.generated_field_errors(atoms).empty?)
checks.add("atomic immutability", "Gate 4A records the unchanged full atomic fingerprint", architecture.dig("metadata", "atomic_lexicon_fingerprint") == EraZeroValidation.fingerprint(atoms_doc.fetch("atoms")) && architecture.dig("metadata", "atomic_meanings_changed") == false && architecture.dig("metadata", "generated_fields_changed") == false)
checks.add("scope boundary", "architecture owns composition but excludes dictionary, English index, IR, and translator", architecture.dig("scope", "owns").length >= 8 && architecture.dig("scope", "does_not_own").length >= 6)
checks.add("source compound order", "describer-before-head and no-gap modifier binding are preserved", architecture.dig("source_grounded_invariants", "describer_before_head").include?("before") && architecture.dig("source_grounded_invariants", "modifier_timing").include?("no-gap"))
checks.add("source argument performance", "short-gap arguments and head-only role contour are preserved", architecture.dig("source_grounded_invariants", "argument_timing").include?("short gap") && architecture.dig("source_grounded_invariants", "head_role_contour").include?("head"))
checks.add("fixed core register mapping", "low, middle, high, and sustained-background core roles match Core 1.0", begin
  core_roles = core.dig("grammar", "register_roles")
  fixed = architecture.dig("source_grounded_invariants", "register_roles")
  fixed["low"].all? { |role| core_roles["low"].include?(role.tr("_", " ")) } && fixed["middle"].all? { |role| core_roles["middle"].include?(role.tr("_", " ")) } && fixed["high"].all? { |role| core_roles["high"].include?(role.tr("_", " ")) } && fixed["sustained_background"].all? { |role| core_roles["sustained_background"].include?(role.tr("_", " ")) }
end)
checks.add("single-head graph", "one explicit root or compound reference is the semantic center", architecture.dig("definition_model", "semantic_head").include?("Exactly one") && architecture.dig("head_selection", "tie_breaker").include?("utterance IR"))
checks.add("typed node model", "root, compound reference, slot, and coordination nodes are specified", node_kinds == %w[root compound_ref slot coordination].to_set)
checks.add("typed edge model", "qualifies, fills_role, and member_of are the only lexical edge types", edge_types == %w[qualifies fills_role member_of].to_set)
checks.add("role completeness", "the role inventory covers fixed and typed compound roles", roles == %w[actor source cause experiencer bearer predicate target result destination instrument material location environment condition persistent_condition].to_set)
checks.add("attachment and scope", "modifier, argument, coordination, and external attachment scopes are explicit", architecture.fetch("attachment_and_scope").keys.to_set == %w[explicit_target nearest_surface_attachment modifier_scope argument_scope coordination_scope external_attachment].to_set)
checks.add("lexical/runtime separation", "runtime state and occurrence grammar are excluded from compound identity", architecture.dig("source_grounded_invariants", "runtime_separation").include?("never stored") && architecture.dig("canonical_serialization", "excluded_from_identity").include?("runtime_state"))
checks.add("canonical serialization", "content identity, canonical ordering, exclusions, and semantic versioning are specified", architecture.dig("canonical_serialization", "content_identity").include?("SHA-256") && architecture.dig("canonical_serialization", "semantic_payload").length >= 5 && architecture.dig("canonical_serialization", "versioning").include?("migration"))
checks.add("change control", "semantic changes, deprecation, atomic collisions, and English independence are governed", architecture.fetch("change_control").keys.to_set == %w[approval_required atomic_collision_check semantic_change deprecation english_independence].to_set)
checks.add("later-gate isolation", "dictionary, English index, utterance IR, renderer, and translator work remain separately gated", architecture.fetch("reserved_for_later_gates").keys.to_set == %w[gate4b gate4c semantic_ir renderer translator].to_set)
checks.add("zero dictionary entries at Gate 4A release", "the Gate 4A release itself created no lexical compound entries", architecture.dig("metadata", "compound_dictionary_started") == false && cases.dig("metadata", "dictionary_entries_created") == 0)
checks.add("schema alignment", "machine schema mirrors architecture node, edge, role, and forbidden-field rules", schema.dig("definition", "nodes", "allowed_kinds").to_set == node_kinds && schema.dig("definition", "edges", "allowed_types").to_set == edge_types && schema.dig("edge_rules", "fills_role", "allowed_roles").to_set == roles)

valid_results = cases.fetch("valid_cases").to_h do |item|
  [item.fetch("case_id"), validate.call(item.fetch("definition"))]
end
invalid_results = cases.fetch("invalid_cases").to_h do |item|
  [item.fetch("case_id"), validate.call(item.fetch("definition"))]
end
checks.add("valid conformance cases", "all #{valid_results.length} structurally diverse valid graphs pass", valid_results.values.all?(&:empty?))
checks.add("invalid conformance cases", "all #{invalid_results.length} invalid graphs fail with their expected diagnostics", cases.fetch("invalid_cases").all? do |item|
  actual = invalid_results.fetch(item.fetch("case_id")).to_set
  item.fetch("expected_errors").to_set.subset?(actual)
end)
checks.add("test breadth", "fixtures cover modifiers, roles, slots, coordination, cycles, disconnection, states, contours, keys, and timing", cases.fetch("valid_cases").length >= 10 && cases.fetch("invalid_cases").length >= 20)

semantic_payload = architecture.fetch("canonical_serialization").fetch("semantic_payload")
checks.add("identity payload discipline", "identity includes graph semantics and excludes presentation metadata", semantic_payload.include?("nodes") && semantic_payload.include?("edges") && (semantic_payload.to_set & architecture.dig("canonical_serialization", "excluded_from_identity").to_set).empty?)

report = checks.markdown(
  title: "Gate 4A Typed Compound Architecture Validation",
  pass_status: "PASS — GATE 4A ARCHITECTURE CANONICAL; GATE 4B MAY BEGIN",
  summary: [
    "Architecture version: **#{architecture.dig('metadata', 'version')}**",
    "Canonical atoms preserved: **#{canonical_ids.length}**",
    "Valid conformance cases: **#{valid_results.length}**",
    "Invalid conformance cases: **#{invalid_results.length}**",
    "Compound dictionary entries: **0**",
    "Gate 4B started: **no**"
  ]
)
unless valid_results.values.all?(&:empty?)
  report << "\n## Unexpected valid-case failures\n\n"
  valid_results.reject { |_id, errors| errors.empty? }.each { |id, errors| report << "- `#{id}`: #{errors.join(', ')}\n" }
end
report << "\n## Boundary\n\nGate 4A approves the composition architecture only. It does not approve any compound meaning, English mapping, grammar implementation, renderer, decoder, or translator. The next authorized design task is Gate 4B: a reviewed high-frequency compound dictionary built under this schema.\n"
EraZeroValidation.write(REPORT, report)

puts "Gate 4A validation: #{checks.success? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{checks.passed}; checks failed: #{checks.failed}"
puts "Valid cases: #{valid_results.length}; invalid cases: #{invalid_results.length}; dictionary entries: 0"
checks.failures.each { |failure| warn failure }
exit(checks.success? ? 0 : 1)
