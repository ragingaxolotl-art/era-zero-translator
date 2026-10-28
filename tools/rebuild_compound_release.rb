#!/usr/bin/env ruby
# Rebuild derived language inventories after an explicitly approved dictionary edit.
require 'yaml'
require 'json'
require 'digest'
require 'rbconfig'
require_relative 'lib/era_zero_validation'
V = EraZeroValidation
Dir.chdir(V::ROOT)
def save(path, value); File.write(path, YAML.dump(value)); end
def refresh(path, fields)
  document=V.load_yaml(path); document.fetch('metadata').merge!(fields); save(path,document)
end
def run(script, *args)
  abort "Failed: #{script}" unless system(RbConfig.ruby, File.join(V::ROOT,'tools',script),*args)
end
atoms=V.load_yaml('lexicon/atoms.yaml').fetch('atoms')
dictionary=V.load_yaml('lexicon/compound_dictionary.yaml')
compounds=dictionary.fetch('entries')
# Preflight before changing derived records. Approval and semantic review are author inputs.
ids=compounds.map { |c| c.fetch('compound_id') }
abort 'Duplicate compound identities' unless ids.uniq.length==ids.length
compounds.each do |entry|
  payload=entry.slice('architecture_version','semantic_head','nodes','edges','lexical_constraints')
  hash=V.fingerprint(payload)
  abort "Unapproved or invalid identity: #{entry['display_title']}" unless entry['status']=='approved' && entry['content_digest']==hash && entry['compound_id']=="CMP:#{hash[0,24]}" && entry.dig('serialization','content_digest')==hash
end
review_ids=V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml').fetch('reviews').map { |r| r['compound_id'] }
abort 'Every compound needs a matching semantic review' unless review_ids.sort==ids.sort
labels=atoms.map { |a| a['title'].downcase.strip }+compounds.map { |c| c['display_title'].downcase.strip }
abort 'Canonical labels must be unique' unless labels.uniq.length==labels.length
dictionary['metadata']['entry_count']=compounds.length;save('lexicon/compound_dictionary.yaml',dictionary)
index=V.load_yaml('lexicon/english_sense_index.yaml')
previous=index['senses'].select { |s| s['sense_key']=='canonical_compound_label' }.to_h { |s| [s['target_id'],s] }
index['senses'].reject! { |s| s['sense_key']=='canonical_compound_label' }
compounds.each do |entry|
  payload={'lemma'=>entry['display_title'].downcase.strip,'part_of_speech'=>'noun_phrase','sense_key'=>'canonical_compound_label','route'=>'compound','target_id'=>entry['compound_id'],'definition'=>entry['invariant_definition']}
  sense=payload.merge('sense_id'=>"ENS:#{V.fingerprint(payload)[0,24]}",'display_form'=>entry['display_title'],'selection_cues'=>['exact approved compound label','all component restrictions are intended'],'excluded_readings'=>[entry.dig('boundaries','excludes')],'confidence'=>entry['confidence'],'controlled_input_allowed'=>true,'provenance'=>'lexicon/compound_dictionary.yaml')
  old=previous[entry['compound_id']]
  sense=old if old && payload.all? { |key,value| old[key]==value }
  index['senses'] << sense
end
index['senses'].sort_by! { |s| [s['lemma'],s['sense_key'],s['sense_id']] }
index['lemma_index']=index['senses'].group_by { |s| s['lemma'] }.sort.to_h do |lemma,records|
  [lemma,{'sense_ids'=>records.map { |s| s['sense_id'] },'requires_disambiguation'=>records.length>1 || records.any? { |s| !%w[atom compound].include?(s['route']) },'direct_target_count'=>records.count { |s| %w[atom compound].include?(s['route']) },'routes'=>records.map { |s| s['route'] }.uniq.sort}]
end
index['metadata'].merge!('sense_count'=>index['senses'].length,'lemma_count'=>index['lemma_index'].length,'canonical_compound_senses'=>compounds.length,'compound_dictionary_fingerprint'=>V.fingerprint(compounds));save('lexicon/english_sense_index.yaml',index)
cases=V.load_yaml('tests/gate4b_compound_cases.yaml');cases['metadata']['approved_entries']=compounds.length;cases['accepted']=compounds.map { |c| {'case_id'=>c['display_title'].tr(' ','_'),'compound_id'=>c['compound_id'],'expected'=>'valid_approved_entry'} };save('tests/gate4b_compound_cases.yaml',cases)
cases=V.load_yaml('tests/gate4c_sense_index_cases.yaml');cases['metadata'].merge!('sense_count'=>index['senses'].length,'lemma_count'=>index['lemma_index'].length);cases['exact_compound_labels']=compounds.map { |c| {'input'=>c['display_title'],'expected_route'=>'compound','expected_target'=>c['compound_id']} };save('tests/gate4c_sense_index_cases.yaml',cases)
version=V.load_yaml('spec/version.yaml');version.merge!('compound_dictionary_entries'=>compounds.length,'english_sense_records'=>index['senses'].length,'english_lemmas'=>index['lemma_index'].length,'etymology_entries'=>atoms.length+compounds.length);save('spec/version.yaml',version)
ready=V.load_yaml('spec/translator_readiness.yaml');ready['gate4a']['dictionary_entries']=compounds.length;save('spec/translator_readiness.yaml',ready)
run('validate_gate4b_compound_dictionary.rb');run('validate_gate4c_english_sense_index.rb')
run('build_gate4d_coverage_report.rb','--inventory-only');run('build_gate4e_etymology_table.rb','--inventory-only')
# Refresh dependency fingerprints in topological order; no grammar or atom meaning changes.
refresh('spec/semantic_ir_1.0.yaml',{'compound_dictionary_fingerprint'=>V.fingerprint(compounds)})
refresh('spec/renderer_decoder_1.0.yaml',{'semantic_ir_fingerprint'=>V.fingerprint(V.load_yaml('spec/semantic_ir_1.0.yaml')),'compound_dictionary_fingerprint'=>V.fingerprint(compounds)})
cases=V.load_yaml('tests/renderer_round_trip_cases.yaml');cases['compound_matrix'].merge!('compounds'=>compounds.length,'assertions'=>compounds.length*3);save('tests/renderer_round_trip_cases.yaml',cases)
refresh('spec/controlled_english_1.0.yaml',{'sense_index_fingerprint'=>V.fingerprint(index['senses']),'semantic_ir_fingerprint'=>V.fingerprint(V.load_yaml('spec/semantic_ir_1.0.yaml')),'renderer_fingerprint'=>V.fingerprint(V.load_yaml('spec/renderer_decoder_1.0.yaml')),'controlled_lexeme_count'=>atoms.length+compounds.length})
refresh('spec/general_english_1.0.yaml',{'sense_index_fingerprint'=>V.fingerprint(index['senses']),'semantic_ir_fingerprint'=>V.fingerprint(V.load_yaml('spec/semantic_ir_1.0.yaml')),'controlled_english_fingerprint'=>V.fingerprint(V.load_yaml('spec/controlled_english_1.0.yaml'))})
refresh('spec/glyph_audio_1.0.yaml',{'renderer_fingerprint'=>V.fingerprint(V.load_yaml('spec/renderer_decoder_1.0.yaml'))})
refresh('spec/product_application_1.0.yaml',{'translator_fingerprint'=>V.fingerprint(V.load_yaml('spec/general_english_1.0.yaml')),'presentation_fingerprint'=>V.fingerprint(V.load_yaml('spec/glyph_audio_1.0.yaml'))})
run('build_plain_english_index.rb');run('build_lexical_pos_audit.rb');run('build_pages_release.rb')
puts "Compound release rebuilt: #{compounds.length} compounds, #{index['senses'].length} senses. Run the complete release regression before publishing."
