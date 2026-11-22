require_relative '../tools/lib/era_zero_validation'
V = EraZeroValidation
migration=V.load_yaml('migrations/placement_vocabulary_2026_11_22.yaml')
preserved=0
migration.fetch('sources').each do |path,record|
  key=path.include?('compound_dictionary')?'entries':'senses'
  id_key=key=='entries'?'compound_id':'sense_id'
  entries=V.load_yaml(path).fetch(key)
  old=entries.select { |entry| record.fetch('preserved_ids').include?(entry.fetch(id_key)) }
  abort "An earlier meaning changed: #{path}" unless V.fingerprint(old)==record.fetch('before_fingerprint')
  preserved+=old.length
end
entries=V.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries')
placement=entries.find { |entry| entry['compound_id']=='CMP:64574c1a25d72a89aafc46ef' }
abort 'Placement missing' unless placement
head=placement.fetch('nodes').find { |node| node['node_id']==placement['semantic_head'] }
abort 'Arrival must be the semantic head' unless head['root_id']=='MOV:110'
dependency=placement.fetch('nodes').find { |node| node['kind']=='compound_ref' }
abort 'Reuse approved physical displacement' unless dependency['compound_id']=='CMP:82dc9c681fbaf7944cb7b85b' && dependency['definition_version']=='1.0.0'
abort 'Placement code conflict' unless entries.count { |entry| entry.dig('conventional_meaning','sound_code')==85 }==1
puts "PASS #{preserved} earlier dictionary/sense records unchanged; placement reuses exact displacement and arrival with a unique convention."
