# frozen_string_literal: true
require "minitest/autorun"
require_relative "../tools/lib/era_zero_compound_dependencies"
require_relative "../tools/lib/era_zero_validation"

class CompoundDependenciesTest < Minitest::Test
  Registry = EraZeroCompoundDependencies::Registry
  Error = EraZeroCompoundDependencies::DependencyError

  def entry(id, refs = [], version = "1.0.0", status = "approved")
    { "compound_id" => id, "definition_version" => version, "status" => status,
      "nodes" => refs.map { |ref, v| { "kind" => "compound_ref", "compound_id" => ref, "definition_version" => v } } }
  end

  def test_nested_diamond_is_dependency_ordered_and_not_a_cycle
    entries = [entry("a", [["b", "1.0.0"], ["c", "1.0.0"]]),
               entry("b", [["d", "1.0.0"]]), entry("c", [["d", "1.0.0"]]), entry("d")]
    inventory = Registry.new(entries).inventory
    assert_equal %w[d b c a], inventory.map { |e| e["compound_id"] }
    assert_equal [0, 1, 1, 2], inventory.map { |e| e["depth"] }
    assert_equal inventory, Registry.new(entries.reverse).inventory
  end

  def test_version_is_not_substituted
    registry = Registry.new([entry("a", [["b", "1.0.0"]]), entry("b", [], "2.0.0")])
    assert_match(/missing compound version b@1.0.0/, assert_raises(Error) { registry.ordered }.message)
  end

  def test_versions_can_coexist
    registry = Registry.new([entry("a", [["b", "1.0.0"]]), entry("b"), entry("b", [], "2.0.0")])
    assert_equal "1.0.0", registry.resolve("b", "1.0.0")["definition_version"]
    assert_equal 3, registry.ordered.length
  end

  def test_cycle_reports_path
    registry = Registry.new([entry("a", [["b", "1.0.0"]]), entry("b", [["a", "1.0.0"]])])
    assert_match(/a@1.0.0 -> b@1.0.0 -> a@1.0.0/, assert_raises(Error) { registry.ordered }.message)
  end

  def test_rejects_missing_pin_unapproved_and_duplicates
    assert_raises(Error) { Registry.new([entry("a", [["b", nil]])]).ordered }
    assert_raises(Error) { Registry.new([entry("a", [], "1.0.0", "superseded")]).ordered }
    assert_raises(Error) { Registry.new([entry("a"), entry("a")]) }
  end

  def test_current_dictionary_dependencies_precede_consumers
    entries = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")
    inventory = Registry.new(entries).inventory
    assert_equal entries.length, inventory.length
    seen = []
    inventory.each do |e|
      e["dependencies"].each do |dependency|
        assert_includes seen, [dependency["compound_id"], dependency["definition_version"]]
      end
      seen << [e["compound_id"], e["definition_version"]]
    end
  end
end
