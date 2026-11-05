# frozen_string_literal: true
require_relative 'era_zero_presentation'

# Compares actual MIDI note/timing output, not formal IDs or embedded glosses.
# MIDI export contains fixed tempo/program metadata and no semantic identifier.
module EraZeroMusicalIdentity
  module_function

  def signature(formal)
    Digest::SHA256.hexdigest(EraZeroPresentation.midi(formal))
  end

  def collisions(records)
    records.group_by { |record| record.fetch('midi_sha256') }.values.map do |group|
      identities = group.map { |record| record.fetch('identity') }.uniq
      next if identities.length < 2
      { 'midi_sha256' => group.first.fetch('midi_sha256'), 'identities' => identities.sort }
    end.compact
  end
end
