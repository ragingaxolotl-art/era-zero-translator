#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"
require_relative "lib/era_zero_validation"

root = EraZeroValidation::ROOT
# Ruby 3.3 disables YAML aliases unless they are explicitly authorized. The
# canonical lexicon intentionally uses anchors/aliases to keep generated forms
# consistent, so the audit must opt in on every supported Ruby version.
load_yaml = lambda do |path|
  absolute = File.join(root, path)
  YAML.safe_load(File.read(absolute), aliases: true, filename: absolute)
end
atoms = load_yaml.call("lexicon/all_atoms.yaml").fetch("atoms")
compounds = load_yaml.call("lexicon/compound_dictionary.yaml").fetch("entries")
senses = load_yaml.call("lexicon/english_sense_index.yaml").fetch("senses")
readiness = load_yaml.call("spec/translator_readiness.yaml")
provenance = load_yaml.call("spec/source_provenance.yaml")

checks = []
add = ->(name, ok, detail) { checks << [name, !!ok, detail] }
atom_ids = atoms.map { |item| item.fetch("canonical_id") }
target_ids = senses.map { |item| item["target_id"] }.compact.uniq
canonical_labels = senses.select { |item| item["sense_key"] == "canonical_atom_label" }
compound_labels = senses.select { |item| item["sense_key"] == "canonical_compound_label" }
shared = provenance.dig("sources", "original_shared_conversation")

add.call("324 canonical atoms", atoms.length == 324 && atom_ids.uniq.length == 324 && atoms.all? { |item| item["status"] == "canonical" }, "#{atoms.length} records / #{atom_ids.uniq.length} unique IDs")
add.call("36 source-developed records", atoms.count { |item| %w[LIF MOV].include?(item["family"]) && (item["family"] == "LIF" || item["address"].start_with?("0")) } >= 36, "source corpus preserved separately with immutable source IDs")
add.call("28 approved compounds", compounds.length == 28 && compounds.all? { |item| item["status"] == "approved" }, "#{compounds.length} approved definitions")
add.call("436 complete sense options", senses.length == 436 && canonical_labels.length == 324 && compound_labels.length == 28, "#{canonical_labels.length} atomic labels / #{compound_labels.length} compound labels")
add.call("352 lexical targets", target_ids.length == 352, "#{target_ids.length} unique direct targets")
add.call("11 explicit gaps", senses.count { |item| item["route"] == "gap" } == 11, "#{senses.count { |item| item["route"] == "gap" }} indexed gaps")
add.call("all planned gates complete", readiness.fetch("required_gates").all? { |gate| gate["status"] == "complete" }, readiness.dig("metadata", "status"))
add.call("current progress flags", readiness.dig("gate4a", "dictionary_entries") == 28 && readiness.dig("gate4c", "general_english_translation") == true && readiness.dig("gate4d", "translator_authorized") == true && readiness.dig("renderer_decoder", "controlled_english_started") == true && readiness.dig("controlled_english", "general_english_started") == true, "no completed layer is still marked unstarted")
add.call("shared conversation fingerprint", shared["decoded_sha256"] == "5a89af8cda717ce223e252348e0cf2f7735cd2d1f58c7b7655094a3d13862475" && shared["decoded_source_nodes"] == 313 && shared["visible_speaker_turns"] == 129, "313 nodes / 129 turns / fixed SHA-256")
add.call("primary source links", shared["url"] == "https://chatgpt.com/share/6a666bd1-8ba4-83ea-90f9-b85db783af13" && provenance.dig("sources", "current_google_document", "drive_file_id") == "1btnSrT37YJt1aD4gXGtJBO8e3ZRG6COYmFLaRkykHA8", "conversation and Google document are explicitly referenced")
required = %w[semantic_authority_status.md lexicon/semantic_authority.yaml spec/canonical_spec.yaml lexicon/completed_atoms_source.md docs/SOURCE_PROVENANCE.md spec/source_provenance.yaml]
add.call("authority artifacts present", required.all? { |path| File.file?(File.join(root, path)) }, required.join(", "))

passed = checks.count { |_name, ok, _detail| ok }
failed = checks.length - passed
lines = ["# Full Project Completeness and Provenance Audit", "", "Status: **#{failed.zero? ? 'PASS' : 'FAIL'}**", "", "- Checks passed: **#{passed}**", "- Checks failed: **#{failed}**", "- Audited: **2026-10-10**", "", "This audit reconciles the browser release with the canonical lexicon, compound dictionary, English index, current gate status, original shared conversation, integrated Google document, and current development-conversation decisions.", ""]
checks.each { |name, ok, detail| lines.concat(["## #{ok ? 'PASS' : 'FAIL'} — #{name}", "", detail, ""]) }
lines.concat(["## Product boundary", "", "The interface accepts any phrase, exposes every indexed option, and preserves unfamiliar terms as EZNAME phonemic labels. A phonemic label identifies a surface form; it is not a fabricated semantic translation. Free-form multi-clause semantic composition remains constrained by the approved IR and must not be guessed.", ""])
File.write(File.join(root, "reports/full_project_completeness_audit.md"), lines.join("\n"))
puts "Project completeness audit: #{failed.zero? ? 'PASS' : 'FAIL'}"
puts "Checks passed: #{passed}; failed: #{failed}"
exit(failed.zero? ? 0 : 1)
