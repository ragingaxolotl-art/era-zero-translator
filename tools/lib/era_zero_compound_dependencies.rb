# frozen_string_literal: true

# Resolve lexical dependencies before expansion or release. This does not infer
# semantic equivalence from English labels, flatten graphs, or change identities.
module EraZeroCompoundDependencies
  class DependencyError < StandardError; end

  class Registry
    def initialize(entries)
      @entries = {}
      entries.each do |entry|
        key = [entry.fetch("compound_id"), entry.fetch("definition_version")]
        raise DependencyError, "duplicate compound version #{key.join('@')}" if @entries.key?(key)
        @entries[key] = entry
      end
    end

    def resolve(id, version)
      entry = @entries[[id, version]]
      raise DependencyError, "missing compound version #{id}@#{version}" unless entry
      unless entry["status"] == "approved"
        raise DependencyError, "compound version is not approved: #{id}@#{version}"
      end
      entry
    end

    def references(entry)
      entry.fetch("nodes").select { |node| node["kind"] == "compound_ref" }.map do |node|
        id = node["compound_id"]
        version = node["definition_version"]
        if !id.is_a?(String) || id.empty? || !version.is_a?(String) || version.empty?
          raise DependencyError, "compound reference requires an ID and explicit version"
        end
        [id, version]
      end.uniq.sort
    end

    # Dependencies precede every consumer; lexical IDs break independent ties.
    # Iterative traversal avoids a Ruby stack overflow for a deep input graph.
    def ordered
      state = {}
      result = []
      @entries.keys.sort.each do |start|
        next if state[start] == :done
        stack = [[start, false]]
        path = []
        until stack.empty?
          key, leaving = stack.pop
          if leaving
            path.pop
            state[key] = :done
            result << resolve(*key)
            next
          end
          next if state[key] == :done
          if state[key] == :visiting
            cycle = (path[path.index(key)..-1] + [key]).map { |item| item.join("@") }
            raise DependencyError, "compound dependency cycle: #{cycle.join(' -> ')}"
          end
          entry = resolve(*key)
          state[key] = :visiting
          path << key
          stack << [key, true]
          references(entry).reverse_each { |dependency| stack << [dependency, false] }
        end
      end
      result
    end

    def inventory
      depths = {}
      ordered.map do |entry|
        key = [entry.fetch("compound_id"), entry.fetch("definition_version")]
        dependencies = references(entry)
        depth = dependencies.empty? ? 0 : dependencies.map { |dep| depths.fetch(dep) }.max + 1
        depths[key] = depth
        {
          "compound_id" => key[0], "definition_version" => key[1],
          "title" => entry["display_title"], "depth" => depth,
          "dependencies" => dependencies.map { |id, version| { "compound_id" => id, "definition_version" => version } },
          "direct_roots" => entry.fetch("nodes").select { |n| n["kind"] == "root" }.map { |n| n.fetch("root_id") }.uniq.sort
        }
      end
    end
  end
end
