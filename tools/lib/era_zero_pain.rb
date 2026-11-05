# frozen_string_literal: true
require_relative 'era_zero_contextual_content'
require_relative 'era_zero_compound_conventions'
module EraZeroPain
  CONTRACT={'predicate'=>'felt_bodily_pain','dependency'=>'CMP:6c9e3042a361ccae6ecf5980','dependency_version'=>'1.0.0','quality'=>'bodily_pain_experience','injury_commitment'=>'not_entailed','cause_commitment'=>'unspecified','intensity_commitment'=>'unspecified','stimulus_commitment'=>'unspecified'}.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Pain requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,CONTRACT.keys+%w[profile status experiencer speech_act scopes runtime_state content_digest content_id])
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError,'Invalid pain contract' unless d['profile']=='EZPAIN-MEANING-1' && d['status']=='draft' && CONTRACT.all?{|k,v|d[k]==v} && %w[assertion question].include?(d['speech_act']) && d['runtime_state'].is_a?(Integer) && [0,1,2].include?(d['runtime_state']) && [[],[neg],[past],[past,neg]].include?(d['scopes'])
    ref={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>d['experiencer'],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
    hash=EraZeroContextualContent.digest(ref)
    EraZeroContextualContent.validate!(ref.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Pain identity mismatch' unless d['content_digest']==hash && d['content_id']=="EZPAIN:#{hash[0,24]}"
    true
  end
  def frame(side,anchor)
    raise ArgumentError,'Invalid pain frame' unless anchor.is_a?(Integer) && anchor.between?(39,88) && %w[open close].include?(side)
    {'kind'=>'grammar_marker','grammar_profile'=>'EZPAIN-MUSIC-1','marker'=>"felt_bodily_pain_#{side}",'register'=>'middle','base_midi'=>anchor,'family_opening_absolute_midi'=>[],'address_absolute_midi'=>[0,side=='open' ? -39 : 39,1,0].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end
  def midi(d,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft);anchor=anchor_midi
    atoms,compounds=EraZeroRenderer.load_authority
    dependency=compounds.fetch(CONTRACT['dependency'])
    raise ArgumentError,'Changed felt dependency' unless dependency['definition_version']==CONTRACT['dependency_version'] && dependency.dig('conventional_meaning','sound_code')==11
    formal={'performance'=>{'anchor_midi'=>anchor}};mark=lambda{|name|EraZeroPresentation.grammar_marker(formal,'pain',name)}
    convention=lambda{|side|EraZeroCompoundConventions.event(dependency['conventional_meaning'],side,'pain-base',anchor,[])}
    ref=d['experiencer'];references=EraZeroRenderer.occurrence_events(ref,{'nodes'=>[ref],'edges'=>[]},atoms,compounds,anchor,'middle')
    conscious=EraZeroRenderer.atom_event(atoms.fetch('LIF:001'),occurrence_id:'pain-base',register:'middle',anchor_midi:anchor,runtime_code:nil);conscious['boundary_after_beats']=0
    head=EraZeroRenderer.atom_event(atoms.fetch('MIN:001'),occurrence_id:'pain-base',register:'middle',anchor_midi:anchor,runtime_code:d['runtime_state']);head['boundary_after_beats']=0.5
    events=[frame('open',anchor),convention.call('open'),mark.call('role_experiencer_open')]+references+[mark.call('role_experiencer_close'),conscious,head,convention.call('close'),frame('close',anchor)]
    d['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}"
      events=[mark.call(key+'_open')]+events+[mark.call(key+'_close')]
    end
    EraZeroPresentation.midi_from_scheduled_events(events,anchor,d['speech_act']=='question' ? [0,2] : [0,0])
  end
end
