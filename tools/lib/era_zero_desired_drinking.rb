# frozen_string_literal: true
require_relative 'era_zero_drinking'
module EraZeroDesiredDrinking
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Desired drinking requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,%w[profile status foundation_id holder content content_status outcome_commitment subject_binding speech_act scopes runtime_state content_id content_digest])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid desired drinking contract' unless d['profile']=='EZDESIRED-DRINKING-1' && d['status']=='draft' && d['foundation_id']=='FND:f66b7a3877f4b0140a0b7023' && d['content_status']=='intensional' && d['outcome_commitment']=='desired_not_asserted' && %w[same_as_desire_holder explicit_content_subject].include?(d['subject_binding']) && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    EraZeroDrinking.reference!(d['holder']);EraZeroDrinking.validate!(d['content'],allow_draft:true)
    raise ArgumentError,'Invalid content subject control' unless d['content']['speech_act']=='assertion' && (d['subject_binding']!='same_as_desire_holder' || d['holder']==d['content']['drinker'])
    EraZeroDrinking.identity!(d,'EZDESDRINK');true
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi
    raise ArgumentError,'Invalid anchor' unless anchor.is_a?(Integer) && anchor.between?(39,88)
    atoms,compounds=EraZeroRenderer.load_authority
    mark=lambda{|name|EraZeroPresentation.grammar_marker({'performance'=>{'anchor_midi'=>anchor}},'desired-drinking',name)}
    frame=lambda{|side|{'kind'=>'grammar_marker','grammar_profile'=>'EZDESIRED-DRINKING-MUSIC-1','marker'=>"desired_drinking_#{d['subject_binding']}_#{d['runtime_state']}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,d['subject_binding']=='same_as_desire_holder' ? 12 : 13,d['runtime_state'],0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}}
    ref=d['holder'];events=[frame.call('open'),mark.call('role_experiencer_open')]+EraZeroRenderer.occurrence_events(ref,{'nodes'=>[ref],'edges'=>[]},atoms,compounds,anchor,'middle')+[mark.call('role_experiencer_close'),mark.call('proposition_content_open')]+EraZeroDrinking.events(d['content'],allow_draft:true,anchor_midi:anchor)+[mark.call('proposition_content_close'),frame.call('close')]
    d['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}";events=[mark.call(key+'_open')]+events+[mark.call(key+'_close')]
    end
    EraZeroPresentation.midi_from_scheduled_events(events,anchor,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
