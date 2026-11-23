#!/usr/bin/env ruby
# Apply the reviewed, dependency-ordered 2026-11-23 vocabulary batch once.
# Re-running checks identical records; it cannot replace an existing meaning.
require_relative 'lib/era_zero_validation'
require_relative 'lib/era_zero_compound_conventions'
V = EraZeroValidation
batch_path = 'lexicon/information_storage_batch_2026_11_23.json'
review_path = 'reviews/information_storage_2026_11_23.md'
migration_path = 'migrations/information_storage_2026_11_23.yaml'
dictionary_path = 'lexicon/compound_dictionary.yaml'
index_path = 'lexicon/english_sense_index.yaml'
dictionary = V.load_yaml(dictionary_path)
index = V.load_yaml(index_path)
reviews = V.load_yaml('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml')
story_text = File.read(File.join(V::ROOT, 'lexicon/story_compound_batch.json'))
story = JSON.parse(story_text)
new_story = []
everyday = JSON.parse(File.read(File.join(V::ROOT, 'lexicon/everyday_choices.json')))
batch = JSON.parse(File.read(File.join(V::ROOT, batch_path)))
records = batch.fetch('compounds')
atoms = V.load_yaml('lexicon/all_atoms.yaml').fetch('atoms')
before = {dictionary_path => dictionary['entries'], index_path => index['senses']}.transform_values do |entries|
  {'before_fingerprint' => V.fingerprint(entries), 'preserved_ids' => entries.map { |e| e['compound_id'] || e['sense_id'] }}
end
added = {}
new_senses = []
records.each do |record|
  parts = record.fetch('parts').map do |part|
    if part.match?(/\A[A-Z]{3}:[012]{3}\z/)
      {'kind' => 'root', 'root_id' => part}
    else
      dependency = dictionary['entries'].find { |e| e['display_title'] == part }
      abort "Dependency must already exist: #{part}" unless dependency
      {'kind' => 'compound_ref', 'compound_id' => dependency.fetch('compound_id'), 'definition_version' => dependency.fetch('definition_version')}
    end
  end
  nodes = parts.each_with_index.map { |part, i| part.merge('node_id' => i == parts.length - 1 ? 'h' : "q#{i + 1}") }
  meaning = {'profile' => 'EZLEX-1', 'sense_key' => record.fetch('title').tr(' ', '_'), 'sound_code' => record.fetch('code'),
    'added_definition' => record.fetch('definition'), 'excludes' => record.fetch('excludes')}
  payload = {'architecture_version' => '1.0', 'semantic_head' => 'h', 'nodes' => nodes,
    'edges' => nodes[0...-1].map { |n| {'type' => 'qualifies', 'from' => n['node_id'], 'to' => 'h'} },
    'lexical_constraints' => record.fetch('constraints'), 'conventional_meaning' => meaning}
  digest = V.fingerprint(payload)
  id = "CMP:#{digest[0,24]}"
  entry = payload.merge('compound_id' => id, 'content_digest' => digest, 'definition_version' => '1.0.0',
    'status' => 'approved', 'approval_date' => '2026-11-23', 'display_title' => record.fetch('title'), 'english_glosses' => [record.fetch('title')],
    'invariant_definition' => record.fetch('definition'), 'boundaries' => {'includes' => record.fetch('definition'), 'excludes' => record.fetch('excludes').join('; ')},
    'collision_audit' => "#{review_path}; exact dependency versions, explicit phase and participant constraints, and convention #{record.fetch('code')} preserve this distinction.",
    'confidence' => 'high', 'approval_record' => migration_path,
    'approval_basis' => "Author semantic review under the user-directed translator completion goal; #{review_path}. Not independent linguistic validation or separate user approval of each definition.",
    'examples' => {'ordinary' => record.fetch('example'), 'technical' => record.fetch('constraints').join(' '), 'future_compound' => record.fetch('reuse'), 'counterexample' => record.fetch('near')},
    'serialization' => {'canonical_format' => 'EZC-JSON-1', 'content_digest' => digest})
  old = dictionary['entries'].find { |e| e['compound_id'] == id }
  abort "Existing entry differs: #{record['title']}" if old && old != entry
  dictionary['entries'] << entry unless old
  added[record.fetch('story_word', record.fetch('word'))] = id
  unless reviews['reviews'].any? { |r| r['compound_id'] == id }
    candidates = [
      ['explicit_retention_commitment', 'Reuse the retained datum, bind its commitment to the target content, then add its causally productive actor without requiring a new copy or altered content.', [9,10,10,9,9,10,8,10], 'winner'],
      ['unmarked_root_conjunction', 'Root adjacency alone does not bind the retained record, target content, capture point and completed commitment, or supply its cause.', [8,9,9,2,3,4,3,4], 'rejected: distinction absent'],
      ['runtime_or_nearby_alias', 'Static retention, copying, transfer, data transformation or a runtime ending cannot replace the selected saving operation.', [2,3,3,1,2,2,2,2], 'rejected: semantic substitution']
    ].map { |key, reason, scores, decision| {'candidate_id' => key, 'direction' => reason, 'scores' => V::SCORE_KEYS.zip(scores).to_h, 'total' => scores.sum, 'decision' => decision} }
    candidates.first['graph'] = payload.slice('semantic_head', 'nodes', 'edges', 'conventional_meaning')
    reviews['reviews'] << {'compound_id' => id, 'display_title' => record.fetch('title'),
      'current_choice_reason' => "#{review_path}; scores are author judgments, not measured accuracy or independent validation.",
      'candidates' => candidates, 'recommendation' => 'approve explicit_retention_commitment', 'confidence' => 'high'}
  end
  story_record = record.slice('word', 'title', 'code', 'parts', 'definition', 'example', 'near', 'reuse', 'forms', 'pos', 'everyday')
  story_record['word'] = record.fetch('story_word', record.fetch('word'))
  old_story = story.find { |w| w['word'] == story_record['word'] }
  abort "Existing story route differs: #{record['word']}" if old_story && old_story != story_record
  unless old_story
    story << story_record
    new_story << story_record
  end
  everyday[id] = record.fetch('everyday')
  next if record.fetch('forms').empty?
  sense_payload = {'lemma' => record.fetch('word'), 'part_of_speech' => record.fetch('pos'), 'sense_key' => meaning.fetch('sense_key'),
    'route' => 'compound', 'target_id' => id, 'definition' => record.fetch('definition')}
  sense_id = "ENS:#{V.fingerprint(sense_payload)[0,24]}"
  sense = sense_payload.merge('sense_id' => sense_id, 'display_form' => record.fetch('word'), 'surface_forms' => record.fetch('forms'),
    'selection_cues' => [record.fetch('example')], 'excluded_readings' => record.fetch('excludes'), 'confidence' => 'high',
    'controlled_input_allowed' => false, 'provenance' => batch_path)
  old_sense = index['senses'].find { |s| s['sense_id'] == sense_id }
  abort "Existing sense differs: #{record['word']}" if old_sense && old_sense != sense
  index['senses'] << sense unless old_sense
  new_senses << sense_id
end
# A new English adjective reuses the exact published atom; it cannot redefine it.
batch.fetch('atomic_surfaces').each do |surface|
  atom = atoms.find { |a| a.fetch('canonical_id') == surface.fetch('target_id') }
  abort 'Missing canonical atom for surface' unless atom && atom.fetch('status') == 'canonical'
  payload = surface.slice('lemma', 'part_of_speech', 'sense_key', 'target_id').merge('route' => 'atom', 'definition' => atom.fetch('core_definition'))
  sense_id = "ENS:#{V.fingerprint(payload)[0,24]}"
  sense = payload.merge(surface.slice('display_form', 'surface_forms', 'selection_cues', 'excluded_readings'),
    'sense_id' => sense_id, 'confidence' => 'high', 'controlled_input_allowed' => false, 'provenance' => batch_path)
  old = index['senses'].find { |entry| entry['sense_id'] == sense_id }
  abort 'Existing stored-information surface differs' if old && old != sense
  index['senses'] << sense unless old
  new_senses << sense_id
end
# Validate all codes before writing anything. A conflicting published code aborts.
EraZeroCompoundConventions.validate!(dictionary['entries'])
dictionary['entries'].sort_by! { |e| e.fetch('compound_id') }
dictionary['metadata']['entry_count'] = dictionary['entries'].length
index['senses'].sort_by! { |s| [s.fetch('lemma'), s.fetch('sense_key'), s.fetch('sense_id')] }
V.write(dictionary_path, YAML.dump(dictionary))
V.write(index_path, YAML.dump(index))
V.write('reviews/gate4b_high_frequency_compounds_scored_candidates.yaml', YAML.dump(reviews))
unless new_story.empty?
  # Preserve the formatting and order of the older reviewed batch.
  tail = new_story.map { |record| JSON.pretty_generate(record).lines.map { |line| '  ' + line }.join }.join(",\n")
  V.write('lexicon/story_compound_batch.json', story_text.rstrip.sub(/\s*\]\z/, ",\n" + tail + "\n]\n"))
end
V.write('lexicon/everyday_choices.json', JSON.pretty_generate(everyday) + "\n")
unless File.exist?(File.join(V::ROOT, migration_path))
  before[dictionary_path]['added_ids'] = added.values
  before[index_path]['added_ids'] = new_senses
  V.write(migration_path, YAML.dump({'authority' => 'User-directed translator-completion goal', 'review' => review_path,
    'sources' => before, 'added_compounds' => added, 'new_convention_codes' => records.map { |r| r['code'] },
    'atomic_inventory_fingerprint' => V.fingerprint(atoms), 'atomic_meanings_changed' => false, 'existing_compound_meanings_changed' => false,
    'required_followup' => 'Rebuild derived inventories; independently decode sentence, scope, role, adjective and all runtime contrasts before publishing.'}))
end
puts JSON.pretty_generate(added)
