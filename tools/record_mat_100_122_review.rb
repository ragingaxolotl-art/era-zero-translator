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

pending_packets = [
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
  },
  {
    "range" => "MAT:100–122",
    "status" => "peer_review_complete_pending_user_decision",
    "canonicalized" => false,
    "recommendation" => "reviews/MAT_100_122_recommended_spec.yaml"
  }
]

authority = load_yaml("lexicon/semantic_authority.yaml")
authority["metadata"]["last_review_update"] = "2026-07-29"
authority["metadata"]["current_status"] =
  "45 canonical roots; 279 provisional roots; 27 provisional roots reviewed pending user decision"
authority["review_packets_pending_user_decision"] = pending_packets
authority["active_review_packet"] = {
  "range" => "MAT:100–122",
  "status" => "peer_review_complete_pending_user_decision",
  "canonicalized" => false
}
authority["semantic_review_progress"] = {
  "canonical_chunks" => 1,
  "reviewed_pending_decision_chunks" => 3,
  "unreviewed_chunks" => 28,
  "reviewed_pending_decision_roots" => 27,
  "unreviewed_roots" => 252
}
authority["stop_boundary"] = {
  "do_not_begin" => [
    "MAT:200–222",
    "any other root block",
    "Gate 4",
    "translator implementation"
  ]
}
write_yaml("lexicon/semantic_authority.yaml", authority)

version = load_yaml("spec/version.yaml")
version["active_review_packet"] = "MAT:100–122"
version["review_packets_pending_user_decision"] = pending_packets.map { |packet| packet["range"] }
version["unreviewed_semantic_roots"] = 252
version["unreviewed_nine_root_chunks"] = 28
version["translator_readiness"] = "spec/translator_readiness.yaml"
version["next_gate_authorized"] = false
write_yaml("spec/version.yaml", version)

phase2 = load_yaml("spec/phase2_provisional_spec.yaml")
phase2["scope"]["remaining_review_chunks"] = 28
phase2["scope"]["reviewed_pending_decision_chunks"] = 3
phase2["scope"]["reviewed_pending_decision_meanings"] = 27
phase2["scope"]["unreviewed_meanings"] = 252
phase2["review_chunks"].each do |chunk|
  chunk["status"] = "peer_review_complete_pending_user_decision" if chunk["range"] == "MAT:100–122"
end
write_yaml("spec/phase2_provisional_spec.yaml", phase2)

standard = load_yaml("spec/era_zero_core_standard_1.0.0.yaml")
standard["metadata"]["review_progress"] =
  "MOV:200–222, MAT:000–022, and MAT:100–122 reviewed pending user decision"
standard["authority"]["reviewed_provisional_roots"] =
  "MOV:200–222, MAT:000–022, and MAT:100–122 have completed adversarial review but remain noncanonical."
standard["inventory"]["reviewed_pending_decision_roots"] = 27
standard["inventory"]["unreviewed_roots"] = 252
standard["inventory"]["reviewed_pending_decision_chunks"] = 3
standard["inventory"]["unreviewed_review_chunks"] = 28
standard["deferred_post_core_layers"].map! do |item|
  item == "MAT:100–122 and every later root block" ?
    "MAT:200–222 and every later root block" : item
end
standard["canonical_review_chunks"].each do |chunk|
  chunk["status"] = "peer_review_complete_pending_user_decision" if chunk["range"] == "MAT:100–122"
end
write_yaml("spec/era_zero_core_standard_1.0.0.yaml", standard)

readiness = load_yaml("spec/translator_readiness.yaml")
readiness["current_inventory"]["reviewed_pending_user_decision"] = {
  "roots" => 27,
  "packets" => pending_packets.map { |packet| packet["range"] }
}
readiness["current_inventory"]["unreviewed"] = {
  "roots" => 252,
  "nine_root_chunks" => 28
}
readiness["next_semantic_chunk_after_pending_decisions"] = "MAT:200–222"
write_yaml("spec/translator_readiness.yaml", readiness)

decisions = load_yaml("extraction/user_decisions.yaml")
decision = {
  "kind" => "next_chunk_review_authorization",
  "decision" => "Proceed with the next detailed semantic-review part.",
  "effect" => "Authorizes review of MAT:100–122 despite the prior packet stop boundary, but does not approve the pending MOV:200–222 or MAT:000–022 recommendations, canonize MAT:100–122, begin MAT:200–222, Gate 4, or translator implementation."
}
unless decisions["decisions"].any? { |item| item["kind"] == decision["kind"] && item["decision"] == decision["decision"] }
  decisions["decisions"] << decision
end
decisions["metadata"]["count"] = decisions["decisions"].length
write_yaml("extraction/user_decisions.yaml", decisions)

puts "Recorded MAT:100–122 as reviewed pending user decision; semantic counts remain 45 canonical / 279 provisional."
