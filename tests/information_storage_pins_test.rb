require_relative '../tools/lib/era_zero_validation'
V = EraZeroValidation
migration = V.load_yaml('migrations/information_storage_2026_11_23.yaml')
preserved = 0
migration.fetch('sources').each do |path, record|
  key = path.include?('compound_dictionary') ? 'entries' : 'senses'
  identity = key == 'entries' ? 'compound_id' : 'sense_id'
  entries = V.load_yaml(path).fetch(key)
  old = entries.select { |entry| record.fetch('preserved_ids').include?(entry.fetch(identity)) }
  abort "Earlier meanings changed in #{path}" unless V.fingerprint(old) == record.fetch('before_fingerprint')
  abort "Missing additions in #{path}" unless (record.fetch('added_ids') - entries.map { |entry| entry.fetch(identity) }).empty?
  preserved += old.length
end
atoms = V.load_yaml('lexicon/all_atoms.yaml').fetch('atoms')
abort 'Existing atoms changed' unless V.fingerprint(atoms) == migration.fetch('atomic_inventory_fingerprint')
entries = V.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries')
commitment, save = [90, 91].map do |code|
  matches = entries.select { |entry| entry.dig('conventional_meaning', 'sound_code') == code }
  abort "Nonunique information-storage code #{code}" unless matches.length == 1
  matches.first
end
[[commitment, 'ORI:110'], [save, 'ORI:211']].each do |entry, root|
  head = entry.fetch('nodes').find { |node| node['node_id'] == entry['semantic_head'] }
  abort 'Wrong storage semantic head' unless head['root_id'] == root
end
abort 'Retention must reuse the stored-information root' unless commitment.fetch('nodes').map { |node| node['root_id'] } == %w[DAT:000 ORI:110]
dependency = save.fetch('nodes').select { |node| node['kind'] == 'compound_ref' }
abort 'Save must reuse the exact prior commitment' unless dependency.length == 1 && dependency.first.values_at('compound_id', 'definition_version') == [commitment['compound_id'], '1.0.0']
senses = V.load_yaml('lexicon/english_sense_index.yaml').fetch('senses')
stored = senses.select { |sense| sense['lemma'] == 'stored' && sense['part_of_speech'] == 'adjective' }
definition = atoms.find { |atom| atom['canonical_id'] == 'DAT:000' }.fetch('core_definition')
abort 'Stored must reuse the exact DAT:000 meaning' unless stored.length == 1 && stored.first.values_at('target_id', 'definition') == ['DAT:000', definition]
puts "PASS #{preserved} earlier compound/sense records and #{atoms.length} atoms preserved; unique dependency-ordered saving meanings and exact stored-state reuse."
