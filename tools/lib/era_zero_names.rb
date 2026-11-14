# frozen_string_literal: true
require "digest"

# Consumer of the existing EZNAME-0.1 encoding, not a new lexical inventory.
# Pronunciation estimation remains in pages/names.mjs; explicit phonemes are
# validated and their notes are reconstructed here rather than trusting input MIDI.
module EraZeroNames
  PHONEMES = %w[AA AE AH AO AW AY B CH D DH EH ER EY F G HH IH IY JH K L M N NG OW OY P R S SH T TH UH UW V W Y Z ZH WB].freeze
  class NameError < StandardError; end
  module_function

  def notes(name)
    raise NameError, "unsupported name format" unless name["format"] == "EZNAME-0.1"
    label = name.fetch("normalized_label")
    phonemes = name.fetch("phonemes")
    unless label.is_a?(String) && !label.empty? && phonemes.is_a?(Array) && !phonemes.empty? && phonemes.all? { |p| PHONEMES.include?(p) }
      raise NameError, "invalid phonemic label"
    end
    tag = name["object_tag"].to_s
    digest = Digest::SHA256.hexdigest(["EZNAME-0.1", label, phonemes.join(" "), tag].join("\n"))
    raise NameError, "phonemic name identity mismatch" unless name["name_id"] == "EZNAME:#{digest[0, 16]}"
    encoded = phonemes.flat_map { |phoneme| code = PHONEMES.index(phoneme); [52 + (code / 8) * 3, 68 + code % 8] }
    instance = tag.empty? ? [] : [72, 65, 72] + digest[0, 8].chars.map { |hex| 76 + hex.to_i(16) }
    [48, 60, 55] + encoded + instance + [55, 60, 48]
  rescue KeyError => error
    raise NameError, "incomplete phonemic name: #{error.message}"
  end
end
