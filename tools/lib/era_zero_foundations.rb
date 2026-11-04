# frozen_string_literal: true
require_relative 'era_zero_validation'
# Candidate profile only: approval is checked before any event can be produced.
module EraZeroFoundations
  KEYS=%w[profile definition_version family_affinity sound_code definition roles excludes].freeze
  OFFSETS={'low'=>-12,'middle'=>0,'high'=>12,'sustained_background'=>-5}.freeze
  module_function
  def payload(record);record.slice(*KEYS);end
  def path(code)
    raise ArgumentError,'Invalid foundation address.' unless code.is_a?(Integer)&&code.between?(0,6560)
    [0,-23,0,*code.to_s(3).rjust(8,'0').chars.map{|d|[0,1,-1][d.to_i]},0]
  end
  def validate!(records,allow_draft:false)
    raise ArgumentError,'Invalid foundation registry.' unless records.is_a?(Array)
    ids=[];codes=[]
    records.each do |r|
      valid=r.is_a?(Hash)&&r['profile']=='EZFOUND-1'&&r['definition_version']=='1.0.0'&&r['family_affinity']=='MIN'&&(['approved']+(allow_draft ? ['candidate'] : [])).include?(r['status'])&&r['definition'].is_a?(String)&&r['definition'].length>=30&&r['excludes'].is_a?(Array)&&!r['excludes'].empty?&&r['excludes'].all?{|v|v.is_a?(String)&&!v.strip.empty?}&&r['roles'].is_a?(Hash)&&!r['roles'].empty?
      raise ArgumentError,'Invalid or unapproved foundation.' unless valid
      r['roles'].each{|role,types|raise ArgumentError,'Invalid foundation argument types.' unless %w[experiencer target comparison_standard content].include?(role)&&types.is_a?(Array)&&!types.empty?&&types.uniq==types&&(types-%w[entity kind proposition]).empty?}
      path(r['sound_code']);digest=EraZeroValidation.fingerprint(payload(r))
      raise ArgumentError,'Foundation identity collision or mismatch.' unless r['content_digest']==digest&&r['foundation_id']=="FND:#{digest[0,24]}"&&!ids.include?(r['foundation_id'])&&!codes.include?(r['sound_code'])
      ids<<r['foundation_id'];codes<<r['sound_code']
    end
    records
  end
  def event(record,occurrence_id:'p',register:'middle',anchor:60,runtime_state:1,allow_draft:false)
    validate!([record],allow_draft:allow_draft)
    raise ArgumentError,'Invalid foundation performance context.' unless OFFSETS.key?(register)&&anchor.is_a?(Integer)&&[0,1,2].include?(runtime_state)&&occurrence_id.is_a?(String)&&!occurrence_id.empty?
    base=anchor+OFFSETS[register];relative=path(record['sound_code']);opening=[0,3,7];last=base+relative.last
    tail=case runtime_state
    when 0 then {'code'=>0,'name'=>'inactive','relative_motion_semitones'=>-1,'absolute_note'=>last-1,'articulation'=>'sharp_stop','duration_beats'=>0.25}
    when 1 then {'code'=>1,'name'=>'active','relative_motion_semitones'=>0,'absolute_note'=>base,'articulation'=>'firm_return','duration_beats'=>0.5}
    when 2 then {'code'=>2,'name'=>'num','relative_motion_semitones'=>7,'absolute_note'=>last+7,'articulation'=>'sustain','duration_beats'=>2.0}
    end
    raise ArgumentError,'Foundation pitch outside MIDI range.' unless (opening+relative).all?{|n|(base+n).between?(0,127)}&&tail['absolute_note'].between?(0,127)
    {'kind'=>'foundation','occurrence_id'=>occurrence_id,'target_id'=>record['foundation_id'],'register'=>register,'base_midi'=>base,'family_qualified_transliteration'=>"MIN·foundation-#{record['sound_code']}",'formal_carrier'=>"si-fen-#{record['sound_code'].to_s(3).rjust(8,'0').chars.map{|d|%w[ma ki nu][d.to_i]}.join('-')}",'family_opening_relative_semitones'=>opening,'family_opening_absolute_midi'=>opening.map{|n|base+n},'address_relative_semitones'=>relative,'address_absolute_midi'=>relative.map{|n|base+n},'note_duration_beats'=>1.0,'runtime_tail'=>tail}
  end
end
