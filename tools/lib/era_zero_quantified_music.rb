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
end
