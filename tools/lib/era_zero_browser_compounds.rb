# frozen_string_literal: true
require_relative 'era_zero_renderer'

# Compile dictionary structure once; browsers bind occurrence values at runtime.
module EraZeroBrowserCompounds
  module_function
  def plans(entries)
    registry=entries.to_h{|entry|[entry.fetch('compound_id'),entry]}
    expander=EraZeroCompoundExpansion::Expander.new(entries)
    entries.to_h do |entry|
      expanded=expander.expand(entry.fetch('compound_id'),entry.fetch('definition_version'))
      scoped=entry.key?('conventional_meaning') || entry.fetch('nodes').any?{|node|node['kind']=='compound_ref'}
      unbound = if scoped
        expanded['nodes'].any?{|node|node['kind']=='slot'} ? nil : expander.ordered_roots(expanded)
      else
        EraZeroRenderer.compound_root_order(entry,compounds:registry).map do |node|
          entry['edges'].any?{|edge|edge['type']=='qualifies'&&edge['from']==node['node_id']} ? node.merge('boundary_after_beats'=>0) : node
        end
      end
      plan={'profile'=>'EZCOMPOUNDPLAN-1','compound_id'=>entry['compound_id'],'definition_version'=>entry['definition_version'],'content_digest'=>entry['content_digest'],
        'expanded'=>expanded,'bound_components'=>expander.ordered_roots(expanded,include_slots:true),'unbound_components'=>unbound,
        'unbound_scopes'=>scoped ? expanded['scopes'] : [],'required_roles'=>EraZeroRenderer.required_compound_roles(entry, compounds: registry)}
      plan['plan_digest']=EraZeroValidation.fingerprint(plan)
      [entry['compound_id'],plan]
    end
  end
end
