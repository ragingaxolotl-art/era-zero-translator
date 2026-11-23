require_relative '../tools/lib/era_zero_validation'
V=EraZeroValidation
migration=V.load_yaml('migrations/container_actions_2026_11_22.yaml')
preserved=0
migration.fetch('sources').each do |path,record|
  key=path.include?('compound_dictionary')?'entries':'senses'
  identity=key=='entries'?'compound_id':'sense_id'
  old=V.load_yaml(path).fetch(key).select { |entry| record.fetch('preserved_ids').include?(entry.fetch(identity)) }
  abort "Earlier meanings changed in #{path}" unless V.fingerprint(old)==record.fetch('before_fingerprint')
  preserved+=old.length
end
entries=V.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries')
[[86,'CMP:d03beca450a29869aa6fd980'],[87,'CMP:7e3cdc51fe00e1c61e5e9f12']].each do |code,state|
  matching=entries.select { |entry| entry.dig('conventional_meaning','sound_code')==code }
  abort "Nonunique container-action code #{code}" unless matching.length==1
  entry=matching.first
  head=entry.fetch('nodes').find { |node| node['node_id']==entry['semantic_head'] }
  abort 'Result actualization must be the head' unless head['root_id']=='ORI:110'
  dependencies=entry.fetch('nodes').select { |node| node['kind']=='compound_ref' }
  abort 'Use exact movement and state definitions' unless dependencies.map { |node| node['compound_id'] }.sort==['CMP:82dc9c681fbaf7944cb7b85b',state].sort && dependencies.all? { |node| node['definition_version']=='1.0.0' }
end
puts "PASS #{preserved} earlier meanings preserved; both container changes reuse exact movement and state dependencies under unique conventions."
