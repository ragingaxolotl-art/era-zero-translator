# frozen_string_literal: true
module EraZeroSubjectControl
  module_function
  def validate!(ir)
    nodes=ir['nodes'].to_h{|n|[n['node_id'],n]};edges=ir['edges']
    nodes.values.select{|n|n['kind']=='reference'&&n['reference_type']=='desire_subject'}.each do |n|
      fail_control=-> {raise ArgumentError,'Invalid desired-subject identity.'}
      fail_control.call unless n['value_type']=='entity' && (n.keys-%w[node_id kind reference_type referent_id value_type]).empty? && Array(ir.dig('discourse_constraints','declared_referents')).include?(n['referent_id'])
      links=edges.select{|e|e['from']==n['node_id']};role=links.find{|e|e['type']=='fills_role'};identity=links.find{|e|e['type']=='corefers_with'}
      fail_control.call unless links.length==2&&role&&identity
      predicate=nodes[role['to']];holder=nodes[identity['to']]
      fail_control.call unless predicate&&predicate['target_type']=='atom'&&{'LIF:211'=>'actor','MOV:201'=>'bearer'}[predicate['target_id']]==role['role']&&holder&&%w[phonemic_reference deictic_reference].include?(holder['kind'])&&holder['referent_id']==n['referent_id']
      id=predicate['node_id'];seen=[]
      until nodes[id]['kind']=='clause'
        fail_control.call if seen.include?(id);seen<<id
        up=edges.select{|e|e['from']==id&&%w[scopes centers].include?(e['type'])};fail_control.call unless up.length==1;id=up[0]['to']
      end
      parents=edges.select{|e|e['from']==id&&e['type']=='fills_role'&&e['role']=='content'}
      fail_control.call unless nodes[id]['content_status']=='intensional'&&parents.length==1
      parent=nodes[parents[0]['to']]
      fail_control.call unless parent&&parent['target_type']=='foundation'&&edges.any?{|e|e['from']==holder['node_id']&&e['to']==parent['node_id']&&e['type']=='fills_role'&&e['role']=='experiencer'}
    end
  end
  def event(node,anchor)
    raise ArgumentError,'Unsupported discourse reference.' unless node['reference_type']=='desire_subject'
    path=[0,-25,0,0]
    raise ArgumentError,'Subject-control pitch outside MIDI range.' unless anchor.is_a?(Integer)&&path.all?{|n|(anchor+n).between?(0,127)}
    {'kind'=>'discourse_reference','occurrence_id'=>node['node_id'],'target_id'=>'EZCONTROL:desire_subject','referent_id'=>node['referent_id'],'register'=>'middle','base_midi'=>anchor,'family_qualified_transliteration'=>'desire_subject','formal_carrier'=>'','family_opening_relative_semitones'=>[],'family_opening_absolute_midi'=>[],'address_relative_semitones'=>path,'address_absolute_midi'=>path.map{|n|anchor+n},'note_duration_beats'=>0.25}
  end
end
