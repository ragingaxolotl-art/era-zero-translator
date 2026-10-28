#!/usr/bin/env ruby
# Integration test: a new compound is added only inside an isolated temporary copy.
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'rbconfig'
require_relative 'lib/era_zero_validation'
v=EraZeroValidation
Dir.mktmpdir('era-zero-compound-extension-') do |workspace|
  Dir.glob(File.join(v::ROOT,'*')).each { |path| FileUtils.cp_r(path,workspace) }
  dictionary=v.load_yaml('lexicon/compound_dictionary.yaml')
  original_ids=dictionary['entries'].map { |e| e['compound_id'] }
  fixture=Marshal.load(Marshal.dump(dictionary['entries'].find { |e| e['display_title']=='love' }))
  fixture['display_title']='test enduring awakening bond'
  fixture['english_glosses']=[fixture['display_title']]
  fixture['nodes'].find { |n| n['node_id']=='q01' }['root_id']='LIF:200'
  fixture['invariant_definition']='A test-only established life-bond characterized by self-awakening and enduring life-capacity.'
  fixture['approval_basis']='Synthetic integration fixture; never copied to the canonical repository.'
  hash=v.fingerprint(fixture.slice('architecture_version','semantic_head','nodes','edges','lexical_constraints'))
  fixture['compound_id']="CMP:#{hash[0,24]}";fixture['content_digest']=hash;fixture['serialization']['content_digest']=hash
  dictionary['entries'] << fixture
  File.write(File.join(workspace,'lexicon/compound_dictionary.yaml'),YAML.dump(dictionary))
  reviews=v.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
  review=Marshal.load(Marshal.dump(reviews['reviews'].find { |r| r['display_title']=='love' }))
  review['compound_id']=fixture['compound_id'];review['display_title']=fixture['display_title'];reviews['reviews']<<review
  File.write(File.join(workspace,'reviews/gate4b_high_frequency_compounds_scored_candidates.yaml'),YAML.dump(reviews))
  execute=lambda do |name|
    output,status=Open3.capture2e(RbConfig.ruby,File.join(workspace,'tools',name),chdir:workspace)
    abort output unless status.success?
  end
  execute.call('rebuild_compound_release.rb')
  data=JSON.parse(File.read(File.join(workspace,'pages/data/index.json')))
  abort 'Compound inventory did not grow' unless data['compounds'].length==original_ids.length+1
  abort 'Existing identities changed' unless (original_ids-data['compounds'].map { |c| c['compound_id'] }).empty?
  abort 'New compound has no English sense' unless data['senses'].any? { |s| s['lemma']==fixture['display_title'] && s['target_id']==fixture['compound_id'] }
  relative=data['resolution_files'].fetch(fixture['compound_id']).sub(%r{\A\./},'')
  variants=JSON.parse(File.read(File.join(workspace,'pages',relative)))['variants']
  abort 'Incomplete or broken rendering' unless variants.length==15 && variants.values.all? { |x| x['round_trip_equal'] }
  before=File.read(File.join(workspace,'pages/data/index.json'))
  execute.call('rebuild_compound_release.rb')
  abort 'Rebuild is not idempotent' unless before==File.read(File.join(workspace,'pages/data/index.json'))
  puts "Compound extension: PASS — #{original_ids.length+1} compounds, new lookup, 15 round trips, stable existing IDs, repeatable rebuild; canonical inventory untouched."
end
