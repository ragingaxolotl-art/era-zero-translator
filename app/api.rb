#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "base64"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_general_english"
require_relative "../tools/lib/era_zero_controlled_english"
require_relative "../tools/lib/era_zero_presentation"
require_relative "../tools/lib/era_zero_exchange"

module EraZeroApp
  VERSION = "1.0.0"
  MAX_BODY_BYTES = 1_048_576
  Response = Struct.new(:status, :headers, :body, keyword_init: true)

  class API
    def initialize
      @general = EraZeroGeneralEnglish::Translator.new
      @controlled = EraZeroControlledEnglish::Compiler.new
      @version = EraZeroValidation.load_yaml("spec/version.yaml")
      @readiness = EraZeroValidation.load_yaml("spec/translator_readiness.yaml")
    end

    def dispatch(method, path, raw_body = "")
      return json(405, error("method_not_allowed", "Only documented HTTP methods are accepted.")) unless method == "GET" || method == "POST"
      return json(413, error("payload_too_large", "Request body exceeds 1 MiB.")) if raw_body.to_s.bytesize > MAX_BODY_BYTES
      case [method, path]
      when ["GET", "/api/health"] then json(200, health)
      when ["GET", "/api/meta"] then json(200, metadata)
      when ["POST", "/api/analyze"]
        data = parse(raw_body); json(200, @general.analyze(required_string(data, "input"), limit: integer(data.fetch("limit", 8), 1, 20)))
      when ["POST", "/api/resolve"]
        data = parse(raw_body)
        result = @general.resolve(required_string(data, "input"), sense_id: required_string(data, "sense_id"), runtime_state: integer(data["runtime_state"], 0, 2), speech_act: data.fetch("speech_act", "assertion"), roles: data.fetch("roles", {}))
        json(result["status"] == "error" ? 422 : 200, result)
      when ["POST", "/api/controlled"]
        data = parse(raw_body); result = @controlled.compile(required_string(data, "input")); json(result["status"] == "error" ? 422 : 200, result)
      when ["POST", "/api/svg"]
        data = parse(raw_body); Response.new(status: 200, headers: { "Content-Type" => "image/svg+xml; charset=utf-8", "Content-Disposition" => "attachment; filename=era-zero.svg" }, body: EraZeroPresentation.svg(data.fetch("formal")))
      when ["POST", "/api/midi"]
        data = parse(raw_body); Response.new(status: 200, headers: { "Content-Type" => "audio/midi", "Content-Disposition" => "attachment; filename=era-zero.mid" }, body: EraZeroPresentation.midi(data.fetch("formal")))
      when ["POST", "/api/bundle/export"]
        data = parse(raw_body); json(200, EraZeroExchange.create(data.fetch("resolution"), source: data["source"]))
      when ["POST", "/api/bundle/import"]
        data = parse(raw_body); json(200, EraZeroExchange.verify(data.fetch("bundle")))
      else json(404, error("not_found", "No API route matches #{method} #{path}."))
      end
    rescue JSON::ParserError
      json(400, error("invalid_json", "Request body must be valid JSON."))
    rescue KeyError => exception
      json(400, error("missing_field", "Required field is missing.", { "field" => exception.key.to_s }))
    rescue ArgumentError => exception
      json(400, error("invalid_parameter", exception.message))
    rescue EraZeroExchange::BundleError => exception
      json(422, error("invalid_bundle", exception.message))
    rescue EraZeroPresentation::PresentationError => exception
      json(422, error("invalid_formal", exception.message))
    rescue StandardError => exception
      json(500, error("internal_error", "The request could not be completed.", { "class" => exception.class.name }))
    end

    private

    def health
      { "status" => "ok", "service" => "era-zero-translator", "version" => VERSION, "translator_release" => @version["translator_release_status"], "all_gates_complete" => @readiness.fetch("required_gates").all? { |gate| gate["status"] == "complete" } }
    end

    def metadata
      { "service" => "Era Zero Translator Workbench", "version" => VERSION, "formats" => %w[EZIR-JSON-1 EZF-1 EZSVG-1 EZB-1 MIDI-0], "counts" => { "atoms" => 324, "compounds" => 28, "senses" => 436, "lemmas" => 419, "gaps" => 11 }, "limits" => { "request_bytes" => MAX_BODY_BYTES, "candidate_limit" => 20 }, "no_silent_guess" => true }
    end

    def parse(raw)
      value = JSON.parse(raw.to_s)
      raise ArgumentError, "JSON body must be an object" unless value.is_a?(Hash)
      value
    end

    def required_string(data, key)
      value = data.fetch(key)
      raise ArgumentError, "#{key} must be a non-empty string" unless value.is_a?(String) && !value.strip.empty?
      value
    end

    def integer(value, min, max)
      result = Integer(value)
      raise ArgumentError, "integer must be between #{min} and #{max}" unless result.between?(min, max)
      result
    end

    def error(code, message, details = {})
      { "status" => "error", "error" => { "code" => code, "message" => message, "details" => details } }
    end

    def json(status, value)
      Response.new(status: status, headers: { "Content-Type" => "application/json; charset=utf-8", "Cache-Control" => "no-store" }, body: JSON.generate(value))
    end
  end
end
