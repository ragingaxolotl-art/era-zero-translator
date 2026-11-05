#!/usr/bin/env ruby
require_relative 'lib/era_zero_validation'
V = EraZeroValidation
path='migrations/min_cross_reference_reconciliation_2026_10_28.yaml'
pairs={
 'The act of perceiving, remembering, learning, interpreting, or reasoning belongs to MIN:1xx and remains provisional until separately reviewed.' => 'MIN:1xx specifies changes to mental representations. Perception, remembering, learning, interpreting, and reasoning are not established merely by selecting a representational-change root.',
 'Competence, attention capacity, belief relation, uncertainty, and distributed intelligence belong to MIN:2xx and remain provisional until separately reviewed.' => 'MIN:2xx specifies selective-attention capacities and relations. Belief, uncertainty, general competence, and distributed intelligence are not established merely by selecting an attention root.'
}
ids=%w[MIN:000 MIN:001 MIN:002 MIN:010 MIN:011 MIN:012 MIN:020 MIN:021 MIN:022]
before=V.load_yaml('lexicon/atoms.yaml').fetch('atoms')
record=File.exist?(File.join(V::ROOT,path)) ? V.load_yaml(path) : nil
%w[lexicon/atoms.yaml lexicon/all_atoms.yaml lexicon/reviewed_canonical_atoms.yaml spec/canonical_spec.yaml].each do |file|
 doc=V.load_yaml(file)
 records=file=='spec/canonical_spec.yaml' ? doc.fetch('lexicon').fetch('completed_atoms') : doc.fetch('atoms')
 targets=records.select{|a|ids.include?(a['canonical_id'])}
 abort "Missing target records: #{file}" unless targets.length==9
 targets.each do |atom|
  field=atom.fetch('distinctions_and_exclusions')
  pairs.each do |old,new|
   abort "Unexpected cross-reference: #{atom['canonical_id']}" unless field.count(old)+field.count(new)==1
   field.map!{|text|text==old ? new : text}
  end
 end
 V.write(file,YAML.dump(doc))
end
after=V.load_yaml('lexicon/atoms.yaml').fetch('atoms')
unless record
 record={'type'=>'editorial_cross_reference_reconciliation','authority'=>'User-directed source reconciliation; later canonical MIN definitions override earlier provisional pointers',
 'scope'=>'Only two distinctions_and_exclusions strings on nine MIN:0xx entries; invariant definitions, lexical trits and generated sounds unchanged',
 'root_ids'=>ids,'replacements'=>pairs,'before_fingerprint'=>V.fingerprint(before),'after_fingerprint'=>V.fingerprint(after),
 'historical_sources_preserved'=>['reviews/MIN_000_022_recommended_spec.yaml','reviews/MIN_000_022_peer_review.md','tools/build_min_000_022_review.rb']}
 V.write(path,YAML.dump(record))
end
abort 'Unexpected authority after migration' unless V.atomic_fingerprint_matches?(after,record['after_fingerprint'])
# The browser index copies these exact records; avoid rebuilding unrelated artifacts.
p=File.join(V::ROOT,'pages/data/index.json');index=JSON.parse(File.read(p));lookup=after.to_h{|a|[a['canonical_id'],a]}
index['atoms'].each{|a|a['distinctions_and_exclusions']=lookup.fetch(a['canonical_id']).fetch('distinctions_and_exclusions') if ids.include?(a['canonical_id'])}
File.write(p,JSON.generate(index))
puts 'Reconciled 18 historical pointers in active inventories, the canonical specification and the browser index.'
