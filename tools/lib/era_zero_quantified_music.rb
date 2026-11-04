# frozen_string_literal: true
module EraZeroQuantifiedMusic
  module_function
  def frames
    result=[]
    %w[open close].each do |side|
      sign=side=='open' ? -1 : 1
      %w[exact at_least at_most].each_with_index{|q,i|result << {'marker'=>"counted_#{q}_#{side}",'path'=>[0,sign*27,i,0]}}
      result << {'marker'=>"counted_restriction_#{side}",'path'=>[0,sign*28,0,0]}
      result << {'marker'=>"counted_predicate_#{side}",'path'=>[0,sign*29,0,0]}
    end
    128.times{|depth|result << {'marker'=>"counted_reference_#{depth}",'path'=>[0,-30]+depth.to_s(3).rjust(5,'0').chars.map{|d|[0,1,-1][d.to_i]}+[0]}}
    result
  end
  def event(marker,anchor=60)
    frame=frames.find{|f|f['marker']==marker}
    raise ArgumentError,'Invalid draft counted-music marker or anchor.' unless frame&&anchor.is_a?(Integer)&&frame['path'].all?{|n|(anchor+n).between?(0,127)}
    {'kind'=>'grammar_marker','grammar_profile'=>'EZCOUNT-MUSIC-1','marker'=>marker,'occurrence_id'=>'draft-count','target_id'=>"EZCOUNT:#{marker}",'register'=>'middle','base_midi'=>anchor,'family_qualified_transliteration'=>marker,'formal_carrier'=>'','family_opening_relative_semitones'=>[],'family_opening_absolute_midi'=>[],'address_relative_semitones'=>frame['path'],'address_absolute_midi'=>frame['path'].map{|n|anchor+n},'note_duration_beats'=>0.25,'boundary_after_beats'=>0.5}
  end

end
