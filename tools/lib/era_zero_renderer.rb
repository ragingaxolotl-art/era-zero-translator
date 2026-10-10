#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "set"
require_relative "era_zero_validation"

module EraZeroRenderer
  ROOT = EraZeroValidation::ROOT
  FORMAT = "EZF-1"
  PROFILE = "reference-midi-v1"
  REGISTER_OFFSETS = { "low" => -12, "middle" => 0, "high" => 12, "sustained_background" => -5 }.freeze
  ROLE_REGISTERS = {
    "actor" => "low", "source" => "low", "cause" => "low",
    "target" => "high", "result" => "high", "destination" => "high", "recipient" => "high", "beneficiary" => "high",
    "environment" => "sustained_background", "persistent_condition" => "sustained_background", "location" => "sustained_background", "time" => "sustained_background"
  }.freeze
  CONTOURS = { "assertion" => "level", "question" => "rising", "command" => "sharply_falling", "definition" => "rise_then_return", "possibility" => "fall_then_rise" }.freeze
  CONTOUR_PATHS = { "level" => [0, 0], "rising" => [0, 2], "sharply_falling" => [0, -4], "rise_then_return" => [0, 2, 0], "fall_then_rise" => [0, -2, 2] }.freeze
  TIMING_BEATS = { "no_gap" => 0.0, "short_gap" => 0.5, "medium_gap" => 1.0, "long_gap" => 2.0, "overlap" => 0.0, "repeated_pulse" => 0.5 }.freeze

  class RenderError < StandardError; end
  class DecodeError < StandardError; end

  module_function

  def load_authority
    return @authority if defined?(@authority) && @authority
    atoms_doc = EraZeroValidation.load_yaml("lexicon/atoms.yaml")
    compounds_doc = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml")
    @authority = [EraZeroValidation.atoms_by_id(atoms_doc), compounds_doc.fetch("entries").to_h { |c| [c.fetch("compound_id"), c] }]
  end

  def semantic_payload(ir)
    ir.slice("ir_version", "root_clause", "speech_act", "nodes", "edges", "discourse_constraints")
  end

  def semantic_digest(ir)
    Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(semantic_payload(ir))))
  end

  def register_for(node_id, ir)
    role_edges = ir.fetch("edges").select { |e| e["type"] == "fills_role" && e["from"] == node_id }
    registers = role_edges.map { |e| ROLE_REGISTERS.fetch(e["role"], "middle") }
    return "high" if registers.include?("high")
    return "low" if registers.include?("low")
    return "sustained_background" if registers.include?("sustained_background")
    "middle"
  end

  def runtime_tail(code, address_relative, base_pitch)
    last_abs = base_pitch + address_relative.last
    case code
    when 0 then { "code" => 0, "name" => "inactive", "relative_motion_semitones" => -1, "absolute_note" => last_abs - 1, "articulation" => "sharp_stop", "duration_beats" => 0.25 }
    when 1 then { "code" => 1, "name" => "active", "relative_motion_semitones" => -address_relative.last, "absolute_note" => base_pitch, "articulation" => "firm_return", "duration_beats" => 0.5 }
    when 2 then { "code" => 2, "name" => "num", "relative_motion_semitones" => 7, "absolute_note" => last_abs + 7, "articulation" => "sustain", "duration_beats" => 2.0 }
    else raise RenderError, "invalid runtime state #{code.inspect}"
    end
  end

  def atom_event(atom, occurrence_id:, register:, anchor_midi:, runtime_code:, component_node_id: nil, component_role: nil)
    base = anchor_midi + REGISTER_OFFSETS.fetch(register)
    relative = atom.fetch("note_path_semitones")
    event = {
      "occurrence_id" => occurrence_id, "component_node_id" => component_node_id, "component_role" => component_role,
      "target_id" => atom.fetch("canonical_id"), "register" => register, "base_midi" => base,
      "family_qualified_transliteration" => atom.fetch("canonical_transliteration"),
      "formal_carrier" => atom.fetch("formal_carrier"),
      "family_opening_relative_semitones" => atom.fetch("harmonic_signature_semitones"),
      "family_opening_absolute_midi" => atom.fetch("harmonic_signature_semitones").map { |n| base + n },
      "address_relative_semitones" => relative,
      "address_absolute_midi" => relative.map { |n| base + n },
      "note_duration_beats" => 1.0
    }.compact
    event["runtime_tail"] = runtime_tail(runtime_code, relative, base) unless runtime_code.nil?
    event
  end

  def compound_root_order(compound)
    roots = compound.fetch("nodes").select { |n| n["kind"] == "root" }
    head = compound.fetch("semantic_head")
    (roots.reject { |n| n["node_id"] == head }.sort_by { |n| n["node_id"] } + roots.select { |n| n["node_id"] == head })
  end

  def required_compound_roles(compound)
    slot_ids = compound.fetch("nodes").select { |node| node["kind"] == "slot" }.map { |node| node.fetch("node_id") }.to_set
    compound.fetch("edges").select { |edge| edge["type"] == "fills_role" && slot_ids.include?(edge["from"]) }.map { |edge| edge.fetch("role") }.uniq.sort
  end

  def validate_compound_roles!(compound, occurrence, ir)
    required = required_compound_roles(compound)
    supplied = ir.fetch("edges").select { |edge| edge["type"] == "fills_role" && edge["to"] == occurrence.fetch("node_id") }.map { |edge| edge["role"] }.compact.uniq
    missing = required - supplied
    raise RenderError, "compound #{compound.fetch('compound_id')} is missing required roles: #{missing.join(', ')}" unless missing.empty?
  end

  def render(ir, anchor_midi: 60)
    atoms, compounds = load_authority
    raise RenderError, "anchor_midi must be an integer from 24 through 96" unless anchor_midi.is_a?(Integer) && anchor_midi.between?(24, 96)
    digest = semantic_digest(ir)
    expected_id = "UTT:#{digest[0, 24]}"
    raise RenderError, "utterance identity mismatch" unless ir["utterance_id"] == expected_id && ir.dig("serialization", "content_digest") == digest
    speech_act = ir.fetch("speech_act")
    contour = CONTOURS.fetch(speech_act) { raise RenderError, "unknown speech act #{speech_act}" }
    lexical_events = []
    ir.fetch("nodes").select { |n| n["kind"] == "lexical_occurrence" }.sort_by { |n| n["node_id"] }.each do |node|
      register = register_for(node["node_id"], ir)
      state = node.fetch("runtime_state").fetch("code")
      if node["target_type"] == "atom"
        atom = atoms[node["target_id"]] or raise RenderError, "unknown atom #{node['target_id']}"
        lexical_events << atom_event(atom, occurrence_id: node["node_id"], register: register, anchor_midi: anchor_midi, runtime_code: state)
      elsif node["target_type"] == "compound"
        compound = compounds[node["target_id"]] or raise RenderError, "unknown compound #{node['target_id']}"
        validate_compound_roles!(compound, node, ir)
        compound_root_order(compound).each do |component|
          atom = atoms.fetch(component.fetch("root_id"))
          is_head = component["node_id"] == compound["semantic_head"]
          lexical_events << atom_event(atom, occurrence_id: node["node_id"], register: register, anchor_midi: anchor_midi, runtime_code: is_head ? state : nil, component_node_id: component["node_id"], component_role: is_head ? "head" : "qualifier")
        end
      else
        raise RenderError, "invalid lexical target type"
      end
    end

    structural_events = ir.fetch("edges").sort_by { |e| e["edge_id"] }.map do |edge|
      timing = case edge["type"]
               when "qualifies" then "no_gap"
               when "fills_role" then "short_gap"
               when "member_of"
                 target = ir.fetch("nodes").find { |n| n["node_id"] == edge["to"] }
                 target && target["operator"] == "parallel" ? "overlap" : "medium_gap"
               else "medium_gap"
               end
      { "edge_id" => edge["edge_id"], "edge_type" => edge["type"], "from" => edge["from"], "to" => edge["to"], "role" => edge["role"], "relation" => edge["relation"], "boundary" => timing, "boundary_beats" => TIMING_BEATS.fetch(timing) }.compact
    end
    secondary = []
    secondary << "repeated_loop" if ir.fetch("nodes").any? { |n| n["kind"] == "scope_operator" && n["operator"] == "repetition" }
    secondary << "overlapping_phrases" if ir.fetch("nodes").any? { |n| n["kind"] == "coordination" && n["operator"] == "parallel" }
    secondary << "unresolved_ending" if ir.fetch("edges").any? { |e| %w[condition_of grounds].include?(e["type"]) }

    relative_events = lexical_events.map do |event|
      copy = event.reject { |key, _| %w[base_midi family_opening_absolute_midi address_absolute_midi].include?(key) }
      copy["runtime_tail"] = copy["runtime_tail"]&.reject { |key, _| key == "absolute_note" }
      copy
    end
    relative_plan = {
      "primary_contour" => contour, "contour_relative_semitones" => CONTOUR_PATHS.fetch(contour),
      "secondary_contours" => secondary, "lexical_events" => relative_events,
      "structural_events" => structural_events, "statement_boundary" => "long_gap", "statement_boundary_beats" => TIMING_BEATS.fetch("long_gap")
    }
    formal_digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort({ "semantic_digest" => digest, "relative_plan" => relative_plan })))
    gloss_parts = lexical_events.map do |event|
      atom = atoms.fetch(event["target_id"])
      tail = event["runtime_tail"]
      "#{event['occurrence_id']}#{event['component_node_id'] ? ".#{event['component_node_id']}" : ''}:#{atom['title']}#{tail ? "[#{tail['code']}]" : ''}"
    end
    {
      "format" => FORMAT, "renderer_version" => "1.0.0", "formal_id" => "EZF:#{formal_digest[0, 24]}", "formal_digest" => formal_digest,
      "semantic_digest" => digest, "semantic_ir" => ir,
      "performance" => { "profile" => PROFILE, "anchor_midi" => anchor_midi, "transposition_semantically_significant" => false, "primary_contour" => contour, "contour_relative_semitones" => CONTOUR_PATHS.fetch(contour), "secondary_contours" => secondary, "lexical_events" => lexical_events, "structural_events" => structural_events, "statement_boundary" => "long_gap", "statement_boundary_beats" => TIMING_BEATS.fetch("long_gap") },
      "literal_gloss" => gloss_parts.join(" | ")
    }
  end

  def decode(formal)
    raise DecodeError, "unknown format" unless formal["format"] == FORMAT
    ir = formal.fetch("semantic_ir")
    digest = semantic_digest(ir)
    raise DecodeError, "semantic digest mismatch" unless formal["semantic_digest"] == digest && ir["utterance_id"] == "UTT:#{digest[0, 24]}" && ir.dig("serialization", "content_digest") == digest
    regenerated = render(ir, anchor_midi: formal.dig("performance", "anchor_midi"))
    %w[formal_id formal_digest performance literal_gloss].each do |field|
      raise DecodeError, "#{field} mismatch" unless formal[field] == regenerated[field]
    end
    ir
  rescue KeyError, RenderError => e
    raise DecodeError, e.message
  end
end
