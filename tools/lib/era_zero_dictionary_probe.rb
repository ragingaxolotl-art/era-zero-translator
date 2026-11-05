# frozen_string_literal: true
require_relative 'era_zero_renderer'
# Synthetic audit inputs satisfy declared identity constraints. Never use this
# helper to infer coreference from a user's English or matching lexical labels.
module EraZeroDictionaryProbe
  module_function
  # One synthetic entity per declared identity class, even when two independent
  # slots share a role name. Full scoped bindings prevent accidental coalescing.
  def scoped_arguments(compound, compounds, prefix: 'probe')
    entries=compounds.is_a?(Hash) ? compounds.values : compounds
    expanded=EraZeroCompoundExpansion::Expander.new(entries).expand(compound.fetch('compound_id'),compound.fetch('definition_version'))
    paths=expanded.fetch('nodes').select { |n| n['kind']=='slot' }.map { |n| n.fetch('path') }.sort
    parents=paths.to_h { |path| [path,path] }
    find=lambda { |path| path=parents.fetch(path) while parents.fetch(path)!=path;path }
    expanded.fetch('binding_constraints',[]).select { |c| c['relation']=='same_argument' }.each do |constraint|
      representative=find.call(constraint['slot_paths'].first)
      constraint['slot_paths'].drop(1).each { |path| parents[find.call(path)]=representative }
    end
    ids={};nodes=[]
    bindings=paths.map do |path|
      key=find.call(path)
      unless ids.key?(key)
        id="#{prefix}#{ids.length}"
        ids[key]=id;nodes<<{'node_id'=>id,'kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'ORI:000','runtime_state'=>{'code'=>1},'value_type'=>'entity'}
      end
      {'slot_path'=>path,'argument_id'=>ids.fetch(key)}
    end
    EraZeroCompoundBindingConstraints.validate_bindings!(expanded.fetch('binding_constraints',[]),bindings,nodes.to_h { |n| [n['node_id'],n] })
    {nodes: nodes, bindings: bindings}
  end
  def role_aliases(compound, compounds)
    entries=compounds.is_a?(Hash) ? compounds.values : compounds
    expanded=EraZeroCompoundExpansion::Expander.new(entries).expand(compound.fetch('compound_id'),compound.fetch('definition_version'))
    by_path=EraZeroCompoundBindingConstraints.unambiguous_role_paths(expanded)
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
