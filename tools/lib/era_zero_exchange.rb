#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "digest"
require_relative "era_zero_validation"
require_relative "era_zero_renderer"
require_relative "era_zero_presentation"

module EraZeroExchange
  FORMAT = "EZB-1"
  VERSION = "1.0.0"
  class BundleError < StandardError; end
  module_function

  def canonical_digest(value)
    Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(value)))
  end

  def create(result, source: nil)
    raise BundleError, "resolution must be successful" unless result.is_a?(Hash) && result["status"] == "resolved"
    formal = result.fetch("formal")
    ir = result.fetch("semantic_ir")
    raise BundleError, "formal document does not decode to semantic IR" unless EraZeroRenderer.decode(formal) == ir
    payload = {
      "source" => source || result["source_input"], "sense_id" => result.fetch("sense_id"),
      "target_id" => result.fetch("target_id"), "controlled_input" => result.fetch("controlled_input"),
      "semantic_ir" => ir, "formal" => formal, "presentation" => EraZeroPresentation.manifest(formal)
    }
    envelope = {
      "format" => FORMAT, "version" => VERSION,
      "authority" => { "semantic_ir" => "1.0.0", "renderer_decoder" => "1.0.0", "controlled_english" => "1.0.0", "general_english" => "1.0.0", "glyph_audio" => "1.0.0" },
      "payload" => payload
    }
    envelope.merge("bundle_digest" => canonical_digest(envelope))
  rescue EraZeroRenderer::DecodeError => error
    raise BundleError, error.message
  end

  def verify(bundle)
    raise BundleError, "bundle must be an object" unless bundle.is_a?(Hash)
    raise BundleError, "unsupported bundle format" unless bundle["format"] == FORMAT && bundle["version"] == VERSION
    supplied = bundle["bundle_digest"]
    body = bundle.reject { |key, _| key == "bundle_digest" }
    raise BundleError, "bundle digest mismatch" unless supplied == canonical_digest(body)
    payload = bundle.fetch("payload")
    ir = payload.fetch("semantic_ir")
    formal = payload.fetch("formal")
    raise BundleError, "bundle IR/formal mismatch" unless EraZeroRenderer.decode(formal) == ir
    manifest = EraZeroPresentation.manifest(formal)
    raise BundleError, "presentation manifest mismatch" unless payload["presentation"] == manifest
    { "status" => "valid", "format" => FORMAT, "bundle_digest" => supplied, "utterance_id" => ir.fetch("utterance_id"), "formal_id" => formal.fetch("formal_id"), "target_id" => payload.fetch("target_id") }
  rescue KeyError, EraZeroRenderer::DecodeError, EraZeroPresentation::PresentationError => error
    raise BundleError, error.message
  end
end
