# frozen_string_literal: true
require_relative 'era_zero_understanding'
require_relative 'era_zero_knowledge_acquisition'

module EraZeroRouteLearning
  READINGS = {
    'memorization'=>['route_information_recall', 'The experiencer retains contextually selected information representing the route and can recall that information to the contextual memory criterion. Recall need not be occurring now. The represented information need not be true or sufficient for navigation.', ['Truth of the memorized information','Practical navigation knowledge','Current attention or recall','Actual route traversal or permanent retention']],
    'navigation'=>['practical_route_knowledge', 'The experiencer knows how to follow the contextually identified route to the contextual practical-navigation criterion. This is usable procedural knowledge, not merely reciting route information. It does not assert present physical ability, actual traversal, complete mastery of every circumstance or permanent retention.', ['Physical mobility or actual travel','Verbatim recall of route instructions','Success under every circumstance','Permanent retention']],
    'familiarity'=>['route_familiarity', 'The experiencer has contextually adequate cognitive acquaintance with the identified route through direct or mediated exposure, so it is familiar rather than wholly unfamiliar. This does not by itself establish recall of route instructions, practical navigation knowledge, or actual traversal.', ['Practical navigation knowledge','Recall of complete instructions','Actual route traversal','Permanent retention']]
  }.freeze
  module_function
  def foundation(reading)
    predicate,definition,excludes=READINGS.fetch(reading)
    r={'profile'=>'EZFOUND-1','definition_version'=>'1.0.0','family_affinity'=>'MIN','status'=>'candidate','review'=>'reviews/route_learning.md','sound_code'=>4+READINGS.keys.index(reading),'display_title'=>predicate,'definition'=>definition,'roles'=>{'experiencer'=>['entity'],'target'=>['entity']},'excludes'=>excludes}
    hash=EraZeroContextualContent.digest(EraZeroFoundations.payload(r))
    r.merge('content_digest'=>hash,'foundation_id'=>"FND:#{hash[0,24]}")
  end
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Route learning requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,%w[profile status transition_root transition_runtime speech_act event_scopes result_assertion phase_contract result_state content_digest acquisition_id])
    raise ArgumentError,'Invalid route acquisition contract' unless d['profile']=='EZROUTE-LEARNING-1' && d['status']=='draft' && d['transition_root']=='ORI:110' && d['result_assertion']=='at_culmination_only' && d['phase_contract']=={'before'=>'does_not_hold','culmination'=>'holds','after'=>'unspecified'}
    allowed=[[],['negation'],['before_speech'],['before_speech','negation'],['previous_day'],['previous_day','negation'],['current_day'],['current_day','negation'],['current_day','before_speech'],['current_day','before_speech','negation']]
    raise ArgumentError,'Invalid route runtime, act or scope' unless [0,1,2].include?(d['transition_runtime']) && %w[assertion question].include?(d['speech_act']) && allowed.include?(d['event_scopes'])
    r=d['result_state'];EraZeroContextualContent.exact!(r,%w[reading predicate criterion experiencer route runtime_state content_commitment])
    definition=READINGS[r['reading']]
    raise ArgumentError,'Invalid route result contract' unless definition && r['predicate']==definition[0] && r['criterion']==definition[1] && [0,1,2].include?(r['runtime_state']) && r['content_commitment']==(r['reading']=='memorization' ? 'representation_without_truth_assertion' : 'contextual_route_reference')
    %w[experiencer route].each do |role|
      reference={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>r[role],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
      hash=EraZeroContextualContent.digest(reference)
      EraZeroContextualContent.validate!(reference.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    end
    route=r['route']
    raise ArgumentError,'Expected explicit route reference' unless route['kind']=='phonemic_reference' && route.dig('name','normalized_label')=='route' && %w[definite_nominal proximal_nominal distal_nominal].include?(route['reference_mode'])
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest acquisition_id].include?(k)})
    raise ArgumentError,'Route acquisition identity mismatch' unless d['content_digest']==hash && d['acquisition_id']=="EZROUTEACQ:#{hash[0,24]}"
    true
  end
  def frame(side,anchor)
    raise ArgumentError,'Invalid route frame' unless anchor.is_a?(Integer) && anchor.between?(37,90) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZROUTE-LEARNING-MUSIC-1','marker'=>"route_learning_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -37 : 37,0,0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def events(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi;r=d['result_state'];formal={'performance'=>{'anchor_midi'=>anchor}}
    marker=lambda{|name|EraZeroPresentation.grammar_marker(formal,'route-learning',name)}
    reference=lambda{|ref,register|EraZeroRenderer.occurrence_events(ref,{'nodes'=>[ref],'edges'=>[]},{},{},anchor,register)}
    result=[marker.call('role_experiencer_open')]+reference.call(r['experiencer'],'middle')+[marker.call('role_experiencer_close'),marker.call('role_target_open')]+reference.call(r['route'],'high')+[marker.call('role_target_close'),EraZeroFoundations.event(foundation(r['reading']),anchor:anchor,runtime_state:r['runtime_state'],allow_draft:true)]
    atoms,_=EraZeroRenderer.load_authority
    transition=EraZeroRenderer.atom_event(atoms.fetch('ORI:110'),occurrence_id:'acquisition',register:'middle',anchor_midi:anchor,runtime_code:d['transition_runtime'])
    events=[frame('open',anchor),EraZeroKnowledgeAcquisition.event('acquisition_result_open',anchor)]+result+[EraZeroKnowledgeAcquisition.event('acquisition_result_close',anchor),transition,frame('close',anchor)]
    d['event_scopes'].reverse_each do |scope|
      key=scope=='negation' ? 'negation' : "time_#{scope}"
      events=[marker.call(key+'_open')]+events+[marker.call(key+'_close')]
    end
    events
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    EraZeroPresentation.midi_from_scheduled_events(events(d,allow_draft:allow_draft,anchor_midi:anchor_midi),anchor_midi,d['speech_act']=='question' ? [0,2] : [0,0])
  end

end
