# frozen_string_literal: true
require_relative 'era_zero_curiosity'
require_relative 'era_zero_route_learning'
require_relative 'era_zero_understanding_acquisition'
module EraZeroCognitiveConjunction
  MEMBERS={'EZCURIOSITY-1'=>EraZeroCuriosity,'EZUNDERSTANDING-CONTENT-1'=>EraZeroUnderstanding,'EZROUTE-LEARNING-1'=>EraZeroRouteLearning,'EZUNDERSTANDING-ACQUISITION-1'=>EraZeroUnderstandingAcquisition}.freeze
  module_function
  def validate!(d,allow_draft:false)
    raise ArgumentError,'Cognitive conjunction requires draft opt-in' unless allow_draft
    EraZeroContextualContent.exact!(d,%w[profile status operator speech_act members content_id content_digest])
    raise ArgumentError,'Invalid conjunction contract' unless d['profile']=='EZCOGNITIVE-CONJUNCTION-1' && d['status']=='draft' && d['operator']=='all_of' && d['speech_act']=='assertion' && d['members'].is_a?(Array) && d['members'].length.between?(2,8)
    d['members'].each do |member|
      raise ArgumentError,'Unsupported declarative member' unless member.is_a?(Hash) && MEMBERS.key?(member['profile']) && member['speech_act']=='assertion'
      MEMBERS.fetch(member['profile']).validate!(member,allow_draft:true)
    end
    hash=EraZeroContextualContent.digest(d.reject{|k,_|%w[content_digest content_id].include?(k)})
    raise ArgumentError,'Conjunction identity mismatch' unless d['content_digest']==hash && d['content_id']=="EZCOGAND:#{hash[0,24]}"
    true
  end
  def midi(d,records,allow_draft:false,anchor_midi:60)
    validate!(d,allow_draft:allow_draft)
    formal={'performance'=>{'anchor_midi'=>anchor_midi}};marker=lambda{|name|EraZeroPresentation.grammar_marker(formal,'conjunction',name)}
    events=[marker.call('coord_all_of_open')]
    d['members'].each_with_index do |member,i|
      events << marker.call('coord_member') if i>0
      implementation=MEMBERS.fetch(member['profile'])
      args=[member];args << records if implementation==EraZeroCuriosity
      events.concat(implementation.events(*args,allow_draft:true,anchor_midi:anchor_midi))
    end
    events << marker.call('coord_all_of_close')
    EraZeroPresentation.midi_from_scheduled_events(events,anchor_midi,[0,0])
  end
end
