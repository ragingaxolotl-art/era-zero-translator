#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "DAT:100–122"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "DAT_100_122"
SEMANTIC_CENTER = "information-state processes: internal data transformation, target data transfer, and systemic data synchronization"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "DAT:100" => ["local encoding complete", "An inward process of reading, decoding, recording, or reformatting data has reached a stable result."],
  "DAT:101" => ["read or decode", "An entity is actively inspecting, parsing, decoding, or updating its local information."],
  "DAT:102" => ["pending read", "An inward data operation is requested or possible but has not begun or is waiting for access."],
  "DAT:110" => ["data transfer complete", "Writing, copying, retrieving, or transmitting information to a target has finished successfully."],
  "DAT:111" => ["write or transmit", "Information is actively being written, copied, sent, retrieved, or assigned to a target."],
  "DAT:112" => ["queued output", "A data transfer or write to a target is prepared but not yet executing."],
  "DAT:120" => ["synchronization complete", "A shared data indexing, aggregation, replication, or synchronization cycle has reached a stable result."],
  "DAT:121" => ["system data processing", "Information is actively being aggregated, indexed, synchronized, or replicated across a system."],
  "DAT:122" => ["pending synchronization", "A system-wide data operation is scheduled or waiting for prerequisites."]
}.freeze

ROOTS = {
  "DAT:100" => { title: "completed internal data transformation", phase: "completed", scope: "inward", kind: "internal data transformation", invariant: "Completion of a bounded transformation of represented information within one reference entity, yielding transformed information without transferring it to a distinct target." },
  "DAT:101" => { title: "active internal data transformation", phase: "active", scope: "inward", kind: "internal data transformation", invariant: "An ongoing bounded transformation of represented information within one reference entity that is producing transformed information without transferring it to a distinct target." },
  "DAT:102" => { title: "nonactualized internal data transformation", phase: "nonactualized", scope: "inward", kind: "internal data transformation", invariant: "A nonactualized bounded transformation that would transform represented information within one reference entity without transferring it to a distinct target." },
  "DAT:110" => { title: "completed target data transfer", phase: "completed", scope: "outward", kind: "target data transfer", invariant: "Completion of a bounded information transfer from one source context to one distinct reference target, causing that target to receive the transferred information." },
  "DAT:111" => { title: "active target data transfer", phase: "active", scope: "outward", kind: "target data transfer", invariant: "An ongoing bounded information transfer from one source context to one distinct reference target that is causing that target to receive the transferred information." },
  "DAT:112" => { title: "nonactualized target data transfer", phase: "nonactualized", scope: "outward", kind: "target data transfer", invariant: "A nonactualized bounded information transfer that would carry information from one source context to one distinct reference target." },
  "DAT:120" => { title: "completed systemic data synchronization", phase: "completed", scope: "systemic", kind: "systemic data synchronization", invariant: "Completion of a coordinated information-state alignment across multiple participants in one shared data domain under one synchronization criterion." },
  "DAT:121" => { title: "active systemic data synchronization", phase: "active", scope: "systemic", kind: "systemic data synchronization", invariant: "An ongoing coordinated information-state alignment across multiple participants in one shared data domain under one synchronization criterion." },
  "DAT:122" => { title: "nonactualized systemic data synchronization", phase: "nonactualized", scope: "systemic", kind: "systemic data synchronization", invariant: "A nonactualized coordinated process that would align information states across multiple participants in one shared data domain under one synchronization criterion." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [6, 8, 9, 5, 6, 8, 8, 9] },
  "information_state_processes" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "interpretation_and_encoding_processes" => { scores: [9, 8, 10, 7, 8, 9, 8, 10] },
  "storage_io_processes" => { scores: [8, 8, 9, 7, 7, 9, 9, 10] },
  "communication_and_replication_processes" => { scores: [8, 7, 7, 6, 5, 9, 9, 9] }
}.freeze

ALT_TITLES = {
  "DAT:100" => ["completed internal interpretation", "completed internal storage operation", "completed internal message processing"],
  "DAT:101" => ["active internal interpretation", "active internal storage operation", "active internal message processing"],
  "DAT:102" => ["nonactualized internal interpretation", "nonactualized internal storage operation", "nonactualized internal message processing"],
  "DAT:110" => ["completed target encoding", "completed target write operation", "completed target communication"],
  "DAT:111" => ["active target encoding", "active target write operation", "active target communication"],
  "DAT:112" => ["nonactualized target encoding", "nonactualized target write operation", "nonactualized target communication"],
  "DAT:120" => ["completed systemic interpretation", "completed distributed storage operation", "completed systemic replication"],
  "DAT:121" => ["active systemic interpretation", "active distributed storage operation", "active systemic replication"],
  "DAT:122" => ["nonactualized systemic interpretation", "nonactualized distributed storage operation", "nonactualized systemic replication"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological conditions, agents, and social collectives. A living agent may transform, transfer, or synchronize information, but DAT:1xx does not encode the agent's life, role, health, or agency.",
  "MOV" => "MOV owns spatial position, path, displacement, and movement. Information transfer may accompany motion of a physical carrier, but DAT:1xx changes information location or state rather than asserting spatial displacement.",
  "MAT" => "MAT owns substance, energy, force, contact, and material change. A physical signal or storage medium may realize a DAT process, but DAT:1xx does not encode the material carrier, energy transfer, or physical mechanism.",
  "MIN" => "MIN owns mental state, attention, belief, interpretation as cognition, and cognitive change. DAT transformation may encode or decode represented information, but it does not assert understanding, belief revision, awareness, or attention.",
  "CON" => "CON owns participant linkage, communication acts, interaction, and social exchange. Target data transfer can be a component of communication, but it does not entail a sender's communicative intent, an addressee role, uptake, dialogue, or social relation.",
  "WRN" => "WRN owns hazards, faults, warnings, and adverse states. Corrupt, missing, delayed, or inconsistent data may ground a warning, but DAT:1xx does not itself assert error, danger, failure, or harm.",
  "STR" => "STR owns arrangements, boundaries, component relations, and structural transitions. A data schema or topology may constrain a DAT process, but the process does not itself assert structural membership, containment, reconfiguration, or boundary crossing.",
  "REP" => "REP owns restoration conditions, restorative processes, and restorative affordances. Restoring a dataset may use transfer or synchronization, but DAT:1xx does not entail recovery, return to a prior acceptable state, or repair success.",
  "LOG" => "LOG owns formal constraints, evaluations, and evaluation affordances. A DAT process may supply inputs or record outputs for a LOG evaluation, but it does not itself judge admissibility, truth, consistency, or validity.",
  "CRE" => "CRE owns coming-into-being, productive transformation, and generation. DAT:100–102 transforms an existing information representation; asserting creation of a new artifact or novel content requires CRE or a compound.",
  "ORI" => "ORI owns temporal, modal, causal, and ontological orientation. Scheduling, intention, possibility, necessity, future placement, and causal explanation of a DAT process require ORI or compounds; lexical nonactualization encodes none of them."
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
  when "information_state_processes"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "interpretation_and_encoding_processes"
    values[1] -= 1 if second == "1"
    values[3] -= 1 if third == "2"
  when "storage_io_processes"
    values[2] -= 1 if second == "2"
    values[5] -= 1 if second == "0"
  when "communication_and_replication_processes"
    values[2] -= 2 if second != "2"
    values[4] -= 2 if second == "1"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional meanings use familiar data-operation vocabulary and approximately follow the #{root.fetch(:scope)} and #{root.fetch(:phase)} slot labels.",
      "useful_coverage" => "They cover reading, decoding, recording, writing, copying, transmitting, aggregating, indexing, replicating, and synchronizing.",
      "semantic_territory_consumed" => "Across the block they mix interpretation, transformation, storage I/O, transfer, retrieval, assignment, aggregation, replication, scheduling, access, and successful outcome.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one process center, and several roots collapse process phase with success, queue state, access conditions, or mutually different operations."
    }
  when "information_state_processes"
    {
      "why_it_fits" => "The first trit selects an information-state process; the second changes only its scope—transformation retained within one entity, transfer to one distinct target, or coordinated alignment across multiple participants; the third changes only completed, active, or nonactualized phase.",
      "useful_coverage" => "It supports encode, decode, parse, serialize, compress, update, copy, send, write, load, replicate, reconcile, synchronize, and distributed convergence through roots or transparent compounds.",
      "semantic_territory_consumed" => "Only transformation, target transfer, or systemic alignment of represented information. Information entities, physical media, communication roles, cognitive interpretation, results, scheduler states, and modality remain separate.",
      "conflicts_or_future_limitations" => "Specific algorithms, destructive versus nondestructive transfer, fidelity, acknowledgment, and conflict-resolution policy require compounds or later specialization rather than broadening the atoms."
    }
  when "interpretation_and_encoding_processes"
    {
      "why_it_fits" => "Encoding and interpretation are central information operations and can occur within one entity, toward a target representation, or across a shared code system.",
      "useful_coverage" => "It would cover encode, decode, parse, interpret, translate representations, serialize, and deserialize.",
      "semantic_territory_consumed" => "It specializes the entire process layer to changes of representation or interpretation conventions.",
      "conflicts_or_future_limitations" => "Direct copying, storage writes, retrieval, and synchronization may preserve representation; cognitive interpretation also collides with MIN and linguistic translation may require CON or later grammar."
    }
  when "storage_io_processes"
    {
      "why_it_fits" => "Read, write, store, load, retrieve, and replicate naturally form completed, active, and nonactualized data operations.",
      "useful_coverage" => "It would cover local reads, cache operations, database writes, retrieval, persistence, distributed storage, and replication.",
      "semantic_territory_consumed" => "It ties the abstract Data process layer to storage-system direction conventions and persistence mechanics.",
      "conflicts_or_future_limitations" => "Inward is not inherently read, outward is not inherently write, and systemic processing is not always storage; the model also collides with MAT media and STR containment."
    }
  when "communication_and_replication_processes"
    {
      "why_it_fits" => "Information commonly moves from a source to a recipient and is replicated among distributed participants.",
      "useful_coverage" => "It would cover send, receive, publish, broadcast, relay, replicate, disseminate, and communicate.",
      "semantic_territory_consumed" => "It makes participant exchange or replication the default center even for inward operations.",
      "conflicts_or_future_limitations" => "Communication requires participant roles, intent, or social linkage owned by CON; replication is only one systemic alignment method and gives the inward triplet no coherent counterpart."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "interpretation_and_encoding_processes"
    "A #{root.fetch(:phase)} interpretation or encoding operation performed at #{root.fetch(:scope)} information scope."
  when "storage_io_processes"
    "A #{root.fetch(:phase)} storage input/output operation performed at #{root.fetch(:scope)} information scope."
  when "communication_and_replication_processes"
    "A #{root.fetch(:phase)} communication or replication operation performed at #{root.fetch(:scope)} information scope."
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
  affordance = "DAT:2#{second}#{third}"
  (siblings + scopes + [entity, affordance]).uniq
end

def roles
  {
    "low" => "reference entity, source context, or participating information state",
    "middle" => "information-state process as the asserted figure",
    "high" => "represented input, distinct target, or synchronization criterion",
    "sustained" => "shared data domain and multiple participants coordinated together"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} completed; it does not assert that the active sibling is still running, that the nonactualized sibling holds, or that the result had either polarity.",
      "1" => "Affirms completion of this #{root.fetch(:kind)}, without asserting success quality, fidelity, persistence, acknowledgment, physical transport, communication uptake, or later availability.",
      "2/num" => "Leaves unresolved whether this completed #{root.fetch(:kind)} claim holds; runtime uncertainty does not change the lexical root into active or nonactualized phase."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is currently ongoing; it does not itself affirm completion, nonactualization, suspension, failure, absence of data, or lack of capability.",
      "1" => "Affirms that this #{root.fetch(:kind)} is currently occurring, without asserting eventual completion, fidelity, correctness, duration, acknowledgment, persistence, or side effects.",
      "2/num" => "Leaves unresolved whether this active #{root.fetch(:kind)} claim holds; runtime uncertainty does not select the completed or nonactualized lexical sibling."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} is nonactualized; it does not by itself affirm completion, current activity, scheduling, permission, impossibility, or any result.",
      "1" => "Affirms a specifically typed #{root.fetch(:kind)} that is not actualized, without encoding intention, planning, readiness, queueing, future time, probability, or missing inputs.",
      "2/num" => "Leaves unresolved whether the selected nonactualized #{root.fetch(:kind)} claim holds; lexical third-trit 2 names process nonactualization, while runtime `[2]/num` marks assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "device" : id[-2] == "1" ? "recipient" : "network"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},INPUT=d,OUTPUT=d′" : id[-2] == "1" ? "SOURCE=s,TARGET=#{entity},DATA=d" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},CRITERION=c"
  ordinary = {
    "0" => "The #{root.fetch(:kind)} finished.",
    "1" => "The #{root.fetch(:kind)} is underway now.",
    "2" => "The typed #{root.fetch(:kind)} is not actualized."
  }.fetch(id[-1])
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts information-process phase, not quality, success, acknowledgment, or scheduling."],
    ["physical_or_spatial", "MAT(BEARER=m)+#{id}[1](#{graph_roles})", "material bearer plus #{root.fetch(:phase)} information process", "A physical medium realizes the information process while MAT separately describes its material motion or change.", "Information change and physical mechanism remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} information process during interval w", "During interval w, the information process has the stated lexical phase.", "ORI supplies time and does not replace process phase."],
    ["cross_family_compound", "DAT:001[1](DATA=d)+#{id}[1](#{graph_roles})+CON(CHANNEL=h)", "manifest datum plus #{root.fetch(:phase)} information process plus communication channel", "The datum and data process remain DAT while CON supplies any participant channel or communicative act.", "Entity, process, and communication roles remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} information-state process", "A runtime tracks the data-operation phase without folding in scheduler state, storage medium, or success quality.", "Process phase, resources, and results remain distinct."],
    ["counterexample", "DAT:001[1](DATA=d)", "manifest datum entity", "The datum is manifest, but no transformation, transfer, or synchronization is occurring.", "A manifest DAT:0xx entity does not entail a DAT:1xx process."]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(data_process.phase == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "information_state_processes", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "interpretation_and_encoding_processes", alt[0], alternative_invariant(id, "interpretation_and_encoding_processes")),
    candidate(id, "storage_io_processes", alt[1], alternative_invariant(id, "storage_io_processes")),
    candidate(id, "communication_and_replication_processes", alt[2], alternative_invariant(id, "communication_and_replication_processes"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "information_state_processes",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one information-state process layer, follows inward/target/systemic scope exactly, and gives every triplet one completed/active/nonactualized axis while reserving information entities, physical carriers, communication roles, cognitive interpretation, scheduler states, success quality, and affordances for DAT:0xx, DAT:2xx, or other families.",
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
  state_label = { "0" => "completed", "1" => "active/ongoing", "2" => "nonactualized" }.fetch(third)
  scope_explanation = {
    "0" => "represented information transformed while retained within one reference entity",
    "1" => "bounded information transferred from one source context to one distinct reference target",
    "2" => "information states aligned across multiple participants under one shared synchronization criterion"
  }.fetch(second)
  scope_boundary = {
    "0" => "The process transforms represented information within one entity and does not require a distinct target. The algorithm, input entity, output entity, and physical realization remain separate.",
    "1" => "The process preserves one source context and one distinct target. It is neutral about copying versus moving, medium, acknowledgment, communicative intent, and later persistence.",
    "2" => "The process requires coordinated alignment across multiple participants under one criterion. Independent transfers or coincident local transformations do not constitute one systemic synchronization."
  }.fetch(second)
  triplet_logic = "Completed, active, and nonactualized are mutually exclusive phases for the same bounded information process at one reference time. Lexical nonactualization states only that the typed process is not actualized; runtime `[2]/num` separately marks uncertainty about any selected phase."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_1" => "Selects an information-state process rather than an information entity, physical carrier, participant interaction, cognitive act, or information-process affordance.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Data-family column.",
      "third_trit" => "Selects the #{state_label} phase of the same information process while leaving runtime truth status, quality, fidelity, acknowledgment, observer knowledge, tense, probability, and scheduling separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral process affecting represented information at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about physical medium, participant intent, semantic truth, success quality, persistence, access, observation, scheduling, probability, timing, and cause.",
    "excluded_meanings" => [
      "The datum, target reference, or shared dataset as an entity, and its persistent, manifest, or dormant status.",
      "The specific encoding, schema, algorithm, checksum, fidelity, consistency result, conflict policy, acknowledgment, or success criterion.",
      "Physical signal, medium, energy, spatial displacement, storage device, or material change realizing the information process.",
      "Communicative intent, sender or addressee role, message uptake, dialogue, social linkage, belief, understanding, attention, or observation.",
      "Creation of novel content, restoration to an acceptable prior state, structural reconfiguration, warning, fault, authority, or ownership.",
      "Capability, access, permission, intention, plan, readiness, queue, schedule, future time, possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` owns only transformations, target transfers, and systemic synchronizations of represented information. `DAT:2xx` remains reserved for information-process affordances or relations. A manifest datum does not entail a process, and a completed process does not entail persistence, fidelity, acknowledgment, or future accessibility. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} phase of this information process. Runtime `[2]/num` instead leaves the already-selected phase claim unresolved; it never changes process phase. Thus a nonactualized root affirmed with `[1]` is a confirmed typed-but-nonactualized data process, while a completed or active root carrying `[2]/num` remains lexically completed or active but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + DAT:0xx supplies the input datum, target reference, or shared dataset without reducing the process to its information entity.",
      "#{id} + MAT/MOV supplies a physical carrier and its displacement while keeping information change distinct from material motion.",
      "#{id} + CON/MIN/LOG supplies communication, cognitive interpretation, or formal evaluation when those meanings are independently asserted.",
      "#{id} + DAT:2xx may later express transformability, transferability, synchronizability, accessibility, or another information-process affordance."
    ],
    "later_era_notes" => "Later eras may lexicalize specific codecs, parsing, serialization, compression, destructive move versus copying, broadcast, streaming, replication strategies, merge policy, conflict resolution, acknowledgment, and integrity verification. Era Zero should preserve the substrate-neutral information-state process centers and derive algorithms, media, participant roles, quality, and scheduler details compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


data_process_stress_base = [
  ["transform data", "one_root", "Use DAT:100–102 when represented information changes while remaining within one reference entity."],
  ["encode", "one_root_or_compound", "Encoding is an internal data transformation when the representation changes locally; the specific code system remains a compound or later specialization."],
  ["decode", "one_root_or_compound", "Decoding is an internal transformation of represented information and does not entail human understanding."],
  ["parse", "one_root_or_compound", "Parsing can use DAT:100–102 for representation transformation; the grammar or formal criterion remains LOG or later vocabulary."],
  ["serialize", "one_root_or_compound", "Serialization is an internal data transformation whose output format is separately represented."],
  ["deserialize", "one_root_or_compound", "Deserialization is an internal data transformation and does not entail storage access or semantic comprehension."],
  ["compress", "one_root_or_compound", "Compression is an internal data transformation; size relation and algorithm remain separate."],
  ["decompress", "one_root_or_compound", "Decompression is an internal data transformation; fidelity is not asserted by completion alone."],
  ["encrypt", "compound_or_later_specialization", "Encryption combines internal data transformation with a key and security purpose; neither is built into DAT:10x."],
  ["decrypt", "compound_or_later_specialization", "Decryption is a keyed internal data transformation and does not entail authorization or successful comprehension."],
  ["update a local record", "one_root_or_compound", "Use DAT:100–102 when the represented content changes locally; the record entity is DAT:0xx."],
  ["calculate a value", "compound", "DAT may transform represented values, while LOG supplies formal evaluation and the operation specification remains separate."],
  ["read", "ambiguous_compound", "A storage read may combine DAT entity access with target transfer or internal transformation; the English word is not forced into one atom."],
  ["inspect data", "different_family_or_compound", "Observation and attention belong to MIN; DAT supplies only the information entity or transformation involved."],
  ["understand", "different_family", "Understanding is cognitive and belongs to MIN even when decoding data is a prerequisite."],
  ["create a new message", "compound", "CRE supplies coming-into-being and DAT supplies the information object or its transformation."],
  ["copy to a target", "one_root", "DAT:110–112 owns bounded information transfer to one distinct target and is neutral about whether the source retains a copy."],
  ["send data", "one_root_or_compound", "DAT:110–112 supplies target transfer; CON is added when a participant communication act or channel is asserted."],
  ["write to storage", "one_root_or_compound", "Target data transfer can model the information arriving at a distinct storage target; MAT or STR supplies the medium or containment."],
  ["load into memory", "one_root_or_compound", "Target data transfer can model information arriving in a distinct target context; memory hardware and access remain separate."],
  ["retrieve", "ambiguous_compound", "Retrieval may be target transfer from storage, but search, access, and source selection are separate meanings."],
  ["download", "compound", "DAT target transfer combines with CON channel and often MOV/MAT carrier realization; direction is resolved by graph roles."],
  ["upload", "compound", "DAT target transfer supplies information arrival at the target while network roles and direction conventions remain external."],
  ["stream", "compound_or_later_specialization", "Streaming is temporally extended target transfer and needs ORI contour or later specialization."],
  ["broadcast", "compound_or_later_specialization", "Broadcast requires one-to-many communication structure; one DAT:11x target transfer alone does not encode it."],
  ["relay", "compound", "Relay combines successive DAT transfers with CON or STR path structure."],
  ["move a file", "compound", "DAT target transfer does not entail deletion at the source; destructive move needs an explicit source-removal or structural compound."],
  ["receive", "role-relative_compound", "The same target transfer can be viewed from the target, but participant receipt or acknowledgment may require CON."],
  ["deliver a message", "compound", "DAT supplies information transfer; CON supplies communicative roles and uptake; completion does not entail comprehension."],
  ["acknowledge receipt", "different_family_or_compound", "Acknowledgment is a communicative response in CON, not part of DAT transfer completion."],
  ["synchronize replicas", "one_root", "DAT:120–122 owns coordinated information-state alignment across multiple participants under one criterion."],
  ["reconcile records", "one_root_or_compound", "Systemic synchronization covers coordinated alignment; comparison policy and conflict resolution require LOG and later specialization."],
  ["replicate data", "one_root_or_compound", "Replication can realize systemic synchronization, but DAT:12x does not require a particular leader, topology, or copy algorithm."],
  ["merge concurrent edits", "compound_or_later_specialization", "Merge combines systemic synchronization with a conflict-resolution rule; the rule and result remain separate."],
  ["reach eventual consistency", "compound", "DAT:120 may assert completed alignment at a reference point; eventuality and the consistency criterion require ORI and LOG."],
  ["index records", "compound_or_later_specialization", "Indexing is a structural or representational transformation, not inherently systemic synchronization."],
  ["aggregate records", "compound_or_later_specialization", "Aggregation may transform many data items into one; plurality alone does not make it synchronization."],
  ["sort", "compound_or_later_specialization", "Sorting is a representation transformation under an ordering rule, requiring DAT plus LOG."],
  ["deduplicate", "compound_or_later_specialization", "Deduplication is an internal or systemic transformation under identity criteria, not the generic synchronization atom."],
  ["cache coherence", "compound", "Systemic synchronization supplies alignment; cache structure and coherence rule remain STR and LOG."],
  ["database transaction", "compound_or_later_specialization", "A transaction may include transformations, transfers, constraints, and synchronization and should not be one DAT atom."],
  ["completed internal data transformation", "one_root", "DAT:100 states completion of a bounded local information transformation without asserting fidelity or success quality."],
  ["active internal data transformation", "one_root", "DAT:101 states that the bounded local information transformation is ongoing."],
  ["nonactualized internal data transformation", "one_root", "DAT:102 states a typed local transformation that is not actualized without implying plan or queue."],
  ["completed target data transfer", "one_root", "DAT:110 states completion of one bounded transfer to one distinct target without asserting acknowledgment."],
  ["active target data transfer", "one_root", "DAT:111 states that one bounded transfer toward one distinct target is ongoing."],
  ["nonactualized target data transfer", "one_root", "DAT:112 states a typed target transfer that is not actualized."],
  ["completed systemic data synchronization", "one_root", "DAT:120 states completion of coordinated alignment across multiple participants under one criterion."],
  ["active systemic data synchronization", "one_root", "DAT:121 states that coordinated multi-participant alignment is ongoing."],
  ["nonactualized systemic data synchronization", "one_root", "DAT:122 states a typed systemic synchronization that is not actualized."],
  ["datum exists", "different_layer", "DAT:0xx owns the information entity; entity existence does not entail a DAT:1xx process."],
  ["datum is manifest", "different_layer", "DAT:001/011/021 owns manifestation; a manifest datum need not be transforming or moving."],
  ["data process is possible", "future_affordance_or_modality", "DAT:2xx or ORI modality must express capability or possibility; DAT:1x2 only states nonactualization."],
  ["data process scheduled", "compound", "ORI and a schedule record supply scheduling; lexical third trit 2 encodes no future time."],
  ["data process queued", "compound", "DAT and ORI may represent a queue; DAT:102/112/122 do not encode readiness or ordering."],
  ["data process uncertain", "runtime", "Use runtime `[2]/num` on the selected phase root rather than substituting lexical nonactualization."],
  ["completed data process uncertain", "runtime_and_lexical", "DAT:100/110/120[2]/num remains lexically completed while the token claim is uncertain."],
  ["nonactualized data process affirmed", "runtime_and_lexical", "DAT:102/112/122[1] affirms a typed-but-nonactualized process."],
  ["active data process denied", "runtime_and_lexical", "Runtime `[0]` denies the active claim without automatically selecting completion or nonactualization."],
  ["completed and active simultaneously", "phase_contradiction", "The same bounded data process cannot be completed and active at one reference time."],
  ["active and nonactualized simultaneously", "phase_contradiction", "The same bounded data process cannot be both ongoing and nonactualized at one reference time."],
  ["completed and nonactualized simultaneously", "phase_contradiction", "The same bounded data process cannot be both completed and nonactualized at one reference time."],
  ["many independent transfers", "multiple_roots_not_one_systemic_root", "Separate transfers do not form one DAT:12x synchronization unless coordinated under one shared alignment criterion."],
  ["one transfer to many unrelated targets", "compound_or_multiple_roots", "Plural targets alone do not establish systemic synchronization or shared-state alignment."],
  ["data transformation versus creation", "scope_resolution_test", "DAT:10x changes represented information; CRE supplies coming-into-being or productive generation when independently asserted."],
  ["data transfer versus motion", "scope_resolution_test", "DAT:11x transfers information; MOV and MAT supply spatial displacement and physical carriers."],
  ["data transfer versus communication", "scope_resolution_test", "DAT supplies information-state arrival while CON supplies participant exchange, intent, channel, or uptake."],
  ["synchronization versus restoration", "scope_resolution_test", "DAT:12x aligns information states; REP supplies return to an acceptable prior condition."],
  ["synchronization versus structural reconfiguration", "scope_resolution_test", "DAT aligns represented states while STR changes component arrangement or membership."],
  ["data process versus time", "scope_resolution_test", "Completed, active, and nonactualized are lexical phases; ORI supplies past, future, duration, deadline, and schedule."]
].freeze

data_process_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the root's invariant without adding a physical carrier, scheduler state, quality judgment, or participant intent."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} with datum", "compound", "DAT:0xx supplies the information entity while #{id} supplies process phase."],
    ["#{root[:title]} under criterion", "compound", "LOG:0xx supplies an encoding, transfer, or synchronization criterion while #{id} supplies the data process."],
    ["#{root[:title]} observed", "compound", "MIN supplies observation or confidence while #{id} remains an information-process claim."],
    ["#{root[:title]} physically realized", "compound", "MAT or MOV supplies the physical mechanism or carrier motion while #{id} supplies only information-state process."],
    ["#{root[:title]} communicated", "compound", "CON supplies participant roles, channel, or uptake while #{id} supplies the information transformation or transfer."]
  ]
end

stress_rows = data_process_stress_base + data_process_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("DAT1-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "DAT:100–122 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/DAT_100_122_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "DAT:100–122 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "DAT:100–102" => "internal data transformation: completed / active / nonactualized", "DAT:110–112" => "target data transfer: completed / active / nonactualized", "DAT:120–122" => "systemic data synchronization: completed / active / nonactualized" }, "triplet_logic" => { "process_phases" => "completed, active, and nonactualized are mutually exclusive for the same bounded information process at one reference time", "nonactualized_member" => "states typed process nonactualization without planning, scheduling, readiness, futurity, or probability", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/DAT_100_122_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "DAT:100–122 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# DAT:100–122 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Data process meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `DAT:1xx` the substrate-neutral process layer for represented information. The inward triplet transforms information while it remains within one reference entity, the outward triplet transfers bounded information from one source context to one distinct target, and the systemic triplet coordinates information-state alignment across multiple participants under one shared synchronization criterion. Completed, active, and nonactualized supply the exact third-trit contrast.\n\nThe three phases are mutually exclusive for the same bounded information process at one reference time. Lexical `1x2` means only that the typed process is not actualized; intention, planning, readiness, queueing, scheduling, future time, probability, and missing access remain separate. Runtime `[2]/num` remains uncertainty about the selected phase. The design rejects the provisional mixture of reads, writes, retrieval, assignment, aggregation, indexing, replication, successful outcome, access state, scheduling, and readiness. Information entities remain `DAT:0xx`; information-process affordances remain `DAT:2xx`; physical carriers, communication roles, cognition, formal evaluation, and creation remain other families.\n\n"

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
review << "| DAT:100–102 | represented information transformed within one entity | transformation completed | transformation ongoing | typed transformation not actualized |\n"
review << "| DAT:110–112 | bounded information transferred to one distinct target | transfer completed | transfer ongoing | typed transfer not actualized |\n"
review << "| DAT:120–122 | multiple participant information states aligned under one criterion | synchronization completed | synchronization ongoing | typed synchronization not actualized |\n\n"
review << "**Triplet logic:** completed, active, and nonactualized are mutually exclusive for the same bounded information process at one reference time. Completion does not entail fidelity, acknowledgment, persistence, or positive evaluation.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | information entity identity, physical carrier, storage medium, communication roles, cognition, success quality, algorithms, acknowledgment, scheduling, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nSpecific codecs and algorithms, storage access, destructive move, streaming, broadcast, message acknowledgment, communicative intent, human understanding, novel-content creation, restoration, integrity and consistency results, merge policy, physical carriers, scheduling, readiness, queues, security, ownership, and modality remain other-family meanings, later DAT specializations, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later DAT layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# DAT:100–122 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MIN interpretation; LOG computation; CRE generation", "1" => "CON communication; MOV/MAT carrier transfer; STR write destination", "2" => "REP restoration; STR reconfiguration; LOG consistency; CON coordination" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | DAT keeps only represented-information transformation, target transfer, or systemic alignment; entities, carriers, participant roles, cognition, results, algorithms, and side effects remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- An information process is not the datum, target reference, shared dataset, physical carrier, implementation algorithm, participant, or quality judgment.\n- A completed transformation, transfer, or synchronization does not entail fidelity, truth, validity, persistence, storage, acknowledgment, access, recognition, or success under an external criterion.\n- A nonactualized information process is typed but not actualized; it is not planned, intended, ready, queued, scheduled, future, impossible, or uncertain.\n- Inward transformation keeps represented information within one reference entity. Target transfer preserves one source context and one distinct target. Systemic synchronization coordinates multiple participants under one alignment criterion.\n- Several unrelated transfers or local transformations do not become one systemic synchronization merely because they occur simultaneously.\n- Completed, active, and nonactualized are mutually exclusive phases for the same bounded information process at one reference time.\n- Runtime `[2]/num` leaves a selected phase assertion unresolved and never selects lexical nonactualization.\n\n**CONCLUSION: DAT:1XX STANDS ALONE ONLY FOR REPRESENTED-INFORMATION TRANSFORMATION, TARGET TRANSFER, AND SYSTEMIC ALIGNMENT; INFORMATION ENTITIES, PHYSICAL CARRIERS, COMMUNICATION ROLES, COGNITION, FORMAL EVALUATION, CREATION, RESTORATION, ALGORITHMS, QUALITY, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built DAT:100–122 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
