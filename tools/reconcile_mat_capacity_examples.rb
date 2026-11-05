#!/usr/bin/env ruby
# Reconcile explanatory prose to the existing selective semantic approval.
# Never rewrite historical proposals or any invariant/generated root field.
require_relative 'lib/era_zero_validation'
V = EraZeroValidation
path='migrations/mat_capacity_example_reconciliation_2026_10_29.yaml'
approval=V.load_yaml('migrations/MAT_200_222_semantic_approval.yaml')
roots=approval.fetch('promoted_roots')
ids=roots.map{|r|r.fetch('canonical_id')}
before=V.load_yaml('lexicon/atoms.yaml').fetch('atoms')
lookup=before.to_h{|r|[r.fetch('canonical_id'),r]}
roots.each do |r|
 atom=lookup.fetch(r.fetch('canonical_id'))
 abort 'Approval invariant differs from current authority' unless atom.fetch('core_definition')==r.fetch('invariant_definition') && atom.fetch('title')==r.fetch('canonical_title')
 r.fetch('fixed_generated_fields').each{|key,value|abort "Generated field changed: #{key}" unless atom.fetch(key)==value}
end
examples={
 'MAT:200'=>"MAT:200 [1] — A battery has a persistent capacity to supply energy for physical change; current availability or use is not asserted.",
 'MAT:201'=>"MAT:201 [1] — A battery's capacity to supply energy for physical change is presently available; actual discharge is not asserted.",
 'MAT:202'=>"MAT:202 [1] — A material bearer's energy-supplying capacity exists but is not presently available for exercise; runtime [1] affirms this latent-capacity meaning.",
 'MAT:210'=>"MAT:210 [1] — An established material coupling allows a bearer to transmit physical influence to a distinct target; ownership, custody and permission are not asserted.",
 'MAT:211'=>"MAT:211 [1] — A material bearer is presently transmitting physical influence to a distinct target; mere contact without influence is insufficient.",
 'MAT:212'=>"MAT:212 [1] — Whether a material bearer can transmit physical influence to a distinct target is unresolved; transfer, intention and future occurrence are not asserted.",
 'MAT:220'=>"MAT:220 [1] — Material parts of a shared system stand in a stable relation of mutual constraint on their physical states; shared membership alone is insufficient.",
 'MAT:221'=>"MAT:221 [1] — Material parts of a shared system are presently exerting reciprocal physical influence; one-way exchange alone is insufficient.",
 'MAT:222'=>"MAT:222 [1] — A possible relation of mutual physical constraint among parts of a shared system remains unrealized; current interdependence is not asserted."
}
record=File.exist?(File.join(V::ROOT,path)) ? V.load_yaml(path) : nil
unless record
 changes=ids.map do |id|
  {'root_id'=>id,'field'=>'normal_example','before'=>lookup.fetch(id).fetch('normal_example'),'after'=>examples.fetch(id)}
 end
 record={'type'=>'editorial_example_reconciliation','authority'=>'Existing applied MAT:200–222 selective semantic approval overrides retained provisional example prose',
  'approval_source'=>'migrations/MAT_200_222_semantic_approval.yaml','scope'=>'Nine normal examples; all other root fields preserved',
  'root_ids'=>ids,'changes'=>changes,'before_fingerprint'=>V.fingerprint(before),
  'historical_sources_preserved'=>['lexicon/provisional_atoms.yaml','reviews/MAT_200_222_peer_review.md','reviews/MAT_200_222_recommended_spec.yaml','tools/build_mat_200_222_review.rb']}
end
files=%w[lexicon/atoms.yaml lexicon/all_atoms.yaml lexicon/reviewed_canonical_atoms.yaml spec/canonical_spec.yaml]
documents=files.to_h do |file|
 doc=V.load_yaml(file)
 rows=file=='spec/canonical_spec.yaml' ? doc.fetch('lexicon').fetch('completed_atoms') : doc.fetch('atoms')
 record.fetch('changes').each do |change|
  row=rows.find{|a|a['canonical_id']==change.fetch('root_id')} or abort "Missing target in #{file}"
  value=row.fetch(change.fetch('field'))
  abort "Unexpected prose in #{file}: #{row['canonical_id']}" unless [change.fetch('before'),change.fetch('after')].include?(value)
  row[change.fetch('field')]=change.fetch('after')
 end
 [file,doc]
end
after=documents.fetch('lexicon/atoms.yaml').fetch('atoms')
if record.key?('after_fingerprint')
 abort 'Unexpected authority after reconciliation' unless V.fingerprint(after)==record.fetch('after_fingerprint')
else
 record['after_fingerprint']=V.fingerprint(after)
end
documents.each{|file,doc|V.write(file,YAML.dump(doc))}
V.write(path,YAML.dump(record))
index_path=File.join(V::ROOT,'pages/data/index.json');index=JSON.parse(File.read(index_path))
record.fetch('changes').each do |change|
 row=index.fetch('atoms').find{|a|a['canonical_id']==change.fetch('root_id')}
 row[change.fetch('field')]=change.fetch('after')
end
File.write(index_path,JSON.generate(index))
puts 'Reconciled nine MAT capacity/coupling examples; definitions, lexical trits and generated sounds are unchanged.'
