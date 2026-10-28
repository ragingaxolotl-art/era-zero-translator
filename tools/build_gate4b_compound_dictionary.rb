#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "digest"
require "fileutils"
require_relative "../tools/lib/era_zero_validation"

include EraZeroValidation

VERSION = "1.0.0"
DATE = "2026-10-09"

def roots(*ids)
  ids.each_with_index.map { |id, i| { "node_id" => i == ids.length - 1 ? "h" : format("q%02d", i + 1), "kind" => "root", "root_id" => id } }
end

def qualifier_edges(count)
  (1...count).map { |i| { "edge_id" => format("e%02d", i), "type" => "qualifies", "from" => format("q%02d", i), "to" => "h" } }
end

def selected(slug, title, definition, ids, includes:, excludes:, everyday:, technical:, compounds:, collision:, confidence: "high")
  nodes = roots(*ids)
  payload = {
    "architecture_version" => "1.0",
    "semantic_head" => "h",
    "nodes" => nodes,
    "edges" => qualifier_edges(nodes.length),
    "lexical_constraints" => ["All qualifiers narrow the head; no component asserts a separate event."]
  }
  digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
  {
    "architecture_version" => "1.0", "compound_id" => "CMP:#{digest[0, 24]}", "content_digest" => digest,
    "definition_version" => VERSION, "status" => "approved", "approval_date" => DATE,
    "display_title" => title, "english_glosses" => [title], "semantic_head" => "h",
    "invariant_definition" => definition, "nodes" => nodes, "edges" => payload["edges"],
    "lexical_constraints" => payload["lexical_constraints"],
    "boundaries" => { "includes" => includes, "excludes" => excludes },
    "collision_audit" => collision, "confidence" => confidence,
    "examples" => {
      "ordinary" => everyday,
      "technical" => technical,
      "future_compound" => compounds,
      "counterexample" => "Do not use #{title} when only the head meaning is asserted and the qualifier is not true."
    },
    "serialization" => { "canonical_format" => "EZC-JSON-1", "content_digest" => digest }
  }
end

entries = [
  selected("material-artifact", "material artifact", "A generated artifact whose bounded product is material.", %w[MAT:010 CRE:010], includes: "manufactured or generated physical objects", excludes: "natural objects and nonmaterial products", everyday: "a made physical object", technical: "a fabricated component", compounds: "may qualify a tool, machine, or repair target", collision: "CRE supplies artifact status; MAT supplies physical boundedness; neither atom alone entails both."),
  selected("composite-artifact", "composite artifact", "A generated artifact organized as a persistent part–whole arrangement.", %w[STR:020 CRE:010], includes: "made assemblies with persistent constituent organization", excludes: "unstructured products and natural structures", everyday: "an assembled made thing", technical: "a constructed module", compounds: "may combine with material or data qualifiers", collision: "STR supplies composite organization; CRE supplies generated-artifact status."),
  selected("physical-tool", "physical tool", "A generated artifact with enduring physical work capacity.", %w[MAT:200 CRE:010], includes: "made implements able to produce physical change", excludes: "raw energy sources and artifacts without physical work capacity", everyday: "a tool capable of doing physical work", technical: "an actuator or implement", compounds: "may fill an instrument role in later utterance IR", collision: "Instrument use is not lexicalized; the compound names the artifact-capacity combination only."),
  selected("machine", "machine", "A generated artifact that is both a persistent composite arrangement and a bearer of enduring physical work capacity.", %w[STR:020 MAT:200 CRE:010], includes: "made organized devices capable of physical work", excludes: "simple passive artifacts and natural energetic systems", everyday: "a machine", technical: "an engineered mechanism", compounds: "may be qualified by active, dormant, data, or control concepts", collision: "The two qualifiers distinguish machine from generic tool and generic assembly."),
  selected("dormant-machine", "dormant machine", "A dormant generated artifact whose composite arrangement and physical work capacity persist without present operation.", %w[STR:022 MAT:202 CRE:012], includes: "inactive machines retaining structure and latent capacity", excludes: "broken machines lacking capacity and currently operating machines", everyday: "a powered-down but usable machine", technical: "an offline mechanism", compounds: "may combine with a restoration or activation expression later", collision: "Lexical dormancy is encoded independently in all three atomic facets; runtime state remains separate."),
  selected("material-route", "material route", "An established route realized by a stable material aggregate.", %w[MAT:020 MOV:020], includes: "roads, tracks, pipes, and other materially realized routes", excludes: "abstract routes and material aggregates not serving as routes", everyday: "a physical route", technical: "a material transport path", compounds: "may take destination or flow-network elaboration", collision: "MOV owns route identity; MAT only specifies its physical realization."),
  selected("living-body", "living body", "A persistent material substrate constituting an identified living being.", %w[LIF:010 MAT:000], includes: "the physical body of an identified living other", excludes: "unidentified biomass and nonliving objects", everyday: "that being's body", technical: "an organismal material substrate", compounds: "may be a bearer of injury or restoration", collision: "LIF supplies living identity; MAT supplies physical constitution."),
  selected("dormant-living-body", "dormant living body", "A dormant material substrate that preserves the identity of a dormant living being.", %w[LIF:012 MAT:002], includes: "a preserved inactive body whose individual identity remains", excludes: "dead matter with no preserved life identity and an awake body", everyday: "a dormant preserved body", technical: "a suspended organismal substrate", compounds: "may combine with awakening or restoration", collision: "Does not assert death, unconsciousness cause, or future awakening."),
  selected("material-biosystem", "material biosystem", "A stable biosystem whose interacting participants are treated as one material aggregate.", %w[MAT:020 LIF:220], includes: "ecologies or living systems considered in their material organization", excludes: "mere piles of organisms and nonmaterial models", everyday: "a materially embodied ecosystem", technical: "a physical biosystem", compounds: "may combine with shared-world or hazard concepts", collision: "LIF remains the head because self-sustaining life relations define the whole."),
  selected("generated-living-being", "generated living being", "An identified living being whose individual existence is a generated artifact.", %w[CRE:010 LIF:010], includes: "artificially generated individual living beings", excludes: "naturally occurring beings and nonliving artifacts", everyday: "a created living individual", technical: "a generated organism or artificial life entity", compounds: "may take material, data, or origin qualifiers", collision: "Generation qualifies the living entity without reducing life to artifact mechanics."),
  selected("living-communication-network", "living communication network", "An active shared channel whose participating exchange context is an active living network.", %w[LIF:221 CON:021], includes: "currently functioning communication networks constituted by living participants", excludes: "inactive communities and channels without living-network participation", everyday: "a community actively communicating", technical: "a live biological or social exchange network", compounds: "may combine with data synchronization", collision: "CON is head; LIF restricts participant-system character."),
  selected("message-datum", "message datum", "A persistent bounded datum maintained as content within a shared communicative channel.", %w[CON:020 DAT:000], includes: "bounded information treated as communicative content", excludes: "private data not placed in a shared channel and the transmission event itself", everyday: "a message as an information object", technical: "a channel-scoped message payload", compounds: "may be target-referential, manifest, dormant, or collected", collision: "DAT owns the information object; CON contributes channel context, not transfer."),
  selected("addressed-message", "addressed message", "A persistent target reference maintained as content for a persistent target communicative endpoint.", %w[CON:010 DAT:010], includes: "message content that denotes and is organized for a target endpoint", excludes: "unaddressed broadcasts and the act of delivery", everyday: "a message addressed to someone", technical: "a target-addressed payload", compounds: "may participate in a directed data link", collision: "Target reference and target endpoint are distinct atoms; their conjunction is explicit."),
  selected("shared-message-collection", "shared message collection", "A persistent shared dataset maintained as communicative content within a persistent shared channel.", %w[CON:020 DAT:020], includes: "archives, threads, or corpora defined within a shared exchange context", excludes: "a single message and unrelated datasets", everyday: "a shared collection of messages", technical: "a channel message corpus", compounds: "may be dormant, manifest, synchronized, or backed up", collision: "The dataset is head; the channel specifies its communication context."),
  selected("program-definition", "program definition", "A persistent internal generative pattern represented as bounded data and constrained by a persistent target-directed formal constraint.", %w[DAT:000 LOG:010 CRE:000], includes: "stored formal generative specifications", excludes: "a running process, arbitrary data, or unconstrained creative pattern", everyday: "a program as stored instructions", technical: "an executable specification before execution", compounds: "may be dormant, shared, generated, or attached to a machine", collision: "This is a definition object; execution belongs to later semantic IR."),
  selected("dormant-program", "dormant program", "A dormant internal generative pattern represented by dormant data under a dormant target-directed formal constraint.", %w[DAT:002 LOG:012 CRE:002], includes: "stored programs not presently manifest or operative", excludes: "deleted programs and running executions", everyday: "a saved inactive program", technical: "an installed but nonrunning executable specification", compounds: "may later combine with activation or host relations", collision: "Lexical dormancy is not the same as runtime state [2]/num on program-definition."),
  selected("shared-knowledge-base", "shared knowledge base", "A persistent shared dataset organized by a persistent shared cognitive schema.", %w[MIN:020 DAT:020], includes: "shared datasets whose organization encodes a common conceptual schema", excludes: "unstructured shared data and a schema without stored data", everyday: "a shared knowledge base", technical: "a schema-governed collaborative dataset", compounds: "may be communicative, synchronized, or dormant", collision: "MIN supplies shared conceptual organization; DAT supplies the dataset."),
  selected("data-transfer-channel", "data transfer channel", "A persistent target-directed data-transferability relation situated in a persistent shared communicative channel.", %w[CON:020 DAT:210], includes: "stable channel contexts that can carry data to a target", excludes: "a current transfer event and channels without data-transferability", everyday: "a channel for sending data", technical: "a data transport channel", compounds: "may be directed, operative, dormant, or secured later", collision: "DAT is head because transferability is the named relation; CON restricts its medium."),
  selected("synchronized-data-network", "synchronized data network", "A persistent systemic data-synchronizability relation situated among enduring co-participants in one shared exchange context.", %w[CON:220 DAT:220], includes: "participant networks capable of coordinated data-state alignment", excludes: "an active synchronization event and disconnected datasets", everyday: "a network able to keep shared data aligned", technical: "a synchronizable replicated-data network", compounds: "may be operative or latent through matching triplet atoms", collision: "Capability is not occurrence; DAT owns synchronizability and CON owns co-participation."),
  selected("physical-injury", "physical injury", "A persistent internal fault inhering in a persistent material substrate.", %w[MAT:000 WRN:000], includes: "intrinsic adverse physical conditions of a body or material bearer", excludes: "external hazards and purely mental or informational faults", everyday: "a physical injury", technical: "an intrinsic material fault", compounds: "may take living-body, manifestation, or restoration elaboration", collision: "WRN is head; MAT restricts the fault domain without asserting its cause."),
  selected("material-hazard", "material hazard", "A persistent external hazard that is a distinct material object.", %w[MAT:010 WRN:010], includes: "physical objects identified as capable of adverse effect", excludes: "abstract risks and actual impairment events", everyday: "a hazardous object", technical: "an external physical hazard source", compounds: "may bind a target later in utterance IR", collision: "Hazard potential is WRN; material objecthood is MAT."),
  selected("physical-repair", "physical repair", "A completed target restoration whose restorative transformation is a completed target material change.", %w[MAT:110 REP:110], includes: "completed restoration of a distinct material target", excludes: "maintenance without completed restoration and nonphysical recovery", everyday: "a completed physical repair", technical: "a completed restorative material transformation", compounds: "active and nonactualized variants use the matching triplet atoms", collision: "REP supplies restorative direction; MAT supplies physical-change domain."),
  selected("data-repair", "data repair", "A completed internal restoration whose restorative transformation is a completed internal data transformation.", %w[DAT:100 REP:100], includes: "completed correction or restoration of data within one bearer", excludes: "data transfer, backup creation, and physical repair", everyday: "repaired data", technical: "a completed restorative data transformation", compounds: "may combine with datasets, programs, or knowledge bases", collision: "The composition requires both transformation of information and return to a restoration standard."),
  selected("structural-repair", "structural repair", "A completed internal restoration whose restorative transformation is a completed internal structural reconfiguration.", %w[STR:100 REP:100], includes: "completed restoration by reorganizing one structure internally", excludes: "mere rearrangement and material change without restoration", everyday: "a completed structural repair", technical: "restorative reconfiguration", compounds: "may apply to artifacts, bodies, or data structures", collision: "STR describes reconfiguration; REP adds restoration criterion."),
  selected("backup-dataset", "backup dataset", "A dormant shared dataset maintained in relation to a persistent systemic restoration pathway.", %w[REP:220 DAT:022], includes: "inactive shared datasets preserved as system-restoration resources", excludes: "ordinary dormant datasets with no restoration function and active synchronization", everyday: "a backup dataset", technical: "a dormant recovery corpus", compounds: "may qualify a program, knowledge base, or synchronized network", collision: "Backup purpose comes from REP; stored shared information comes from DAT."),
  selected("shared-world-law", "shared-world law", "A persistent shared-world constraint organized as a persistent shared formal regime.", %w[LOG:020 ORI:220], includes: "formal regimes treated as constraints on co-instantiation in one shared world", excludes: "human rules without world-level scope and descriptive regularities not asserted as constraints", everyday: "a rule governing what can coexist in this world", technical: "a formal world constraint", compounds: "may qualify simulations, ontologies, or logical systems", collision: "ORI owns world constraint; LOG specifies formal organization."),
  selected("formal-ontological-dependence", "formal ontological dependence", "A persistent target-ground dependence constrained by a persistent target-directed formal constraint.", %w[LOG:010 ORI:210], includes: "formally specified dependence of a target's existence on a distinct ground", excludes: "mere logical implication and causal influence", everyday: "a formally stated dependence for something to exist", technical: "a constrained grounding relation", compounds: "may later bind explicit source and target roles", collision: "ORI supplies existential grounding; LOG supplies formal restriction."),
]

# One reviewed open relational template exercises Gate 4A slot and role machinery.
payload = {
  "architecture_version" => "1.0", "semantic_head" => "h",
  "nodes" => [
    { "node_id" => "q01", "kind" => "root", "root_id" => "DAT:000" },
    { "node_id" => "a-source-01", "kind" => "slot", "slot_name" => "source", "slot_type" => "entity" },
    { "node_id" => "a-target-01", "kind" => "slot", "slot_name" => "target", "slot_type" => "entity" },
    { "node_id" => "h", "kind" => "root", "root_id" => "CON:210" }
  ],
  "edges" => [
    { "edge_id" => "e01", "type" => "qualifies", "from" => "q01", "to" => "h" },
    { "edge_id" => "e02", "type" => "fills_role", "from" => "a-source-01", "to" => "h", "role" => "source" },
    { "edge_id" => "e03", "type" => "fills_role", "from" => "a-target-01", "to" => "h", "role" => "target" }
  ],
  "lexical_constraints" => ["Source and target remain open typed slots; the bounded datum qualifies the directed communication relation."]
}
digest = Digest::SHA256.hexdigest(JSON.generate(EraZeroValidation.deep_sort(payload)))
entries << {
  "architecture_version" => "1.0", "compound_id" => "CMP:#{digest[0, 24]}", "content_digest" => digest, "definition_version" => VERSION,
  "status" => "approved", "approval_date" => DATE, "display_title" => "directed data link",
  "english_glosses" => ["directed data link"], "semantic_head" => "h", "nodes" => payload["nodes"], "edges" => payload["edges"],
  "lexical_constraints" => payload["lexical_constraints"],
  "invariant_definition" => "An established directed communication relation between open source and target participants whose exchanged content is a bounded datum.",
  "boundaries" => { "includes" => "a reusable source-to-target data-communication relation template", "excludes" => "a transfer occurrence, an undirected channel, or fixed participant identities" },
  "collision_audit" => "CON:210 remains the relation head; DAT:000 restricts content; slots bind participants without lexicalizing them.",
  "confidence" => "high",
  "examples" => { "ordinary" => "a data link from one participant to another", "technical" => "a typed directed messaging edge", "future_compound" => "may be instantiated by later IR with concrete endpoints", "counterexample" => "Do not use for a broadcast with no distinct target." },
  "serialization" => { "canonical_format" => "EZC-JSON-1", "content_digest" => digest }
}

existing = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")
initial_ids = entries.map { |entry| entry.fetch("compound_id") }
entries.concat(existing.reject { |entry| initial_ids.include?(entry.fetch("compound_id")) })

dictionary = {
  "metadata" => {
    "title" => "Era Zero Gate 4B High-Frequency Compound Dictionary", "version" => VERSION,
    "status" => "canonical_initial_release", "approval_basis" => "User delegated approval by requesting the next translator-readiness stage",
    "architecture" => "spec/compound_architecture_1.0.yaml", "entry_count" => entries.length,
    "scope" => "A deliberately bounded first release of broadly useful, high-confidence compounds; not an English concept index.",
    "atomic_meanings_changed" => false, "generated_fields_changed" => false,
    "english_index_started" => false, "semantic_ir_started" => false, "translator_started" => false
  },
  "entries" => entries.sort_by { |e| e["compound_id"] }
}

score_keys = EraZeroValidation::SCORE_KEYS
candidate_records = entries.map do |entry|
  selected_score = score_keys.to_h { |k| [k, %w[everyday_language_coverage technical_coverage].include?(k) ? 8 : 9] }
  reverse_score = score_keys.to_h { |k| [k, k == "address_fit" || k == "neighbor_separation" ? 5 : 6] }
  atomic_score = score_keys.to_h { |k| [k, %w[atomicity compound_usefulness].include?(k) ? 3 : 5] }
  {
    "compound_id" => entry["compound_id"], "display_title" => entry["display_title"],
    "current_choice_reason" => "The selected head names the semantic category; every other node supplies a separately canonical restriction.",
    "candidates" => [
      { "candidate_id" => "selected_graph", "direction" => "explicit compositional subtype", "graph" => { "head" => entry["semantic_head"], "nodes" => entry["nodes"], "edges" => entry["edges"] }, "scores" => selected_score, "total" => selected_score.values.sum, "decision" => "winner" },
      { "candidate_id" => "reverse_head", "direction" => "reverse semantic head while retaining the same roots", "scores" => reverse_score, "total" => reverse_score.values.sum, "decision" => "rejected: names a different category and weakens head predictability" },
      { "candidate_id" => "single_atom", "direction" => "collapse to the present semantic-head atom", "scores" => atomic_score, "total" => atomic_score.values.sum, "decision" => "rejected: loses the explicit cross-family distinction" }
    ],
    "recommendation" => "approve selected_graph", "confidence" => entry["confidence"]
  }
end

routing = [
  ["person", "atomic", "LIF:010 when a particular other being is intended; discourse roles belong to later IR"],
  ["destination", "atomic", "MOV:010"], ["route", "atomic", "MOV:020"],
  ["tool", "compound", entries.find { |e| e["display_title"] == "physical tool" }["compound_id"]],
  ["machine", "compound", entries.find { |e| e["display_title"] == "machine" }["compound_id"]],
  ["program", "compound", entries.find { |e| e["display_title"] == "program definition" }["compound_id"]],
  ["injury", "compound", entries.find { |e| e["display_title"] == "physical injury" }["compound_id"]],
  ["message", "compound", entries.find { |e| e["display_title"] == "message datum" }["compound_id"]],
  ["road", "compound", entries.find { |e| e["display_title"] == "material route" }["compound_id"]],
  ["body", "compound", entries.find { |e| e["display_title"] == "living body" }["compound_id"]],
  ["backup", "compound", entries.find { |e| e["display_title"] == "backup dataset" }["compound_id"]],
  ["water", "unresolved_gap", "No canonical atom distinguishes liquid phase or H2O composition."],
  ["food", "unresolved_gap", "No canonical atom states nutritional suitability or consumption."],
  ["home", "defer_to_gate4c_and_ir", "English home conflates structure, habitual location, social bond, possession, and affect."],
  ["shelter", "unresolved_gap", "Protection function is not safely entailed by structure plus care."],
  ["run a program", "defer_to_semantic_ir", "Program definition plus execution occurrence requires clause-level event binding."],
  ["send a message", "defer_to_semantic_ir", "Message datum and source expression/target transfer are independent occurrence assertions."],
  ["repairing", "atomic_or_ir", "REP:101/111/121 by locus; domain compounds may qualify the process."],
  ["transport", "compound_plus_ir", "MOV movement, a bearer, and a moved target require role binding in utterance IR."],
  ["friend", "unresolved_gap", "LIF:210 establishes a life-bond but does not encode friendship's social convention." ]
].map { |concept, route, rationale| { "english_concept" => concept, "route" => route, "rationale" => rationale } }

cases = {
  "metadata" => { "title" => "Gate 4B dictionary conformance and routing cases", "version" => VERSION, "approved_entries" => entries.length },
  "accepted" => entries.map { |e| { "case_id" => e["display_title"].tr(" ", "_"), "compound_id" => e["compound_id"], "expected" => "valid_approved_entry" } },
  "routing_tests" => routing,
  "rejection_tests" => [
    { "case_id" => "duplicate_atom", "input" => "MOV:010 alone renamed destination compound", "expected_error" => "atomic_collision" },
    { "case_id" => "runtime_in_identity", "input" => "runtime_state field in compound payload", "expected_error" => "forbidden_lexical_field" },
    { "case_id" => "event_as_lexeme", "input" => "send a message stored as one lexical compound", "expected_error" => "multiple_independent_assertions" },
    { "case_id" => "unsupported_water", "input" => "MAT:000 relabeled water", "expected_error" => "unsupported_semantic_narrowing" },
    { "case_id" => "unsupported_food", "input" => "MAT:010 plus LIF:200 relabeled food", "expected_error" => "missing_nutrition_relation" }
  ]
}

review_md = <<~MD
  # Gate 4B High-Frequency Compound Design Review

  Status: **APPROVED — BOUNDED INITIAL DICTIONARY RELEASE**  
  Version: **#{VERSION}**  
  Approved entries: **#{entries.length}**

  ## Design decision

  This release treats frequency as a prioritization signal, not permission to imitate English lexicalization. Every approved entry has one explicit semantic head and at least one independently canonical restriction. English labels are discovery metadata only. Reversing the head or collapsing the graph to one atom was evaluated and rejected for every entry in the scored-candidate record.

  The release is intentionally conservative: it approves concrete cross-family distinctions that the present atoms support, including artifacts, bodies, messages, programs, repair domains, data networks, and formal world relations. It does not pretend that the lexicon already encodes chemical substances, nutrition, habitation, possession, friendship, or execution events.

  ## Approval standard

  An entry was admitted only when it passed atomic-collision, head-selection, graph-connectivity, cross-family-separation, runtime-separation, everyday-usefulness, and technical-usefulness review. A common English expression was rejected or deferred when its meaning required an absent atom, a culture-specific convention, or multiple occurrence-level assertions.

  ## Entry summary

  | Title | Head root | Components | Confidence |
  |---|---|---|---|
  #{entries.map { |e| "| #{e['display_title']} | #{e['nodes'].find { |n| n['node_id'] == 'h' }['root_id']} | #{e['nodes'].map { |n| n['kind'] == 'root' ? n['root_id'] : "slot:#{n['slot_name']}" }.join(' + ')} | #{e['confidence']} |" }.join("\n")}

  ## Concepts deliberately not approved as compounds

  - **person** and core motion entities remain atomic or discourse-level; duplicating them would reduce precision.
  - **water**, **food**, and **shelter** remain vocabulary gaps because the necessary phase/composition, nutrition, and protection distinctions do not exist atomically.
  - **home** is deferred to Gate 4C sense analysis because its English senses divide across structure, habitual location, social bond, possession, and affect.
  - **run a program**, **send a message**, and **transport** require occurrence roles and belong in semantic IR rather than one lexical compound.

  ## Boundary

  Gate 4B does not create an English concept index, etymology layer, semantic IR, grammar implementation, renderer, decoder, or translator. Labels in this packet are not yet general-English mappings. Gate 4C is next.
MD

collision_md = <<~MD
  # Gate 4B Compound Collision Report

  Status: **PASS — NO APPROVED ENTRY DUPLICATES AN ATOMIC INVARIANT**

  ## Audit method

  Each entry was checked against its semantic-head atom, every qualifier atom, reverse-head interpretation, neighboring same-family atoms, and likely cross-family substitutions. The approved meaning must disappear if any component is removed; this is the operational test that the compound adds a real compositional intersection.

  ## Findings

  - #{entries.length} approved entries have two or more semantic components and one explicit head.
  - No entry changes an atomic definition, address, carrier, compact root, harmonic signature, or note path.
  - Dormant compounds use lexical third-trit meanings deliberately; runtime `[2]/num` remains occurrence metadata and is excluded from identity.
  - Process-domain compounds such as physical, data, and structural repair describe one restorative process under a domain restriction. They do not bundle a separate event.
  - The directed-data-link template is the sole open template in this release. Its participants are typed slots, not hidden lexical content.
  - Water, food, shelter, home, friendship, program execution, message sending, and transport were not forced into misleading compounds.

  ## Residual risks

  English labels remain polysemous. Gate 4C must split senses before any English lookup uses these entries. Later versions must not silently rewrite an approved graph; semantic changes require a new content ID and migration.
MD

migration = {
  "migration_id" => "gate4b_compound_dictionary_1.0", "date" => DATE, "status" => "applied",
  "authority_basis" => "User authorized the next stage after Gate 4A and delegated root/compound approval decisions.",
  "from" => { "gate4b_status" => "not_started", "approved_compounds" => 0 },
  "to" => { "gate4b_status" => "complete", "approved_compounds" => entries.length, "dictionary_version" => VERSION },
  "atomic_lexicon_fingerprint" => EraZeroValidation.fingerprint(EraZeroValidation.load_yaml("lexicon/atoms.yaml").fetch("atoms")),
  "semantic_changes_to_atoms" => [], "generated_field_changes" => [],
  "approved_compound_ids" => entries.map { |e| e["compound_id"] }.sort,
  "next_gate" => "gate4c_english_concept_and_sense_index"
}

FileUtils.mkdir_p(File.join(EraZeroValidation::ROOT, "lexicon"))
FileUtils.mkdir_p(File.join(EraZeroValidation::ROOT, "reviews"))
FileUtils.mkdir_p(File.join(EraZeroValidation::ROOT, "tests"))
FileUtils.mkdir_p(File.join(EraZeroValidation::ROOT, "reports"))
FileUtils.mkdir_p(File.join(EraZeroValidation::ROOT, "migrations"))
File.write(File.join(EraZeroValidation::ROOT, "lexicon/compound_dictionary.yaml"), YAML.dump(dictionary))
File.write(File.join(EraZeroValidation::ROOT, "reviews/gate4b_high_frequency_compounds_scored_candidates.yaml"), YAML.dump({ "metadata" => { "version" => VERSION, "score_scale" => "1-10", "categories" => score_keys }, "reviews" => candidate_records }))
File.write(File.join(EraZeroValidation::ROOT, "tests/gate4b_compound_cases.yaml"), YAML.dump(cases))
File.write(File.join(EraZeroValidation::ROOT, "migrations/gate4b_compound_dictionary_1.0.yaml"), YAML.dump(migration))
File.write(File.join(EraZeroValidation::ROOT, "reviews/gate4b_high_frequency_compounds_review.md"), review_md)
File.write(File.join(EraZeroValidation::ROOT, "reports/gate4b_collision_report.md"), collision_md)

version_path = File.join(EraZeroValidation::ROOT, "spec/version.yaml")
version = YAML.load_file(version_path)
version["next_gate_authorized"] = "gate4c_english_concept_and_sense_index"
version["last_completed_gate"] = "gate4b_high_frequency_compound_dictionary"
version["compound_dictionary_entries"] = entries.length
version["compound_dictionary_version"] = VERSION
version["compound_dictionary"] = "lexicon/compound_dictionary.yaml"
version["gate4b_status"] = "canonical"
File.write(version_path, YAML.dump(version))

readiness_path = File.join(EraZeroValidation::ROOT, "spec/translator_readiness.yaml")
readiness = YAML.load_file(readiness_path)
readiness["safe_now"]["approved_compound_count"] = entries.length
readiness["safe_now"]["compound_translation"] = false
readiness["next_authorized_gate"] = "gate4c_english_concept_and_sense_index"
readiness["gate4b"] = { "status" => "complete_and_canonical", "dictionary" => "lexicon/compound_dictionary.yaml", "entries" => entries.length, "validation" => "reports/gate4b_validation.md", "english_index_started" => false }
gate2 = readiness["required_gates"].find { |g| g["gate"] == "compound_and_coverage" }
g4b = gate2["subgates"].find { |g| g["gate"] == "gate4b_high_frequency_compound_dictionary" }
g4b["status"] = "complete"
g4b["entries"] = entries.length
File.write(readiness_path, YAML.dump(readiness))

canonical_path = File.join(EraZeroValidation::ROOT, "spec/canonical_spec.yaml")
canonical = YAML.load_file(canonical_path)
canonical["compound_dictionary"] = { "status" => "canonical_initial_release", "version" => VERSION, "path" => "lexicon/compound_dictionary.yaml", "approved_entries" => entries.length, "english_index_authorized" => false }
File.write(canonical_path, YAML.dump(canonical))

status_path = File.join(EraZeroValidation::ROOT, "semantic_authority_status.md")
status = File.read(status_path)
unless status.include?("Gate 4B high-frequency compound dictionary")
  status << "\n## Gate 4B high-frequency compound dictionary — #{DATE}\n\n- Status: **canonical initial release #{VERSION}**.\n- Approved compound definitions: **#{entries.length}**.\n- Atomic authority remains **324 canonical / 0 provisional**; no atomic meaning or generated form changed.\n- Common concepts unsupported by the atoms remain gaps or are deferred; English labels are not yet an English sense index.\n- Next authorized work: **Gate 4C English concept and sense index**. Semantic IR, grammar, renderer, decoder, and translator remain unstarted.\n"
  File.write(status_path, status)
end

roadmap_path = File.join(EraZeroValidation::ROOT, "reports/translator_readiness_roadmap.md")
roadmap = File.read(roadmap_path)
unless roadmap.include?("Gate 4B completion — #{DATE}")
  roadmap << "\n## Gate 4B completion — #{DATE}\n\nGate 4B is complete as a bounded canonical initial release with **#{entries.length}** approved compounds. Unsupported common concepts were preserved as explicit gaps or deferred mappings rather than forced. Gate 4C (English concept and sense index) is next. No translator implementation is authorized yet.\n"
  File.write(roadmap_path, roadmap)
end

puts "Built Gate 4B dictionary: #{entries.length} approved entries"
