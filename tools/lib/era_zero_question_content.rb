# frozen_string_literal: true
require_relative 'era_zero_presentation'

# Draft wrapper; its proposition is checked by the canonical renderer as well
# as its own content identity. Neither answer is asserted by this document.
module EraZeroQuestionContent
  module_function
  def digest(value)
    Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(value)))
  end

  def validate!(document, allow_draft: false)
    raise ArgumentError, 'Question content requires draft opt-in' unless allow_draft
    fields = %w[profile status content_id content_digest question_kind assertion_commitment proposition]
    raise ArgumentError, 'Invalid question content fields' unless document.is_a?(Hash) && document.keys.sort == fields.sort
    raise ArgumentError, 'Invalid polar question contract' unless document['profile'] == 'EZQUESTION-CONTENT-1' && document['status'] == 'draft' && document['question_kind'] == 'polar' && document['assertion_commitment'] == 'neither_answer'
    ir = document['proposition']
    raise ArgumentError, 'Question body must be a proposition' unless ir.is_a?(Hash) && ir['speech_act'] == 'assertion'
    # Includes graph, roles, reference identities and canonical semantic digest.
    EraZeroRenderer.render(ir)
    body = document.reject { |key, _| %w[content_id content_digest].include?(key) }
    expected = digest(body)
    raise ArgumentError, 'Question content identity mismatch' unless document['content_digest'] == expected && document['content_id'] == "EZQ:#{expected[0, 24]}"
    true
  end

  def frames
    %w[open close].map { |side| { 'marker' => "polar_content_#{side}", 'path' => [0, side == 'open' ? -31 : 31, 0, 0] } }
  end

  def event(side, anchor)
    frame = frames.find { |f| f['marker'] == "polar_content_#{side}" }
    raise ArgumentError, 'Invalid question frame or anchor' unless frame && anchor.is_a?(Integer) && frame['path'].all? { |n| (anchor + n).between?(0, 127) }
    { 'kind' => 'grammar_marker', 'grammar_profile' => 'EZQUESTION-MUSIC-1', 'marker' => frame['marker'], 'register' => 'middle', 'base_midi' => anchor, 'family_opening_absolute_midi' => [], 'address_absolute_midi' => frame['path'].map { |n| anchor + n }, 'note_duration_beats' => 0.25, 'boundary_after_beats' => 0.5 }
  end

  def midi(document, anchor_midi: 60, allow_draft: false)
    validate!(document, allow_draft: allow_draft)
    formal = EraZeroRenderer.render(document['proposition'], anchor_midi: anchor_midi)
    events = [event('open', anchor_midi)] + EraZeroPresentation.scheduled_lexical_events(formal) + [event('close', anchor_midi)]
    EraZeroPresentation.midi_from_scheduled_events(events, anchor_midi, [0, 0])
  end
end
