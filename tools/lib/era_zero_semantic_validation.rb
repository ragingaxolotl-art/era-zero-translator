# frozen_string_literal: true
require "json"
require "digest"
require "set"
require_relative "era_zero_validation"
require_relative "era_zero_names"

# Shared semantic validation for fixtures and sentence composition.
module EraZeroSemanticValidation
  module_function
  def reaches?(start, root, graph, seen = Set.new)
    return true if start == root
    return false if seen.include?(start)
    graph.fetch(start, []).any? { |n| reaches?(n, root, graph, seen | [start]) }
  end


  def validate(ir)
    return ["invalid_document"] unless ir.is_a?(Hash)
    return ["invalid_nodes"] unless ir["nodes"].is_a?(Array) && ir["nodes"].all? { |n| n.is_a?(Hash) && n["node_id"].is_a?(String) }
    return ["invalid_edges"] unless ir["edges"].is_a?(Array) && ir["edges"].all? { |e| e.is_a?(Hash) && e["edge_id"].is_a?(String) }
    spec = EraZeroValidation.load_yaml("spec/semantic_ir_1.0.yaml")
    schema = EraZeroValidation.load_yaml("spec/semantic_ir_schema.yaml")
    atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
    compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
    atom_ids = atoms_doc.fetch("atoms").map { |a| a["canonical_id"] }.to_set
    compound_ids = compounds_doc.fetch("entries").map { |c| c["compound_id"] }.to_set
    node_kinds = schema.fetch("node_kinds").to_set
    edge_types = schema.fetch("edge_types").to_set
    roles = schema.fetch("roles").to_set
    forbidden = schema.fetch("forbidden_semantic_fields").to_set
    units = spec.dig("quantity_and_measurement", "units").values.flatten.to_set
    errors = []
    nodes = ir["nodes"].is_a?(Array) ? ir["nodes"] : []
    edges = ir["edges"].is_a?(Array) ? ir["edges"] : []
    ids = nodes.map { |n| n["node_id"] }
    root = ir["root_clause"]
    map = nodes.to_h { |n| [n["node_id"], n] }
    errors << "missing_required_field" unless schema["required_document_fields"].all? { |f| ir.key?(f) }
    errors << "invalid_root_clause" unless map[root] && map[root]["kind"] == "clause"
    errors << "duplicate_node" unless ids.uniq.length == ids.length
    errors << "duplicate_edge" unless edges.map { |e| e["edge_id"] }.uniq.length == edges.length
    nodes.each do |n|
      errors << "unknown_node_kind" unless node_kinds.include?(n["kind"])
      errors << "forbidden_surface_field" unless (n.keys.to_set & forbidden).empty?
      if n["kind"] == "lexical_occurrence"
        valid_target = n["target_type"] == "atom" ? atom_ids.include?(n["target_id"]) : n["target_type"] == "compound" && compound_ids.include?(n["target_id"])
        errors << "unknown_target" unless valid_target
        state = n["runtime_state"] || {}
        errors << "invalid_runtime_state" unless [0, 1, 2].include?(state["code"])
        errors << "invalid_runtime_parameter" if state.key?("num")
      elsif n["kind"] == "phonemic_reference"
        errors << "invalid_phonemic_reference" unless n["value_type"] == "entity" && n["referent_id"].is_a?(String) && !n["referent_id"].empty? && !n.key?("runtime_state")
        begin
          raise EraZeroNames::NameError, "missing name" unless n["name"].is_a?(Hash)
          EraZeroNames.notes(n["name"])
        rescue EraZeroNames::NameError
          errors << "invalid_phonemic_name"
        end
      elsif n["kind"] == "measurement"
        errors << "invalid_unit" unless units.include?(n["unit"])
        errors << "invalid_quantity" unless n["magnitude"].to_s.match?(/\A-?(?:0|[1-9]\d*)(?:\.\d+)?\z/)
      elsif n["kind"] == "reference"
        declared = Array(ir.dig("discourse_constraints", "declared_referents"))
        errors << "unresolved_reference" unless declared.include?(n["referent_id"])
      end
    end
    nodes.select { |n| n["kind"] == "scope_operator" }.each do |n|
      errors << "unknown_scope_operator" unless spec.dig("node_types", "scope_operator", "operators").include?(n["operator"])
    end
    edges.each do |e|
      errors << "unknown_edge_type" unless edge_types.include?(e["type"])
      errors << "edge_endpoint_missing" unless map.key?(e["from"]) && map.key?(e["to"])
      errors << "unknown_role" if e["type"] == "fills_role" && !roles.include?(e["role"])
    end
    nodes.select { |n| n["kind"] == "clause" }.each do |n|
      errors << "clause_center_cardinality" unless edges.count { |e| e["type"] == "centers" && e["to"] == n["node_id"] } == 1
      if n["clause_type"] == "transition"
        errors << "invalid_transition" unless edges.count { |e| e["type"] == "before_state" && e["to"] == n["node_id"] } == 1 && edges.count { |e| e["type"] == "after_state" && e["to"] == n["node_id"] } == 1
      end
    end
    nodes.select { |n| n["kind"] == "scope_operator" }.each { |n| errors << "scope_cardinality" unless edges.count { |e| e["type"] == "scopes" && e["to"] == n["node_id"] } == 1 }
    nodes.select { |n| n["kind"] == "coordination" }.each do |n|
      members = edges.select { |e| e["type"] == "member_of" && e["to"] == n["node_id"] }
      bad = members.length < 2
      if n["operator"] == "sequence"
        bad ||= members.map { |e| e["order"] }.sort != (1..members.length).to_a
      elsif n["operator"] == "parallel"
        bad ||= members.any? { |e| e.key?("order") }
      end
      errors << "invalid_coordination" if bad
    end
    graph = ids.to_h { |id| [id, []] }
    edges.each { |e| graph[e["from"]] << e["to"] if graph.key?(e["from"]) && graph.key?(e["to"]) }
    errors << "disconnected_node" unless map[root] && ids.all? { |id| reaches?(id, root, graph) }
    payload = ir.slice("ir_version", "root_clause", "speech_act", "nodes", "edges", "discourse_constraints")
    digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
    errors << "invalid_identity" unless ir["utterance_id"] == "UTT:#{digest[0, 24]}" && ir.dig("serialization", "content_digest") == digest
    errors.uniq
  end

end
