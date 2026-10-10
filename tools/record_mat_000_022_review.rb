#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def write_yaml(path, value)
  File.write(File.join(ROOT, path), YAML.dump(value))
end

authority = load_yaml("lexicon/semantic_authority.yaml")
authority["metadata"]["last_review_update"] = "2026-07-29"
authority["metadata"]["current_status"] =
  "45 canonical roots; 279 provisional roots; 18 provisional roots reviewed pending user decision"
authority["review_packets_pending_user_decision"] = [
  {
    "range" => "MOV:200–222",
    "status" => "peer_review_complete_pending_user_decision",
    "canonicalized" => false,
    "recommendation" => "reviews/MOV_200_222_recommended_spec.yaml"
  },
  {
    "range" => "MAT:000–022",
    "status" => "peer_review_complete_pending_user_decision",
    "canonicalized" => false,
    "recommendation" => "reviews/MAT_000_022_recommended_spec.yaml"
  }
]
authority["active_review_packet"] = {
  "range" => "MAT:000–022",
  "status" => "peer_review_complete_pending_user_decision",
  "canonicalized" => false
}
authority["semantic_review_progress"] = {
  "canonical_chunks" => 1,
  "reviewed_pending_decision_chunks" => 2,
  "unreviewed_chunks" => 29,
  "reviewed_pending_decision_roots" => 18,
  "unreviewed_roots" => 261
}
authority["stop_boundary"] = {
  "do_not_begin" => [
    "MAT:100–122",
    "any other root block",
    "Gate 4",
    "translator implementation"
  ]
}
write_yaml("lexicon/semantic_authority.yaml", authority)

version = load_yaml("spec/version.yaml")
version["active_review_packet"] = "MAT:000–022"
version["review_packets_pending_user_decision"] = [
  "MOV:200–222",
  "MAT:000–022"
]
version["unreviewed_semantic_roots"] = 261
version["unreviewed_nine_root_chunks"] = 29
version["translator_readiness"] = "spec/translator_readiness.yaml"
version["next_gate_authorized"] = false
write_yaml("spec/version.yaml", version)

phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
phase2["scope"]["remaining_review_chunks"] = 29
phase2["scope"]["reviewed_pending_decision_chunks"] = 2
phase2["scope"]["reviewed_pending_decision_meanings"] = 18
phase2["scope"]["unreviewed_meanings"] = 261
phase2["review_chunks"].each do |chunk|
  chunk["status"] = "peer_review_complete_pending_user_decision" if chunk["range"] == "MAT:000–022"
end
write_yaml("spec/phase2_provisional_spec.yaml", phase2)

standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["review_progress"] =
  "MOV:200–222 and MAT:000–022 reviewed pending user decision"
standard["authority"]["reviewed_provisional_roots"] =
  "MOV:200–222 and MAT:000–022 have completed adversarial review but remain noncanonical."
standard["inventory"]["reviewed_pending_decision_roots"] = 18
standard["inventory"]["unreviewed_roots"] = 261
standard["inventory"]["reviewed_pending_decision_chunks"] = 2
standard["inventory"]["unreviewed_review_chunks"] = 29
standard["deferred_post_core_layers"].map! do |item|
  item == "MAT:000–022 and every root block after MOV:200–222" ?
    "MAT:100–122 and every later root block" : item
end
standard["canonical_review_chunks"].each do |chunk|
  chunk["status"] = "peer_review_complete_pending_user_decision" if chunk["range"] == "MAT:000–022"
end
write_yaml("spec/era_zero_core_standard_1.0.0.yaml", standard)

decisions = load_yaml("extraction/user_decisions.yaml")
decisions["decisions"] << {
  "kind" => "review_authorization_with_translator_readiness_request",
  "decision" => "Explain what remains before translation and perform the next detailed semantic chunk.",
  "effect" => "Authorizes detailed review of MAT:000–022 and a translator-readiness roadmap, but does not approve MOV:200–222, canonize MAT meanings, begin MAT:100–122, Gate 4, or translator implementation."
}
decisions["metadata"]["count"] = decisions["decisions"].length
write_yaml("extraction/user_decisions.yaml", decisions)

puts "Recorded MAT:000–022 as reviewed pending user decision; semantic counts remain 45 canonical / 279 provisional."
