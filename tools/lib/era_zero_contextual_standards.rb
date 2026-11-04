# frozen_string_literal: true
module EraZeroContextualStandards
  NORMS={'hot'=>['thermodynamic_temperature','greater_than',0],'cold'=>['thermodynamic_temperature','less_than',1],'heavy'=>['mass','greater_than',2],'light'=>['mass','less_than',3],'bright'=>['luminance','greater_than',4],'dim'=>['luminance','less_than',5]}.freeze
  module_function
  def valid?(node,ir)
    norm=NORMS[node['norm']]
    return false unless norm&&node['standard']=='contextual'&&node['dimension']==norm[0]&&node['relation']==norm[1]&&(node.keys-%w[node_id kind operator standard norm dimension relation]).empty?
    scopes=ir['edges'].select{|e|e['type']=='scopes'&&e['to']==node['node_id']};return false unless scopes.length==1
    predicate=ir['nodes'].find{|n|n['node_id']==scopes[0]['from']}
    return false unless predicate&&predicate['kind']=='lexical_occurrence'&&predicate['target_type']=='atom'&&%w[MAT:000 MAT:010].include?(predicate['target_id'])
    roles=ir['edges'].select{|e|e['type']=='fills_role'&&e['to']==predicate['node_id']};return false unless roles.length==1&&roles[0]['role']=='bearer'
    ir['nodes'].any?{|n|n['node_id']==roles[0]['from']&&%w[phonemic_reference deictic_reference].include?(n['kind'])&&n['reference_mode']!='nominal_class'}
  end
end
