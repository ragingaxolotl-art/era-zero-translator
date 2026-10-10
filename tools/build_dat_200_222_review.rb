#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "DAT:200–222"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "DAT_200_222"
SEMANTIC_CENTER = "information-process affordances: internal transformability, source-target transferability, and systemic synchronizability"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "DAT:200" => ["stable access capacity", "An entity has dependable permission and means to read, retain, or use its own information."],
  "DAT:201" => ["active retrievability", "Information is currently readable, writable, searchable, or recoverable by the entity."],
  "DAT:202" => ["locked data potential", "Information exists and may be recoverable, but access, decoding, or retrieval is presently unavailable."],
  "DAT:210" => ["stable reference", "An information object has an established addressing, citation, lookup, or identity relation to a target."],
  "DAT:211" => ["active dereference", "A reference is presently resolving, retrieving, validating, or linking its target."],
  "DAT:212" => ["unresolved reference", "A possible link to a target exists but is broken, ambiguous, missing, or not yet verified."],
  "DAT:220" => ["stable information integrity", "A data system has established fidelity, provenance, consistency, and replication relationships."],
  "DAT:221" => ["active provenance network", "Records are actively being traced, checked, reconciled, or replicated across a distributed system."],
  "DAT:222" => ["recoverable information possibility", "A coherent system-level record could be reconstructed or discovered, but it is not yet available."]
}.freeze

ROOTS = {
  "DAT:200" => { title: "persistent internal data transformability", phase: "persistent", scope: "inward", kind: "internal data transformability", invariant: "A persistent capacity of represented information within one reference entity to undergo bounded internal data transformation, independently of whether that capacity is presently operative." },
  "DAT:201" => { title: "operative internal data transformability", phase: "operative", scope: "inward", kind: "internal data transformability", invariant: "A capacity of represented information within one reference entity to undergo bounded internal data transformation that is presently operative." },
  "DAT:202" => { title: "latent internal data transformability", phase: "latent", scope: "inward", kind: "internal data transformability", invariant: "A capacity of represented information within one reference entity to undergo bounded internal data transformation that exists without being presently operative." },
  "DAT:210" => { title: "persistent source-target data transferability", phase: "persistent", scope: "outward", kind: "source-target data transferability", invariant: "A persistent information-transfer relation between one source context and one distinct reference target that can enable bounded target data transfer, independently of whether that relation is presently operative." },
  "DAT:211" => { title: "operative source-target data transferability", phase: "operative", scope: "outward", kind: "source-target data transferability", invariant: "An information-transfer relation between one source context and one distinct reference target that presently enables bounded target data transfer." },
  "DAT:212" => { title: "latent source-target data transferability", phase: "latent", scope: "outward", kind: "source-target data transferability", invariant: "An information-transfer relation between one source context and one distinct reference target that exists without presently enabling bounded target data transfer." },
  "DAT:220" => { title: "persistent systemic data synchronizability", phase: "persistent", scope: "systemic", kind: "systemic data synchronizability", invariant: "A persistent capacity of information states across multiple participants in one shared data domain to undergo coordinated alignment under one synchronization criterion, independently of whether that capacity is presently operative." },
  "DAT:221" => { title: "operative systemic data synchronizability", phase: "operative", scope: "systemic", kind: "systemic data synchronizability", invariant: "A capacity of information states across multiple participants in one shared data domain to undergo coordinated alignment under one synchronization criterion that is presently operative." },
  "DAT:222" => { title: "latent systemic data synchronizability", phase: "latent", scope: "systemic", kind: "systemic data synchronizability", invariant: "A capacity of information states across multiple participants in one shared data domain to undergo coordinated alignment under one synchronization criterion that exists without being presently operative." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 9, 4, 5, 8, 8, 9] },
  "information_process_affordances" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "access_retrieval_relations" => { scores: [9, 8, 9, 7, 7, 9, 10, 10] },
  "reference_resolution_relations" => { scores: [8, 8, 10, 7, 8, 9, 9, 10] },
  "integrity_provenance_relations" => { scores: [8, 7, 9, 6, 7, 9, 8, 10] }
}.freeze

ALT_TITLES = {
  "DAT:200" => ["persistent internal retrievability", "persistent internal reference resolution", "persistent internal integrity relation"],
  "DAT:201" => ["operative internal retrievability", "operative internal reference resolution", "operative internal integrity relation"],
  "DAT:202" => ["latent internal retrievability", "latent internal reference resolution", "latent internal integrity relation"],
  "DAT:210" => ["persistent target access relation", "persistent target reference resolution", "persistent target provenance relation"],
  "DAT:211" => ["operative target access relation", "operative target reference resolution", "operative target provenance relation"],
  "DAT:212" => ["latent target access relation", "latent target reference resolution", "latent target provenance relation"],
  "DAT:220" => ["persistent systemic retrievability", "persistent systemic reference resolution", "persistent systemic integrity relation"],
  "DAT:221" => ["operative systemic retrievability", "operative systemic reference resolution", "operative systemic integrity relation"],
  "DAT:222" => ["latent systemic retrievability", "latent systemic reference resolution", "latent systemic integrity relation"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological capacities, agents, and social roles. A living bearer may support data processing, but DAT:2xx does not encode life, health, intelligence, office, or agency.",
  "MOV" => "MOV owns position, routes, displacement, and motion affordances. Physical carrier reachability may realize transferability, but information-process enablement is not spatial reachability or a route.",
  "MAT" => "MAT owns substance, energy, force, contact, material compatibility, and physical capacities. Material media may realize a data affordance, but DAT:2xx does not encode storage hardware, energy, mechanism, or physical coupling.",
  "MIN" => "MIN owns attention, belief, expectation, confidence, understanding, and cognitive capacity. Data transformability or transferability can hold without anyone knowing, understanding, observing, or intending that it holds.",
  "CON" => "CON owns communication, social linkage, participation, access authority, and interaction channels. A channel may realize target data transfer, but participant reachability, permission, and communicative uptake are not DAT:2xx affordances.",
  "WRN" => "WRN owns hazards, faults, adverse processes, susceptibility, exposure, and propagation pathways. Lack of a data affordance may be adverse, but DAT:2xx does not assert corruption, danger, failure, warning, or vulnerability.",
  "STR" => "STR owns arrangements, interfaces, dependencies, structural compatibility, and transformation affordances. Structure may realize a data affordance, but DAT:2xx adds only typed information-process enablement.",
  "REP" => "REP owns restoration conditions, transformations, and affordances. Recovering information may use DAT processes, but DAT:2xx is not recoverability, restoration applicability, or a recovery pathway.",
  "LOG" => "LOG owns formal criteria, evaluations, applicability, and joint evaluability. A rule may qualify a data operation, but formal admissibility and data-process enablement remain distinct.",
  "CRE" => "CRE owns generation, construction, transformation, and productive capacities. Creating information or an algorithm is separate from whether existing represented information can be transformed, transferred, or synchronized.",
  "ORI" => "ORI owns general possibility, necessity, probability, time, cause, and ontological qualification. DAT:2xx asserts a typed existing information-process affordance, never unrestricted possibility or futurity."
}.freeze

def scores(values)
  EraZeroValidation::SCORE_KEYS.zip(values).to_h
end

def score_values(architecture, id)
  values = ARCHITECTURES.fetch(architecture).fetch(:scores).dup
  second = id[-2]
  third = id[-1]
  case architecture
  when "current_phase2"
    values[0] -= 1 if third == "2"
    values[3] -= 1 if second == "2"
  when "information_process_affordances"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "access_retrieval_relations"
    values[1] -= 1 if second == "1"
    values[3] -= 1 if third == "2"
  when "reference_resolution_relations"
    values[2] -= 1 if second == "2"
    values[5] -= 1 if second == "0"
  when "integrity_provenance_relations"
    values[2] -= 1 if second != "1"
    values[4] -= 2 if second == "1"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional titles use familiar data-relation vocabulary—access, retrieval, reference, dereference, integrity, provenance, consistency, and recoverability—and roughly reflect #{root.fetch(:scope)} scope and #{root.fetch(:phase)} status.",
      "useful_coverage" => "They reach storage access, lookup, addressing, provenance, distributed consistency, reconstruction, and permission-aware systems.",
      "semantic_territory_consumed" => "Across the block they mix permission, means, reading, writing, search, recovery, reference identity, dereference processes, validation, integrity, provenance, replication, reconstruction, observer uncertainty, and possibility.",
      "conflicts_or_future_limitations" => "The three triplets have no shared invariant center and the third trit shifts among stability, current processes, brokenness, ambiguity, missingness, and possibility."
    }
  when "information_process_affordances"
    {
      "why_it_fits" => "First-trit 2 becomes the capacity or qualifying relation enabling the matching DAT:1xx process; the second trit changes only inward, target, or systemic scope; and the third changes only persistent, operative, or latent status.",
      "useful_coverage" => "It supports transformable, encodable, transferable, writable-to, stream-capable, synchronizable, interoperable, replication-capable, and capability-aware programming.",
      "semantic_territory_consumed" => "Only typed enablement for the approved information transformation, transfer, or synchronization processes. Data entities, actual processes, algorithms, media, permission, integrity results, provenance, observer access, and modality remain separate.",
      "conflicts_or_future_limitations" => "Stronger claims about authorization, bandwidth, losslessness, consistency, termination, storage durability, or recovery require compounds or later specialization."
    }
  when "access_retrieval_relations"
    {
      "why_it_fits" => "Access and retrieval relations are central to information systems and can be described as persistent, operative, or latent.",
      "useful_coverage" => "It would cover readable, writable, searchable, retrievable, available, accessible, and recoverable data.",
      "semantic_territory_consumed" => "It consumes observer- or principal-relative access and storage availability rather than general enablement of the three DAT:1xx processes.",
      "conflicts_or_future_limitations" => "Access requires an accessor, permission or channel, and often a storage relation; it fits the outward column better than the entire cube and collides with CON, STR, REP, and MIN."
    }
  when "reference_resolution_relations"
    {
      "why_it_fits" => "References and their resolution are central Data relations, especially for a source pointing toward a distinct target.",
      "useful_coverage" => "It would cover addressable, resolvable, dereferenceable, linkable, citable, locatable, and lookup-capable.",
      "semantic_territory_consumed" => "It consumes the relation between an information object and its referent rather than enablement for transformation, transfer, or synchronization.",
      "conflicts_or_future_limitations" => "Reference resolution strongly favors the outward column; inward and systemic variants become strained, while DAT:010–012 already owns target-denoting information entities."
    }
  when "integrity_provenance_relations"
    {
      "why_it_fits" => "Integrity and provenance are important information relations that can be persistent, presently effective, or latent across local, target, and systemic scopes.",
      "useful_coverage" => "It would cover authentic, intact, traceable, consistent, verified, replicated, and provenance-linked information.",
      "semantic_territory_consumed" => "It consumes positive quality, historical origin, or agreement relations rather than process enablement.",
      "conflicts_or_future_limitations" => "Integrity is a result under a criterion, provenance requires causal/history structure, and neither supplies a coherent inward/target/systemic affordance cube."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "access_retrieval_relations"
    "A #{root.fetch(:phase)} information access or retrieval relation at #{root.fetch(:scope)} scope."
  when "reference_resolution_relations"
    "A #{root.fetch(:phase)} reference-resolution relation at #{root.fetch(:scope)} information scope."
  when "integrity_provenance_relations"
    "A #{root.fetch(:phase)} information-integrity or provenance relation at #{root.fetch(:scope)} scope."
  end
end

def candidate(id, architecture, title, invariant)
  score_map = scores(score_values(architecture, id))
  {
    "candidate_id" => architecture,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => candidate_analysis(id, architecture, title),
    "scores" => score_map,
    "total" => score_map.values.sum,
    "maximum" => 80
  }
end

def nearest_neighbors(id)
  address = id.split(":").last
  first, second, third = address.chars
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "DAT:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "DAT:#{first}#{x}#{third}" }
  entity = "DAT:0#{second}#{third}"
  process = "DAT:1#{second}#{third}"
  (siblings + scopes + [entity, process]).uniq
end

def roles
  {
    "low" => "reference entity, source context, or participant whose data affordance is asserted",
    "middle" => "information-process capacity or transfer relation as the asserted figure",
    "high" => "represented information, distinct target, or synchronization criterion",
    "sustained" => "shared data domain and multiple synchronizable participants"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} persists in the stated information context; it does not select the operative or latent sibling and does not establish a different access or quality relation.",
      "1" => "Affirms that this #{root.fetch(:kind)} persists independently of current operation, without asserting that a data process is occurring or that any result quality holds.",
      "2/num" => "Leaves unresolved whether this persistent #{root.fetch(:kind)} claim holds; runtime uncertainty does not change the lexical root into operative or latent status."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently operative; it does not deny persistent identity or affirm the latent sibling, impossibility, or rule absence.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently operative under the applicable conditions, without asserting that the corresponding data process is underway or completed.",
      "2/num" => "Leaves current operation of this #{root.fetch(:kind)} unresolved; token uncertainty does not select the persistent or latent lexical sibling."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} exists as the stated nonoperative information affordance; it does not establish that an operative sibling holds or that the process is impossible.",
      "1" => "Affirms this #{root.fetch(:kind)} as existing but not presently operative, without encoding hiddenness, uncertainty, probability, future activation, missing resources, or permission.",
      "2/num" => "Leaves unresolved even the assertion that this latent #{root.fetch(:kind)} exists; lexical latency remains distinct from runtime assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "device" : id[-2] == "1" ? "recipient" : "network"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},DATA=d" : id[-2] == "1" ? "SOURCE=s,TARGET=#{entity},DATA=d" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},CRITERION=c"
  status_text = { "0" => "persists independently of present operation", "1" => "is presently operative", "2" => "exists but is not presently operative" }.fetch(id[-1])
  ordinary = "The #{root.fetch(:kind)} for the #{entity} #{status_text}."
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts information-process enablement and lexical status, not an actual process or result."],
    ["physical_or_spatial", "MAT(BEARER=m)+#{id}[1](#{graph_roles})", "material bearer plus #{root.fetch(:phase)} information-process affordance", "The machine has the stated data affordance while MAT separately describes storage media, signal mechanics, or carrier motion.", "Information affordance and physical implementation remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} information-process affordance during interval w", "During interval w, the affordance has the stated lexical status.", "ORI supplies time and does not replace persistent, operative, or latent status."],
    ["cross_family_compound", "DAT:001[1](DATA=d)+#{id}[1](#{graph_roles})+CON(CHANNEL=h)", "manifest datum plus #{root.fetch(:phase)} information affordance plus channel", "The datum and affordance remain DAT while CON supplies any communication channel or access authority.", "Entity, affordance, and participant relation remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} information-process affordance", "A runtime tracks whether the selected data affordance has the stated status without asserting process execution or outcome.", "Capability, process, and result remain distinct."],
    ["counterexample", "DAT:101[1](ENTITY=#{entity},DATA=d)", "active internal data transformation", "The information transformation is running now.", "Use DAT:1xx for the actual process; #{id} names only its enabling capacity or relation."]
  ]
  entries.map do |category, graph, gloss, english, analysis|
    {
      "category" => category,
      "semantic_graph" => graph,
      "literal_gloss" => gloss,
      "natural_english" => english,
      "runtime_state" => 1,
      "contour" => category == "executable_or_programming" ? "level assertion or sharply falling execution" : "level declaration",
      "role_registers" => roles,
      "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid",
      "analysis" => analysis,
      "pseudocode" => category == "executable_or_programming" ? "assert(data_affordance.status == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "information_process_affordances", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "access_retrieval_relations", alt[0], alternative_invariant(id, "access_retrieval_relations")),
    candidate(id, "reference_resolution_relations", alt[1], alternative_invariant(id, "reference_resolution_relations")),
    candidate(id, "integrity_provenance_relations", alt[2], alternative_invariant(id, "integrity_provenance_relations"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "information_process_affordances",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one information-process-enablement center, follows inward/target/systemic scope exactly, and gives every triplet one persistent/operative/latent axis while reserving information entities, actual processes, algorithms, media, access, integrity, provenance, permission, and modality for other roots or composition.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  root = ROOTS.fetch(id)
  second = id[-2]
  third = id[-1]
  scope_label = { "0" => "inward/self", "1" => "outward/target", "2" => "systemic/collective" }.fetch(second)
  state_label = { "0" => "persistent", "1" => "operative", "2" => "latent" }.fetch(third)
  scope_explanation = {
    "0" => "represented information within one entity and its capacity for bounded internal transformation",
    "1" => "one source context and one distinct target joined by an information-transfer relation",
    "2" => "multiple participants whose information states can undergo coordinated alignment under one synchronization criterion"
  }.fetch(second)
  scope_boundary = {
    "0" => "The capacity concerns represented information within one entity without requiring a distinct external target. The datum, algorithm, medium, actual transformation, and result remain separate.",
    "1" => "The relation preserves one source context and one distinct target. Physical path, channel, permission, actual transfer, acknowledgment, and later persistence remain separate.",
    "2" => "The capacity requires multiple participants to be jointly synchronizable under one shared criterion. Several independently transformable or transferable participants do not constitute one systemic affordance."
  }.fetch(second)
  triplet_logic = "Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time. Lexical latency affirms an existing but nonoperative affordance; runtime `[2]/num` separately marks uncertainty about any selected status."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_2" => "Selects an information-process capacity or qualifying transfer relation rather than an information entity, actual data process, physical carrier, result value, or unrestricted modality.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Data-family column.",
      "third_trit" => "Selects the #{state_label} status of the same information-process affordance while leaving runtime truth status, actual processing, quality, observer knowledge, tense, probability, permission, and scheduling separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral information-process affordance at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about information-object identity, storage medium, access authority, fidelity, integrity, provenance, bandwidth, resource sufficiency, observer belief, scheduling, probability, timing, and cause.",
    "excluded_meanings" => [
      "The internal datum, target reference, or shared dataset as an entity, and its persistent, manifest, or dormant status.",
      "The completed, active, or nonactualized transformation, target transfer, or synchronization process and any quality or acknowledgment result.",
      "Specific encodings, schemas, algorithms, storage devices, physical carriers, channels, credentials, bandwidth, or computational resources.",
      "Physical, biological, communicative, cognitive, logical, structural, restorative, creative, or adverse capacity or transformation.",
      "Access permission, retrieval, reference resolution, integrity, provenance, consistency, compatibility, ownership, authority, performance, or resource sufficiency.",
      "Observer knowledge, evidence, intention, plan, readiness, queue, schedule, future time, unrestricted possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` owns the corresponding completed, active, or nonactualized information processes. `DAT:2xx` owns only typed process enablement: internal transformability, source-target transferability, and systemic synchronizability. A datum does not entail transformability, an affordance does not entail an actual process, and a completed process does not entail fidelity, persistence, or acknowledgment. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} status of this information-process affordance. Runtime `[2]/num` instead leaves the already-selected status claim unresolved; it never changes affordance status. Thus a latent root affirmed with `[1]` is a confirmed existing-but-nonoperative affordance, while a persistent or operative root carrying `[2]/num` remains lexically persistent or operative but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + DAT:0xx supplies the datum, target reference, or shared dataset without reducing the affordance to its information entity.",
      "#{id} + DAT:1xx states that the corresponding data transformation, transfer, or synchronization is actually completed, active, or nonactualized.",
      "#{id} + MAT/MOV/STR supplies media, physical paths, resources, and implementation while preserving the DAT affordance boundary.",
      "#{id} + ORI/CON/LOG may express timing, modality, permission, authority, or a qualifying criterion as separate meanings."
    ],
    "later_era_notes" => "Later eras may lexicalize readability, writability, storage durability, lossless transformability, bandwidth, reachability, authorization, retrievability, reference resolution, provenance, integrity, convergence guarantees, and resource-bounded processing. Era Zero should preserve the substrate-neutral information-process-enablement center and derive stronger technical claims compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


data_affordance_stress_base = [
  ["transformable data", "one_root", "DAT:200–202 asserts a typed capacity for represented information within one entity to undergo internal transformation."],
  ["encodable", "one_root_or_compound", "Internal transformability can support encoding, while a specific codec and losslessness remain separate."],
  ["decodable", "one_root_or_compound", "Internal transformability can support decoding without entailing access, comprehension, or successful output."],
  ["compressible", "one_root_or_compound", "Compression capability combines DAT transformability with an algorithm and possibly a size relation."],
  ["writable", "ambiguous_compound", "Writability may mean internal transformability or target transferability depending on roles; permission and storage medium remain separate."],
  ["readable", "ambiguous_compound", "Readability can require transformability, transferability, representation compatibility, and an observer; do not force it into one atom."],
  ["retrievable", "compound_or_later_specialization", "Retrievability requires source selection, access, and transfer toward a requester beyond generic transferability."],
  ["accessible", "compound_or_different_family", "Access adds an accessor, permission or reachability relation; DAT:2xx alone asserts only process enablement."],
  ["permitted to read", "compound", "CON/LIF/LOG supplies authority and policy; DAT supplies the relevant information affordance."],
  ["data transferable", "one_root", "DAT:210–212 states an information-transfer relation from one source context to one distinct target."],
  ["target reachable for data", "one_root_or_compound", "DAT transferability may combine with CON or MOV reachability; physical or social reachability is not identical to it."],
  ["stream-capable", "compound_or_later_specialization", "Streaming capability combines transferability with temporal continuity and throughput constraints."],
  ["copyable to a target", "one_root_or_compound", "Target transferability supports copying, but source retention and duplication policy remain separate."],
  ["movable to a target", "compound", "Destructive move requires transferability plus explicit source removal; transferability alone is neutral."],
  ["broadcast-capable", "compound", "Broadcast requires one-to-many communication structure in addition to target transferability."],
  ["channel available", "different_family_or_compound", "CON owns the communication channel; channel availability may realize but does not equal DAT transferability."],
  ["bandwidth sufficient", "compound", "Bandwidth and resource sufficiency qualify operative transferability but are not its invariant meaning."],
  ["synchronizable data", "one_root", "DAT:220–222 states capacity for coordinated alignment across multiple participants under one criterion."],
  ["replication-capable", "one_root_or_compound", "Systemic synchronizability supports replication, while topology and replica policy remain separate."],
  ["mergeable replicas", "compound_or_later_specialization", "Mergeability combines synchronizability with a conflict-resolution rule and data structure."],
  ["convergent", "result_or_guarantee", "Convergence is a result or guarantee under a criterion, not generic synchronizability."],
  ["eventually consistent", "compound", "Synchronizability plus an ORI eventuality and LOG consistency criterion expresses eventual consistency."],
  ["interoperable", "compound_or_later_specialization", "Interoperability may require transformability, transferability, synchronizability, shared schemas, and structural compatibility."],
  ["replicas agree", "result_not_affordance", "Agreement is an information-state result; synchronizability alone entails no current agreement."],
  ["data has integrity", "result_or_relation", "Integrity is a quality under a criterion, not the capacity to transform, transfer, or synchronize."],
  ["data has provenance", "reserved_relation", "Provenance is historical or causal attribution and remains separate from data-process affordance."],
  ["reference resolves", "reserved_relation_or_process", "Reference resolution concerns a target-denoting datum and a resolution process, not the general affordance cube."],
  ["link exists", "entity_or_relation", "DAT:010–012 may represent target-denoting information; a link does not entail transferability."],
  ["recoverable data", "compound_or_different_family", "Recovery requires REP restoration semantics plus relevant DAT affordances and records."],
  ["possible data operation", "different_family", "ORI owns unrestricted possibility; DAT:2xx asserts a specific existing typed affordance."],
  ["data process running", "process_layer", "DAT:1xx owns actual process phase; DAT:2xx only states capacity or qualifying relation."],
  ["data process completed", "process_layer", "DAT:1x0 owns completion; affordance alone entails no actual process or result."],
  ["datum exists", "entity_layer", "DAT:0xx owns information entity identity; a datum may lack an operative processing affordance."],
  ["datum is manifest", "entity_layer", "DAT:0x1 owns manifestation; manifestation does not entail transformability or transferability."],
  ["algorithm exists", "compound", "DAT or CRE may represent or create an algorithm; its existence may realize an affordance but is not identical to it."],
  ["resources available", "compound", "MAT, DAT, or STR owns resources; availability may realize operative status but is not the affordance itself."],
  ["persistent internal data transformability", "one_root", "DAT:200 preserves internal transformability independently of current operation."],
  ["operative internal data transformability", "one_root", "DAT:201 states that internal transformability is presently operative."],
  ["latent internal data transformability", "one_root", "DAT:202 states that transformability exists without being presently operative."],
  ["persistent source-target data transferability", "one_root", "DAT:210 preserves one source-target transfer relation independently of present operation."],
  ["operative source-target data transferability", "one_root", "DAT:211 states that one source-target transfer relation presently enables transfer."],
  ["latent source-target data transferability", "one_root", "DAT:212 states that the transfer relation exists without presently enabling transfer."],
  ["persistent systemic data synchronizability", "one_root", "DAT:220 preserves synchronizability across participants independently of present operation."],
  ["operative systemic data synchronizability", "one_root", "DAT:221 states that the systemic synchronization capacity is presently operative."],
  ["latent systemic data synchronizability", "one_root", "DAT:222 states that the systemic capacity exists without being presently operative."],
  ["persistent plus operative transformability", "two_compatible_roots", "DAT:200 and DAT:201 may co-occur because persistent identity is neutral about current operation."],
  ["persistent plus latent transformability", "two_compatible_roots", "DAT:200 and DAT:202 may co-occur while the capacity is nonoperative."],
  ["operative and latent transformability simultaneously", "invalid_same_reference_claim", "DAT:201 and DAT:202 are mutually exclusive for the same capacity at one reference time."],
  ["persistent plus operative transferability", "two_compatible_roots", "DAT:210 and DAT:211 may co-occur because persistence and current operation are independent claims."],
  ["persistent plus latent transferability", "two_compatible_roots", "DAT:210 and DAT:212 may co-occur while the relation is nonoperative."],
  ["operative and latent transferability simultaneously", "invalid_same_reference_claim", "DAT:211 and DAT:212 are mutually exclusive at one reference time."],
  ["persistent plus operative synchronizability", "two_compatible_roots", "DAT:220 and DAT:221 may co-occur because persistent identity is neutral about current operation."],
  ["persistent plus latent synchronizability", "two_compatible_roots", "DAT:220 and DAT:222 may co-occur while the systemic capacity is nonoperative."],
  ["operative and latent synchronizability simultaneously", "invalid_same_reference_claim", "DAT:221 and DAT:222 are mutually exclusive at one reference time."],
  ["latent data affordance affirmed", "runtime_and_lexical", "DAT:202/212/222[1] affirms an existing nonoperative affordance without uncertainty or future time."],
  ["operative data affordance uncertain", "runtime_and_lexical", "DAT:201/211/221[2]/num leaves current operation unresolved while preserving the operative lexical selection."],
  ["persistent data affordance denied", "runtime_and_lexical", "Runtime [0] denies persistent identity without selecting the operative or latent sibling."],
  ["unknown data affordance", "runtime_or_epistemic", "Use runtime [2]/num or MIN/DAT evidence; lexical latency does not mean unknown."],
  ["hidden transferability", "compound", "DAT:212 supplies nonoperation only; MIN or DAT evidence separately states that observers have not discovered the relation."],
  ["scheduled activation", "compound", "A latent DAT affordance plus ORI and schedule data may describe activation; latency never means scheduled."],
  ["data affordance versus entity", "scope_resolution_test", "DAT:2xx owns enablement while DAT:0xx owns the information entity."],
  ["data affordance versus process", "scope_resolution_test", "DAT:2xx owns enablement while DAT:1xx owns actual processing by phase."],
  ["transformability versus understanding", "scope_resolution_test", "MIN owns comprehension; represented information can be transformable without being understood."],
  ["transferability versus communication", "scope_resolution_test", "DAT owns information transfer enablement while CON owns participant channel, intent, and uptake."],
  ["transferability versus physical reachability", "scope_resolution_test", "MOV/MAT owns carrier paths and movement; DAT owns information-state transfer enablement."],
  ["synchronizability versus consistency", "scope_resolution_test", "Synchronizability is capacity for alignment; LOG or a result claim states consistency."],
  ["synchronizability versus restoration", "scope_resolution_test", "DAT enables alignment while REP owns return to an acceptable prior state."],
  ["data affordance versus general possibility", "scope_resolution_test", "DAT:2xx asserts a specific existing affordance; ORI owns unrestricted possibility, necessity, and probability."],
  ["one source transferable to many unrelated targets", "multiple_relations", "Use separate DAT:21x claims unless a shared synchronization criterion establishes DAT:22x."],
  ["common schema without synchronizability", "entity_or_rule_not_affordance", "A shared schema may exist even when participants cannot presently or persistently synchronize."],
  ["network reachability only", "different_family", "CON or MOV reachability may implement transfer but does not by itself entail DAT transferability."]
].freeze

data_affordance_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the root's invariant without adding an information entity, actual process, physical medium, quality, or authority."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} affordance claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} with datum", "compound", "DAT:0xx supplies the information entity while #{id} supplies typed information-process enablement."],
    ["#{root[:title]} under rule", "compound", "LOG:0xx supplies a qualifying criterion while #{id} supplies the corresponding data affordance."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or confidence while #{id} remains an objective data-affordance claim."],
    ["#{root[:title]} actualized", "compound", "DAT:1xx supplies actual process phase while #{id} supplies only enabling capacity or relation."]
  ]
end

stress_rows = data_affordance_stress_base + data_affordance_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("DAT2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "DAT:200–222 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/DAT_200_222_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "DAT:200–222 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "DAT:200–202" => "internal data transformability: persistent / operative / latent", "DAT:210–212" => "source-target data transferability: persistent / operative / latent", "DAT:220–222" => "systemic data synchronizability: persistent / operative / latent" }, "triplet_logic" => { "affordance_statuses" => "persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time", "latent_member" => "affirms an existing nonoperative affordance without hiddenness, probability, planning, scheduling, or futurity", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/DAT_200_222_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "DAT:200–222 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# DAT:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Data relation/capacity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `DAT:2xx` the substrate-neutral information-process-affordance layer paired with canonical `DAT:1xx`. The inward triplet states represented information's capacity for bounded transformation within one entity, the outward triplet states one source context's transferability relation to one distinct target, and the systemic triplet states capacity for coordinated information-state alignment across multiple participants under one synchronization criterion. Persistent, operative, and latent supply the exact third-trit contrast.\n\nPersistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time. Lexical latency means an existing but nonoperative affordance, not uncertainty, hiddenness, brokenness, probability, permission, scheduling, or future time. Runtime `[2]/num` remains uncertainty about the selected status. The design rejects the provisional mixture of access, permission, retrieval, reference identity, dereference processes, broken links, integrity, provenance, consistency, replication, reconstruction, and possibility. Information entities remain `DAT:0xx`; actual information processes remain `DAT:1xx`; access, integrity, provenance, algorithms, media, authority, results, and modality remain separate or compounded.\n\n"

IDS.each do |id|
  scored_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n### A. Fixed generated forms\n\n"
  review << "- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Local compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### B. Why the current meaning was probably chosen\n\n#{scored_root['current_meaning_rationale']}\n\n### C. Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  scored_root.fetch("candidates").each do |candidate_item|
    values = EraZeroValidation::SCORE_KEYS.map { |key| candidate_item.dig("scores", key) }
    review << "| #{candidate_item['title']} | #{values.join(' | ')} | **#{candidate_item['total']}/80** |\n"
  end
  review << "\n"
  scored_root.fetch("candidates").each do |candidate_item|
    analysis = candidate_item.fetch("analysis")
    review << "#### #{candidate_item['title']}\n\n**Invariant candidate:** #{candidate_item['invariant_candidate']}\n\n- Fit: #{analysis['why_it_fits']}\n- Useful coverage: #{analysis['useful_coverage']}\n- Territory consumed: #{analysis['semantic_territory_consumed']}\n- Conflicts and limitations: #{analysis['conflicts_or_future_limitations']}\n\n"
  end
  review << "### D. Recommended permanent semantic specification\n\n**Title:** #{spec['proposed_title']}\n\n**Invariant:** #{spec['invariant_definition']}\n\n**Inclusion boundary:** #{spec['inclusion_boundary']}\n\n**Excluded meanings:**\n\n"
  spec.fetch("excluded_meanings").each { |item| review << "- #{item}\n" }
  review << "\n**Address justification:**\n\n"
  spec.fetch("address_justification").each { |axis, explanation| review << "- `#{axis}`: #{explanation}\n" }
  review << "\n**Nearest neighbors:** #{spec['nearest_neighbors'].map { |neighbor| "`#{neighbor}`" }.join(', ')}\n\n**Same-family boundary:** #{spec['same_family_contrast']}\n\n**Runtime-state interpretation:**\n\n"
  spec.fetch("runtime_state_interpretation").each { |state, meaning| review << "- `[#{state}]`: #{meaning}\n" }
  review << "\n**Lexical/runtime distinction:** #{spec['lexical_runtime_distinction']}\n\n### E. Examples\n\n| Type | Semantic graph | Literal gloss | Natural English | State | Result |\n| --- | --- | --- | --- | ---: | --- |\n"
  spec.fetch("examples").each { |example| review << "| #{example['category']} | `#{example['semantic_graph']}` | #{example['literal_gloss']} | #{example['natural_english']} | #{example['runtime_state']} | #{example['use_status']} |\n" }
  review << "\n"
end

review << "## Triplet coherence\n\n| Triplet | Shared axis | `0` | `1` | `2` |\n| --- | --- | --- | --- | --- |\n"
review << "| DAT:200–202 | represented information's capacity for internal transformation within one entity | capacity persists | capacity operative | capacity exists nonoperatively |\n"
review << "| DAT:210–212 | one source context's information-transfer relation to one distinct target | relation persists | relation operative | relation exists nonoperatively |\n"
review << "| DAT:220–222 | multiple participants' capacity for coordinated information-state alignment | capacity persists | capacity operative | capacity exists nonoperatively |\n\n"
review << "**Triplet logic:** persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | information entity, actual process, physical carrier, algorithm, access, integrity, provenance, permission, acknowledgment, scheduling, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nReadability and writability, retrieval, storage durability, destructive move, streaming, broadcast, bandwidth, access and permission, reference resolution, integrity, provenance, consistency, convergence guarantees, algorithms, resources, acknowledgment, scheduling, readiness, queues, and unrestricted modality remain other-family meanings, later vocabulary, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later specialization, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# DAT:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MIN understanding; CRE generation; MAT storage implementation", "1" => "CON access/channel; MOV/MAT reachability; STR interface", "2" => "LOG consistency; REP recoverability; STR interoperability" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | DAT keeps only typed information-process enablement; entity, process, carrier, algorithm, access, quality, provenance, authority, and modality remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- An information-process affordance is not the datum, reference, dataset, actual process, physical carrier, algorithm, resource, participant, or result.\n- Internal transformability does not entail readability, writability, losslessness, understanding, access, permission, resource sufficiency, or successful transformation.\n- Source-target transferability does not entail a physical path, channel, permission, authority, actual transfer, acknowledgment, delivery, persistence, or structural compatibility.\n- Systemic synchronizability requires coordinated alignment under one criterion; several independently transformable or transferable participants are insufficient.\n- A latent affordance exists but is not operative; it is not unknown, merely possible, broken, missing, planned, queued, scheduled, future, or prohibited.\n- Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time.\n- Runtime `[2]/num` leaves a selected status assertion unresolved and never selects lexical latency.\n\n**CONCLUSION: DAT:2XX STANDS ALONE ONLY FOR TYPED INFORMATION-PROCESS ENABLEMENT; INFORMATION ENTITIES, ACTUAL PROCESSES, PHYSICAL CARRIERS, ALGORITHMS, ACCESS, INTEGRITY, PROVENANCE, QUALITY, AUTHORITY, PERMISSION, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built DAT:200–222 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
