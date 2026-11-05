# frozen_string_literal: true
require_relative 'era_zero_pain_stimulus'
module EraZeroPainComparison
  CONTRACT={'dimension'=>'felt_bodily_pain_intensity','basis'=>'same_experiencer_and_selected_context','scale'=>'ordinal_no_numeric_score','operand_scope'=>'governed_by_comparison_and_matrix_scope'}.freeze
  CODES={'greater_than'=>5,'less_than'=>6,'equal'=>7}.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Pain comparison requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,CONTRACT.keys+%w[profile status relation left right context speech_act scopes runtime_state content_digest content_id])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid pain comparison contract' unless d['profile']=='EZPAIN-COMPARISON-1' && d['status']=='draft' && CONTRACT.all?{|k,v|d[k]==v} && CODES.key?(d['relation']) && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    %w[left right].each do |key|
      EraZeroPainStimulus.validate!(d[key],allow_draft:true)
      raise ArgumentError,'Scoped comparison operand' unless d[key]['speech_act']=='assertion' && d[key]['scopes']==[]
    end
    raise ArgumentError,'Incompatible pain operands' unless d['left']['relation']==d['right']['relation'] && d['left']['outcome']['experiencer']==d['right']['outcome']['experiencer']
    ref={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>d['context'],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
    hash=EraZeroContextualContent.digest(ref)
    EraZeroContextualContent.validate!(ref.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Comparison identity mismatch' unless d['content_digest']==hash && d['content_id']=="EZPAINCMP:#{hash[0,24]}"
    true
  end
  def frame(d,side,anchor)
    raise ArgumentError,'Invalid comparison frame' unless anchor.is_a?(Integer) && anchor.between?(39,88) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZPAIN-COMPARISON-MUSIC-1','marker'=>"pain_comparison_#{d['relation']}_#{d['runtime_state']}_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,CODES.fetch(d['relation']),d['runtime_state'],0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def events(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi;atoms,compounds=EraZeroRenderer.load_authority
    mark=lambda{|name|EraZeroPresentation.grammar_marker({'performance'=>{'anchor_midi'=>anchor}},'pain-comparison',name)}
    ref=d['context'];reference=EraZeroRenderer.occurrence_events(ref,{'nodes'=>[ref],'edges'=>[]},atoms,compounds,anchor,'middle')
    events=[frame(d,'open',anchor),mark.call('role_content_open')]+reference+[mark.call('role_content_close'),mark.call('role_target_open')]+EraZeroPainStimulus.events(d['left'],allow_draft:true,anchor_midi:anchor)+[mark.call('role_target_close'),mark.call('role_comparison_standard_open')]+EraZeroPainStimulus.events(d['right'],allow_draft:true,anchor_midi:anchor)+[mark.call('role_comparison_standard_close'),frame(d,'close',anchor)]
    d['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}"
      events=[mark.call(key+'_open')]+events+[mark.call(key+'_close')]
    end
    events
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    EraZeroPresentation.midi_from_scheduled_events(events(d,allow_draft:allow_draft,anchor_midi:anchor_midi),anchor_midi,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
