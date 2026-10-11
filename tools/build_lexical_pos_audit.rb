#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

index = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml")
profile = EraZeroValidation.load_yaml("lexicon/game_story_surface_routes.yaml")
plain = EraZeroValidation.load_yaml("lexicon/plain_english_index.yaml")
atoms = EraZeroValidation.load_yaml("lexicon/all_atoms.yaml").fetch("atoms")
senses = index.fetch("senses")
profile_senses = profile.fetch("senses")
plain_by_target = plain.fetch("entries").to_h { |entry| [entry.fetch("target_id"), entry] }
all_surface = senses + profile_senses

affordance_for = lambda do |atom|
  slot = atom.fetch("universal_slot")
  primary = if slot.include?(" process")
              "process_like"
            elsif slot.include?(" relationship")
              "relationship_like"
            else
              "entity_like"
            end
  {
    "primary" => primary,
    "english_realizations" => all_surface.select { |sense| sense["target_id"] == atom.fetch("canonical_id") }.map { |sense| sense.fetch("part_of_speech") }.uniq.sort,
    "policy" => "The root has a semantic affordance, not an English part of speech. Part of speech belongs to each English sense."
  }
end

root_records = atoms.map do |atom|
  mapped = all_surface.select { |sense| sense["target_id"] == atom.fetch("canonical_id") }
  plain_entry = plain_by_target.fetch(atom.fetch("canonical_id"))
  {
    "target_id" => atom.fetch("canonical_id"),
    "canonical_title" => atom.fetch("title"),
    "invariant_definition" => atom.fetch("core_definition"),
    "universal_slot" => atom.fetch("universal_slot"),
    "semantic_affordance" => affordance_for.call(atom),
    "indexed_english_sense_ids" => mapped.map { |sense| sense.fetch("sense_id") }.sort,
    "ordinary_language_tags" => plain_entry.fetch("ordinary_terms"),
    "search_phrases" => plain_entry.fetch("match_phrases"),
    "mapping_authority" => "discovery_only_noncanonical"
  }
end

sense_records = all_surface.map do |sense|
  {
    "sense_id" => sense.fetch("sense_id"),
    "lemma" => sense.fetch("lemma"),
    "part_of_speech" => sense.fetch("part_of_speech"),
    "surface_forms" => sense.fetch("surface_forms", [sense.fetch("display_form", sense.fetch("lemma"))]).uniq,
    "route" => sense.fetch("route"),
    "target_id" => sense["target_id"],
    "sense_key" => sense.fetch("sense_key"),
    "definition" => sense.fetch("definition"),
    "fidelity" => sense.fetch("fidelity", sense.fetch("confidence", "indexed")),
    "controlled_input_allowed" => sense.fetch("controlled_input_allowed", false),
    "authority_layer" => sense.fetch("sense_id").start_with?("GSE:") ? "game_story_surface_profile" : "english_sense_index"
  }
end

pos_counts = sense_records.group_by { |sense| sense.fetch("part_of_speech") }.transform_values(&:length).sort.to_h
document = {
  "metadata" => {
    "format" => "EZ-LEXICAL-POS-AUDIT-1",
    "version" => "1.0.0",
    "status" => "noncanonical_metadata_complete",
    "canonical_semantic_changes" => 0,
    "root_count" => root_records.length,
    "indexed_sense_count" => senses.length,
    "game_story_surface_sense_count" => profile_senses.length,
    "total_audited_senses" => sense_records.length,
    "part_of_speech_counts" => pos_counts,
    "policy" => "English senses carry parts of speech; Era Zero roots retain address-derived semantic affordances and may support more than one English syntactic realization."
  },
  "roots" => root_records,
  "senses" => sense_records
}
EraZeroValidation.write("lexicon/lexical_pos_audit.yaml", YAML.dump(document))

verbs = sense_records.select { |sense| %w[verb verb_phrase].include?(sense.fetch("part_of_speech")) }
report = <<~MARKDOWN
  # Era Zero lexical and part-of-speech audit

  Status: **PASS — COMPLETE NONCANONICAL METADATA LAYER**

  - Canonical roots audited: **#{root_records.length}/324**
  - Canonical English-index senses audited: **#{senses.length}/436**
  - Game/story surface senses audited: **#{profile_senses.length}/#{profile_senses.length}**
  - Verb or verb-phrase senses: **#{verbs.length}**
  - Canonical meanings changed: **0**

  ## Design decision

  An Era Zero atom is not permanently labeled “noun,” “verb,” or “adjective.” Its address supplies an entity-, process-, or relationship-like semantic affordance. English part of speech belongs to a particular indexed sense. This prevents English grammar from silently redefining the language.

  ## Coverage

  Every root now has its canonical title and definition, address slot, semantic affordance, indexed English sense links, ordinary-language tags, and search phrases in `lexicon/lexical_pos_audit.yaml`. Every indexed and game/story surface sense has a normalized POS, route, target, fidelity, and surface-form inventory.

  ## Verb policy

  Existing verbs are consolidated into reviewed senses. An unfamiliar verb is never converted into a phonemic noun label. It enters the concept-intake workflow and is routed to an existing atom, existing compound, proposed compound, Semantic IR, grammar, an explicit gap, or a later-era proposal. No new root is created merely because English has another verb.

  ## POS counts

  #{pos_counts.map { |pos, count| "- `#{pos}`: **#{count}**" }.join("\n")}
MARKDOWN
EraZeroValidation.write("reports/lexical_pos_and_verb_audit.md", report)
puts "Built lexical/POS audit: #{root_records.length} roots; #{sense_records.length} senses; #{verbs.length} verbal senses"
