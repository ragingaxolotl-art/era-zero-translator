# frozen_string_literal: true
require_relative "era_zero_compound_dependencies"
require_relative "era_zero_compound_binding_constraints"
require "json"
require "digest"

module EraZeroCompoundExpansion
  class ExpansionError < StandardError; end

  # Produces occurrence-scoped graph data without changing dictionary identities.
  # Scope records retain compound boundaries and local constraints: an attachment
  # to a compound reference targets that scope, not every descendant indiscriminately.
  class Expander
    def initialize(entries, max_nodes: 10_000, max_depth: 64)
      @registry = EraZeroCompoundDependencies::Registry.new(entries)
      @max_nodes, @max_depth = max_nodes, max_depth
      unless max_nodes.is_a?(Integer) && max_nodes.positive? && max_depth.is_a?(Integer) && max_depth.positive?
        raise ArgumentError, "expansion limits must be positive integers"
      end
    end

    def expand(id, version)
      output = { "nodes" => [], "edges" => [], "scopes" => [] }
      output["semantic_head"] = visit(id, version, [], [], output)
      constraints=EraZeroCompoundBindingConstraints.expand(output["scopes"],output["nodes"])
      output["binding_constraints"]=constraints unless constraints.empty?
      output
    rescue EraZeroCompoundDependencies::DependencyError, EraZeroCompoundBindingConstraints::ConstraintError, KeyError => error
      raise ExpansionError, error.message
    end

    # Traverse references as units, so modifiers of a referenced compound precede
    # that complete unit instead of being inserted at its flattened final root.
    def ordered_roots(expanded, include_slots: false)
      scopes = expanded.fetch("scopes").to_h { |scope| [scope.fetch("path"), scope] }
      nodes = expanded.fetch("nodes").to_h { |node| [node.fetch("path"), node] }
      edges = expanded.fetch("edges").group_by { |edge| edge.fetch("to_scope_target") }
      hashes = {}
      subtree_hash = nil
      subtree_hash = lambda do |path|
        hashes[path] ||= begin
          incoming = edges.fetch(path, []).map do |edge|
            [edge.fetch("type"), edge["role"], subtree_hash.call(edge.fetch("from_scope_target"))]
          end.sort_by { |value| JSON.generate(value) }
          meaning = if scopes.key?(path)
                      scope = scopes.fetch(path)
                      local_head = scope.fetch("semantic_head").take(path.length + 1)
                      ["compound", scope.fetch("lexical_constraints"), subtree_hash.call(local_head)] + (scope.key?("conventional_meaning") ? [scope.fetch("conventional_meaning").sort.to_h] : [])
                    else
                      node = nodes.fetch(path)
                      # Internal identifiers are not semantic ordering keys.
                      node.reject { |key, _| %w[node_id path scope_path slot_name].include?(key) }.sort.to_h
                    end
          Digest::SHA256.hexdigest(JSON.generate([meaning, incoming]))
        end
      end
      result = []
      scope_contexts = {}
      walk = nil
      walk = lambda do |path, role, qualified_slots|
        scope_contexts[path] = qualified_slots if scopes.key?(path)
        incoming = edges.fetch(path, [])
        incoming.sort_by { |edge| [edge.fetch("type"), edge.fetch("role", ""), subtree_hash.call(edge.fetch("from_scope_target"))] }.each do |edge|
          qualifier_slots = qualified_slots
          if edge["type"] == "qualifies" && nodes[path] && nodes[path]["kind"] == "slot"
            qualifier_slots = qualified_slots + [path]
          end
          before = result.length
          walk.call(edge.fetch("from_scope_target"), edge["role"] || role, qualifier_slots)
          result.last["boundary_after_beats"] = 0 if edge["type"] == "qualifies" && result.length > before
        end
        if scopes.key?(path)
          scope = scopes.fetch(path)
          # The original local head can itself be a reference.
          local_head_path = scope.fetch("semantic_head").take(path.length + 1)
          walk.call(local_head_path, role, qualified_slots)
        else
          node = nodes.fetch(path)
          node = node.merge("qualified_slot_paths" => qualified_slots) unless qualified_slots.empty?
          contexts = scope_contexts.select { |scope, slots| !slots.empty? && path.take(scope.length) == scope }.map { |scope, slots| { "scope_path" => scope, "qualified_slot_paths" => slots } }
          node = node.merge("convention_slot_contexts" => contexts) unless contexts.empty?
          if node["kind"] == "root"
            result << node.merge("component_role" => role, "external_head" => path == expanded.fetch("semantic_head"))
          elsif node["kind"] == "slot"
            result << node.merge("component_role" => role, "external_head" => false) if include_slots
          elsif node["kind"] != "coordination"
            raise ExpansionError, "unsupported expanded node kind"
          end
        end
      end
      walk.call([], nil, [])
      result
    end

    # Bind by occurrence path, never by the display name of a slot. Argument
    # value types must come from semantic interpretation, not guessed noun text.
    # Returns bindings without mutating dictionary or expanded graph data.
    def bind_slots(expanded, bindings:, arguments:)
      slots = expanded.fetch("nodes").select { |node| node["kind"] == "slot" }.to_h { |node| [node.fetch("path"), node] }
      resolved = {}
      bindings.each do |binding|
        path = binding.fetch("slot_path")
        slot = slots[path] or raise ExpansionError, "unknown compound slot path #{path.inspect}"
        raise ExpansionError, "duplicate binding for compound slot #{path.inspect}" if resolved.key?(path)
        argument_id = binding.fetch("argument_id")
        argument = arguments[argument_id] or raise ExpansionError, "unknown argument #{argument_id}"
        unless argument["value_type"] == slot.fetch("slot_type")
          raise ExpansionError, "slot #{path.inspect} requires #{slot['slot_type']}, received #{argument['value_type'].inspect}"
        end
        edges = expanded.fetch("edges").select { |edge| edge["from_path"] == path }
        unless edges.length == 1 && edges.first["type"] == "fills_role" && edges.first["role"].is_a?(String)
          raise ExpansionError, "compound slot must fill exactly one explicit role"
        end
        edge = edges.first
        if binding.key?("role") && binding["role"] != edge["role"]
          raise ExpansionError, "binding role does not match the declared slot role"
        end
        resolved[path] = {
          "slot_path" => path.dup, "argument_id" => argument_id,
          "value_type" => argument.fetch("value_type"), "role" => edge.fetch("role"),
          "predicate_path" => edge.fetch("to_path").dup,
          "predicate_scope_target" => edge.fetch("to_scope_target").dup
        }
      end
      missing = slots.keys - resolved.keys
      raise ExpansionError, "unbound compound slots: #{missing.inspect}" unless missing.empty?
      EraZeroCompoundBindingConstraints.validate_bindings!(expanded.fetch("binding_constraints",[]),resolved.values,arguments)
      resolved.values.sort_by { |binding| JSON.generate(binding.fetch("slot_path")) }
    rescue EraZeroCompoundBindingConstraints::ConstraintError => error
      raise ExpansionError, error.message
    rescue KeyError => error
      raise ExpansionError, "incomplete compound binding: #{error.message}"
    end

    private

    # Array paths avoid collisions when a local node ID contains '/' or '.'.
    def visit(id, version, path, ancestors, output)
      key = [id, version]
      raise ExpansionError, "compound dependency cycle at #{id}@#{version}" if ancestors.include?(key)
      raise ExpansionError, "compound expansion exceeds depth limit #{@max_depth}" if ancestors.length >= @max_depth
      entry = @registry.resolve(id, version)
      nodes = entry.fetch("nodes")
      edges = entry.fetch("edges")
      validate_graph!(entry, nodes, edges)
      @registry.references(entry) # Require explicit pins before traversing references.
      head_paths = {}
      nodes.each do |node|
        node_path = path + [node.fetch("node_id")]
        if node["kind"] == "compound_ref"
          head_paths[node["node_id"]] = visit(node.fetch("compound_id"), node.fetch("definition_version"), node_path, ancestors + [key], output)
        else
          raise ExpansionError, "compound expansion exceeds node limit #{@max_nodes}" if output["nodes"].length >= @max_nodes
          output["nodes"] << Marshal.load(Marshal.dump(node)).merge("path" => node_path, "scope_path" => path)
          head_paths[node["node_id"]] = node_path
        end
      end
      edges.each do |edge|
        # Keep original scope endpoints as well as resolved lexical endpoints.
        output["edges"] << Marshal.load(Marshal.dump(edge)).merge(
          "scope_path" => path, "from_path" => head_paths.fetch(edge.fetch("from")),
          "to_path" => head_paths.fetch(edge.fetch("to")),
          "from_scope_target" => path + [edge.fetch("from")],
          "to_scope_target" => path + [edge.fetch("to")]
        )
      end
      head = head_paths.fetch(entry.fetch("semantic_head"))
      output["scopes"] << {
        "path" => path, "compound_id" => id, "definition_version" => version,
        "semantic_head" => head,
        "lexical_constraints" => Marshal.load(Marshal.dump(entry.fetch("lexical_constraints", [])))
      }
      if entry.key?("conventional_meaning")
        output["scopes"].last["conventional_meaning"] = Marshal.load(Marshal.dump(entry.fetch("conventional_meaning")))
      end
      if entry.key?("binding_constraints")
        output["scopes"].last["binding_constraints"]=Marshal.load(Marshal.dump(entry["binding_constraints"]))
      end
      head
    end

    def validate_graph!(entry, nodes, edges)
      ids = nodes.map { |node| node.fetch("node_id") }
      unless ids.all? { |id| id.is_a?(String) && !id.empty? } && ids.uniq.length == ids.length
        raise ExpansionError, "compound nodes require unique nonempty IDs"
      end
      head = entry.fetch("semantic_head")
      head_node = nodes.find { |node| node["node_id"] == head }
      unless head_node && %w[root compound_ref].include?(head_node["kind"])
        raise ExpansionError, "semantic head must be a root or compound reference"
      end
      unless nodes.all? { |node| %w[root compound_ref slot coordination].include?(node["kind"]) }
        raise ExpansionError, "unknown compound node kind"
      end
      outgoing = ids.to_h { |id| [id, []] }
      edges.each do |edge|
        unless ids.include?(edge["from"]) && ids.include?(edge["to"])
          raise ExpansionError, "compound edge has an unknown endpoint"
        end
        raise ExpansionError, "unknown compound edge type" unless %w[qualifies fills_role member_of].include?(edge["type"])
        outgoing.fetch(edge["from"]) << edge["to"]
      end
      # Topological elimination simultaneously detects disconnected components
      # and cycles: in a valid connected DAG only the head can be a sink.
      sinks = outgoing.select { |_, targets| targets.empty? }.keys
      raise ExpansionError, "every compound node must reach its semantic head" unless sinks == [head]
      remaining = outgoing.transform_values(&:dup)
      until remaining.empty?
        ready = remaining.select { |_, targets| targets.empty? }.keys
        raise ExpansionError, "compound graph contains a cycle" if ready.empty?
        ready.each { |id| remaining.delete(id) }
        remaining.each_value { |targets| targets.reject! { |target| ready.include?(target) } }
      end
    end
  end
end
