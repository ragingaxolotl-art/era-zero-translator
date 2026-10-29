#!/usr/bin/env ruby
# Reconcile explanatory prose to the existing selective semantic approval.
# Never rewrite historical proposals or any invariant/generated root field.
require_relative 'lib/era_zero_validation'
V = EraZeroValidation
path='migrations/mov_process_example_reconciliation_2026_10_28.yaml'
approval=V.load_yaml('migrations/MOV_100_122_semantic_approval.yaml')
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
 'MOV:102'=>"MOV:102 [1] — Displacement away from the source is potential, not presently active or completed; readiness or a departure plan is not asserted.",
 'MOV:112'=>"MOV:112 [1] — Displacement toward the target position is potential, not presently active or completed; intention, queuing and future time are not asserted.",
 'MOV:120'=>"MOV:120 [1] — The mover's change of position relative to the shared reference frame is complete; route traversal and nonpositional transitions are not asserted.",
 'MOV:121'=>"MOV:121 [1] — The mover's position is changing relative to the shared reference frame; a route, schedule or temporal transition is not asserted.",
 'MOV:122'=>"MOV:122 [1] — A change of the mover's position relative to the shared reference frame is potential, not presently active or completed; staging or scheduling is not asserted."
}
record=File.exist?(File.join(V::ROOT,path)) ? V.load_yaml(path) : nil
unless record
 changes=ids.flat_map do |id|
  atom=lookup.fetch(id)
  notes=atom.fetch('neighbor_contrast_notes').map do |note|
   neighbor=lookup.fetch(note[/\AMOV:\d{3}/])
   "#{neighbor.fetch('canonical_id')} (#{neighbor.fetch('title')}): #{neighbor.fetch('core_definition')} Do not merge it with #{id}."
  end
  fields={'neighbor_contrast_notes'=>notes}
  fields['normal_example']=examples[id] if examples.key?(id)
  fields.map{|field,value|{'root_id'=>id,'field'=>field,'before'=>atom.fetch(field),'after'=>value}}
 end
 record={'type'=>'editorial_example_reconciliation','authority'=>'Existing applied MOV:100–122 selective semantic approval overrides retained provisional example prose',
  'approval_source'=>'migrations/MOV_100_122_semantic_approval.yaml','scope'=>'Five normal examples and eighteen neighbor-note strings on nine roots; all other root fields preserved',
  'root_ids'=>ids,'changes'=>changes,'before_fingerprint'=>V.fingerprint(before),
  'historical_sources_preserved'=>['lexicon/provisional_atoms.yaml','reviews/MOV_100_122_peer_review.md','reviews/MOV_100_122_detailed_review.md','tools/build_mov_100_122_review.rb']}
end
files=%w[lexicon/atoms.yaml lexicon/all_atoms.yaml lexicon/reviewed_canonical_atoms.yaml spec/canonical_spec.yaml]
documents=files.to_h do |file|
 doc=V.load_yaml(file)
 rows=file=='spec/canonical_spec.yaml' ? doc.fetch('lexicon').fetch('completed_atoms') : doc.fetch('atoms')
 record.fetch('changes').each do |change|
  row=rows.find{|a|a['canonical_id']==change.fetch('root_id')} or abort "Missing target in #{file}"
  # The compact all_atoms inventory never contained this optional prose field.
  if file=='lexicon/all_atoms.yaml' && change.fetch('field')=='neighbor_contrast_notes'
   abort 'Unexpected compact-inventory layout' if row.key?('neighbor_contrast_notes')
   next
  end
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
 next if change.fetch('field')=='neighbor_contrast_notes'
 row=index.fetch('atoms').find{|a|a['canonical_id']==change.fetch('root_id')}
 row[change.fetch('field')]=change.fetch('after')
end
File.write(index_path,JSON.generate(index))
puts 'Reconciled 23 explanatory strings across nine MOV process roots; definitions, lexical trits and generated sounds are unchanged.'
