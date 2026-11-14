# frozen_string_literal: true
module EraZeroSubjectControl
  SUBJECTS={'FND:fe36cb2a6d649151067c7754'=>['foundation','experiencer'],'CMP:1e2ec87e1feff0da19aadc3b'=>['compound','actor',%w[h s-actor]],'CMP:d54499d2989fa97349e8e23d'=>['compound','experiencer',%w[h h s-experiencer]],'CMP:c58b38d03fab27880ac3e1f0'=>['compound','experiencer',%w[h h s-experiencer]],'CMP:748be1f0ce7ceb2963716292'=>['compound','experiencer',%w[h h s-experiencer]],'CMP:60cd46250d183e3105b7250a'=>['compound','experiencer',%w[h h s-experiencer]],'CMP:3c13b9c619d95f1c40ea5da5'=>['compound','experiencer',%w[h s-experiencer]],'LIF:211'=>['atom','actor'],'MOV:201'=>['atom','bearer'],'LIF:001'=>['atom','bearer'],'LIF:002'=>['atom','bearer'],'LIF:011'=>['atom','bearer'],'LIF:012'=>['atom','bearer'],'WRN:001'=>['atom','bearer'],'REP:001'=>['atom','bearer'],'MIN:201'=>['atom','bearer'],'FND:018dd25d713dff83661a76a4'=>['foundation','experiencer']}.freeze
  module_function
  def validate!(ir)
    nodes=ir['nodes'].to_h{|n|[n['node_id'],n]};edges=ir['edges']
    nodes.values.select{|n|n['kind']=='reference'&&n['reference_type']=='desire_subject'}.each do |n|
      fail_control=-> {raise ArgumentError,'Invalid desired-subject identity.'}
      fail_control.call unless n['value_type']=='entity' && (n.keys-%w[node_id kind reference_type referent_id value_type]).empty? && Array(ir.dig('discourse_constraints','declared_referents')).include?(n['referent_id'])
      links=edges.select{|e|e['from']==n['node_id']};role=links.find{|e|e['type']=='fills_role'};identity=links.find{|e|e['type']=='corefers_with'}
      bindings=nodes.values.flat_map{|p|Array(p['compound_bindings']).select{|b|b['argument_id']==n['node_id']}.map{|b|[p,b]}}
      fail_control.call unless identity&&links.length==(role ? 2 : 1)&&bindings.length==(role ? 0 : 1)
      predicate=role ? nodes[role['to']] : bindings[0][0];holder=nodes[identity['to']]
      subject=predicate&&SUBJECTS[predicate['target_id']]
      fail_control.call unless subject&&predicate['target_type']==subject[0]&&holder&&%w[phonemic_reference deictic_reference].include?(holder['kind'])&&holder['referent_id']==n['referent_id']
      if subject[0]=='compound'
        fail_control.call unless !role&&bindings[0][1]['slot_path']==subject[2]
      else
        fail_control.call unless role&&role['role']==subject[1]
      end
      id=predicate['node_id'];seen=[]
      until nodes[id]['kind']=='clause'
        fail_control.call if seen.include?(id);seen<<id
        up=edges.select{|e|e['from']==id&&%w[scopes centers].include?(e['type'])};fail_control.call unless up.length==1;id=up[0]['to']
      end
      parents=edges.select{|e|e['from']==id&&e['type']=='fills_role'&&e['role']=='content'}
      fail_control.call unless nodes[id]['content_status']=='intensional'&&nodes[id]['value_type']=='proposition'&&parents.length==1
      parent=nodes[parents[0]['to']]
      fail_control.call unless parent&&parent['target_type']=='foundation'&&parent['target_id']=='FND:f66b7a3877f4b0140a0b7023'&&edges.any?{|e|e['from']==holder['node_id']&&e['to']==parent['node_id']&&e['type']=='fills_role'&&e['role']=='experiencer'}
    end
  end
  def event(node,anchor)
    raise ArgumentError,'Unsupported discourse reference.' unless node['reference_type']=='desire_subject'
    path=[0,-25,0,0]
    raise ArgumentError,'Subject-control pitch outside MIDI range.' unless anchor.is_a?(Integer)&&path.all?{|n|(anchor+n).between?(0,127)}
    {'kind'=>'discourse_reference','occurrence_id'=>node['node_id'],'target_id'=>'EZCONTROL:desire_subject','referent_id'=>node['referent_id'],'register'=>'middle','base_midi'=>anchor,'family_qualified_transliteration'=>'desire_subject','formal_carrier'=>'','family_opening_relative_semitones'=>[],'family_opening_absolute_midi'=>[],'address_relative_semitones'=>path,'address_absolute_midi'=>path.map{|n|anchor+n},'note_duration_beats'=>0.25}
  end
end
