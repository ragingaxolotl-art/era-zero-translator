# frozen_string_literal: true
require 'json'

module EraZeroCompoundBindingConstraints
  class ConstraintError < ArgumentError; end
  module_function

  def expand(scopes, nodes)
    slots=nodes.select { |n| n['kind']=='slot' }.to_h { |n| [n.fetch('path'),n] }
    result=[]
    scopes.each do |scope|
      next unless scope.key?('binding_constraints')
      records=scope['binding_constraints']
      unless scope.key?('conventional_meaning') && records.is_a?(Array) && !records.empty?
        raise ConstraintError,'Binding constraints require an explicit conventional meaning and nonempty array'
      end
      records.each do |record|
        unless record.is_a?(Hash) && record.keys.sort==%w[relation slot_paths] && %w[same_argument distinct_arguments].include?(record['relation']) &&
            record['slot_paths'].is_a?(Array) && record['slot_paths'].length.between?(2,128) &&
            record['slot_paths'].all? { |p| p.is_a?(Array) && !p.empty? && p.all? { |s| s.is_a?(String) && !s.empty? } } && record['slot_paths'].uniq==record['slot_paths']
          raise ConstraintError,'Malformed compound binding constraint'
        end
        paths=record['slot_paths'].map { |p| scope.fetch('path')+p }
        raise ConstraintError,'Binding constraint names a missing slot' unless paths.all? { |p| slots.key?(p) }
        if record['relation']=='same_argument' && paths.map { |p| slots[p]['slot_type'] }.uniq.length!=1
          raise ConstraintError,'Equal argument slots must have the same type'
        end
        result << { 'relation'=>record['relation'], 'slot_paths'=>paths }
        raise ConstraintError,'Expanded binding constraint limit exceeded' if result.length>10000
      end
    end
    # Reject direct and transitive contradictions in dictionary structure.
    parents=slots.keys.to_h { |p| [p,p] }
    find=lambda do |p|
      while parents[p]!=p
        parents[p]=parents[parents[p]];p=parents[p]
      end
      p
    end
    result.select { |c| c['relation']=='same_argument' }.each do |c|
      head=find.call(c['slot_paths'].first)
      c['slot_paths'].drop(1).each { |p| parents[find.call(p)]=head }
    end
    result.select { |c| c['relation']=='distinct_arguments' }.each do |c|
      classes=c['slot_paths'].map { |p| find.call(p) }
      raise ConstraintError,'Contradictory compound binding constraints' unless classes.uniq.length==classes.length
    end
    result
  end

  def validate_bindings!(constraints, bindings, arguments)
    by_path=bindings.to_h { |b| [b.fetch('slot_path'),b.fetch('argument_id')] }
    constraints.each do |constraint|
      ids=constraint.fetch('slot_paths').map { |p| by_path.fetch(p) }
      if constraint.fetch('relation')=='same_argument'
        raise ConstraintError,'Compound slots must share the same argument occurrence' unless ids.uniq.length==1
      else
        # Explicit referent identity can reveal aliases across different nodes.
        # Separate node IDs alone do not prove real-world nonidentity.
        identities=ids.map { |id| arguments.fetch(id).key?('referent_id') ? ['referent',arguments.fetch(id).fetch('referent_id')] : ['occurrence',id] }
        raise ConstraintError,'Compound slots require distinct arguments' unless identities.uniq.length==identities.length
      end
    end
    true
  end
end
