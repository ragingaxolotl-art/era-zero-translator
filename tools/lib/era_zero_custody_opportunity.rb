# frozen_string_literal: true
require_relative 'era_zero_contextual_content'
module EraZeroCustodyOpportunity
  CONTRACT={'predicate'=>'contextual_practical_custody_opportunity','activity_compound'=>'CMP:c332d2e89b9f6177486fc93b','activity'=>'acquisition_of_practical_physical_custody','activity_binding'=>'prospective_holder_acquires_same_resource','opportunity'=>'contextual_circumstances_admit_realization_of_activity','activity_status'=>'possible_not_asserted','activity_time'=>'prospective_relative_to_opportunity','access_context_scope'=>'inside_opportunity_proposition','context_rules'=>'not_encoded_by_reference_label','prior_custody_if_realized'=>false,'custody_at_culmination_if_realized'=>true,'current_custody'=>'not_entailed','ownership'=>'not_entailed','normative_permission'=>'not_entailed','intention_or_willingness'=>'not_entailed','actual_acquisition'=>'not_entailed','ongoing_acquisition'=>'not_entailed','availability_for_other_activities'=>'not_asserted'}.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Custody opportunity requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,CONTRACT.keys+%w[profile status prospective_holder resource access_context speech_act scopes runtime_state content_id content_digest])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid custody opportunity contract' unless d['profile']=='EZCUSTODY-OPPORTUNITY-1' && d['status']=='draft' && CONTRACT.all?{|k,v|d[k]==v} && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    %w[prospective_holder resource access_context].each do |role|
      body={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>d[role],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
      hash=EraZeroContextualContent.digest(body)
      EraZeroContextualContent.validate!(body.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    end
    raise ArgumentError,'Explicit access context required' unless d['access_context']['kind']=='phonemic_reference'
    raise ArgumentError,'Distinct holder/resource required' if d['prospective_holder']['referent_id']==d['resource']['referent_id']
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Invalid custody opportunity identity' unless d['content_digest']==hash && d['content_id']=="EZCUSTOP:#{hash[0,24]}"
    true
  end
  def events(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi
    raise ArgumentError,'Invalid anchor' unless anchor.is_a?(Integer) && anchor.between?(39,88)
    atoms,compounds=EraZeroRenderer.load_authority
    mark=lambda{|name|EraZeroPresentation.grammar_marker({'performance'=>{'anchor_midi'=>anchor}},'custody_opportunity',name)}
    frame=lambda{|side|{'kind'=>'grammar_marker','grammar_profile'=>'EZCUSTODY-OPPORTUNITY-MUSIC-1','marker'=>"custody_opportunity_#{d['runtime_state']}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,17,d['runtime_state'],0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}}
    events=[frame.call('open')]
    [['experiencer',d['prospective_holder']],['content',d['resource']],['comparison_standard',d['access_context']]].each do |role,ref|
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
