# frozen_string_literal: true
require 'set'
# Draft binding-only validator; this does not admit a musical grammar profile.
module EraZeroQuantifiedBinding
  module_function
  def validate!(ir)
    fail_binding=-> {raise ArgumentError,'Invalid quantified-predicate binding.'}
    fail_binding.call unless ir.is_a?(Hash)&&ir['nodes'].is_a?(Array)&&ir['edges'].is_a?(Array)&&ir['nodes'].length<=10000
    list=ir['nodes'];edges=ir['edges']
    fail_binding.call unless list.all?{|n|n.is_a?(Hash)&&n['node_id'].is_a?(String)&&!n['node_id'].empty?}
    nodes=list.to_h{|n|[n['node_id'],n]};fail_binding.call unless nodes.length==list.length
    fail_binding.call unless edges.all?{|e|e.is_a?(Hash)&&nodes.key?(e['from'])&&nodes.key?(e['to'])}
    fail_binding.call if list.any?{|n|n['operator']=='quantified_predication'&&n['kind']!='scope_operator'}
    binders=list.select{|n|n['kind']=='scope_operator'&&n['operator']=='quantified_predication'}
    refs=list.select{|n|n['kind']=='quantified_reference'}
    structural=%w[scopes centers member_of condition_of]
    body_of=->(start){
      reached=Set.new;active=Set.new;visit=nil
      visit=->(id,depth){
        fail_binding.call if depth>128||active.include?(id)
        return if reached.include?(id)
        active.add(id);reached.add(id)
        fail_binding.call unless %w[lexical_occurrence scope_operator coordination clause].include?(nodes[id]['kind'])
        edges.select{|e|e['to']==id&&structural.include?(e['type'])}.each{|e|visit.call(e['from'],depth+1)}
        active.delete(id)
      };visit.call(start,0);reached
    }
    enclosed=nil
    enclosed=->(id,binder,active){
      return true if id==binder
      return false if active.include?(id)||active.length>128
      following=active.dup.add(id);parents=edges.select{|e|e['from']==id&&structural.include?(e['type'])}
      !parents.empty?&&parents.all?{|e|enclosed.call(e['to'],binder,following)}
    }
    bodies={}
    binders.each do |binder|
      fail_binding.call unless binder.keys.sort==%w[kind node_id operator quantifier value]&&%w[exact at_least at_most].include?(binder['quantifier'])&&binder['value'].is_a?(String)&&binder['value'].length<=1024&&binder['value'].match?(/\A(?:0|[1-9][0-9]*)\z/)
      scoped=edges.select{|e|e['type']=='scopes'&&e['to']==binder['node_id']};restrictions=edges.select{|e|e['type']=='restricts'&&e['to']==binder['node_id']}
      fail_binding.call unless scoped.length==1&&restrictions.length==1
      restriction=nodes[restrictions[0]['from']]
      fail_binding.call unless restriction['kind']=='phonemic_reference'&&restriction['reference_mode']=='nominal_class'&&restriction['value_type']=='entity'
      body=body_of.call(scoped[0]['from']);fail_binding.call if body.include?(binder['node_id']);bodies[binder['node_id']]=body
      fail_binding.call unless refs.any?{|r|r['binder_id']==binder['node_id']}
    end
    refs.each do |ref|
      fail_binding.call unless ref.keys.sort==%w[binder_id kind node_id value_type]&&ref['value_type']=='entity'&&bodies.key?(ref['binder_id'])
      body=bodies[ref['binder_id']];uses=edges.select{|e|e['from']==ref['node_id']}
      bound=list.flat_map{|n|Array(n['compound_bindings']).select{|b|b['argument_id']==ref['node_id']}.map{n}}
      fail_binding.call if uses.empty?&&bound.empty?
      fail_binding.call if uses.any?{|e|e['type']!='fills_role'||!body.include?(e['to'])||nodes[e['to']]['kind']!='lexical_occurrence'}||bound.any?{|n|!body.include?(n['node_id'])}
      fail_binding.call unless (uses.map{|e|e['to']}+bound.map{|n|n['node_id']}).all?{|id|enclosed.call(id,ref['binder_id'],Set.new)}
      fail_binding.call if edges.any?{|e|e['to']==ref['node_id']}
    end
    fail_binding.call if edges.any?{|e|e['type']=='restricts'&&!bodies.key?(e['to'])}
    {'profile'=>'EZCOUNT-BIND-1','binder_count'=>binders.length,'reference_count'=>refs.length}
  end
end
