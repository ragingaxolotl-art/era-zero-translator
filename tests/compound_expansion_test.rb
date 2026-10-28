# frozen_string_literal: true
require "minitest/autorun"
require_relative "../tools/lib/era_zero_compound_expansion"
require_relative "../tools/lib/era_zero_validation"

class CompoundExpansionTest < Minitest::Test
  Expander = EraZeroCompoundExpansion::Expander
  Error = EraZeroCompoundExpansion::ExpansionError

  def root(id, atom)
    { "node_id" => id, "kind" => "root", "root_id" => atom }
  end

  def ref(id, target, version = "1.0.0")
    { "node_id" => id, "kind" => "compound_ref", "compound_id" => target, "definition_version" => version }
  end

  def entry(id, nodes, head, edges)
    { "compound_id" => id, "definition_version" => "1.0.0", "status" => "approved",
      "nodes" => nodes, "semantic_head" => head,
      "edges" => edges.map { |from, to| { "type" => "qualifies", "from" => from, "to" => to } },
      "lexical_constraints" => ["scope of #{id}"] }
  end

  def fixtures
    [entry("base", [root("q", "MAT:200"), root("h", "CRE:010")], "h", [["q", "h"]]),
     entry("nested", [root("q", "STR:020"), ref("h", "base")], "h", [["q", "h"]]),
     entry("outer", [ref("q", "base"), ref("h", "nested")], "h", [["q", "h"]])]
  end

  def test_recursive_head_and_repeated_references_have_distinct_paths
    expanded = Expander.new(fixtures).expand("outer", "1.0.0")
    assert_equal ["h", "h", "h"], expanded["semantic_head"]
    assert_equal 5, expanded["nodes"].length
    assert_equal 5, expanded["nodes"].map { |n| n["path"] }.uniq.length
    assert_includes expanded["nodes"].map { |n| n["path"] }, ["q", "h"]
    assert_includes expanded["nodes"].map { |n| n["path"] }, ["h", "h", "h"]
  end

  def test_reference_attachment_preserves_scope_not_just_flat_head
    expanded = Expander.new(fixtures).expand("outer", "1.0.0")
    edge = expanded["edges"].find { |e| e["scope_path"].empty? }
    assert_equal ["h"], edge["to_scope_target"]
    assert_equal ["h", "h", "h"], edge["to_path"]
    assert_equal ["scope of nested"], expanded["scopes"].find { |s| s["path"] == ["h"] }["lexical_constraints"]
  end

  def test_slots_are_occurrence_scoped_and_input_is_not_modified
    base = entry("slotted", [{ "node_id" => "s", "kind" => "slot", "slot_name" => "target", "slot_type" => "entity" }, root("h", "REP:111")], "h", [])
    base["edges"] << { "from" => "s", "to" => "h", "type" => "fills_role", "role" => "target" }
    outer = entry("outer", [ref("q", "slotted"), ref("h", "slotted")], "h", [["q", "h"]])
    input = [base, outer]
    original = Marshal.dump(input)
    result = Expander.new(input).expand("outer", "1.0.0")
    assert_equal [["q", "s"], ["h", "s"]], result["nodes"].select { |n| n["kind"] == "slot" }.map { |n| n["path"] }
    result["nodes"].first["slot_name"] = "modified"
    assert_equal original, Marshal.dump(input)
  end

  def test_missing_version_and_dependency_cycle_are_rejected
    assert_raises(Error) { Expander.new(fixtures).expand("outer", "2.0.0") }
    cyclic = entry("cycle", [ref("h", "cycle")], "h", [])
    assert_match(/cycle/, assert_raises(Error) { Expander.new([cyclic]).expand("cycle", "1.0.0") }.message)
  end

  def test_malformed_graph_and_configurable_limits
    disconnected = entry("bad", [root("q", "MAT:200"), root("h", "CRE:010")], "h", [])
    assert_raises(Error) { Expander.new([disconnected]).expand("bad", "1.0.0") }
    assert_raises(Error) { Expander.new(fixtures, max_nodes: 4).expand("outer", "1.0.0") }
    assert_raises(Error) { Expander.new(fixtures, max_depth: 2).expand("outer", "1.0.0") }
  end

  def test_every_current_compound_expands_without_losing_roots_or_slots
    entries = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")
    expander = Expander.new(entries)
    entries.each do |entry|
      result = expander.expand(entry["compound_id"], entry["definition_version"])
      assert_equal entry["nodes"].length, result["nodes"].length
      assert_equal [entry["semantic_head"]], result["semantic_head"]
    end
  end
end
