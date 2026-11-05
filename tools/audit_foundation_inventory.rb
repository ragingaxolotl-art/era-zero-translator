#!/usr/bin/env ruby
# Evidence inventory, not an automated proof of semantic expressibility.
require_relative 'lib/era_zero_renderer'
require 'digest'
require 'json'
atoms, compounds = EraZeroRenderer.load_authority
snapshot = lambda do |entry|
  Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(entry)))
end
report = {
  'purpose' => 'Pin the complete runtime authority used by the foundation review; counts and hashes do not prove semantic coverage.',
  'authority' => %w[lexicon/atoms.yaml lexicon/compound_dictionary.yaml].to_h { |path| [path, Digest::SHA256.file(path).hexdigest] },
  'root_count' => atoms.length,
  'compound_count' => compounds.length,
  'families' => atoms.values.group_by { |root| root.fetch('family') }.transform_values do |roots|
    roots.sort_by { |root| root.fetch('canonical_id') }.map do |root|
      { 'id' => root.fetch('canonical_id'), 'definition' => root.fetch('core_definition'), 'entry_sha256' => snapshot.call(root) }
    end
  end,
  'compounds' => compounds.values.sort_by { |entry| entry.fetch('compound_id') }.map do |entry|
    { 'id' => entry.fetch('compound_id'), 'title' => entry.fetch('display_title'), 'definition' => entry.fetch('invariant_definition'), 'entry_sha256' => snapshot.call(entry) }
  end,
  'historical_provisional_cross_references' => atoms.values.flat_map do |root|
    Array(root['distinctions_and_exclusions']).select { |text| text.match?(/provisional|until separately reviewed/i) }.map do |text|
      { 'id' => root.fetch('canonical_id'), 'current_status' => root.fetch('status'), 'text' => text,
        'resolution' => 'Read referenced roots by their current invariant definitions; this historical pointer does not approve additional meanings.' }
    end
  end,
  'review' => 'reviews/perception_foundation_review.md',
  'completion_proven' => false
}
path = File.expand_path('../reports/foundation_inventory_audit.json', __dir__)
content = JSON.pretty_generate(report) + "\n"
if ARGV.include?('--check')
  abort 'Foundation inventory evidence is stale; regenerate and review changed definitions.' unless File.exist?(path) && File.read(path) == content
else
  File.write(path, content)
end
puts JSON.generate(report.slice('root_count', 'compound_count', 'completion_proven').merge('historical_cross_reference_count' => report['historical_provisional_cross_references'].length))
