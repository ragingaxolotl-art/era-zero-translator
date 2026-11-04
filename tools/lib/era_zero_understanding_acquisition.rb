# frozen_string_literal: true
require_relative 'era_zero_understanding'
require_relative 'era_zero_knowledge_acquisition'
module EraZeroUnderstandingAcquisition
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Understanding acquisition requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,%w[profile status transition_root transition_runtime speech_act event_scopes result_assertion phase_contract result_state content_digest acquisition_id])
    raise ArgumentError,'Invalid comprehension acquisition contract' unless d['profile']=='EZUNDERSTANDING-ACQUISITION-1' && d['status']=='draft' && d['transition_root']=='ORI:110' && d['result_assertion']=='at_culmination_only' && d['phase_contract']=={'before'=>'does_not_hold','culmination'=>'holds','after'=>'unspecified'}
    raise ArgumentError,'Invalid transition runtime' unless d['transition_runtime'].is_a?(Hash) && d['transition_runtime'].keys==['code'] && [0,1,2].include?(d['transition_runtime']['code'])
    allowed=[[],['negation'],['before_speech'],['before_speech','negation'],['previous_day'],['previous_day','negation'],['current_day'],['current_day','negation'],['current_day','before_speech'],['current_day','before_speech','negation']]
    raise ArgumentError,'Invalid acquisition act/scope' unless %w[assertion question].include?(d['speech_act']) && allowed.include?(d['event_scopes'])
    result=d['result_state'];EraZeroUnderstanding.validate!(result,allow_draft:true)
    raise ArgumentError,'Result belongs at culmination only' unless result['speech_act']=='assertion' && result['scopes']==[]
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest acquisition_id].include?(k)})
    raise ArgumentError,'Acquisition identity mismatch' unless d['content_digest']==hash && d['acquisition_id']=="EZUACQ:#{hash[0,24]}"
    true
  end
  def event(side,anchor)
    raise ArgumentError,'Invalid acquisition anchor' unless anchor.is_a?(Integer) && anchor.between?(36,91) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZUNDERSTANDING-ACQUISITION-MUSIC-1','marker'=>"understanding_acquisition_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -36 : 36,0,0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi;formal={'performance'=>{'anchor_midi'=>anchor}}
    atoms,_compounds=EraZeroRenderer.load_authority
    transition=EraZeroRenderer.atom_event(atoms.fetch('ORI:110'),occurrence_id:'acquisition',register:'middle',anchor_midi:anchor,runtime_code:d['transition_runtime']['code'])
    events=[event('open',anchor),EraZeroKnowledgeAcquisition.event('acquisition_result_open',anchor)]+EraZeroUnderstanding.events(d['result_state'],anchor_midi:anchor,allow_draft:true)+[EraZeroKnowledgeAcquisition.event('acquisition_result_close',anchor),transition,event('close',anchor)]
    d['event_scopes'].reverse_each do |scope|
      key=scope=='negation' ? 'negation' : "time_#{scope}"
      events=[EraZeroPresentation.grammar_marker(formal,'acquisition',key+'_open')]+events+[EraZeroPresentation.grammar_marker(formal,'acquisition',key+'_close')]
    end
    EraZeroPresentation.midi_from_scheduled_events(events,anchor,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
