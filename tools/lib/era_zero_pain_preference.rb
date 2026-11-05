# frozen_string_literal: true
require_relative 'era_zero_pain_comparison'
module EraZeroPainPreference
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Pain preference requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,%w[profile status foundation_id holder target comparison_standard pain_comparison more_painful_role restriction_scope speech_act scopes runtime_state content_id content_digest])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid preference contract' unless d['profile']=='EZPAIN-PREFERENCE-1' && d['status']=='draft' && d['foundation_id']=='FND:018dd25d713dff83661a76a4' && %w[target comparison_standard].include?(d['more_painful_role']) && d['restriction_scope']=='reference_descriptions_not_preference_polarity' && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    %w[holder target comparison_standard].each do |role|
      ref={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>d[role],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
      hash=EraZeroContextualContent.digest(ref)
      EraZeroContextualContent.validate!(ref.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    end
    raise ArgumentError,'Ambiguous alternative identities' if d['target']==d['comparison_standard']
    c=d['pain_comparison'];EraZeroPainComparison.validate!(c,allow_draft:true)
    more=d['more_painful_role'];less=more=='target' ? 'comparison_standard' : 'target'
    raise ArgumentError,'Invalid restriction binding' unless c['relation']=='greater_than' && c['speech_act']=='assertion' && c['scopes']==[] && c['left']['stimulus']==d[more] && c['right']['stimulus']==d[less]
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Preference identity mismatch' unless d['content_digest']==hash && d['content_id']=="EZPAINPREF:#{hash[0,24]}"
    true
  end
  def frame(d,side,anchor)
    raise ArgumentError,'Invalid preference frame' unless anchor.is_a?(Integer) && anchor.between?(39,88) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZPAIN-PREFERENCE-MUSIC-1','marker'=>"pain_preference_#{d['runtime_state']}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,8,d['runtime_state'],0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi;atoms,compounds=EraZeroRenderer.load_authority
    mark=lambda{|name|EraZeroPresentation.grammar_marker({'performance'=>{'anchor_midi'=>anchor}},'pain-preference',name)}
    events=[frame(d,'open',anchor)]
    [['experiencer','holder'],['target','target'],['comparison_standard','comparison_standard']].each do |role,key|
      ref=d[key];events += [mark.call("role_#{role}_open")]+EraZeroRenderer.occurrence_events(ref,{'nodes'=>[ref],'edges'=>[]},atoms,compounds,anchor,'middle')+[mark.call("role_#{role}_close")]
    end
    events += EraZeroPainComparison.events(d['pain_comparison'],allow_draft:true,anchor_midi:anchor)+[frame(d,'close',anchor)]
    d['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}"
      events=[mark.call(key+'_open')]+events+[mark.call(key+'_close')]
    end
    EraZeroPresentation.midi_from_scheduled_events(events,anchor,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
