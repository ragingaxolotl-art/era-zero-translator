#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "set"
require "yaml"

module EraZeroValidation
  ROOT = File.expand_path("../..", __dir__)

  WITHDRAWAL = "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION"
  SOURCE_CANONICAL_FINGERPRINT =
    "52caf28d708027b515ba8dd9e00023efb6642afdbe156fe3449c82c9d09dff50"

  FAMILIES = {
    "LIF" => ["ni", [0, 4, 7]],
    "MOV" => ["gi", [0, 2, 7]],
    "MAT" => ["ba", [0, 7, 12]],
    "MIN" => ["si", [0, 3, 7]],
    "CON" => ["wu", [0, 4, 7, 9]],
    "STR" => ["do", [0, 5, 7]],
    "WRN" => ["da", [0, 3, 6]],
    "REP" => ["ya", [0, 3, 7, 9]],
    "LOG" => ["te", [0, 4, 8]],
    "DAT" => ["li", [0, 4, 7, 11]],
    "CRE" => ["ga", [0, 3, 7, 11]],
    "ORI" => ["nu", [0, 1, 7]]
  }.freeze

  SLOTS = {
    [0, 0] => ["stable inward entity", "active inward entity", "dormant inward entity"],
    [0, 1] => ["stable outward entity", "active outward entity", "dormant outward entity"],
    [0, 2] => ["stable collective entity", "active collective entity", "dormant collective entity"],
    [1, 0] => ["completed inward process", "active inward process", "pending inward process"],
    [1, 1] => ["completed outward process", "active outward process", "pending outward process"],
    [1, 2] => ["completed systemic process", "active systemic process", "pending systemic process"],
    [2, 0] => ["stable inward capacity", "active inward capacity", "dormant inward capacity"],
    [2, 1] => ["stable outward relationship", "active outward relationship", "unresolved outward relationship"],
    [2, 2] => ["stable systemic relationship", "active systemic relationship", "unrealized systemic possibility"]
  }.freeze

  SCORE_KEYS = %w[
    atomicity address_fit family_fit neighbor_separation
    cross_family_separation compound_usefulness
    everyday_language_coverage technical_coverage
  ].freeze

  PROHIBITED_DEPENDENCIES = [
    "compounds",
    "English concept index",
    "etymology layer",
    "semantic IR",
    "grammar implementation",
    "renderer",
    "translator"
  ].freeze

  EFFECTIVE_MIGRATIONS = %w[
    migrations/MOV_100_122_semantic_approval.yaml
    migrations/2026-07-29_pending_review_packets_approval.yaml
    migrations/MAT_200_222_semantic_approval.yaml
    migrations/MIN_000_022_semantic_approval.yaml
    migrations/MIN_100_122_semantic_approval.yaml
    migrations/MIN_200_222_semantic_approval.yaml
    migrations/CON_000_022_semantic_approval.yaml
    migrations/CON_100_122_semantic_approval.yaml
    migrations/CON_200_222_semantic_approval.yaml
    migrations/STR_000_022_semantic_approval.yaml
    migrations/STR_100_122_semantic_approval.yaml
    migrations/STR_200_222_semantic_approval.yaml
    migrations/WRN_000_022_semantic_approval.yaml
    migrations/WRN_100_122_semantic_approval.yaml
    migrations/WRN_200_222_semantic_approval.yaml
    migrations/REP_000_022_semantic_approval.yaml
    migrations/REP_100_122_semantic_approval.yaml
    migrations/REP_200_222_semantic_approval.yaml
    migrations/LOG_000_022_semantic_approval.yaml
    migrations/LOG_100_122_semantic_approval.yaml
    migrations/LOG_200_222_semantic_approval.yaml
    migrations/DAT_000_022_semantic_approval.yaml
    migrations/DAT_100_122_semantic_approval.yaml
    migrations/DAT_200_222_semantic_approval.yaml
    migrations/CRE_000_022_semantic_approval.yaml
    migrations/CRE_100_122_semantic_approval.yaml
    migrations/CRE_200_222_semantic_approval.yaml
    migrations/ORI_000_022_semantic_approval.yaml
    migrations/ORI_100_122_semantic_approval.yaml
    migrations/ORI_200_222_semantic_approval.yaml
  ].freeze

  module_function

  def load_yaml(relative_path)
    path = File.join(ROOT, relative_path)
    content = File.read(path, encoding: "UTF-8")
    # Psych 4+ changed YAML.load_file to safe loading and rejects the aliases
    # emitted by Ruby's own YAML serializer for shared arrays in the canonical
    # lexicon. These files are trusted, version-controlled project authority,
    # so preserve the historical full-loader behavior across Ruby versions.
    YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(content) : YAML.load(content)
  end

  def write(relative_path, content)
    File.write(File.join(ROOT, relative_path), content, encoding: "UTF-8")
  end

  def atoms_by_id(document)
    document.fetch("atoms").to_h { |record| [record.fetch("canonical_id"), record] }
  end

  def deep_sort(value)
    case value
    when Hash
      value.keys.sort.to_h { |key| [key, deep_sort(value.fetch(key))] }
    when Array
      value.map { |item| deep_sort(item) }
    else
      value
    end
  end

  def fingerprint(value)
    Digest::SHA256.hexdigest(JSON.generate(deep_sort(value)))
  end

  # Historical fingerprints remain immutable. Accept only the exact documented
  # editorial migration, and prove its reversal restores the complete old records.
  def atomic_fingerprint_matches?(atoms, expected)
    actual = fingerprint(atoms)
    return true if actual == expected
    migration = load_yaml("migrations/min_cross_reference_reconciliation_2026_10_28.yaml")
    return false unless actual == migration.fetch("after_fingerprint") && expected == migration.fetch("before_fingerprint")
    restored = Marshal.load(Marshal.dump(atoms))
    targets = restored.select { |atom| migration.fetch("root_ids").include?(atom["canonical_id"]) }
    return false unless targets.length == 9
    targets.each do |atom|
      values = atom.fetch("distinctions_and_exclusions")
      migration.fetch("replacements").each do |old, corrected|
        return false unless values.count(corrected) == 1 && values.count(old).zero?
        values.map! { |text| text == corrected ? old : text }
      end
    end
    fingerprint(restored) == expected
  end

  def normalized_range(value)
    match = value.to_s.upcase.tr("–—", "-").match(/\A([A-Z]{3}):(\d{3})-(\d{3})\z/)
    raise ArgumentError, "range must look like CON:000-022" unless match

    family, first, last = match.captures
    raise ArgumentError, "unknown family #{family}" unless FAMILIES.key?(family)
    unless first[0] == last[0] && first[1, 2] == "00" && last[1, 2] == "22"
      raise ArgumentError, "range must cover one complete third-trit triplet grid (for example CON:000-022)"
    end

    "#{family}:#{first}–#{last}"
  end

  def ids_for_range(value)
    normalized = normalized_range(value)
    family, endpoints = normalized.split(":", 2)
    first, last = endpoints.split("–", 2)
    layer = first[0].to_i
    raise ArgumentError, "range endpoints must share a first trit" unless last[0].to_i == layer

    [0, 1, 2].product([0, 1, 2]).map do |second, third|
      "#{family}:#{layer}#{second}#{third}"
    end
  end

  def stem_for_range(value)
    normalized_range(value).tr(":–", "__")
  end

  def expected_generated_fields(atom)
    family = atom.fetch("family")
    address = atom.fetch("address")
    trits = address.chars.map(&:to_i)
    raise KeyError, "invalid address #{address}" unless trits.length == 3 && trits.all? { |trit| trit.between?(0, 2) }

    onset, harmony = FAMILIES.fetch(family)
    compact = "#{%w[n k m][trits[0]]}#{%w[a o i][trits[1]]}#{%w[m k n][trits[2]]}"
    path = [0]
    trits.each { |trit| path << path.last + [0, 2, -2][trit] }

    {
      "canonical_id" => "#{family}:#{address}",
      "family" => family,
      "address" => address,
      "family_onset" => onset,
      "harmonic_signature_semitones" => harmony,
      "universal_slot" => SLOTS.fetch([trits[0], trits[1]])[trits[2]],
      "local_compact_root" => compact,
      "canonical_transliteration" => "#{onset}·#{compact}",
      "formal_carrier" => ([onset] + trits.map { |trit| %w[ma ki nu][trit] }).join("-"),
      "note_path_semitones" => path
    }
  end

  def generated_field_errors(atoms)
    atoms.values.flat_map do |atom|
      expected_generated_fields(atom).map do |field, expected|
        next if atom[field] == expected

        "#{atom.fetch("canonical_id")}.#{field}: expected #{expected.inspect}, got #{atom[field].inspect}"
      end.compact
    end
  end

  def packet_fixed_projection(atom)
    {
      "canonical_id" => atom.fetch("canonical_id"),
      "universal_slot" => atom.fetch("universal_slot"),
      "family_qualified_transliteration" => atom.fetch("canonical_transliteration"),
      "local_compact_root" => atom.fetch("local_compact_root"),
      "formal_carrier" => atom.fetch("formal_carrier"),
      "harmonic_signature_semitones" => atom.fetch("harmonic_signature_semitones"),
      "relative_note_path_semitones" => atom.fetch("note_path_semitones")
    }
  end

  def migration_fixed_projection(atom)
    expected_generated_fields(atom).slice(
      "family", "address", "universal_slot", "harmonic_signature_semitones",
      "family_onset", "local_compact_root", "canonical_transliteration",
      "formal_carrier", "note_path_semitones"
    )
  end

  def effective_migrations
    EFFECTIVE_MIGRATIONS.map { |path| [path, load_yaml(path)] }
  end

  def effective_promotions
    effective_migrations.flat_map do |path, migration|
      migration.fetch("promoted_roots").map { |root| [path, root] }
    end
  end

  def promotion_ranges
    effective_promotions.map { |_path, root| root.fetch("canonical_id") }
                        .group_by { |id| [id.split(":").first, id.split(":").last[0]] }
                        .values
                        .map do |ids|
      sorted = ids.sort
      "#{sorted.first}–#{sorted.last.split(":").last}"
    end.sort
  end

  class CheckSet
    attr_reader :checks, :failures

    def initialize
      @checks = []
      @failures = []
    end

    def add(name, detail, condition)
      condition = !!condition
      @checks << [name, detail, condition]
      @failures << "#{name}: #{detail}" unless condition
      condition
    rescue StandardError => error
      @checks << [name, "#{detail} (#{error.class}: #{error.message})", false]
      @failures << "#{name}: #{error.class}: #{error.message}"
      false
    end

    def passed
      @checks.count { |_name, _detail, ok| ok }
    end

    def failed
      @failures.length
    end

    def success?
      @failures.empty?
    end

    def markdown(title:, pass_status:, fail_status: "FAIL", summary: [])
      output = +"# #{title}\n\n"
      output << "Status: **#{success? ? pass_status : fail_status}**\n\n"
      output << "- Checks passed: **#{passed}**\n"
      output << "- Checks failed: **#{failed}**\n"
      summary.each { |line| output << "- #{line}\n" }
      output << "\n"
      checks.each do |name, detail, ok|
        output << "## #{ok ? "PASS" : "FAIL"} — #{name}\n\n#{detail}\n\n"
      end
      unless success?
        output << "## Failures\n\n"
        failures.each { |failure| output << "- #{failure}\n" }
        output << "\n"
      end
      output
    end
  end
end
