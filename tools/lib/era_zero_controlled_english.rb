#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "set"
require_relative "era_zero_validation"
require_relative "era_zero_renderer"
require_relative "era_zero_compound_role_binding"

module EraZeroControlledEnglish
  ROOT = EraZeroValidation::ROOT
  VERSION = "1.0.0"
  ACTS = { "ASSERT" => "assertion", "QUESTION" => "question", "COMMAND" => "command", "DEFINE" => "definition", "POSSIBILITY" => "possibility" }.freeze
  MODES = %w[possible necessary permitted obligated intended predicted counterfactual].freeze
  ASPECTS = %w[bounded ongoing habitual iterative perfect prospective].freeze
  TIME_RELATIONS = %w[before at after during starts ends overlaps].freeze
  ROLES = %w[actor source cause experiencer bearer predicate target result destination instrument material content recipient location environment condition persistent_condition time manner quantity comparison_standard beneficiary].freeze
  UNITS = %w[1 second minute hour day meter kilometer gram kilogram degree radian bit byte].freeze

  class CompileError < StandardError
    attr_reader :code, :details

    def initialize(code, message, details = {})
      super(message)
      @code = code
      @details = details
    end

    def to_h(input)
      { "status" => "error", "error" => { "code" => code, "message" => message, "input" => input, "details" => details } }
    end
  end

  class Compiler
    def initialize
      senses = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses")
      @all_senses = senses.group_by { |sense| normalize(sense.fetch("lemma")) }
      allowed = senses.select { |sense| sense["controlled_input_allowed"] == true && %w[atom compound].include?(sense["route"]) }
      @allowed = allowed.group_by { |sense| normalize(sense.fetch("lemma")) }
      @compounds = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries").to_h { |compound| [compound.fetch("compound_id"), compound] }
    end

    def compile(input)
      text = input.to_s.strip
      raise CompileError.new("empty_input", "Controlled English input is empty.") if text.empty?
      raise CompileError.new("missing_terminal_period", "Controlled English statements must end with one period.") unless text.end_with?(".")
      body = text[0...-1].strip
      act_token, rest = body.split(/\s+/, 2)
      speech_act = ACTS[act_token]
      raise CompileError.new("unsupported_speech_act", "Expected ASSERT, QUESTION, COMMAND, DEFINE, or POSSIBILITY.", { "token" => act_token }) unless speech_act
      raise CompileError.new("missing_clause", "The speech-act keyword must be followed by a controlled clause.") unless rest

      ir = if rest.start_with?("SEQUENCE ")
             compile_coordination(rest.delete_prefix("SEQUENCE "), speech_act, "sequence", "THEN")
           elsif rest.start_with?("PARALLEL ")
             compile_coordination(rest.delete_prefix("PARALLEL "), speech_act, "parallel", "AND")
           elsif rest.start_with?("REPEAT ")
             compile_repetition(rest.delete_prefix("REPEAT "), speech_act)
           elsif rest.start_with?("IF ")
             compile_conditional(rest.delete_prefix("IF "), speech_act)
           else
             compile_simple(rest, speech_act)
           end
      { "status" => "ok", "compiler_version" => VERSION, "normalized_input" => text, "semantic_ir" => ir }
    rescue CompileError => error
      error.to_h(input.to_s)
    end

    def compile!(input)
      result = compile(input)
      return result.fetch("semantic_ir") if result["status"] == "ok"
      error = result.fetch("error")
      raise CompileError.new(error.fetch("code"), error.fetch("message"), error.fetch("details"))
    end

    private

    def normalize(value)
      value.to_s.unicode_normalize(:nfc).downcase.gsub(/\s+/, " ").strip
    end

    def resolve(label)
      key = normalize(label)
      candidates = @allowed.fetch(key, [])
      if candidates.length > 1
        raise CompileError.new("ambiguous_lexeme", "The label has more than one controlled sense.", { "label" => label, "sense_ids" => candidates.map { |sense| sense["sense_id"] }.sort })
      end
      return candidates.first if candidates.length == 1
      known = @all_senses.fetch(key, [])
      if known.any?
        raise CompileError.new("unsupported_sense_route", "The label exists but is not an approved controlled atom or compound label.", { "label" => label, "routes" => known.map { |sense| sense["route"] }.uniq.sort })
      end
      raise CompileError.new("unknown_lexeme", "The quoted label is not in the controlled lexicon.", { "label" => label })
    end

    def parse_lexical_prefix(text)
      match = /\A"([^"]+)"\s*\[([^\]]+)\]/.match(text)
      raise CompileError.new("invalid_lexical_form", "Expected a quoted controlled label followed by runtime [0], [1], or [2].") unless match
      raw_state = match[2]
      raise CompileError.new("invalid_runtime_state", "Runtime state must be 0, 1, or 2; num is the name of state 2, not input syntax.", { "state" => raw_state }) unless %w[0 1 2].include?(raw_state)
      sense = resolve(match[1])
      [{ "label" => match[1], "target_type" => sense.fetch("route"), "target_id" => sense.fetch("target_id"), "runtime_state" => raw_state.to_i }, text[match.end(0)..].to_s]
    end

    def lexical_node(id, lexical)
      { "node_id" => id, "kind" => "lexical_occurrence", "target_type" => lexical.fetch("target_type"), "target_id" => lexical.fetch("target_id"), "runtime_state" => { "code" => lexical.fetch("runtime_state") } }
    end

    def node_id(number)
      format("n%03d", number)
    end

    def edge_id(number)
      format("e%03d", number)
    end

    def finalize(nodes, edges, speech_act, root = "n001")
      begin
        EraZeroCompoundRoleBinding.bind_unique_roles!(nodes, edges, @compounds)
      rescue ArgumentError => error
        raise CompileError.new("ambiguous_compound_binding", error.message)
      end
      nodes = nodes.sort_by { |node| node.fetch("node_id") }
      edges = edges.sort_by { |edge| edge.fetch("edge_id") }
      payload = { "ir_version" => "1.0", "root_clause" => root, "speech_act" => speech_act, "nodes" => nodes, "edges" => edges, "discourse_constraints" => {} }
      digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
      payload.merge("utterance_id" => "UTT:#{digest[0, 24]}", "serialization" => { "canonical_format" => "EZIR-JSON-1", "content_digest" => digest })
    end

    def required_roles(lexical)
      return [] unless lexical["target_type"] == "compound"
      EraZeroRenderer.required_compound_roles(@compounds.fetch(lexical.fetch("target_id")), compounds: @compounds)
    end

    def compile_simple(text, speech_act)
      prefix = { "negation" => false, "modality" => nil, "aspect" => nil }
      if text.start_with?("NOT ")
        prefix["negation"] = true
        text = text.delete_prefix("NOT ")
      end
      if (match = /\AMODAL\s+(\S+)\s+/.match(text))
        mode = match[1]
        raise CompileError.new("invalid_modality", "Unknown controlled modality.", { "mode" => mode, "allowed" => MODES }) unless MODES.include?(mode)
        prefix["modality"] = mode
        text = text[match.end(0)..]
      end
      if (match = /\AASPECT\s+(\S+)\s+/.match(text))
        aspect = match[1]
        raise CompileError.new("invalid_aspect", "Unknown controlled aspect.", { "aspect" => aspect, "allowed" => ASPECTS }) unless ASPECTS.include?(aspect)
        prefix["aspect"] = aspect
        text = text[match.end(0)..]
      end
      head, rest = parse_lexical_prefix(text)
      nodes = [{ "node_id" => "n001", "kind" => "clause", "clause_type" => speech_act == "definition" ? "definition" : "predication" }, lexical_node("n002", head)]
      edges = []
      next_node = 3
      next_edge = 1
      roles = Set.new
      role_arguments = {}
      time_spec = nil
      measurement = nil
      quantifier = nil

      until rest.strip.empty?
        rest = rest.lstrip
        if (match = /\AROLE\s+(\S+)\s+/.match(rest))
          role = match[1]
          raise CompileError.new("invalid_role", "Unknown controlled role.", { "role" => role, "allowed" => ROLES }) unless ROLES.include?(role)
          raise CompileError.new("duplicate_role", "A singular controlled role may occur only once.", { "role" => role }) if roles.include?(role)
          argument_text = rest[match.end(0)..]
          if (reference = /\AREF\s+(\S+)(?=\s|\z)/.match(argument_text))
            referenced_role = reference[1]
            id = role_arguments[referenced_role]
            unless id
              raise CompileError.new("unknown_role_reference", "REF must name an earlier role in this clause.", { "role" => referenced_role })
            end
            tail = argument_text[reference.end(0)..]
          else
            argument, tail = parse_lexical_prefix(argument_text)
            id = node_id(next_node); next_node += 1
            nodes << lexical_node(id, argument)
          end
          role_arguments[role] = id
          edges << { "edge_id" => edge_id(next_edge), "type" => "fills_role", "from" => id, "to" => "n002", "role" => role }; next_edge += 1
          roles << role
          rest = tail
        elsif (match = /\ATIME\s+(\S+)\s+SPEECH_TIME\b/.match(rest))
          relation = match[1]
          raise CompileError.new("invalid_time_relation", "Unknown controlled time relation.", { "relation" => relation, "allowed" => TIME_RELATIONS }) unless TIME_RELATIONS.include?(relation)
          raise CompileError.new("duplicate_time", "Only one TIME clause is allowed in this controlled template.") if time_spec
          time_spec = relation
          rest = rest[match.end(0)..]
        elsif (match = /\AMEASURE\s+(\S+)\s+(\S+)\b/.match(rest))
          magnitude, unit = match[1], match[2]
          raise CompileError.new("invalid_quantity", "Measurement magnitude must be a canonical finite decimal.", { "magnitude" => magnitude }) unless magnitude.match?(/\A-?(?:0|[1-9]\d*)(?:\.\d+)?\z/)
          raise CompileError.new("invalid_unit", "Unknown controlled measurement unit.", { "unit" => unit, "allowed" => UNITS }) unless UNITS.include?(unit)
          raise CompileError.new("duplicate_measurement", "Only one MEASURE clause is allowed in this controlled template.") if measurement
          measurement = [magnitude, unit]
          rest = rest[match.end(0)..]
        elsif (match = /\AQUANTIFIER\s+(exact|at_least|at_most|range|all|some|none|proportional)(?:\s+(\S+))?\b/.match(rest))
          kind, value = match[1], match[2]
          needs_value = %w[exact at_least at_most proportional].include?(kind)
          raise CompileError.new("missing_quantifier_value", "This quantifier requires a canonical numeric value.", { "quantifier" => kind }) if needs_value && value.nil?
          if value && !value.match?(/\A-?(?:0|[1-9]\d*)(?:\.\d+)?\z/)
            raise CompileError.new("invalid_quantity", "Quantifier value must be a canonical finite decimal.", { "value" => value })
          end
          raise CompileError.new("duplicate_quantifier", "Only one QUANTIFIER clause is allowed in this controlled template.") if quantifier
          quantifier = [kind, value]
          rest = rest[match.end(0)..]
        else
          raise CompileError.new("unexpected_token", "Input contains text outside the controlled template.", { "remainder" => rest.strip })
        end
      end

      missing = required_roles(head) - roles.to_a
      raise CompileError.new("missing_compound_role", "The compound has unbound required roles.", { "target_id" => head["target_id"], "missing_roles" => missing }) unless missing.empty?

      center = "n002"
      [["negation", prefix["negation"]], ["modality", prefix["modality"]], ["aspect", prefix["aspect"]]].each do |operator, value|
        next unless value
        id = node_id(next_node); next_node += 1
        data = { "node_id" => id, "kind" => "scope_operator", "operator" => operator }
        data["mode"] = value if operator == "modality"
        data["aspect"] = value if operator == "aspect"
        nodes << data
        edges << { "edge_id" => edge_id(next_edge), "type" => "scopes", "from" => center, "to" => id }; next_edge += 1
        center = id
      end
      if quantifier
        id = node_id(next_node); next_node += 1
        data = { "node_id" => id, "kind" => "scope_operator", "operator" => "quantifier", "quantifier" => quantifier[0] }
        data["value"] = quantifier[1] if quantifier[1]
        nodes << data
        edges << { "edge_id" => edge_id(next_edge), "type" => "scopes", "from" => center, "to" => id }; next_edge += 1
        center = id
      end
      edges << { "edge_id" => edge_id(next_edge), "type" => "centers", "from" => center, "to" => "n001" }; next_edge += 1
      if time_spec
        id = node_id(next_node); next_node += 1
        nodes << { "node_id" => id, "kind" => "time_anchor", "anchor_type" => "speech_time" }
        edges << { "edge_id" => edge_id(next_edge), "type" => "time_relation", "from" => id, "to" => "n001", "relation" => time_spec }; next_edge += 1
      end
      if measurement
        raise CompileError.new("duplicate_role", "MEASURE and ROLE quantity cannot both fill the singular quantity role.", { "role" => "quantity" }) if roles.include?("quantity")
        id = node_id(next_node)
        nodes << { "node_id" => id, "kind" => "measurement", "magnitude" => measurement[0], "unit" => measurement[1] }
        edges << { "edge_id" => edge_id(next_edge), "type" => "fills_role", "from" => id, "to" => "n002", "role" => "quantity" }
      end
      finalize(nodes, edges, speech_act)
    end

    def compile_coordination(text, speech_act, operator, separator)
      parts = text.split(/\s+#{separator}\s+/)
      raise CompileError.new("invalid_coordination", "#{operator.upcase} requires at least two lexical members separated by #{separator}.") if parts.length < 2
      lexicals = parts.map do |part|
        lexical, rest = parse_lexical_prefix(part)
        raise CompileError.new("unexpected_token", "Coordination members contain unsupported trailing text.", { "remainder" => rest.strip }) unless rest.strip.empty?
        required = required_roles(lexical)
        raise CompileError.new("missing_compound_role", "A slotted compound must use the simple clause template with explicit ROLE bindings.", { "target_id" => lexical["target_id"], "missing_roles" => required }) unless required.empty?
        lexical
      end
      nodes = [{ "node_id" => "n001", "kind" => "clause", "clause_type" => "predication" }, { "node_id" => "n002", "kind" => "coordination", "operator" => operator }]
      edges = [{ "edge_id" => "e001", "type" => "centers", "from" => "n002", "to" => "n001" }]
      lexicals.each_with_index do |lexical, index|
        id = node_id(index + 3)
        nodes << lexical_node(id, lexical)
        edge = { "edge_id" => edge_id(index + 2), "type" => "member_of", "from" => id, "to" => "n002" }
        edge["order"] = index + 1 if operator == "sequence"
        edges << edge
      end
      finalize(nodes, edges, speech_act)
    end

    def compile_repetition(text, speech_act)
      match = /\A([1-9]\d*)\s+TIMES\s+/.match(text)
      raise CompileError.new("invalid_repetition", "REPEAT requires a positive integer followed by TIMES.") unless match
      lexical, rest = parse_lexical_prefix(text[match.end(0)..])
      raise CompileError.new("unexpected_token", "Repetition contains unsupported trailing text.", { "remainder" => rest.strip }) unless rest.strip.empty?
      required = required_roles(lexical)
      raise CompileError.new("missing_compound_role", "A slotted compound must use the simple clause template with explicit ROLE bindings.", { "target_id" => lexical["target_id"], "missing_roles" => required }) unless required.empty?
      nodes = [{ "node_id" => "n001", "kind" => "clause", "clause_type" => "predication" }, { "node_id" => "n002", "kind" => "scope_operator", "operator" => "repetition", "mode" => "count", "count" => match[1].to_i }, lexical_node("n003", lexical)]
      edges = [{ "edge_id" => "e001", "type" => "centers", "from" => "n002", "to" => "n001" }, { "edge_id" => "e002", "type" => "scopes", "from" => "n003", "to" => "n002" }]
      finalize(nodes, edges, speech_act)
    end

    def compile_conditional(text, speech_act)
      parts = text.split(/\s+THEN\s+/, 2)
      raise CompileError.new("invalid_conditional", "IF requires one lexical condition and one lexical consequent separated by THEN.") unless parts.length == 2
      condition, condition_rest = parse_lexical_prefix(parts[0])
      consequent, consequent_rest = parse_lexical_prefix(parts[1])
      unless condition_rest.strip.empty? && consequent_rest.strip.empty?
        raise CompileError.new("unexpected_token", "Conditional branches contain unsupported trailing text.")
      end
      [condition, consequent].each do |lexical|
        required = required_roles(lexical)
        raise CompileError.new("missing_compound_role", "A slotted compound must use the simple clause template with explicit ROLE bindings.", { "target_id" => lexical["target_id"], "missing_roles" => required }) unless required.empty?
      end
      nodes = [
        { "node_id" => "n001", "kind" => "clause", "clause_type" => "conditional" },
        { "node_id" => "n002", "kind" => "clause", "clause_type" => "predication" },
        lexical_node("n003", condition),
        { "node_id" => "n004", "kind" => "clause", "clause_type" => "predication" },
        lexical_node("n005", consequent)
      ]
      edges = [
        { "edge_id" => "e001", "type" => "centers", "from" => "n004", "to" => "n001" },
        { "edge_id" => "e002", "type" => "centers", "from" => "n003", "to" => "n002" },
        { "edge_id" => "e003", "type" => "centers", "from" => "n005", "to" => "n004" },
        { "edge_id" => "e004", "type" => "condition_of", "from" => "n002", "to" => "n004", "condition_status" => "open" }
      ]
      finalize(nodes, edges, speech_act)
    end
  end
end
