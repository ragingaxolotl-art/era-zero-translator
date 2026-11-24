require_relative '../tools/lib/era_zero_validation'
V=EraZeroValidation
m=V.load_yaml('migrations/ordinary_comparatives_2026_11_23.yaml')
senses=V.load_yaml(m.fetch('source').fetch('path')).fetch('senses')
old=senses.select { |s| m.fetch('source').fetch('preserved_ids').include?(s.fetch('sense_id')) }
abort 'Earlier English meanings changed' unless V.fingerprint(old)==m.fetch('source').fetch('before_fingerprint')
abort 'Earlier roots changed' unless V.fingerprint(V.load_yaml('lexicon/all_atoms.yaml').fetch('atoms'))==m.fetch('atomic_inventory_fingerprint')
abort 'Earlier compounds changed' unless V.fingerprint(V.load_yaml('lexicon/compound_dictionary.yaml').fetch('entries'))==m.fetch('compound_fingerprint')
added=senses.select { |s| m.fetch('added_senses').include?(s.fetch('sense_id')) }
abort 'Missing comparative senses' unless added.map { |s| s.fetch('lemma') }.sort==%w[colder heavier hotter lighter]
abort 'Comparatives must retain structural roles' unless added.all? { |s| s['part_of_speech']=='adjective' && s['route']=='semantic_ir' && !s.key?('target_id') }
puts "PASS #{old.length} earlier senses, all roots and compounds preserved; four structural comparative adjective routes."
