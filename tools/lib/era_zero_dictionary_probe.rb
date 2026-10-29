# frozen_string_literal: true
require_relative 'era_zero_renderer'
# Synthetic audit inputs satisfy declared identity constraints. Never use this
# helper to infer coreference from a user's English or matching lexical labels.
module EraZeroDictionaryProbe
  module_function
  def role_aliases(compound, compounds)
    entries=compounds.is_a?(Hash) ? compounds.values : compounds
    expanded=EraZeroCompoundExpansion::Expander.new(entries).expand(compound.fetch('compound_id'),compound.fetch('definition_version'))
    slots=expanded.fetch('nodes').select { |n| n['kind']=='slot' }
    by_path=slots.to_h do |slot|
      edges=expanded['edges'].select { |e| e['from_path']==slot['path'] && e['type']=='fills_role' }
      raise ArgumentError,'Probe slot needs one role' unless edges.length==1
      [slot['path'],edges.first['role']]
    end
    raise ArgumentError,'Repeated roles require explicit scoped probe inputs' unless by_path.values.uniq.length==by_path.length
    parents=by_path.values.to_h { |role| [role,role] }
    find=lambda { |role| role=parents[role] while parents[role]!=role;role }
    expanded.fetch('binding_constraints',[]).select { |c| c['relation']=='same_argument' }.each do |constraint|
      roles=constraint['slot_paths'].map { |path| by_path.fetch(path) }
      representative=find.call(roles.first)
      roles.drop(1).each { |role| parents[find.call(role)]=representative }
    end
    groups=parents.keys.group_by { |role| find.call(role) }
    groups.values.each_with_object({}) do |roles,aliases|
      first=roles.min
      roles.each { |role| aliases[role]=first unless role==first }
    end
  end
end
