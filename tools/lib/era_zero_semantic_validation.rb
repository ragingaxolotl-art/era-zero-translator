# frozen_string_literal: true
require "json"
require "digest"
require "set"
require_relative "era_zero_validation"
require_relative "era_zero_names"
require_relative "era_zero_compound_expansion"

# Shared semantic validation for fixtures and sentence composition.
module EraZeroSemanticValidation
  module_function
  def reaches?(start, root, graph, seen = Set.new)
    return true if start == root
    return false if seen.include?(start)
    graph.fetch(start, []).any? { |n| reaches?(n, root, graph, seen | [start]) }
  end


  def canonical_decimal?(value)
    value.is_a?(String) && value.length <= 1024 && value != "-0" && value.match?(/\A-?(?:0|[1-9][0-9]*)(?:\.[0-9]*[1-9])?\z/)
  end

  def authority_documents
    paths = %w[spec/semantic_ir_1.0.yaml spec/semantic_ir_schema.yaml lexicon/atoms.yaml lexicon/compound_dictionary.yaml]
    signature = paths.map { |path| stat = File.stat(File.join(EraZeroValidation::ROOT, path)); [stat.mtime.to_f, stat.size] }
    if !@authority_documents || @authority_signature != signature
      @authority_documents = paths.map { |path| EraZeroValidation.load_yaml(path) }
      @authority_signature = signature
    end
    @authority_documents
  end

  def validate(ir, compound_entries: nil)
    return ["invalid_document"] unless ir.is_a?(Hash)
    return ["invalid_nodes"] unless ir["nodes"].is_a?(Array) && ir["nodes"].all? { |n| n.is_a?(Hash) && n["node_id"].is_a?(String) }
    return ["invalid_edges"] unless ir["edges"].is_a?(Array) && ir["edges"].all? { |e| e.is_a?(Hash) && e["edge_id"].is_a?(String) }
    return ["invalid_serialization"] if ir.key?("serialization") && !ir["serialization"].is_a?(Hash)
    return ["invalid_discourse_constraints"] if ir.key?("discourse_constraints") && !ir["discourse_constraints"].is_a?(Hash)
    spec, schema, atoms_doc, compounds_doc = authority_documents
    atom_ids = atoms_doc.fetch("atoms").map { |a| a["canonical_id"] }.to_set
    entries = compound_entries || compounds_doc.fetch("entries")
    compound_ids = entries.map { |c| c["compound_id"] }.to_set
    node_kinds = schema.fetch("node_kinds").to_set
    edge_types = schema.fetch("edge_types").to_set
    roles = schema.fetch("roles").to_set
    forbidden = schema.fetch("forbidden_semantic_fields").to_set
    units = spec.dig("quantity_and_measurement", "units").values.flatten.to_set
    errors = []
    binding_edges = []
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
      errors << "invalid_nominal_reference" if n.key?("reference_mode") && n["kind"] != "phonemic_reference"
      errors << "unknown_node_kind" unless node_kinds.include?(n["kind"])
      errors << "forbidden_surface_field" unless (n.keys.to_set & forbidden).empty?
      if n["kind"] == "lexical_occurrence"
        valid_target = n["target_type"] == "atom" ? atom_ids.include?(n["target_id"]) : n["target_type"] == "compound" && compound_ids.include?(n["target_id"])
        errors << "unknown_target" unless valid_target
        state = n["runtime_state"].is_a?(Hash) ? n["runtime_state"] : {}
        errors << "invalid_runtime_state" unless [0, 1, 2].include?(state["code"])
        errors << "invalid_runtime_parameter" if state.key?("num")
      elsif n["kind"] == "deictic_reference"
        role = n["deictic_role"]
        errors << "invalid_deictic_reference" unless %w[speaker addressee].include?(role) && n["referent_id"] == "discourse:#{role}" && n["value_type"] == "entity" && !n.key?("runtime_state")
      elsif n["kind"] == "phonemic_reference"
        errors << "invalid_phonemic_reference" unless n["value_type"] == "entity" && n["referent_id"].is_a?(String) && !n["referent_id"].empty? && !n.key?("runtime_state")
        begin
          raise EraZeroNames::NameError, "missing name" unless n["name"].is_a?(Hash)
          EraZeroNames.notes(n["name"])
          if n.key?("reference_mode")
            errors << "invalid_nominal_reference" unless n["reference_mode"] == "definite_nominal" && n["referent_id"] == "nominal:definite:#{n['name']['name_id']}" && n['name']['normalized_label'].match?(/\A[a-z]+\z/)
          end
        rescue EraZeroNames::NameError
          errors << "invalid_phonemic_name"
        end
      elsif n["kind"] == "time_anchor"
        errors << "invalid_time_anchor" unless spec.dig("node_types", "time_anchor", "anchor_types").include?(n["anchor_type"])
      elsif n["kind"] == "measurement"
        errors << "invalid_unit" unless units.include?(n["unit"])
        errors << "invalid_quantity" unless canonical_decimal?(n["magnitude"])
      elsif n["kind"] == "scope_operator" && n["operator"] == "quantifier"
        counted = %w[exact at_least at_most].include?(n["quantifier"])
        allowed = %w[node_id kind operator quantifier] + (counted ? ["value"] : [])
        valid = %w[exact at_least at_most all some none].include?(n["quantifier"]) && (n.keys - allowed).empty?
        valid &&= n["value"].is_a?(String) && n["value"].length <= 1024 && n["value"].match?(/\A(?:0|[1-9][0-9]*)\z/) if counted
        errors << "invalid_quantifier" unless valid
      elsif n["kind"] == "reference"
        declared = Array(ir.dig("discourse_constraints", "declared_referents"))
        errors << "unresolved_reference" unless declared.include?(n["referent_id"])
      end
    end
    nodes.select { |n| n.key?("compound_bindings") }.each do |n|
      unless n["kind"] == "lexical_occurrence" && n["target_type"] == "compound"
        errors << "bindings_on_noncompound"
        next
      end
      bindings = n["compound_bindings"]
      unless bindings.is_a?(Array) && bindings.all? { |b| b.is_a?(Hash) && b["slot_path"].is_a?(Array) && b["slot_path"].all? { |p| p.is_a?(String) } && b["argument_id"].is_a?(String) }
        errors << "invalid_compound_bindings"
        next
      end
      begin
        compound = entries.find { |entry| entry["compound_id"] == n["target_id"] }
        raise EraZeroCompoundExpansion::ExpansionError, "unknown compound" unless compound
        expander = EraZeroCompoundExpansion::Expander.new(entries)
        expanded = expander.expand(compound.fetch("compound_id"), compound.fetch("definition_version"))
        resolved = expander.bind_slots(expanded, bindings: bindings, arguments: map)
        resolved.each do |binding|
          errors << "unknown_role" unless roles.include?(binding["role"])
          binding_edges << [binding["argument_id"], n["node_id"]]
        end
      rescue EraZeroCompoundExpansion::ExpansionError, EraZeroCompoundDependencies::DependencyError, KeyError
        errors << "invalid_compound_bindings"
      end
    end
    # A binding participates in connectivity without inventing a second fills_role
    # edge that would erase the nested slot path. Binding cycles are never valid.
    binding_graph = ids.to_h { |id| [id, []] }
    binding_edges.each { |from, to| binding_graph[from] << to }
    binding_edges.each { |from, to| errors << "cyclic_compound_bindings" if reaches?(to, from, binding_graph) }
    nodes.select { |n| n["kind"] == "scope_operator" }.each do |n|
      errors << "unknown_scope_operator" unless spec.dig("node_types", "scope_operator", "operators").include?(n["operator"])
    end
    edges.each do |e|
      errors << "unknown_edge_type" unless edge_types.include?(e["type"])
      errors << "edge_endpoint_missing" unless map.key?(e["from"]) && map.key?(e["to"])
      if e["type"] == "time_relation"
        errors << "invalid_time_relation" unless map.dig(e["from"], "kind") == "time_anchor" && map.dig(e["to"], "kind") == "clause" && spec.dig("time_and_aspect", "relations").include?(e["relation"])
      end
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
        orders = members.map { |e| e["order"] }
        bad ||= !orders.all? { |order| order.is_a?(Integer) } || orders.sort != (1..members.length).to_a
      elsif n["operator"] == "parallel"
        bad ||= members.any? { |e| e.key?("order") }
      end
      errors << "invalid_coordination" if bad
    end
    graph = ids.to_h { |id| [id, []] }
    edges.each { |e| graph[e["from"]] << e["to"] if graph.key?(e["from"]) && graph.key?(e["to"]) }
    binding_edges.each { |from, to| graph[from] << to }
    errors << "disconnected_node" unless map[root] && ids.all? { |id| reaches?(id, root, graph) }
    payload = ir.slice("ir_version", "root_clause", "speech_act", "nodes", "edges", "discourse_constraints")
    digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
    errors << "invalid_identity" unless ir["utterance_id"] == "UTT:#{digest[0, 24]}" && ir.dig("serialization", "content_digest") == digest
    errors.uniq
  end

end
