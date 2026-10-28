#!/usr/bin/env ruby
require_relative 'lib/era_zero_musical_identity'
atoms, compounds = EraZeroRenderer.load_authority
records = []
(atoms.keys + compounds.keys).sort.each do |id|
  type = atoms.key?(id) ? 'atom' : 'compound'
  roles = type == 'compound' ? EraZeroRenderer.required_compound_roles(compounds.fetch(id)) : []
  [0, 1, 2].each do |state|
    ir = { 'ir_version' => '1.0', 'root_clause' => 'c', 'speech_act' => 'assertion',
      'nodes' => [{ 'node_id' => 'c', 'kind' => 'clause', 'clause_type' => 'predication' },
                  { 'node_id' => 'p', 'kind' => 'lexical_occurrence', 'target_type' => type, 'target_id' => id, 'runtime_state' => { 'code' => state } }],
      'edges' => [{ 'edge_id' => 'e0', 'type' => 'centers', 'from' => 'p', 'to' => 'c' }], 'discourse_constraints' => {} }
    roles.each_with_index do |role, index|
      node_id = "a#{index}"
      ir['nodes'] << { 'node_id' => node_id, 'kind' => 'lexical_occurrence', 'target_type' => 'atom', 'target_id' => 'ORI:000', 'runtime_state' => { 'code' => 1 } }
      ir['edges'] << { 'edge_id' => "e#{index + 1}", 'type' => 'fills_role', 'from' => node_id, 'to' => 'p', 'role' => role }
    end
    digest = EraZeroRenderer.semantic_digest(ir)
    ir.merge!('utterance_id' => "UTT:#{digest[0,24]}", 'serialization' => { 'canonical_format' => 'EZIR-JSON-1', 'content_digest' => digest })
    formal = EraZeroRenderer.render(ir)
    records << { 'identity' => "#{id}[#{state}]", 'midi_sha256' => EraZeroMusicalIdentity.signature(formal), 'synthetic_roles' => roles }
  end
end
collisions = EraZeroMusicalIdentity.collisions(records)
report = { 'scope' => 'Exact MIDI equality for every approved dictionary identity in three runtime states, assertion contour at anchor 60. Required roles use identical synthetic ORI:000 fillers. This is not arbitrary sentence or perceptual-audio decoding coverage.',
  'dictionary_entries' => atoms.length + compounds.length, 'performance_count' => records.length,
  'collisions' => collisions, 'completion_proven' => false, 'records' => records }
File.write(File.expand_path('../reports/dictionary_musical_identity.json', __dir__), JSON.pretty_generate(report) + "\n")
puts JSON.generate(report.slice('dictionary_entries', 'performance_count', 'collisions', 'completion_proven'))
exit(collisions.empty? ? 0 : 1)
