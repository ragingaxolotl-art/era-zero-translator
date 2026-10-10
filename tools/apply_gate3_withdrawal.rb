#!/usr/bin/env ruby

require "yaml"
require "digest"
require "fileutils"
require "date"

ROOT = File.expand_path("..", __dir__)
WITHDRAWAL = "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION"
PROVISIONAL = "PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW"
CANONICAL_IDS = YAML.load_file(File.join(ROOT, "lexicon/completed_atoms.yaml"))
                    .fetch("atoms")
                    .map { |atom| atom.fetch("canonical_id") }
                    .freeze

def yaml_write(path, value)
  File.write(path, value.to_yaml(line_width: -1))
end

def canonical_digest(atoms)
  selected = atoms.select { |atom| CANONICAL_IDS.include?(atom.fetch("canonical_id")) }
  Digest::SHA256.hexdigest(Marshal.dump(selected))
end

def mark_provisional_atoms!(document)
  document.fetch("atoms").each do |atom|
    next if CANONICAL_IDS.include?(atom.fetch("canonical_id"))

    atom["status"] = "provisional_pending_detailed_semantic_review"
    atom["approval_effect"] = "#{PROVISIONAL}. Generated structural fields remain fixed; this candidate meaning may not support downstream language layers."
    atom["authority"] = {
      "semantic_status" => "provisional_pending_detailed_semantic_review",
      "gate3_approval_status" => WITHDRAWAL,
      "downstream_dependency_permitted" => false
    }
    if atom["canonization"]
      atom["canonization"]["approval_status"] = WITHDRAWAL
      atom["canonization"]["audit_history_only"] = true
      atom["canonization"]["downstream_implementation_occurred"] = false
    end
  end
end

atoms_path = File.join(ROOT, "lexicon/atoms.yaml")
atoms = YAML.load_file(atoms_path)
canonical_before = canonical_digest(atoms.fetch("atoms"))
old_atoms_metadata = Marshal.load(Marshal.dump(atoms.fetch("metadata")))
mark_provisional_atoms!(atoms)
atoms["metadata"] = {
  "title" => "Era Zero architecture 1.0 atomic-address lexicon",
  "architecture_version" => "1.0",
  "semantic_authority_status" => "mixed_36_canonical_288_provisional",
  "count" => 324,
  "families" => 12,
  "addresses_per_family" => 27,
  "canonical_semantic_roots" => 36,
  "provisional_semantic_roots" => 288,
  "fixed_generated_records" => 324,
  "source_extracted_meanings" => 36,
  "gate3_approval_status" => WITHDRAWAL,
  "downstream_dependency_permitted_for_provisional_meanings" => false,
  "withdrawn_canonization_metadata" => old_atoms_metadata,
  "authority_record" => "gate3_withdrawal_record.md",
  "change_policy" => "Never change a source-canonical meaning silently. Provisional meanings require detailed review and explicit user approval."
}
yaml_write(atoms_path, atoms)
raise "source-canonical atom content changed" unless canonical_before == canonical_digest(atoms.fetch("atoms"))

all_atoms_path = File.join(ROOT, "lexicon/all_atoms.yaml")
all_atoms = YAML.load_file(all_atoms_path)
all_before = canonical_digest(all_atoms.fetch("atoms"))
mark_provisional_atoms!(all_atoms)
all_atoms["metadata"].merge!(
  "title" => "Era Zero complete 324-address lexicon — current authority",
  "total_count" => 324,
  "canonical_count" => 36,
  "provisional_count" => 288,
  "semantic_status" => "mixed_36_canonical_and_288_provisional",
  "gate3_approval_status" => WITHDRAWAL,
  "downstream_dependency_permitted_for_provisional_meanings" => false
)
yaml_write(all_atoms_path, all_atoms)
raise "source-canonical all-atoms content changed" unless all_before == canonical_digest(all_atoms.fetch("atoms"))

provisional_path = File.join(ROOT, "lexicon/provisional_atoms.yaml")
provisional = YAML.load_file(provisional_path)
provisional.fetch("atoms").each do |atom|
  atom["status"] = "provisional_pending_detailed_semantic_review"
  atom["approval_effect"] = "#{PROVISIONAL}. Generated structural fields remain fixed; the semantic title and definition are candidates only."
  atom["authority"] = {
    "semantic_status" => "provisional_pending_detailed_semantic_review",
    "gate3_approval_status" => WITHDRAWAL,
    "downstream_dependency_permitted" => false
  }
end
provisional["metadata"].merge!(
  "title" => "Era Zero 288 generated addresses — provisional semantic candidates",
  "status" => "provisional_pending_detailed_semantic_review",
  "count" => 288,
  "canonical_baseline_count" => 36,
  "gate3_approval_status" => WITHDRAWAL,
  "approval_policy" => "Review from first principles by nine-root chunk. No candidate meaning is canonical until explicitly approved after detailed semantic review."
)
yaml_write(provisional_path, provisional)

authority_machine = {
  "metadata" => {
    "title" => "Era Zero semantic authority status",
    "effective_date" => Date.today.iso8601,
    "user_direction" => WITHDRAWAL
  },
  "architecture" => {
    "version" => "1.0",
    "status" => "fixed"
  },
  "semantic_inventory" => {
    "total_generated_addresses" => 324,
    "canonical_roots" => 36,
    "provisional_roots" => 288,
    "missing_generated_addresses" => 0,
    "canonical_ranges" => ["LIF:000–222", "MOV:000–022"],
    "provisional_ranges" => [
      "MOV:100–222", "MAT:000–222", "MIN:000–222", "CON:000–222",
      "STR:000–222", "WRN:000–222", "REP:000–222", "LOG:000–222",
      "DAT:000–222", "CRE:000–222", "ORI:000–222"
    ]
  },
  "fixed_for_all_324_addresses" => [
    "family", "address", "universal_slot", "harmonic_signature",
    "family_onset", "local_compact_root", "formal_carrier", "relative_note_path"
  ],
  "provisional_for_288_addresses" => ["semantic_title", "invariant_definition", "translation_candidates"],
  "prohibited_dependencies" => [
    "compounds", "English concept index", "etymology layer", "semantic IR",
    "grammar implementation", "renderer", "translator"
  ],
  "active_review_packet" => {
    "range" => "MOV:100–122",
    "status" => "detailed_review_complete_pending_user_decision",
    "canonicalized" => false
  },
  "stop_boundary" => {
    "do_not_begin" => ["MOV:200–222", "Gate 4", "compound architecture"]
  }
}
yaml_write(File.join(ROOT, "lexicon/semantic_authority.yaml"), authority_machine)

version_path = File.join(ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version.replace(
  "language" => "Era Zero DBA",
  "architecture_version" => "1.0",
  "architecture_status" => "fixed",
  "semantic_authority_status" => "36_canonical_288_provisional",
  "canonical_semantic_roots" => 36,
  "provisional_semantic_roots" => 288,
  "canonical_specification" => "spec/canonical_spec.yaml",
  "current_authority_ledger" => "lexicon/semantic_authority.yaml",
  "atomic_lexicon" => "lexicon/atoms.yaml",
  "gate3_approval_status" => WITHDRAWAL,
  "withdrawn_standard_record" => "spec/era_zero_core_standard_1.0.0.yaml",
  "active_review_packet" => "MOV:100–122",
  "next_gate_authorized" => false
)
yaml_write(version_path, version)

standard_path = File.join(ROOT, "spec/era_zero_core_standard_1.0.0.yaml")
standard = YAML.load_file(standard_path)
standard["metadata"].merge!(
  "title" => "Era Zero Core Architecture 1.0 with withdrawn Gate 3 semantic promotion",
  "architecture_version" => "1.0",
  "status" => "architecture_fixed_gate3_semantic_promotion_withdrawn",
  "approval_scope" => "Architecture and 36 source-developed roots only",
  "gate3_approval_status" => WITHDRAWAL,
  "audit_history_preserved" => true
)
standard["authority"] = {
  "source_canonical_roots" => "LIF:000–222 and MOV:000–022 retain their approved source meanings.",
  "generated_addresses" => "All 324 addresses retain their accepted algorithmic forms.",
  "phase2_semantics" => "#{PROVISIONAL}.",
  "gate3_record" => "The earlier promotion record is retained solely as withdrawn audit history.",
  "downstream_dependency_policy" => "No compound, index, etymology, IR, grammar implementation, renderer, or translator may depend on the 288 provisional meanings.",
  "change_control" => "The 36 source-canonical meanings may not be modified silently."
}
standard["inventory"].merge!(
  "atomic_roots" => 324,
  "canonical_roots" => 36,
  "provisional_roots" => 288,
  "missing_roots" => 0,
  "canonical_chunks" => 4,
  "provisional_review_chunks" => 32
)
if standard["resolved_decisions"] && standard["resolved_decisions"]["ORI:002"]
  standard["resolved_decisions"]["ORI:002"] = {
    "generated_form" => "nu·nan",
    "generated_form_status" => "fixed",
    "semantic_candidate" => "latent first condition",
    "semantic_status" => "provisional_pending_detailed_semantic_review"
  }
end
if standard["resolved_decisions"] && standard["resolved_decisions"]["num_as_atomic_alias"]
  standard["resolved_decisions"]["num_as_atomic_alias"] = {
    "status" => "unresolved_for_atomic_semantics",
    "fixed_fact" => "num remains the runtime-state 2 name",
    "note" => "No provisional ORI meaning may settle an atomic alias or etymology decision."
  }
end
standard["deferred_post_core_layers"] = [
  "MOV:200–222 and all later semantic review packets",
  "compound dictionary and English concept coverage",
  "conventional contraction and etymology table",
  "formal semantic IR and executable grammar schema",
  "negation finalization",
  "quantitative rhythm, harmony, and dynamics mappings",
  "long-address namespace allocation",
  "visual glyph geometry",
  "deterministic renderer and decoder",
  "controlled and general English interfaces",
  "MIDI, SVG, and audio output"
]
standard["canonical_review_chunks"]&.each do |chunk|
  chunk["status"] = "provisional_pending_detailed_semantic_review"
  chunk["gate3_approval_status"] = WITHDRAWAL
end
yaml_write(standard_path, standard)

migration_path = File.join(ROOT, "migrations/1.0.0-canonization.yaml")
migration = YAML.load_file(migration_path)
migration["approval_status"] = WITHDRAWAL
migration["effective_as_semantic_authority"] = false
migration["audit_history_only"] = true
migration["downstream_implementation_occurred"] = false
migration["withdrawal"] = {
  "authority" => "direct user correction",
  "effect" => "All 288 promoted semantic titles and definitions revert to provisional status; fixed generated fields are unchanged.",
  "canonical_roots_after_withdrawal" => 36,
  "provisional_roots_after_withdrawal" => 288,
  "record" => "gate3_withdrawal_record.md"
}
yaml_write(migration_path, migration)

unresolved_path = File.join(ROOT, "extraction/unresolved_issues_core_1.0.0.yaml")
unresolved = YAML.load_file(unresolved_path)
unresolved["metadata"].merge!(
  "snapshot" => "Withdrawn Gate 3 audit snapshot with current authority overlay",
  "gate3_approval_status" => WITHDRAWAL
)
unresolved.fetch("issues").each do |issue|
  case issue["issue_id"]
  when "EZ-UNRES-0001"
    issue["resolution"] = "The generated atomic form nu·nan and runtime-state name num remain fixed structural facts. ORI:002's semantic title/definition and any atomic alias or etymology decision are provisional and unresolved."
    issue["status"] = "reopened_by_gate3_withdrawal"
  when "EZ-UNRES-0003"
    issue["resolution"] = "Remain open. Gate 4 is not authorized, and no compound may depend on provisional CRE or DAT meanings."
    issue["status"] = "open_gate4_not_authorized"
  end
end
yaml_write(unresolved_path, unresolved)

semantic_status_md = <<~MD
  # Era Zero Semantic Authority Status

  Effective authority: **#{WITHDRAWAL}**

  ## Current fixed authority

  - Era Zero Core Architecture **1.0** remains fixed.
  - The **36 source-developed roots** remain canonical: `LIF:000–222` and `MOV:000–022`.
  - The 36 source-canonical titles and definitions are unchanged.
  - All 324 three-trit addresses retain their deterministic family, address, universal slot, harmonic signature, family onset, local compact root, formal carrier, and relative note path.

  ## Current provisional authority

  The remaining **288 semantic titles and definitions** are **#{PROVISIONAL}**. The former Gate 3 promotion is not a basis for downstream implementation.

  No compound dictionary, English concept index, etymology layer, semantic IR, grammar implementation, renderer, or translator may depend on those provisional meanings.

  ## Active review and stop boundary

  - Active packet: `MOV:100–122`.
  - Packet status: proposed detailed review, not canonical.
  - Not authorized: `MOV:200–222`, Gate 4, or compound architecture.

  Machine-readable authority: `lexicon/semantic_authority.yaml`.
  Withdrawal history: `gate3_withdrawal_record.md`.
MD
File.write(File.join(ROOT, "semantic_authority_status.md"), semantic_status_md)

withdrawal_md = <<~MD
  # Gate 3 Withdrawal Record

  ## Approval status

  **#{WITHDRAWAL}**

  ## Authority and effect

  This direct user correction supersedes the earlier Gate 3 canonization decision before any downstream implementation was authorized.

  - The earlier canonization record, semantic audit, validation report, and 32 canonized chunk files are preserved as audit history.
  - Their semantic promotion result is no longer effective authority.
  - `LIF:000–222` and `MOV:000–022` remain the only canonical atomic meanings: **36 roots**.
  - The other **288 generated addresses** retain their fixed algorithmic forms.
  - Their titles and definitions revert to **#{PROVISIONAL}**.
  - No downstream compound, index, etymology, IR, grammar implementation, renderer, or translator may use those provisional meanings as settled inputs.

  ## Preserved audit artifacts

  - `migrations/1.0.0-canonization.yaml`
  - `reports/core_1.0.0_semantic_audit.md`
  - `reports/core_1.0.0_validation.md`
  - `reports/core_1.0.0_chunks/`
  - the `CORE STANDARD 1.0.0 CANONIZATION RECORD` section in the main Google Doc

  Each preserved artifact must be read together with this withdrawal record. None is a current approval record.

  ## Downstream implementation statement

  The withdrawal occurred before downstream implementation. Gate 4 and the compound architecture were not begun under the withdrawn semantic promotion.
MD
File.write(File.join(ROOT, "gate3_withdrawal_record.md"), withdrawal_md)

{
  "reports/core_1.0.0_semantic_audit.md" => "# WITHDRAWAL NOTICE\n\n**#{WITHDRAWAL}**\n\nThis report is preserved as audit history. Its promotion decision is not current semantic authority; the 288 Phase 2 meanings are provisional pending detailed review.\n\n",
  "reports/core_1.0.0_validation.md" => "# AUTHORITY NOTICE\n\n**#{WITHDRAWAL}**\n\nThe algorithm assertions below remain historical structural evidence. Claims that 324 meanings are canonical are withdrawn; current authority is 36 canonical meanings and 288 provisional meanings.\n\n"
}.each do |relative, notice|
  path = File.join(ROOT, relative)
  content = File.read(path)
  File.write(path, notice + content) unless content.start_with?(notice.lines.first.strip)
end

puts "Authority withdrawal applied."
puts "Canonical semantic roots: 36"
puts "Provisional semantic roots: 288"
puts "Source-canonical digest: #{canonical_before}"
