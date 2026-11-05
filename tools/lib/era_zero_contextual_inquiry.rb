# frozen_string_literal: true
require_relative 'era_zero_contextual_content'
module EraZeroContextualInquiry
  CONTRACT={'profile'=>'EZCONTEXTUAL-INQUIRY-1','status'=>'draft','content_kind'=>'contextual_question_set','resolution_scope'=>'local_context','question_selection'=>'contextually_relevant_unresolved','answer_commitment'=>'none','specific_question_supplied'=>false}.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Contextual inquiry requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,CONTRACT.keys+%w[topic content_digest content_id])
    raise ArgumentError,'Invalid inquiry contract' unless CONTRACT.all?{|k,v|d[k]==v}
    EraZeroContextualContent.validate!(d['topic'],allow_draft:true)
    raise ArgumentError,'Expected topic content' unless d['topic']['content_kind']=='topic' && !d['topic'].key?('selection')
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Inquiry identity mismatch' unless d['content_digest']==hash && d['content_id']=="EZINQUIRY:#{hash[0,24]}"
    true
  end
  def frame(side,anchor)
    raise ArgumentError,'Invalid inquiry frame' unless anchor.is_a?(Integer) && anchor.between?(38,89) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZCONTEXTUAL-INQUIRY-MUSIC-1','marker'=>"contextual_inquiry_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -38 : 38,0,0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def events(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi;r=d['topic']['anchor']
    [frame('open',anchor),EraZeroContextualContent.event('topic','open',anchor)]+EraZeroRenderer.occurrence_events(r,{'nodes'=>[r],'edges'=>[]},{},{},anchor,'middle')+[EraZeroContextualContent.event('topic','close',anchor),frame('close',anchor)]
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    EraZeroPresentation.midi_from_scheduled_events(events(d,allow_draft:allow_draft,anchor_midi:anchor_midi),anchor_midi,[0,0])
  end
end
