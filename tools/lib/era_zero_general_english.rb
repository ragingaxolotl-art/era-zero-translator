#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"
require_relative "era_zero_validation"
require_relative "era_zero_controlled_english"
require_relative "era_zero_renderer"

module EraZeroGeneralEnglish
  VERSION = "1.0.0"
  STOPWORDS = %w[a an the to of in on at for from with is are was were be being been do does did i you he she it we they this that these those my your his her its our their please].to_set.freeze
  DIRECT_ROUTES = %w[atom compound].freeze

  class ResolutionError < StandardError
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

  class Translator
    def initialize(profile: true)
      canonical_senses = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses")
      game_story_senses = profile ? EraZeroValidation.load_yaml("lexicon/game_story_surface_routes.yaml").fetch("senses") : []
      @senses = canonical_senses + game_story_senses
      @analysis_senses = @senses.reject { |sense| sense["route"] == "label" }
      @sense_by_id = @senses.to_h { |sense| [sense.fetch("sense_id"), sense] }
      controlled = @senses.select { |sense| sense["controlled_input_allowed"] == true && DIRECT_ROUTES.include?(sense["route"]) }
      @canonical_label = controlled.to_h { |sense| [sense.fetch("target_id"), sense.fetch("lemma")] }
      @controlled_compiler = EraZeroControlledEnglish::Compiler.new
      @compounds = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries").to_h { |compound| [compound.fetch("compound_id"), compound] }
    end

    def analyze(input, limit: 8)
      original = input.to_s
      text, explicit_state = extract_runtime(original)
      normalized = normalize(text)
      return error("empty_input", "General-English input is empty.", original) if normalized.empty?
      proposed_speech_act = original.strip.end_with?("?") ? "question" : "assertion"
      tokens = semantic_tokens(normalized)
      ranked = @analysis_senses.map { |sense| score_sense(sense, normalized, tokens) }.select { |candidate| candidate["score"] > 0.0 }.sort_by { |candidate| [-candidate["score"], candidate["sense_id"]] }.first(limit)
      return error("no_candidate", "No indexed Era Zero sense overlaps the input.", original, { "normalized_input" => normalized }) if ranked.empty?

      ranked.each { |candidate| enrich_candidate!(candidate, explicit_state, proposed_speech_act) }
      top = ranked.first
      exact = top["match_type"] == "exact_lemma"
      competing = ranked.drop(1).select { |candidate| top["score"] - candidate["score"] < 0.12 }
      material_ambiguity = competing.any?
      direct = DIRECT_ROUTES.include?(top["route"])
      missing_runtime = direct && explicit_state.nil?
      missing_roles = Array(top["required_roles"]).any?
      structural = %w[semantic_ir grammar].include?(top["route"])
      gap = top["route"] == "gap"
      auto_allowed = exact && !material_ambiguity && direct && !missing_runtime && !missing_roles
      result = {
        "status" => "ok", "translator_version" => VERSION, "input" => original,
        "normalized_input" => normalized, "speech_act_proposal" => proposed_speech_act,
        "explicit_runtime_state" => explicit_state, "candidates" => ranked,
        "decision" => {
          "auto_resolution_allowed" => auto_allowed,
          "requires_clarification" => !auto_allowed,
          "reasons" => clarification_reasons(material_ambiguity, missing_runtime, missing_roles, structural, gap, exact),
          "competing_sense_ids" => competing.map { |candidate| candidate["sense_id"] }
        }
      }
      if auto_allowed
        result["translation"] = resolve(original, sense_id: top.fetch("sense_id"), runtime_state: explicit_state, speech_act: result["speech_act_proposal"])
      else
        result["clarification"] = clarification(top, competing, explicit_state)
      end
      result
    rescue ResolutionError => exception
      exception.to_h(original)
    end

    def resolve(input, sense_id:, runtime_state:, speech_act: "assertion", roles: {})
      sense = @sense_by_id[sense_id]
      raise ResolutionError.new("unknown_sense", "The selected sense ID is not in the canonical index.", { "sense_id" => sense_id }) unless sense
      unless DIRECT_ROUTES.include?(sense["route"])
        raise ResolutionError.new("structural_route_requires_template", "The selected sense requires a semantic-IR or grammar template and cannot be reduced to one lexical occurrence.", { "sense_id" => sense_id, "route" => sense["route"] })
      end
      raise ResolutionError.new("invalid_runtime_state", "Resolution requires runtime state 0, 1, or 2.", { "runtime_state" => runtime_state }) unless [0, 1, 2].include?(runtime_state)
      act = speech_act.to_s
      keyword = EraZeroControlledEnglish::ACTS.key(act)
      raise ResolutionError.new("invalid_speech_act", "Resolution requires a canonical speech act.", { "speech_act" => speech_act }) unless keyword
      label = @canonical_label.fetch(sense.fetch("target_id"))
      role_text = roles.sort_by { |role, _| role.to_s }.map do |role, value|
        role_name = role.to_s
        raise ResolutionError.new("invalid_role", "Unknown resolution role.", { "role" => role_name }) unless EraZeroControlledEnglish::ROLES.include?(role_name)
        data = value.is_a?(Hash) ? value : { "label" => value, "state" => 1 }
        role_label = data["label"] || data[:label]
        role_state = data.key?("state") ? data["state"] : data.fetch(:state, 1)
        %( ROLE #{role_name} "#{role_label}" [#{role_state}])
      end.join
      controlled = %(#{keyword} "#{label}" [#{runtime_state}]#{role_text}.)
      compiled = @controlled_compiler.compile(controlled)
      if compiled["status"] == "error"
        code = compiled.dig("error", "code") == "missing_compound_role" ? "missing_required_role" : "controlled_resolution_failed"
        raise ResolutionError.new(code, "The selected interpretation still needs valid explicit arguments.", { "controlled_error" => compiled["error"], "controlled_input" => controlled })
      end
      ir = compiled.fetch("semantic_ir")
      formal = EraZeroRenderer.render(ir)
      {
        "status" => "resolved", "source_input" => input.to_s, "sense_id" => sense_id,
        "route" => sense.fetch("route"), "target_id" => sense.fetch("target_id"), "controlled_input" => controlled,
        "semantic_ir" => ir, "formal" => formal, "round_trip_equal" => EraZeroRenderer.decode(formal) == ir
      }
    rescue ResolutionError => exception
      exception.to_h(input.to_s)
    end

    private

    def error(code, message, input, details = {})
      { "status" => "error", "error" => { "code" => code, "message" => message, "input" => input, "details" => details } }
    end

    def normalize(value)
      value.to_s.unicode_normalize(:nfc).downcase.gsub(/[?!.,;:()]/, " ").gsub(/\s+/, " ").strip
    end

    def extract_runtime(value)
      match = /\s*\[([^\]]+)\]\s*[?.!]?\s*\z/.match(value.to_s)
      return [value.to_s, nil] unless match
      raw = match[1]
      raise ResolutionError.new("invalid_runtime_state", "An explicit runtime marker must be [0], [1], or [2].", { "runtime_state" => raw }) unless %w[0 1 2].include?(raw)
      [value.to_s[0...match.begin(0)], raw.to_i]
    end

    def semantic_tokens(value)
      value.scan(/[\p{L}\p{N}_-]+/).reject { |token| STOPWORDS.include?(token) }.to_set
    end

    def phrase_present?(text, phrase)
      /(?:\A|\s)#{Regexp.escape(phrase)}(?:\z|\s)/.match?(text)
    end

    def score_sense(sense, input, input_tokens)
      forms = [sense.fetch("lemma"), *Array(sense["surface_forms"])].map { |form| normalize(form) }.uniq
      exact = forms.include?(input)
      contained = forms.any? { |form| phrase_present?(input, form) }
      lemma_tokens = forms.map { |form| semantic_tokens(form) }.max_by { |tokens| (input_tokens & tokens).length.fdiv([tokens.length, 1].max) }
      lexical_overlap = (input_tokens & lemma_tokens).length
      return empty_candidate(sense) if !exact && !contained && lexical_overlap.zero?
      base = if exact then 1.0 elsif contained then 0.72 else [0.18 * lexical_overlap / [lemma_tokens.length, 1].max.to_f, 0.45].min end
      cues = Array(sense["selection_cues"]).join(" ")
      cue_overlap = (input_tokens & semantic_tokens(normalize(cues))).length
      definition_overlap = (input_tokens & semantic_tokens(normalize(sense.fetch("definition", "")))).length
      score = [base + [cue_overlap * 0.06, 0.18].min + [definition_overlap * 0.02, 0.08].min, 1.0].min.round(4)
      {
        "sense_id" => sense.fetch("sense_id"), "lemma" => sense.fetch("lemma"), "sense_key" => sense.fetch("sense_key"),
        "route" => sense.fetch("route"), "target_id" => sense["target_id"], "definition" => sense.fetch("definition"),
        "selection_cues" => Array(sense["selection_cues"]), "generalization" => sense["generalization"],
        "fidelity" => sense["fidelity"], "part_of_speech" => sense["sense_id"].start_with?("GSE:") ? sense["part_of_speech"] : nil, "score" => score,
        "confidence" => score >= 0.9 ? "high" : score >= 0.65 ? "medium" : "low",
        "match_type" => exact ? "exact_lemma" : contained ? "contained_lemma" : "token_overlap",
        "evidence" => { "lexical_overlap" => lexical_overlap, "selection_cue_overlap" => cue_overlap, "definition_overlap" => definition_overlap }
      }.compact
    end

    def empty_candidate(sense)
      { "sense_id" => sense.fetch("sense_id"), "score" => 0.0 }
    end

    def enrich_candidate!(candidate, explicit_state, speech_act)
      return unless DIRECT_ROUTES.include?(candidate["route"])
      target_id = candidate.fetch("target_id")
      label = @canonical_label.fetch(target_id)
      candidate["canonical_label"] = label
      required = if candidate["route"] == "compound"
                   EraZeroRenderer.required_compound_roles(@compounds.fetch(target_id), compounds: @compounds)
                 else
                   []
                 end
      candidate["required_roles"] = required
      states = explicit_state.nil? ? [0, 1, 2] : [explicit_state]
      keyword = EraZeroControlledEnglish::ACTS.key(speech_act)
      candidate["semantic_ir_options"] = if required.empty?
                                            states.map do |state|
                                              compiled = @controlled_compiler.compile(%(#{keyword} "#{label}" [#{state}].))
                                              { "runtime_state" => state, "semantic_ir" => compiled.fetch("semantic_ir") }
                                            end
                                          else
                                            []
                                          end
    end

    def clarification_reasons(material, runtime, roles, structural, gap, exact)
      reasons = []
      reasons << "material_sense_ambiguity" if material
      reasons << "runtime_state_required" if runtime
      reasons << "required_roles_missing" if roles
      reasons << "structural_template_required" if structural
      reasons << "documented_vocabulary_gap" if gap
      reasons << "nonexact_surface_match" unless exact
      reasons.uniq
    end

    def clarification(top, competing, explicit_state)
      questions = []
      if competing.any?
        questions << { "field" => "sense_id", "question" => "Which meaning is intended?", "options" => ([top] + competing).map { |candidate| { "sense_id" => candidate["sense_id"], "definition" => candidate["definition"], "route" => candidate["route"] } } }
      end
      questions << { "field" => "runtime_state", "question" => "What is the occurrence runtime state: 0, 1, or 2?", "options" => [0, 1, 2] } if DIRECT_ROUTES.include?(top["route"]) && explicit_state.nil?
      if Array(top["required_roles"]).any?
        questions << { "field" => "roles", "question" => "Supply canonical controlled labels for every required role.", "required_roles" => top["required_roles"] }
      end
      if %w[semantic_ir grammar].include?(top["route"])
        questions << { "field" => "structure", "question" => "Supply the missing participants, states, or clause structure required by this semantic route.", "route" => top["route"] }
      elsif top["route"] == "gap"
        questions << { "field" => "vocabulary", "question" => "This concept is an explicit Era Zero vocabulary gap; choose a supported paraphrase or defer translation.", "sense_id" => top["sense_id"] }
      end
      questions
    end
  end
end
