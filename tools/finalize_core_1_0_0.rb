#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)
VERSION = "1.0.0"

TITLE_CLARIFICATIONS = {
  "CON:111" => "active transmission",
  "STR:101" => "active self-organization",
  "STR:111" => "active construction",
  "WRN:111" => "active warning or isolation",
  "REP:101" => "active self-repair",
  "REP:111" => "active target repair",
  "LOG:101" => "active computation",
  "DAT:101" => "active local decoding",
  "DAT:111" => "active data transfer",
  "CRE:101" => "active ideation",
  "CRE:111" => "active artifact creation",
  "ORI:101" => "active becoming",
  "ORI:111" => "active manifestation"
}.freeze

WATCHLIST = [
  {
    "roots" => %w[REP:010 REP:111],
    "risk" => "repaired target could be confused with the act of repairing a target",
    "resolution" => "REP:010 is the restored target condition; REP:111 is the active outward repair process. REP:111 received a clarifying title."
  },
  {
    "roots" => %w[MIN:001 MIN:201],
    "risk" => "present attention could be confused with the capacity for focus",
    "resolution" => "MIN:001 is a presently occurring mental condition; MIN:201 is the active availability of a mental capacity."
  },
  {
    "roots" => %w[MIN:202 CRE:202],
    "risk" => "latent aptitude and untapped creativity are both dormant inward capacities",
    "resolution" => "MIN:202 is capacity to learn or understand; CRE:202 is capacity to originate or transform forms."
  },
  {
    "roots" => %w[MAT:200 STR:200],
    "risk" => "material integrity and structural load capacity overlap",
    "resolution" => "MAT:200 concerns the physical substrate's resistance to disruption; STR:200 concerns an organized framework's ability to bear, contain, or order."
  },
  {
    "roots" => %w[CON:020 DAT:020],
    "risk" => "a communication network could be confused with an information collection",
    "resolution" => "CON:020 is the channel/community topology; DAT:020 is the bounded collection of records carried or stored through such systems."
  },
  {
    "roots" => %w[DAT:002 DAT:022],
    "risk" => "a dormant record could be confused with an archive",
    "resolution" => "DAT:002 is one inward/local dormant information object; DAT:022 is a collective or systemic body of preserved information."
  },
  {
    "roots" => %w[CRE:020 CRE:220],
    "risk" => "design system and design space sound interchangeable",
    "resolution" => "CRE:020 is a stable created collection of templates or rules; CRE:220 is the relation-space connecting forms, constraints, and transformations."
  },
  {
    "roots" => %w[STR:222 ORI:222],
    "risk" => "possible architecture could be confused with a possible world",
    "resolution" => "STR:222 is an unrealized organized arrangement inside a reality; ORI:222 is an unrealized coherent reality-and-law system."
  },
  {
    "roots" => %w[WRN:222 ORI:222],
    "risk" => "catastrophe possibility could be treated as any possible world",
    "resolution" => "WRN:222 is specifically an unrealized system failure; ORI:222 is ontological possibility without an inherent danger meaning."
  },
  {
    "roots" => %w[MIN:222 LOG:222],
    "risk" => "hypothesis space could be confused with formal possibility space",
    "resolution" => "MIN:222 contains possible understandings in minds; LOG:222 contains formally valid proofs, programs, or solutions under rules."
  }
].freeze

def write_yaml(path, object)
  File.write(path, YAML.dump(object), encoding: "UTF-8")
end

def canonical_chunk_definitions
  chunks = []
  number = 0
  {
    "MOV" => %w[1 2],
    "MAT" => %w[0 1 2],
    "MIN" => %w[0 1 2],
    "CON" => %w[0 1 2],
    "STR" => %w[0 1 2],
    "WRN" => %w[0 1 2],
    "REP" => %w[0 1 2],
    "LOG" => %w[0 1 2],
    "DAT" => %w[0 1 2],
    "CRE" => %w[0 1 2],
    "ORI" => %w[0 1 2]
  }.each do |family, layers|
    layers.each do |layer|
      number += 1
      addresses = %w[00 01 02 10 11 12 20 21 22].map { |tail| "#{layer}#{tail}" }
      chunks << {
        "number" => number,
        "family" => family,
        "layer" => layer,
        "range" => "#{family}:#{layer}00–#{layer}22",
        "ids" => addresses.map { |address| "#{family}:#{address}" },
        "status" => "canonical"
      }
    end
  end
  chunks
end

completed = YAML.load_file(File.join(ROOT, "lexicon/completed_atoms.yaml")).fetch("atoms")
provisional_document = YAML.load_file(File.join(ROOT, "lexicon/provisional_atoms.yaml"))
provisional = provisional_document.fetch("atoms")
provisional_by_id = provisional.each_with_object({}) { |atom, index| index[atom.fetch("canonical_id")] = atom }

promoted = provisional.map do |source_atom|
  atom = Marshal.load(Marshal.dump(source_atom))
  id = atom.fetch("canonical_id")
  atom["title"] = TITLE_CLARIFICATIONS.fetch(id, atom.fetch("title"))
  atom["status"] = "canonical"
  atom["canonical_version"] = VERSION
  atom["approval_effect"] = "Canonical in Era Zero Core Standard #{VERSION}. Any later semantic change requires a versioned migration record."
  atom["semantic_origin"] = "Model-authored Phase 2 completion requested by the user, audited against the accepted family/address system, and explicitly authorized for canonization."

  sibling_notes = atom.fetch("neighbor_contrasts").map do |sibling_id|
    sibling = provisional_by_id.fetch(sibling_id)
    sibling_title = TITLE_CLARIFICATIONS.fetch(sibling_id, sibling.fetch("title"))
    "#{sibling_id} (#{sibling_title}) occupies #{sibling.fetch('universal_slot')}; do not merge it with #{id}."
  end
  atom["distinctions_and_exclusions"] = [
    "Keep this root inside the #{atom.fetch('family')} domain: #{atom.fetch('family_domain')}.",
    "The third address trit is lexical and permanent; it is not the runtime-state ending.",
    "A following runtime state [0], [1], or [2]/num changes current assertion status without changing this root's address.",
    *sibling_notes
  ]
  atom["neighbor_contrast_notes"] = sibling_notes
  atom["canonization"] = {
    "standard" => "Era Zero Core Standard #{VERSION}",
    "approval_basis" => "The user directly instructed Codex to perform the recommended audit-and-freeze step after reviewing the next-stage plan.",
    "meaning_change_from_phase2_proposal" => false,
    "title_clarified" => TITLE_CLARIFICATIONS.key?(id),
    "source_proposal_file" => "lexicon/provisional_atoms.yaml"
  }
  atom
end

atoms = completed + promoted
atoms.sort_by! do |atom|
  family_order = %w[LIF MOV MAT MIN CON STR WRN REP LOG DAT CRE ORI]
  [family_order.index(atom.fetch("family")), atom.fetch("address")]
end

write_yaml(
  File.join(ROOT, "lexicon/atoms.yaml"),
  {
    "metadata" => {
      "title" => "Era Zero Core Standard #{VERSION} canonical atomic lexicon",
      "version" => VERSION,
      "status" => "canonical",
      "count" => atoms.length,
      "families" => 12,
      "addresses_per_family" => 27,
      "source_extracted_meanings" => completed.length,
      "audited_and_user_approved_meanings" => promoted.length,
      "supersedes_for_runtime_use" => [
        "lexicon/completed_atoms.yaml",
        "lexicon/all_atoms.yaml",
        "lexicon/provisional_atoms.yaml"
      ],
      "change_policy" => "Never change a canonical address silently; use a versioned migration."
    },
    "atoms" => atoms
  }
)

chunks = canonical_chunk_definitions
write_yaml(
  File.join(ROOT, "spec/era_zero_core_standard_1.0.0.yaml"),
  {
    "metadata" => {
      "title" => "Era Zero Core Standard #{VERSION}",
      "version" => VERSION,
      "status" => "canonical",
      "framework_source" => "spec/canonical_spec.yaml",
      "atomic_lexicon" => "lexicon/atoms.yaml",
      "approval_scope" => "All 324 three-trit atomic roots"
    },
    "authority" => {
      "source_extracted_roots" => "LIF:000–222 and MOV:000–022 retain their approved source meanings.",
      "completed_roots" => "The remaining 288 meanings were audited and canonized under the user's direct instruction.",
      "encoding_algorithms" => "The accepted family, address, compact-root, carrier, note-path, contour, register, timing, and runtime-state rules remain unchanged.",
      "change_control" => "Canonical meanings require a versioned migration record for any later change."
    },
    "inventory" => {
      "families" => 12,
      "addresses_per_family" => 27,
      "atomic_roots" => 324,
      "canonical_roots" => 324,
      "provisional_roots" => 0,
      "missing_roots" => 0,
      "canonical_chunks" => 36
    },
    "resolved_decisions" => {
      "ORI:002" => {
        "canonical_form" => "nu·nan",
        "canonical_meaning" => "latent first condition",
        "decision" => "The latest compact-root algorithm controls the atomic form."
      },
      "runtime_state_2" => {
        "canonical_name" => "num",
        "role" => "runtime-state ending",
        "distinct_from" => "ORI:002"
      },
      "num_as_atomic_alias" => {
        "status" => "not_canonical_in_1.0.0",
        "note" => "Any historical contraction use belongs in the later etymology layer."
      }
    },
    "deferred_post_core_layers" => [
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
    ],
    "canonical_review_chunks" => chunks
  }
)

write_yaml(
  File.join(ROOT, "spec/version.yaml"),
  {
    "language" => "Era Zero DBA",
    "current_core_standard" => VERSION,
    "status" => "canonical",
    "canonical_specification" => "spec/era_zero_core_standard_1.0.0.yaml",
    "canonical_atomic_lexicon" => "lexicon/atoms.yaml",
    "previous_phase" => "Phase 2 provisional 288-root completion"
  }
)

FileUtils.mkdir_p(File.join(ROOT, "migrations"))
write_yaml(
  File.join(ROOT, "migrations/1.0.0-canonization.yaml"),
  {
    "migration_id" => "EZ-MIG-1.0.0-CANONIZATION",
    "from" => "Phase 2 provisional lexicon",
    "to" => "Era Zero Core Standard #{VERSION}",
    "authorization" => "Direct user instruction to perform the recommended audit-and-freeze step.",
    "promoted_records" => promoted.map { |atom| atom.fetch("canonical_id") },
    "semantic_definition_changes" => [],
    "title_clarifications" => TITLE_CLARIFICATIONS.map do |id, title|
      {
        "canonical_id" => id,
        "from" => provisional_by_id.fetch(id).fetch("title"),
        "to" => title,
        "reason" => "Make the address-slot distinction explicit without changing the approved core meaning."
      }
    end,
    "resolved_decisions" => [
      "ORI:002 is nu·nan, latent first condition.",
      "num is the runtime-state 2 name and is not an alternative canonical ORI:002 form."
    ],
    "preserved_history" => [
      "lexicon/provisional_atoms.yaml",
      "lexicon/all_atoms.yaml",
      "reports/phase2_chunk_review.md",
      "reports/phase2_chunks/"
    ]
  }
)

phase1_issues = YAML.load_file(File.join(ROOT, "extraction/unresolved_issues.yaml"))
core_issues = Marshal.load(Marshal.dump(phase1_issues))
core_issues["metadata"]["snapshot"] = "Era Zero Core Standard #{VERSION}"
core_issues.fetch("issues").each do |issue|
  case issue.fetch("issue_id")
  when "EZ-UNRES-0001"
    issue["status"] = "resolved_in_core_1.0.0"
    issue["resolution"] = "ORI:002 is canonically nu·nan, latent first condition. num is canonically the separate runtime-state 2 name. Historical contraction use is deferred to etymology."
  when "EZ-UNRES-0003"
    issue["resolution"] = "Remain open for Gate 4. With the canonical atom meanings, the original LIF:010 + CRE:020 + DAT:210 decomposition is not literal enough. Revalidate the candidate using LIF:010 + CRE:010 + DAT:210 or a fuller semantic graph."
  when "EZ-UNRES-0009"
    issue["status"] = "resolved_in_core_1.0.0"
    issue["resolution"] = "MOV:000–022 remains source-canonical and is included unchanged in the 1.0.0 atomic lexicon."
  end
end
write_yaml(File.join(ROOT, "extraction/unresolved_issues_core_1.0.0.yaml"), core_issues)

FileUtils.mkdir_p(File.join(ROOT, "reports/core_1.0.0_chunks"))
chunks.each do |chunk|
  chunk_atoms = atoms.select { |atom| chunk.fetch("ids").include?(atom.fetch("canonical_id")) }
  filename = format("%02d_%s_%s00-%s22.md", chunk.fetch("number"), chunk.fetch("family"), chunk.fetch("layer"), chunk.fetch("layer"))
  lines = [
    "# Canonical Chunk #{format('%02d', chunk.fetch('number'))}: #{chunk.fetch('range')}",
    "",
    "**Status:** Canonical in Era Zero Core Standard #{VERSION}.",
    "",
    "| ID | Form | Title | Universal slot | Canonical core definition |",
    "| --- | --- | --- | --- | --- |"
  ]
  chunk_atoms.each do |atom|
    lines << "| `#{atom.fetch('canonical_id')}` | **#{atom.fetch('canonical_transliteration')}** | #{atom.fetch('title')} | #{atom.fetch('universal_slot')} | #{atom.fetch('core_definition').gsub('|', '\\|')} |"
  end
  lines << ""
  File.write(File.join(ROOT, "reports/core_1.0.0_chunks", filename), lines.join("\n"), encoding: "UTF-8")
end

audit_lines = [
  "# Era Zero Core Standard #{VERSION} Semantic Audit",
  "",
  "## Result",
  "",
  "- Roots audited: **#{atoms.length}**",
  "- Previously source-canonical roots preserved: **#{completed.length}**",
  "- Phase 2 proposals reviewed and promoted: **#{promoted.length}**",
  "- Core-definition changes during audit: **0**",
  "- Clarifying title changes: **#{TITLE_CLARIFICATIONS.length}**",
  "- Canonical roots after audit: **#{atoms.length}**",
  "- Provisional or missing roots after audit: **0**",
  "",
  "The audit found no semantic collision requiring an address reassignment or core-definition change. Clarifying titles were applied where a short label could blur the entity/process or current-state/capacity distinction.",
  "",
  "## Audit criteria",
  "",
  "- family-domain fit",
  "- first-trit concept-type fit",
  "- second-trit orientation fit",
  "- third-trit lexical-state fit",
  "- stable/active/potential triad coherence",
  "- inward/outward/systemic parallelism",
  "- within-family synonym separation",
  "- cross-family boundary clarity",
  "- atomicity and compound usefulness",
  "- separation of lexical third trit from runtime state",
  "- generation of compact root, carrier, transliteration, and note path",
  "",
  "## Clarifying title changes",
  ""
]
TITLE_CLARIFICATIONS.each do |id, title|
  audit_lines << "- `#{id}`: **#{provisional_by_id.fetch(id).fetch('title')}** → **#{title}**"
end
audit_lines += ["", "All affected core definitions are unchanged.", "", "## Collision watchlist and disposition", ""]
WATCHLIST.each do |item|
  audit_lines << "### #{item.fetch('roots').join(' / ')}"
  audit_lines << ""
  audit_lines << "**Risk:** #{item.fetch('risk')}."
  audit_lines << ""
  audit_lines << "**Disposition:** #{item.fetch('resolution')}"
  audit_lines << ""
end
audit_lines += [
  "## ORI / num decision",
  "",
  "- `ORI:002` is canonically **nu·nan**, “latent first condition.”",
  "- Runtime state 2 is canonically named **num**.",
  "- `num` is not an alternative canonical atomic form for `ORI:002` in version #{VERSION}.",
  "- Possible historical contraction use remains a later etymology question.",
  "",
  "## Cyber-pet compound consequence",
  "",
  "The source's provisional `LIF:010 + CRE:020 + DAT:210` compound is not promoted automatically. Under the completed lexicon, `CRE:020` means “design system,” not an individual created artifact. Gate 4 should compare `LIF:010 + CRE:010 + DAT:210` with a fuller semantic graph before approving a canonical cyber-pet compound.",
  "",
  "## Canonization decision",
  "",
  "The user's direct instruction to perform the recommended audit-and-freeze step authorizes promotion of the audited 288 meanings. All 324 atomic roots are canonical in Era Zero Core Standard #{VERSION}. Later changes require a versioned migration."
]
File.write(File.join(ROOT, "reports/core_1.0.0_semantic_audit.md"), audit_lines.join("\n"), encoding: "UTF-8")

puts "Finalized Era Zero Core Standard #{VERSION}: #{atoms.length} canonical roots, #{TITLE_CLARIFICATIONS.length} title clarifications."
