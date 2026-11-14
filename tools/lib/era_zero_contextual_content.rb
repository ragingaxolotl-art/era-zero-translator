# frozen_string_literal: true
require_relative 'era_zero_presentation'

# Draft contextual selectors; no matrix cognitive predicate is asserted.
module EraZeroContextualContent
  KINDS = %w[topic communicated_content reasons perspective].freeze
  MODES = {'definite_nominal'=>'definite', 'proximal_nominal'=>'proximal', 'distal_nominal'=>'distal'}.freeze
  module_function
  def exact!(value, fields)
    raise ArgumentError, 'Invalid contextual content fields' unless value.is_a?(Hash) && value.keys.sort == fields.sort
  end
  def digest(value)
    Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(value)))
  end
  def validate!(document, allow_draft: false)
    raise ArgumentError, 'Contextual content requires draft opt-in' unless allow_draft
    exact!(document, %w[profile status content_kind anchor resolution_scope assertion_commitment content_id content_digest]+(document.key?('selection') ? ['selection'] : []))
    unless document['profile']=='EZCONTEXTUAL-CONTENT-1' && document['status']=='draft' && KINDS.include?(document['content_kind']) && document['resolution_scope']=='local_context' && document['assertion_commitment']=='none'
      raise ArgumentError, 'Invalid contextual content contract'
    end
    if document.key?('selection')
      raise ArgumentError, 'Invalid content source selection' unless document['content_kind']=='communicated_content' && document['selection']=={'channel'=>'speech','time'=>'before_speech'}
    end
    r=document['anchor']
    raise ArgumentError, 'Invalid content anchor' unless r.is_a?(Hash) && r['node_id']=='anchor' && r['value_type']=='entity'
    case r['kind']
    when 'deictic_reference'
      exact!(r, %w[node_id kind value_type deictic_role referent_id])
      raise ArgumentError, 'Invalid discourse reference' unless %w[speaker addressee].include?(r['deictic_role']) && r['referent_id']=="discourse:#{r['deictic_role']}"
    when 'phonemic_reference'
      exact!(r, %w[node_id kind value_type name referent_id]+(r.key?('reference_mode') ? ['reference_mode'] : []))
      n=r['name']
      exact!(n, %w[format status label normalized_label phonemes events frame object_tag instance_notes name_id semantic_claim])
      EraZeroNames.notes(n)
      raise ArgumentError, 'Invalid label' unless n['label'].is_a?(String)
      normalized=n['label'].unicode_normalize(:nfc).downcase.gsub(/[^a-z\s-]/,' ').gsub(/[-\s]+/,' ').strip
      tag=n['object_tag']
      raise ArgumentError, 'Invalid name metadata' unless normalized==n['normalized_label'] && n['status']=='experimental_nonsemantic_label' && n['semantic_claim']==false && (tag.nil? || (tag.is_a?(String) && !tag.empty? && tag==tag.unicode_normalize(:nfc).strip))
      events=n['phonemes'].each_with_index.map do |p,i|
        code=EraZeroNames::PHONEMES.index(p)
        {'index'=>i,'phoneme'=>p,'notes'=>[52+(code/8)*3,68+code%8],'sound_class'=>%w[AA AE AH AO AW AY EH ER EY IH IY OW OY UH UW].include?(p) ? 'vowel' : 'consonant'}
      end
      hash=Digest::SHA256.hexdigest(['EZNAME-0.1',normalized,n['phonemes'].join(' '),tag.to_s].join("\n"))
      instance=tag.nil? ? [] : hash[0,8].chars.map{|h|76+h.to_i(16)}
      raise ArgumentError, 'Corrupt encoded name' unless n['events']==events && n['frame']=={'start'=>[48,60,55],'end'=>[55,60,48]} && n['instance_notes']==instance
      if r.key?('reference_mode')
        mode=MODES[r['reference_mode']]
        raise ArgumentError, 'Invalid nominal reference' unless mode && normalized.match?(/\A[a-z]+\z/) && r['referent_id']=="nominal:#{mode}:#{n['name_id']}"
      else
        raise ArgumentError, 'Invalid named reference' unless r['referent_id']=="name:#{n['name_id']}"
      end
    else
      raise ArgumentError, 'Unsupported content anchor'
    end
    body=document.reject{|k,_|%w[content_id content_digest].include?(k)}
    expected=digest(body)
    raise ArgumentError, 'Content identity mismatch' unless document['content_digest']==expected && document['content_id']=="EZCTX:#{expected[0,24]}"
    true
  end
  def event(kind, side, anchor)
    code=KINDS.index(kind)
    raise ArgumentError, 'Invalid contextual frame' unless code && %w[open close].include?(side) && anchor.is_a?(Integer) && anchor.between?(34,93)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZCONTEXTUAL-CONTENT-MUSIC-1','marker'=>"content_#{kind}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -34 : 34,code,0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def selected_events(document, refs, anchor)
    return refs unless document.key?('selection')
    raise ArgumentError, 'Invalid content source selection' unless document['content_kind']=='communicated_content' && document['selection']=={'channel'=>'speech','time'=>'before_speech'} && anchor.is_a?(Integer) && anchor.between?(35,92)
    marker=lambda do |side|
      {'kind'=>'grammar_marker','grammar_profile'=>'EZCONTENT-SELECTION-1','marker'=>"spoken_source_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -35 : 35,0,0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
    end
    formal={'performance'=>{'anchor_midi'=>anchor}}
    [marker.call('open'),EraZeroPresentation.grammar_marker(formal,'content-source','time_before_speech_open')]+refs+[EraZeroPresentation.grammar_marker(formal,'content-source','time_before_speech_close'),marker.call('close')]
  end
  def midi(document, anchor_midi: 60, allow_draft: false)
    validate!(document, allow_draft: allow_draft)
    kind=document['content_kind']
    opening=event(kind,'open',anchor_midi)
    refs=EraZeroRenderer.occurrence_events(document['anchor'],{'nodes'=>[document['anchor']],'edges'=>[]},{},{},anchor_midi,'middle')
    EraZeroPresentation.midi_from_scheduled_events([opening]+selected_events(document,refs,anchor_midi)+[event(kind,'close',anchor_midi)],anchor_midi,[0,0])
  end
end
