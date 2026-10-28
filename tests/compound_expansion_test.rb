# frozen_string_literal: true
require "minitest/autorun"
require_relative "../tools/lib/era_zero_compound_expansion"
require_relative "../tools/lib/era_zero_validation"
require_relative "../tools/lib/era_zero_renderer"

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

  def test_nested_compounds_reach_renderer_with_one_external_ending
    atoms, = EraZeroRenderer.load_authority
    compounds = fixtures.to_h { |e| [e["compound_id"], e] }
    ir = { "ir_version" => "1.0", "root_clause" => "c", "speech_act" => "assertion",
      "nodes" => [{ "node_id" => "c", "kind" => "clause", "clause_type" => "predication" },
                  { "node_id" => "p", "kind" => "lexical_occurrence", "target_type" => "compound", "target_id" => "outer", "runtime_state" => { "code" => 2 } }],
      "edges" => [{ "edge_id" => "e", "type" => "centers", "from" => "p", "to" => "c" }], "discourse_constraints" => {} }
    digest = EraZeroRenderer.semantic_digest(ir)
    ir.merge!("utterance_id" => "UTT:#{digest[0, 24]}", "serialization" => { "content_digest" => digest })
    EraZeroRenderer.stub(:load_authority, [atoms, compounds]) do
      formal = EraZeroRenderer.render(ir)
      events = formal.dig("performance", "lexical_events")
      assert_equal %w[MAT:200 CRE:010 STR:020 MAT:200 CRE:010], events.map { |e| e["target_id"] }
      assert_equal 1, events.count { |e| e.key?("runtime_tail") }
      assert_equal 2, events.last.dig("runtime_tail", "code")
      assert_equal '["h","h","h"]', events.last["component_node_id"]
      assert_equal ir, EraZeroRenderer.decode(formal)
      assert_equal formal["formal_id"], EraZeroRenderer.render(ir, anchor_midi: 72)["formal_id"]
    end
  end

  def test_sibling_order_is_independent_of_node_names_and_storage_order
    original = entry("same", [root("first", "MAT:200"), root("second", "STR:020"), root("h", "CRE:010")], "h", [["first", "h"], ["second", "h"]])
    renamed = entry("same", [root("z", "MAT:200"), root("a", "STR:020"), root("head", "CRE:010")].reverse, "head", [["a", "head"], ["z", "head"]])
    sequences = [original, renamed].map do |definition|
      expander = Expander.new([definition])
      expander.ordered_roots(expander.expand("same", "1.0.0")).map { |node| node["root_id"] }
    end
    assert_equal sequences.first, sequences.last
    assert_equal "CRE:010", sequences.first.last
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
