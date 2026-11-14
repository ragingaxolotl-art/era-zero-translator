# frozen_string_literal: true
require_relative 'era_zero_contextual_content'
module EraZeroOwnership
  CONTRACT={'predicate'=>'framework_relative_ownership','relation'=>'owner_has_ownership_status_for_object_under_framework','framework_scope'=>'inside_proposition','framework_rules'=>'not_encoded_by_reference_label','physical_custody'=>'not_entailed','physical_control'=>'not_entailed','acquisition_or_transfer'=>'not_entailed','unlimited_use_or_disposal'=>'not_entailed','exclusive_ownership'=>'not_entailed','fractional_share'=>'unspecified','universal_agreement'=>'not_entailed','other_framework_status'=>'not_asserted'}.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Ownership requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,CONTRACT.keys+%w[profile status owner object framework speech_act scopes runtime_state content_id content_digest])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid ownership contract' unless d['profile']=='EZOWNERSHIP-MEANING-1' && d['status']=='draft' && CONTRACT.all?{|k,v|d[k]==v} && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    %w[owner object framework].each do |role|
      body={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>d[role],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
      hash=EraZeroContextualContent.digest(body)
      EraZeroContextualContent.validate!(body.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    end
    raise ArgumentError,'Explicit framework required' unless d['framework']['kind']=='phonemic_reference'
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Invalid ownership identity' unless d['content_digest']==hash && d['content_id']=="EZOWN:#{hash[0,24]}"
    true
  end
  def events(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi
    raise ArgumentError,'Invalid anchor' unless anchor.is_a?(Integer) && anchor.between?(39,88)
    atoms,compounds=EraZeroRenderer.load_authority
    mark=lambda{|name|EraZeroPresentation.grammar_marker({'performance'=>{'anchor_midi'=>anchor}},'ownership',name)}
    frame=lambda{|side|{'kind'=>'grammar_marker','grammar_profile'=>'EZOWNERSHIP-MUSIC-1','marker'=>"ownership_#{d['runtime_state']}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,14,d['runtime_state'],0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}}
    events=[frame.call('open')]
    [['experiencer',d['owner']],['content',d['object']],['comparison_standard',d['framework']]].each do |role,ref|
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
