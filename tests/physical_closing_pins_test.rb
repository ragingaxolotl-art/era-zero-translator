require_relative '../tools/lib/era_zero_validation'
V=EraZeroValidation
migration=V.load_yaml('migrations/physical_closing_2026_11_22.yaml')
preserved=0
migration.fetch('sources').each do |path,record|
  key=path.include?('compound_dictionary')?'entries':'senses'
  identity=key=='entries'?'compound_id':'sense_id'
  old=V.load_yaml(path).fetch(key).select { |entry| record.fetch('preserved_ids').include?(entry.fetch(identity)) }
  abort "Earlier meanings changed in #{path}" unless V.fingerprint(old)==record.fetch('before_fingerprint')
  preserved+=old.length
end
entries=V.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries')
[[88,'ORI:110','CMP:82a697e83c845e4a7b38b53e'],[89,'ORI:211','CMP:9a954f78879ed70ce262bdc5']].each do |code,head_id,dependency|
  matching=entries.select { |entry| entry.dig('conventional_meaning','sound_code')==code }
  abort "Nonunique closing code #{code}" unless matching.length==1
  entry=matching.first
  head=entry.fetch('nodes').find { |node| node['node_id']==entry['semantic_head'] }
  abort 'Wrong closing head' unless head['root_id']==head_id
  dependencies=entry.fetch('nodes').select { |node| node['kind']=='compound_ref' }
  abort 'Reuse the exact state before its transition, and transition before its cause' unless dependencies.length==1 && dependencies.first.values_at('compound_id','definition_version')==[dependency,'1.0.0']
end
puts "PASS #{preserved} earlier meanings preserved; closing transition and cause reuse their exact prior dependencies under unique conventions."
