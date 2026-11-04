# frozen_string_literal: true
require_relative 'era_zero_presentation'
module EraZeroKnowledgeAcquisition
  module_function
  FIELDS = %w[profile status transition_root transition_runtime speech_act event_scopes result_assertion phase_contract result_state vocabulary content_digest acquisition_id].freeze
  KNOWLEDGE_ID = 'FND:fe36cb2a6d649151067c7754'.freeze
  def digest(value)
    Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(value)))
  end
  def validate!(document, allow_draft: false)
    raise ArgumentError, 'Acquisition requires draft opt-in' unless allow_draft
    raise ArgumentError, 'Invalid acquisition fields' unless document.is_a?(Hash) && document.keys.sort == FIELDS.sort
    raise ArgumentError, 'Invalid acquisition contract' unless document['profile']=='EZKNOWLEDGE-ACQUISITION-1' && document['status']=='draft' && document['transition_root']=='ORI:110' && document['result_assertion']=='at_culmination_only' && document['phase_contract']=={'before'=>'does_not_hold','culmination'=>'holds','after'=>'unspecified'}
    runtime=document['transition_runtime']
    raise ArgumentError, 'Invalid acquisition runtime' unless runtime.is_a?(Hash) && runtime.keys==['code'] && [0,1,2].include?(runtime['code'])
    allowed=[[],['negation'],['before_speech'],['before_speech','negation'],['previous_day'],['previous_day','negation'],['current_day'],['current_day','negation'],['current_day','before_speech'],['current_day','before_speech','negation']]
    raise ArgumentError,'Invalid acquisition act or scope' unless %w[assertion question].include?(document['speech_act']) && allowed.include?(document['event_scopes'])
    ir=document['result_state'];records=document['vocabulary']
    # Full authority-based validation and formal regeneration, not digest alone.
    formal=EraZeroRenderer.render(ir,foundation_records:records,allow_draft_foundations:true)
    center=ir['edges'].find{|e|e['type']=='centers'&&e['to']==ir['root_clause']}
    predicate=ir['nodes'].find{|n|n['node_id']==center['from']}
    definition=records.find{|r|r['foundation_id']==predicate['target_id']}
    raise ArgumentError, 'Invalid knowledge result' unless ir['speech_act']=='assertion' && predicate['target_type']=='foundation' && definition && definition['foundation_id']==KNOWLEDGE_ID && definition['roles']=={'experiencer'=>['entity'],'content'=>['question']}
    raise ArgumentError, 'Result time belongs to culmination' if ir['edges'].any?{|e|e['type']=='time_relation'&&e['to']==ir['root_clause']}
    body=document.reject{|k,_|%w[content_digest acquisition_id].include?(k)};expected=digest(body)
    raise ArgumentError, 'Acquisition identity mismatch' unless document['content_digest']==expected && document['acquisition_id']=="EZACQ:#{expected[0,24]}"
    formal
  end
  def frames
    %w[open close].flat_map{|side|[['knowledge_acquisition',32],['acquisition_result',33]].map{|name,code|{'marker'=>"#{name}_#{side}",'path'=>[0,side=='open' ? -code : code,0,0]}}}
  end
  def event(marker,anchor)
    frame=frames.find{|f|f['marker']==marker}
    raise ArgumentError,'Invalid acquisition frame/anchor' unless frame && anchor.is_a?(Integer) && frame['path'].all?{|n|(anchor+n).between?(0,127)}
    {'kind'=>'grammar_marker','grammar_profile'=>'EZKNOWLEDGE-ACQUISITION-MUSIC-1','marker'=>marker,'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>frame['path'].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def midi(document,allow_draft:false)
    formal=validate!(document,allow_draft:allow_draft);anchor=formal.dig('performance','anchor_midi')
    atoms,_compounds=EraZeroRenderer.load_authority
    transition=EraZeroRenderer.atom_event(atoms.fetch('ORI:110'),occurrence_id:'acquisition',register:'middle',anchor_midi:anchor,runtime_code:document.dig('transition_runtime','code'))
    events=[event('knowledge_acquisition_open',anchor),event('acquisition_result_open',anchor)]+EraZeroPresentation.scheduled_lexical_events(formal)+[event('acquisition_result_close',anchor),transition,event('knowledge_acquisition_close',anchor)]
    document['event_scopes'].reverse_each do |scope|
      prefix=scope=='negation' ? 'negation' : "time_#{scope}"
      events=[EraZeroPresentation.grammar_marker(formal,'acquisition',"#{prefix}_open")]+events+[EraZeroPresentation.grammar_marker(formal,'acquisition',"#{prefix}_close")]
    end
    EraZeroPresentation.midi_from_scheduled_events(events,anchor,document['speech_act']=='question' ? [0,2] : [0,0])
  end
end
