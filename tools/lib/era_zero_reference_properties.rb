# frozen_string_literal: true
# EZREFPROPERTY-1. Keep the restriction inside the reference's audible frame,
# including when that reference is substituted into a nested compound slot.
module EraZeroReferenceProperties
  module_function
  def valid?(node)
    p = node['property_restriction']
    node['kind'] == 'phonemic_reference' && node['reference_mode'] == 'definite_nominal' && p.is_a?(Hash) &&
      p.keys.sort == %w[comparison dimension magnitude unit] && p['dimension'] == 'mass' && p['unit'] == 'kilogram' &&
      %w[greater_than less_than].include?(p['comparison']) && p['magnitude'].is_a?(String) && p['magnitude'].length <= 1024 &&
      p['magnitude'].match?(/\A(?:0|[1-9][0-9]*)(?:\.[0-9]*[1-9])?\z/)
  end
  def restrict(node, events, anchor)
    return events unless node.key?('property_restriction')
    raise ArgumentError, 'unsupported nominal property restriction' unless valid?(node)
    p = node.fetch('property_restriction')
    marker = lambda do |name, path|
      {'kind'=>'grammar_marker', 'grammar_profile'=>'EZGRAM-1', 'marker'=>name, 'occurrence_id'=>node.fetch('node_id'), 'target_id'=>"EZGRAM:#{name}", 'register'=>'middle', 'base_midi'=>anchor,
       'family_qualified_transliteration'=>name, 'formal_carrier'=>'', 'family_opening_relative_semitones'=>[], 'family_opening_absolute_midi'=>[],
       'address_relative_semitones'=>path, 'address_absolute_midi'=>path.map { |n| anchor+n }, 'note_duration_beats'=>0.25, 'boundary_after_beats'=>0.5}
    end
    compare = p['comparison'] == 'greater_than' ? 1 : 2
    value = [marker.call("measure_compare_#{p['comparison']}_open", [0,-17,compare,0]), marker.call('measurement_open',[0,-13,-1,0])] +
      p['magnitude'].chars.map { |c| c == '.' ? marker.call('decimal_point',[0,10,-1,0]) : marker.call("digit_#{c}",[0,10,c.to_i/4,c.to_i%4,0]) } +
      [marker.call('measurement_unit_9',[0,13,9,13,0]), marker.call('measurement_close',[0,13,1,0]), marker.call("measure_compare_#{p['comparison']}_close",[0,17,compare,0])]
    [marker.call('nominal_mass_open',[0,-21,1,0])] + value + [marker.call('nominal_property_head',[0,21,0,21])] + events + [marker.call('nominal_mass_close',[0,21,1,0])]
  end
end
