# frozen_string_literal: true
require_relative 'era_zero_contextual_inquiry'
require_relative 'era_zero_foundations'
module EraZeroCuriosity
  CONTRACT={
    'predicate'=>'epistemic_curiosity','desire_foundation_id'=>'FND:f66b7a3877f4b0140a0b7023',
    'criterion'=>'The experiencer has epistemic interest in the contextual inquiry: resolving some contextually relevant uncertainty about the topic is itself motivationally attractive, rather than wanted solely for a separate practical outcome. Instrumental motives may coexist. This does not require pleasure, current attention, a conscious feeling, intention, action, successful discovery or complete ignorance of the topic.',
    'desired_outcome'=>'same_experiencer_gains_contextually_relevant_information_resolving_some_inquiry_uncertainty',
    'outcome_commitment'=>'desired_not_asserted','question_commitment'=>'contextual_not_specified'
  }.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Curiosity requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,CONTRACT.keys+%w[profile status experiencer inquiry speech_act scopes runtime_state content_digest content_id])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid curiosity contract' unless d['profile']=='EZCURIOSITY-1' && d['status']=='draft' && CONTRACT.all?{|k,v|d[k]==v} && %w[assertion question].include?(d['speech_act']) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    EraZeroContextualInquiry.validate!(d['inquiry'],allow_draft:true)
    holder={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>d['experiencer'],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
    hash=EraZeroContextualContent.digest(holder)
    EraZeroContextualContent.validate!(holder.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Curiosity identity mismatch' unless d['content_digest']==hash && d['content_id']=="EZCUR:#{hash[0,24]}"
    true
  end
  def frame(side,anchor)
    raise ArgumentError,'Invalid curiosity frame' unless anchor.is_a?(Integer) && anchor.between?(39,88) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZCURIOSITY-MUSIC-1','marker'=>"epistemic_curiosity_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,0,0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def midi(d,records,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);EraZeroFoundations.validate!(records,allow_draft:true)
    desire=records.find{|r|r['foundation_id']==CONTRACT['desire_foundation_id']};raise ArgumentError,'Original desire definition required' unless desire
    anchor=anchor_midi;formal={'performance'=>{'anchor_midi'=>anchor}};marker=lambda{|name|EraZeroPresentation.grammar_marker(formal,'curiosity',name)};r=d['experiencer']
    events=[frame('open',anchor),marker.call('role_experiencer_open')]+EraZeroRenderer.occurrence_events(r,{'nodes'=>[r],'edges'=>[]},{},{},anchor,'middle')+[marker.call('role_experiencer_close'),marker.call('role_content_open')]+EraZeroContextualInquiry.events(d['inquiry'],allow_draft:true,anchor_midi:anchor)+[marker.call('role_content_close'),EraZeroFoundations.event(desire,anchor:anchor,runtime_state:d['runtime_state'],allow_draft:true),frame('close',anchor)]
    d['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}"
      events=[marker.call(key+'_open')]+events+[marker.call(key+'_close')]
    end
    EraZeroPresentation.midi_from_scheduled_events(events,anchor,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
