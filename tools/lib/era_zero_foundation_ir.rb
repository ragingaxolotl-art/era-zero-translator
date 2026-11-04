# frozen_string_literal: true
require_relative 'era_zero_foundations'
module EraZeroFoundationIR
  module_function
  def argument_type(n)
    return 'proposition' if n['kind']=='clause' && n['clause_type']=='content' && n['content_status']=='intensional' && n['value_type']=='proposition'
    return 'kind' if n['kind']=='phonemic_reference' && n['reference_mode']=='nominal_class'
    return 'entity' if %w[phonemic_reference deictic_reference].include?(n['kind']) && n['value_type']=='entity'
    nil
  end
  def validate!(ir, records, allow_draft:false)
    EraZeroFoundations.validate!(records,allow_draft:allow_draft)
    nodes=ir.fetch('nodes'); edges=ir.fetch('edges'); map=nodes.to_h{|n|[n.fetch('node_id'),n]}
    raise ArgumentError,'Duplicate nodes or edges.' unless map.length==nodes.length && edges.map{|e|e['edge_id']}.uniq.length==edges.length
    raise ArgumentError,'Unknown edge endpoint.' unless edges.all?{|e|map.key?(e['from'])&&map.key?(e['to'])}
    definitions=records.to_h{|r|[r['foundation_id'],r]}
    foundations=nodes.select{|n|n['target_type']=='foundation'}
    foundations.each do |n|
      d=definitions[n['target_id']]
      raise ArgumentError,'Invalid foundation occurrence.' unless n['kind']=='lexical_occurrence' && d && n['foundation_version']==d['definition_version'] && !n.key?('compound_bindings') && n['runtime_state'].is_a?(Hash) && [0,1,2].include?(n['runtime_state']['code']) && !n['runtime_state'].key?('num')
      roles=edges.select{|e|e['type']=='fills_role'&&e['to']==n['node_id']}
      raise ArgumentError,'Incomplete foundation arguments.' unless roles.length==d['roles'].length
      d['roles'].each do |role,types|
        matches=roles.select{|e|e['role']==role}
        raise ArgumentError,'Invalid foundation argument type.' unless matches.length==1 && types.include?(argument_type(map.fetch(matches[0]['from'])))
      end
    end
    nodes.select{|n|n['kind']=='clause'&&(n['clause_type']=='content'||n.key?('content_status'))}.each do |n|
      raise ArgumentError,'Invalid intensional proposition.' unless argument_type(n)=='proposition' && n['node_id']!=ir['root_clause']
      outgoing=edges.select{|e|e['from']==n['node_id']}
      raise ArgumentError,'Content cannot also be asserted or shared.' unless outgoing.length==1 && outgoing[0]['type']=='fills_role' && foundations.any?{|f|f['node_id']==outgoing[0]['to']}
      centers=edges.select{|e|e['type']=='centers'&&e['to']==n['node_id']}
      raise ArgumentError,'Content requires one center.' unless centers.length==1
      raise ArgumentError,'Content predicate also centers an assertion.' if edges.any?{|e|e['type']=='centers'&&e['from']==centers[0]['from']&&e['to']!=n['node_id']}
      owned={n['node_id']=>true};pending=[n['node_id']]
      until pending.empty?
        target=pending.pop
        edges.each do |e|
          next if e['to']!=target || %w[phonemic_reference deictic_reference reference literal variable].include?(map[e['from']]['kind']) || owned[e['from']]
          owned[e['from']]=true;pending<<e['from']
        end
      end
      raise ArgumentError,'Embedded predicate or scope escapes intensional content.' if edges.any?{|e|owned[e['from']]&&e['from']!=n['node_id']&&!owned[e['to']]}

    end
    graph=nodes.to_h{|n|[n['node_id'],[]]}
    edges.each{|e|graph[e['from']]<<e['to'] if %w[fills_role centers scopes member_of].include?(e['type'])}
    visiting={};done={};visit=nil
    visit=lambda do |id|
      raise ArgumentError,'Cyclic foundation content.' if visiting[id]
      next if done[id]
      visiting[id]=true;graph[id].each{|other|visit.call(other)};visiting.delete(id);done[id]=true
    end
    foundations.each{|n|visit.call(n['node_id'])}
    true
  end
end
