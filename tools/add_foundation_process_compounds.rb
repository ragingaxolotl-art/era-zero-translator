#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative "lib/era_zero_validation"
V = EraZeroValidation

# Versioned, idempotent migration of the reviewed first foundation batch.
# Semantic approval is delegated by the user's translator-completion goal.
dictionary = V.load_yaml("lexicon/compound_dictionary.yaml")
reviews = V.load_yaml("reviews/gate4b_high_frequency_compounds_scored_candidates.yaml")
before = V.fingerprint(dictionary.fetch("entries"))
added = []
[
  ["physical repair", "ongoing physical repair", "MAT:111", "REP:111",
   "An ongoing source-to-target restorative transformation whose restorative transformation is an ongoing physical-state change localized in that distinct material target.",
   "actively restoring a distinct physical target toward its applicable restoration standard",
   "completed or merely possible repair, arbitrary physical change, internal self-restoration, and future intention without ongoing repair"],
  ["data repair", "ongoing internal data repair", "DAT:101", "REP:101",
   "An ongoing restorative transformation originating within one reference entity whose restorative transformation is an ongoing bounded transformation of represented information within that entity, without transfer to a distinct target.",
   "internal restoration of damaged represented information by an ongoing internal information transformation",
   "arbitrary editing, transfer to another target, completed restoration, and restoration originating from a distinct external source"],
  ["structural repair", "ongoing internal structural repair", "STR:101", "REP:101",
   "An ongoing restorative transformation originating within one reference structure whose restorative transformation changes how that structure's constituents occupy its internal positions.",
   "ongoing internal structural reconfiguration toward the applicable restoration standard",
   "arbitrary rearrangement, incorporation of a distinct target, formation of a peer composite, and completed or merely possible restoration"]
].each do |previous_title, title, qualifier, head, definition, includes, excludes|
  previous = dictionary.fetch("entries").find { |entry| entry["display_title"] == previous_title } or abort "Missing foundation #{previous_title}"
  entry = Marshal.load(Marshal.dump(previous))
  entry["nodes"].each { |node| node["root_id"] = node["node_id"] == entry["semantic_head"] ? head : qualifier }
  digest = V.fingerprint(entry.slice("architecture_version", "semantic_head", "nodes", "edges", "lexical_constraints"))
  id = "CMP:#{digest[0, 24]}"
  entry.merge!("compound_id" => id, "content_digest" => digest, "display_title" => title,
    "english_glosses" => [title], "approval_date" => "2026-10-28", "invariant_definition" => definition,
    "approval_basis" => "Delegated semantic approval under the user-directed translator-completion goal; reviews/foundation_process_compounds.md",
    "boundaries" => { "includes" => includes, "excludes" => excludes },
    "collision_audit" => "The restorative head and domain qualifier both encode an ongoing process. Runtime status does not replace lexical phase. The completed foundation remains unchanged.",
    "examples" => { "ordinary" => includes, "technical" => definition,
      "future_compound" => "May be reused as an ongoing restorative process with explicit participants and domain restrictions.",
      "counterexample" => "Do not use for #{excludes}." },
    "serialization" => { "canonical_format" => "EZC-JSON-1", "content_digest" => digest })
  existing = dictionary["entries"].find { |item| item["compound_id"] == id }
  abort "Existing definition differs: #{title}" if existing && existing != entry
  dictionary["entries"] << entry unless existing
  unless reviews["reviews"].any? { |review| review["compound_id"] == id }
    candidates = [
      ["active_graph", "Both domain and restoration are ongoing; preserves all required distinctions.", [9, 10, 10, 10, 9, 9, 8, 9], "winner"],
      ["head_only", "Using only the restorative head loses the domain restriction.", [10, 10, 10, 3, 3, 5, 5, 5], "rejected: domain distinction is missing"],
      ["completed_with_runtime", "Changing runtime on the completed foundation does not change its lexical phase.", [8, 2, 8, 1, 7, 2, 2, 2], "rejected: completed process is not ongoing"]
    ].map do |key, reason, scores, decision|
      { "candidate_id" => key, "direction" => reason,
        "scores" => V::SCORE_KEYS.zip(scores).to_h, "total" => scores.sum, "decision" => decision }
    end
    candidates.first["graph"] = { "head" => entry["semantic_head"], "nodes" => entry["nodes"], "edges" => entry["edges"] }
    reviews["reviews"] << { "compound_id" => id, "display_title" => title,
      "current_choice_reason" => "Review in reviews/foundation_process_compounds.md; scores are implementation-author judgments, not independent review or measured coverage.",
      "candidates" => candidates, "recommendation" => "approve active_graph", "confidence" => "high" }
  end
  added << { "compound_id" => id, "display_title" => title, "completed_foundation" => previous["compound_id"] }
end
dictionary["entries"].sort_by! { |entry| entry["compound_id"] }
dictionary["metadata"]["entry_count"] = dictionary["entries"].length
V.write("lexicon/compound_dictionary.yaml", YAML.dump(dictionary))
V.write("reviews/gate4b_high_frequency_compounds_scored_candidates.yaml", YAML.dump(reviews))
path = "migrations/foundation_process_compounds_2026_10_28.yaml"
unless File.exist?(File.join(V::ROOT, path))
  V.write(path, YAML.dump({ "authority" => "User-directed translator-completion goal", "date" => "2026-10-28",
    "review" => "reviews/foundation_process_compounds.md", "atomic_meanings_changed" => false,
    "existing_compound_meanings_changed" => false, "before_dictionary_fingerprint" => before,
    "added" => added, "required_followup" => "Run rebuild_compound_release.rb and phase contrast tests before publication." }))
end
puts "Foundation dictionary now has #{dictionary['entries'].length} entries. Rebuild derived records next."
