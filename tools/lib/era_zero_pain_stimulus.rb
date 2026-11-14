# frozen_string_literal: true
require_relative 'era_zero_pain'
module EraZeroPainStimulus
  RELATIONS={
    'actual_causation'=>'The stimulus causally contributes to the specified pain experience; causal contribution is not mere correlation or temporal order and need not be the sole cause.',
    'expected_outcome'=>'In the selected local context, occurrence or application of the stimulus is expected to produce the specified pain experience; neither occurrence nor pain is asserted as actual.',
    'disposition'=>'The stimulus has a contextually qualified tendency to produce the specified pain experience when encountered or applied; no particular occurrence, inevitability or present pain is asserted.'
  }.freeze
  CODES={'actual_causation'=>2,'expected_outcome'=>3,'disposition'=>4}.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Pain stimulus requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,%w[profile status relation criterion stimulus outcome speech_act scopes runtime_state outcome_scope content_digest content_id])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid pain stimulus contract' unless d['profile']=='EZPAIN-STIMULUS-1' && d['status']=='draft' && RELATIONS.key?(d['relation']) && d['criterion']==RELATIONS[d['relation']] && d['outcome_scope']=='governed_by_relation_and_matrix_scope' && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    EraZeroPain.validate!(d['outcome'],allow_draft:true)
    raise ArgumentError,'Invalid scoped outcome' unless d['outcome']['speech_act']=='assertion' && d['outcome']['scopes']==[]
    ref={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>d['stimulus'],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
    hash=EraZeroContextualContent.digest(ref)
    EraZeroContextualContent.validate!(ref.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Pain stimulus identity mismatch' unless d['content_digest']==hash && d['content_id']=="EZPAINSTIM:#{hash[0,24]}"
    true
  end
  def frame(d,side,anchor)
    raise ArgumentError,'Invalid relation frame' unless anchor.is_a?(Integer) && anchor.between?(39,88) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZPAIN-STIMULUS-MUSIC-1','marker'=>"pain_stimulus_#{d['relation']}_#{d['runtime_state']}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,CODES.fetch(d['relation']),d['runtime_state'],0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def events(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi
    atoms,compounds=EraZeroRenderer.load_authority
    mark=lambda{|name|EraZeroPresentation.grammar_marker({'performance'=>{'anchor_midi'=>anchor}},'pain-stimulus',name)}
    ref=d['stimulus'];reference=EraZeroRenderer.occurrence_events(ref,{'nodes'=>[ref],'edges'=>[]},atoms,compounds,anchor,'middle')
    events=[frame(d,'open',anchor),mark.call('role_content_open')]+reference+[mark.call('role_content_close')]+EraZeroPain.events(d['outcome'],allow_draft:true,anchor_midi:anchor)+[frame(d,'close',anchor)]
    d['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}"
      events=[mark.call(key+'_open')]+events+[mark.call(key+'_close')]
    end
    events
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    EraZeroPresentation.midi_from_scheduled_events(events(d,allow_draft:allow_draft,anchor_midi:anchor_midi),anchor_midi,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
