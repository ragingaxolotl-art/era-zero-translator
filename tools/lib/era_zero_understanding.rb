# frozen_string_literal: true
require_relative 'era_zero_contextual_content'
require_relative 'era_zero_foundations'

module EraZeroUnderstanding
  READINGS = {
    'communicated_content'=>'Grasps the intended meaning of contextually selected content conveyed by the anchor; does not assert that the conveyed claims are true.',
    'reasons'=>'Grasps contextually selected explanatory reasons concerning the anchor, to the contextual standard of explanatory adequacy; does not assert approval or shared motives.',
    'perspective'=>'Grasps the contextually selected standpoint or experiences of the anchor, to the contextual standard of perspective understanding; does not assert shared feelings, agreement or approval.'
  }.freeze
  module_function
  def foundation
    r={'profile'=>'EZFOUND-1','definition_version'=>'1.0.0','family_affinity'=>'MIN','status'=>'candidate','review'=>'reviews/understanding_content.md','sound_code'=>3,'display_title'=>'contextual content comprehension','definition'=>'The experiencer grasps the selected contextual content under its specific adequacy criterion. '+READINGS.values.join(' '),'roles'=>{'experiencer'=>['entity'],'content'=>['contextual_content']},'excludes'=>['Attention, receipt, confidence or memorization alone treated as comprehension','Truth of communicated claims, shared feelings, approval, acquisition or permanent retention inferred from comprehension','A topic label used as a particular message or explanation']}
    hash=EraZeroContextualContent.digest(EraZeroFoundations.payload(r))
    r.merge('content_digest'=>hash,'foundation_id'=>"FND:#{hash[0,24]}")
  end
  def validate!(document, allow_draft: false)
    raise ArgumentError, 'Understanding requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(document,%w[profile status predicate criterion experiencer content speech_act scopes runtime_state content_id content_digest])
    kind=document.dig('content','content_kind')
    unless document['profile']=='EZUNDERSTANDING-CONTENT-1' && document['status']=='draft' && document['predicate']=='content_comprehension' && READINGS.key?(kind) && document['criterion']==READINGS[kind] && %w[assertion question].include?(document['speech_act']) && [0,1,2].include?(document['runtime_state'])
      raise ArgumentError, 'Invalid comprehension contract'
    end
    EraZeroContextualContent.validate!(document['content'],allow_draft:true)
    # Exact reference validation, without treating the holder as understood content.
    holder={'profile'=>'EZCONTEXTUAL-CONTENT-1','status'=>'draft','content_kind'=>'topic','anchor'=>document['experiencer'],'resolution_scope'=>'local_context','assertion_commitment'=>'none'}
    hash=EraZeroContextualContent.digest(holder)
    EraZeroContextualContent.validate!(holder.merge('content_digest'=>hash,'content_id'=>"EZCTX:#{hash[0,24]}"),allow_draft:true)
    neg={'operator'=>'negation'};past={'operator'=>'time','relation'=>'before_speech'}
    raise ArgumentError, 'Unsupported comprehension scope' unless [[],[neg],[past],[past,neg]].include?(document['scopes'])
    body=document.reject{|k,_|%w[content_id content_digest].include?(k)};hash=EraZeroContextualContent.digest(body)
    raise ArgumentError, 'Understanding identity mismatch' unless document['content_digest']==hash && document['content_id']=="EZUND:#{hash[0,24]}"
    true
  end
  def events(document, anchor_midi: 60, allow_draft: false)
    validate!(document,allow_draft:allow_draft)
    formal={'performance'=>{'anchor_midi'=>anchor_midi}}
    marker=lambda{|name|EraZeroPresentation.grammar_marker(formal,'understanding',name)}
    reference=lambda{|r|EraZeroRenderer.occurrence_events(r,{'nodes'=>[r],'edges'=>[]},{},{},anchor_midi,'middle')}
    kind=document['content']['content_kind']
    notes=[marker.call('role_experiencer_open')]+reference.call(document['experiencer'])+[marker.call('role_experiencer_close'),marker.call('role_content_open'),EraZeroContextualContent.event(kind,'open',anchor_midi)]+reference.call(document['content']['anchor'])+[EraZeroContextualContent.event(kind,'close',anchor_midi),marker.call('role_content_close'),EraZeroFoundations.event(foundation,anchor:anchor_midi,runtime_state:document['runtime_state'],allow_draft:true)]
    document['scopes'].reverse_each do |scope|
      key=scope['operator']=='negation' ? 'negation' : "time_#{scope['relation']}"
      notes=[marker.call(key+'_open')]+notes+[marker.call(key+'_close')]
    end
    notes
  end
  def midi(document, anchor_midi: 60, allow_draft: false)
    notes=events(document,anchor_midi:anchor_midi,allow_draft:allow_draft)
    EraZeroPresentation.midi_from_scheduled_events(notes,anchor_midi,document['speech_act']=='question' ? [0,2] : [0,0])
  end
end
