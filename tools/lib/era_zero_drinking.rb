# frozen_string_literal: true
require_relative 'era_zero_contextual_content'
module EraZeroDrinking
  CONTRACT={'predicate'=>'literal_drinking','action_category'=>'oral_intake_of_liquid_as_drink','participant_binding'=>'drinker_performs_intake_of_material','material_classification_scope'=>'within_drinking_content_not_global_label_fact','thirst_commitment'=>'not_entailed','ownership_commitment'=>'not_entailed','pleasure_commitment'=>'not_entailed','benefit_commitment'=>'not_entailed','intention_commitment'=>'not_entailed','whole_amount_consumption'=>'not_asserted'}.freeze
  MATERIAL={'material_kind_commitment'=>'label_not_classification','quantity'=>'unspecified','whole_amount_consumption'=>'not_asserted','existence_commitment'=>'governed_by_enclosing_content'}.freeze
  VIEWS={'ongoing'=>'Drinking activity is in progress; no completed intake amount or completed event is asserted.','bounded'=>'A bounded drinking event is presented as a whole; some intake belongs to that event, but no entire contextual portion or numeric amount is asserted.','habitual'=>'Drinking is a recurring or characteristic activity; no particular occurrence at speech time is asserted.'}.freeze
  CODES={'ongoing'=>9,'bounded'=>10,'habitual'=>11}.freeze
  module_function
  def identity!(d,prefix)
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Invalid identity' unless d['content_digest']==hash && d['content_id']=="#{prefix}:#{hash[0,24]}"
  end
  def reference!(r)
    body={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>r,'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
    hash=EraZeroContextualContent.digest(body)
    EraZeroContextualContent.validate!(body.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
  end
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Drinking requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,CONTRACT.keys+%w[profile status drinker material viewpoint viewpoint_contract speech_act scopes runtime_state content_id content_digest])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid drinking contract' unless d['profile']=='EZDRINKING-MEANING-1' && d['status']=='draft' && CONTRACT.all?{|k,v|d[k]==v} && VIEWS.key?(d['viewpoint']) && d['viewpoint_contract']==VIEWS[d['viewpoint']] && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    reference!(d['drinker']);m=d['material'];EraZeroContextualContent.exact!(m,MATERIAL.keys+%w[profile status reading reference content_digest content_id])
    raise ArgumentError,'Invalid material contract' unless m['profile']=='EZMATERIAL-REFERENCE-1' && m['status']=='draft' && MATERIAL.all?{|k,v|m[k]==v}
    r=m['reference'];EraZeroContextualContent.exact!(r,%w[node_id kind value_type name referent_id reference_mode])
    modes={'nominal_class'=>'class','definite_nominal'=>'definite','proximal_nominal'=>'proximal','distal_nominal'=>'distal'};mode=r['reference_mode'];kind=mode=='nominal_class'
    raise ArgumentError,'Invalid material binding' unless r['node_id']=='material' && r['kind']=='phonemic_reference' && modes.key?(mode) && r['value_type']==(kind ? 'kind' : 'entity') && m['reading']==(kind ? 'kind' : 'contextual_portion') && r['referent_id']=="nominal:#{modes[mode]}:#{r.dig('name','name_id')}" && r.dig('name','object_tag').nil?
    # Reuse strict name checking without changing the original kind marker.
    ref=Marshal.load(Marshal.dump(r));ref['node_id']='anchor';ref['value_type']='entity'
    if kind;ref['reference_mode']='definite_nominal';ref['referent_id']="nominal:definite:#{r.dig('name','name_id')}";end
    reference!(ref);identity!(m,'EZMATREF');identity!(d,'EZDRINK');true
  end
  def events(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi
    raise ArgumentError,'Invalid anchor' unless anchor.is_a?(Integer) && anchor.between?(39,88)
    atoms,compounds=EraZeroRenderer.load_authority
    mark=lambda{|name|EraZeroPresentation.grammar_marker({'performance'=>{'anchor_midi'=>anchor}},'drinking',name)}
    frame=lambda{|side|{'kind'=>'grammar_marker','grammar_profile'=>'EZDRINKING-MUSIC-1','marker'=>"drinking_#{d['viewpoint']}_#{d['runtime_state']}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,CODES[d['viewpoint']],d['runtime_state'],0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}}
    events=[frame.call('open')]
    [['experiencer',d['drinker']],['content',d['material']['reference'].merge('value_type'=>'entity')]].each do |role,ref|
      events += [mark.call("role_#{role}_open")]+EraZeroRenderer.occurrence_events(ref,{'nodes'=>[ref],'edges'=>[]},atoms,compounds,anchor,'middle')+[mark.call("role_#{role}_close")]
    end
    events << frame.call('close')
    d['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}";events=[mark.call(key+'_open')]+events+[mark.call(key+'_close')]
    end
    events
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    EraZeroPresentation.midi_from_scheduled_events(events(d,allow_draft:allow_draft,anchor_midi:anchor_midi),anchor_midi,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
