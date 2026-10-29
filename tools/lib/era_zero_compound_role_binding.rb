# frozen_string_literal: true
require_relative 'era_zero_compound_expansion'

# Adapt explicit role arguments to scoped slots only when the role identifies
# exactly one slot. Never guess among repeated roles in nested definitions.
module EraZeroCompoundRoleBinding
  module_function
  def bind_unique_roles!(nodes, edges, compounds)
    expander = nil
    nodes.select { |n| n['kind']=='lexical_occurrence' && n['target_type']=='compound' && !n.key?('compound_bindings') }.each do |node|
      definition=compounds.fetch(node.fetch('target_id'))
      next unless definition.key?('conventional_meaning') || definition.fetch('nodes').any? { |n| n['kind']=='compound_ref' }
      expander ||= EraZeroCompoundExpansion::Expander.new(compounds.values)
      expanded=expander.expand(definition.fetch('compound_id'),definition.fetch('definition_version'))
      slots=expanded.fetch('nodes').select { |n| n['kind']=='slot' }
      next if slots.empty?
      roles=slots.map do |slot|
        outgoing=expanded.fetch('edges').select { |e| e['from_path']==slot['path'] }
        raise ArgumentError,'Scoped slots require one explicit role each' unless outgoing.length==1 && outgoing.first['type']=='fills_role'
        outgoing.first.fetch('role')
      end
      raise ArgumentError,'Repeated scoped roles require explicit slot-path bindings' unless roles.uniq.length==roles.length
      consumed=[]
      bindings=slots.zip(roles).map do |slot,role|
        incoming=edges.select { |e| e['type']=='fills_role' && e['to']==node['node_id'] && e['role']==role }
        raise ArgumentError,"Missing or ambiguous scoped role #{role}" unless incoming.length==1
        edge=incoming.first;argument=nodes.find { |n| n['node_id']==edge['from'] }
        unless slot['slot_type']=='entity' && argument && %w[lexical_occurrence phonemic_reference deictic_reference].include?(argument['kind']) && (!argument.key?('value_type') || argument['value_type']=='entity')
          raise ArgumentError,'Scoped role argument must be an explicit entity occurrence'
        end
        argument['value_type']='entity';consumed<<edge
        { 'slot_path'=>slot['path'], 'argument_id'=>argument['node_id'] }
      end
      EraZeroCompoundBindingConstraints.validate_bindings!(expanded.fetch('binding_constraints',[]),bindings,nodes.to_h { |n| [n['node_id'],n] })
      node['compound_bindings']=bindings
      edges.reject! { |e| consumed.include?(e) }
    end
  end
end
