#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "REP:100–122"
STEM = "REP_100_122"
IDS = EraZeroValidation.ids_for_range(RANGE)
SEMANTIC_CENTER = "substrate-neutral restorative transformation: internal restoration, source-to-target restoration, and coordinated systemic restoration"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "REP:100" => ["self-repair complete", "An entity has completed an inward process of healing, correction, recalibration, or restoration."],
  "REP:101" => ["active self-repair", "An entity is actively healing, correcting, or rebuilding its own function."],
  "REP:102" => ["queued self-repair", "An inward recovery process is possible or scheduled but has not begun."],
  "REP:110" => ["target repair complete", "Repair, healing, correction, or restoration applied to an external target has finished."],
  "REP:111" => ["active target repair", "A target is actively being healed, corrected, restored, or recalibrated."],
  "REP:112" => ["scheduled target repair", "A repair operation for a target is prepared but not yet executing."],
  "REP:120" => ["system recovery complete", "A coordinated recovery or maintenance cycle has restored stable function across a system."],
  "REP:121" => ["coordinated restoration", "Participants are actively repairing, healing, restoring, or maintaining a shared system."],
  "REP:122" => ["staged system recovery", "A system-level restoration plan and resources are prepared but have not been activated."]
}.freeze

ROOTS = {
  "REP:100" => ["completed internal restoration", "Completion of a restorative transformation originating within one reference entity by which that entity enters its applicable internal restoration condition."],
  "REP:101" => ["active internal restoration", "An ongoing restorative transformation originating within one reference entity by which that entity is entering its applicable internal restoration condition."],
  "REP:102" => ["nonactualized internal restoration", "A nonactualized restorative transformation originating within one reference entity by which that entity would enter its applicable internal restoration condition."],
  "REP:110" => ["completed target restoration", "Completion of a restorative transformation by which one distinct source causes one reference target to enter its applicable target restoration condition."],
  "REP:111" => ["active target restoration", "An ongoing restorative transformation by which one distinct source causes one reference target to enter its applicable target restoration condition."],
  "REP:112" => ["nonactualized target restoration", "A nonactualized restorative transformation by which one distinct source would cause one reference target to enter its applicable target restoration condition."],
  "REP:120" => ["completed systemic restoration", "Completion of a coordinated restorative transformation by which one shared restoration condition becomes realized across multiple participant entities within one shared system."],
  "REP:121" => ["active systemic restoration", "An ongoing coordinated restorative transformation by which one shared restoration condition is becoming realized across multiple participant entities within one shared system."],
  "REP:122" => ["nonactualized systemic restoration", "A nonactualized coordinated restorative transformation by which one shared restoration condition would become realized across multiple participant entities within one shared system."]
}.freeze

SCORE_PROFILES = {
  "current_phase2" => [6, 7, 8, 5, 4, 7, 8, 8],
  "restorative_transformation" => [10, 10, 10, 10, 9, 10, 10, 10],
  "maintenance_action" => [8, 8, 9, 7, 7, 9, 10, 8],
  "corrective_validation" => [8, 8, 6, 8, 4, 9, 8, 10],
  "replacement_reconstruction" => [8, 8, 7, 7, 5, 9, 9, 9]
}.freeze

ALT_TITLES = {
  "REP:100" => ["completed internal maintenance", "completed internal revalidation", "completed internal reconstruction"],
  "REP:101" => ["active internal maintenance", "active internal revalidation", "active internal reconstruction"],
  "REP:102" => ["nonactualized internal maintenance", "nonactualized internal revalidation", "nonactualized internal reconstruction"],
  "REP:110" => ["completed target maintenance", "completed target correction check", "completed target replacement"],
  "REP:111" => ["active target maintenance", "active target correction check", "active target replacement"],
  "REP:112" => ["nonactualized target maintenance", "nonactualized target correction check", "nonactualized target replacement"],
  "REP:120" => ["completed systemic maintenance", "completed systemic revalidation", "completed systemic reconstruction"],
  "REP:121" => ["active systemic maintenance", "active systemic revalidation", "active systemic reconstruction"],
  "REP:122" => ["nonactualized systemic maintenance", "nonactualized systemic revalidation", "nonactualized systemic reconstruction"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, physiology, health, injury, illness, and care roles. REP can classify healing as restoration, but it does not define the biological mechanism or the living bearer.",
  "MOV" => "MOV owns location, displacement, approach, traversal, and return. Moving something back can serve restoration, but REP names transformation toward an applicable restoration condition rather than the path traveled.",
  "MAT" => "MAT owns substance, force, energy, fracture, contact, shape, and physical change. REP abstracts restorative direction and scope; material repair mechanics remain separately asserted.",
  "MIN" => "MIN owns perception, attention, belief, memory, intention, satisfaction, and recognition. Restoration can occur without awareness, and believing something repaired does not perform the transformation.",
  "CON" => "CON owns care communication, service requests, coordination, and participant exchange. Coordination may support systemic restoration but is not itself the restorative transformation.",
  "WRN" => "WRN owns faults, hazards, degradation, impairment, and adverse propagation. REP:1xx moves toward realizing an applicable restoration condition; WRN moves toward a less acceptable condition, and neither process entails the other.",
  "STR" => "STR owns reconfiguration, incorporation, integration, and structural affordances. A structural change can implement restoration, but REP does not specify topology or constituent arrangement.",
  "LOG" => "LOG owns correctness, validity, rule satisfaction, permission, and constraints. Correction can be one result of restoration, but checking or satisfying a rule is not automatically a restorative transformation.",
  "DAT" => "DAT owns records, checkpoints, backups, schemas, measurements, and information transformation. Restoring data may use a checkpoint, but the record and copy operation do not replace the REP transformation claim.",
  "CRE" => "CRE owns generation, fabrication, replacement, reconstruction, and destruction. Replacement or rebuilding may realize restoration, but creation and substitution are not identical to movement toward a restoration condition.",
  "ORI" => "ORI owns tense, duration, possibility, necessity, and general transition. Lexical REP:1x2 selects a nonactualized restorative process and does not encode plan, schedule, queue, probability, future time, or eventual realization."
}.freeze

def lexical_axes(id)
  address = id.split(":").last
  scope = { "0" => "inward/self", "1" => "outward/target", "2" => "shared/systemic" }.fetch(address[1])
  phase = { "0" => "completed", "1" => "active", "2" => "nonactualized" }.fetch(address[2])
  [scope, phase]
end

def candidate_analysis(id, architecture)
  scope, phase = lexical_axes(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional choice follows the #{scope} and #{phase} slot labels and favors familiar Repair language such as healing, correction, recalibration, restoration, maintenance, and recovery.",
      "useful_coverage" => "It reaches common talk about self-repair, target repair, system recovery, maintenance cycles, queued work, and staged recovery.",
      "semantic_territory_consumed" => "It mixes restorative transformation, maintenance, rebuilding, possibility, schedules, preparation, plans, resources, coordination, and stable results.",
      "conflicts_or_future_limitations" => "The lexical 1x2 roots improperly encode possibility, queues, schedules, or plans; the systemic triplet mixes maintenance and restoration; and several definitions collide with CRE, DAT, CON, LOG, and ORI."
    }
  when "restorative_transformation"
    {
      "why_it_fits" => "Every address selects one substrate-neutral transformation toward realizing an applicable restoration condition; the second trit alone distinguishes internally originating restoration, one-source target restoration, or coordinated restoration across multiple system participants, and the third alone selects phase.",
      "useful_coverage" => "It covers heal, repair, restore, recover, recalibrate, reconcile, rehabilitate, remediate, return to service, and coordinated recovery across ordinary and technical domains.",
      "semantic_territory_consumed" => "Only restorative change and its scope. Domain mechanics, movement, maintenance, replacement, records, validation, coordination, resources, probability, plans, and time remain separate.",
      "conflicts_or_future_limitations" => "The applicable restoration condition must be resolved from REP:0xx or context, but that factoring is compositional and prevents this process atom from absorbing domain-specific health, integrity, or correctness."
    }
  when "maintenance_action"
    {
      "why_it_fits" => "Internal upkeep, target servicing, and systemic maintenance naturally use inward, outward, and shared scope with completed, active, or nonactualized phases.",
      "useful_coverage" => "It covers service, preserve, sustain, clean, patch, inspect, tune, lubricate, and administer upkeep.",
      "semantic_territory_consumed" => "Preservation of an existing acceptable condition, recurring service, inspection, resource use, and organizational responsibility.",
      "conflicts_or_future_limitations" => "Maintenance need not move anything toward restoration, restoration can occur without ongoing maintenance, and the architecture collides with LOG rules, DAT schedules, MAT actions, and CON service relations."
    }
  when "corrective_validation"
    {
      "why_it_fits" => "Self-checking, target correction verification, and systemic revalidation can be framed as Repair processes at all three scopes.",
      "useful_coverage" => "It covers test, validate, verify, reconcile, audit, certify, check correction, and confirm recovery.",
      "semantic_territory_consumed" => "Rule satisfaction, evidence acquisition, comparison, records, and observer judgment rather than restoration itself.",
      "conflicts_or_future_limitations" => "LOG owns validity and acceptance, DAT owns measurements and evidence, MIN owns judgment, and a restored condition can exist without validation."
    }
  when "replacement_reconstruction"
    {
      "why_it_fits" => "Self-rebuilding, replacement of a target, and reconstruction of a shared system are common ways to accomplish repair and support all phases.",
      "useful_coverage" => "It covers replace, rebuild, reconstruct, regenerate, refabricate, reinstall, recreate, and swap components.",
      "semantic_territory_consumed" => "Creation, destruction, substitution, identity continuity, structural assembly, and material operations.",
      "conflicts_or_future_limitations" => "CRE and STR own those transformations, many repairs do not replace or rebuild, and a replacement can occur without restoration of the original bearer."
    }
  end
end

def alternative_invariant(id, architecture)
  scope, phase = lexical_axes(id)
  case architecture
  when "maintenance_action"
    "A #{phase} upkeep process that preserves an already acceptable condition at #{scope} scope."
  when "corrective_validation"
    "A #{phase} verification process that tests a corrected condition against a criterion at #{scope} scope."
  when "replacement_reconstruction"
    "A #{phase} replacement or reconstruction process that substitutes newly made structure at #{scope} scope."
  end
end

def score_hash(values)
  EraZeroValidation::SCORE_KEYS.zip(values).to_h
end

def score_values(architecture, id)
  values = SCORE_PROFILES.fetch(architecture).dup
  second = id[-2]
  third = id[-1]
  case architecture
  when "current_phase2"
    values[0] -= 1 if third == "2"
    values[1] -= 1 if third == "2"
    values[4] -= 1 if second == "2"
  when "restorative_transformation"
    values[6] -= 1 if third == "2"
  when "maintenance_action"
    values[7] += 1 if second == "2"
    values[4] -= 1 if second == "1"
  when "corrective_validation"
    values[6] += 1 if second == "1"
    values[4] -= 1 if second == "2"
  when "replacement_reconstruction"
    values[2] -= 1 if second == "0"
    values[4] -= 1 if second == "2"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate(id, architecture, title, invariant)
  scores = score_hash(score_values(architecture, id))
  {
    "candidate_id" => architecture,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => candidate_analysis(id, architecture),
    "scores" => scores,
    "total" => scores.values.sum,
    "maximum" => 80
  }
end

def nearest_neighbors(id)
  family, address = id.split(":")
  first, second, third = address.chars
  siblings = %w[0 1 2].reject { |value| value == third }.map { |value| "#{family}:#{first}#{second}#{value}" }
  scopes = %w[0 1 2].reject { |value| value == second }.map { |value| "#{family}:#{first}#{value}#{third}" }
  (siblings + scopes + ["#{family}:0#{second}#{third}", "#{family}:2#{second}#{third}"]).uniq
end

def role_registers
  {
    "low" => "reference entity or restoration target",
    "middle" => "restorative transformation",
    "high" => "distinct restorative source or participating agent",
    "sustained" => "shared system and participants realizing one restoration condition"
  }
end

EXAMPLE_CONTENT = {
  "0" => {
    "ordinary" => ["device", "condition", "The device completed an internally originating restoration into its accepted condition.", "The device is undergoing an internally originating restoration toward its accepted condition.", "The internally originating restoration by which the device would enter its accepted condition is nonactualized."],
    "physical" => ["organism", "condition", "The organism completed an internally originating healing process into its applicable restored condition.", "The organism is actively healing toward its applicable restored condition.", "The organism's internally originating healing process is nonactualized."],
    "program" => ["service", "known_good", "The service completed an internally originating recovery into its known-good condition.", "The service is actively recovering toward its known-good condition.", "The service's internally originating recovery process is nonactualized."],
    "counter" => ["WRN:101[1](ENTITY=device)", "ongoing internal degradation", "The device is deteriorating.", "Degradation moves toward a less acceptable condition and belongs to WRN, not internal restoration."]
  },
  "1" => {
    "ordinary" => ["target", "technician", "The technician completed a restorative transformation that returned the target to its accepted condition.", "The technician is restoring the target toward its accepted condition.", "The technician-to-target restoration process is nonactualized."],
    "physical" => ["panel", "repairer", "The repairer completed restoration of the panel to its accepted target condition.", "The repairer is restoring the panel toward its accepted target condition.", "The repairer's restoration of the panel is nonactualized."],
    "program" => ["database", "recovery_service", "The recovery service completed restoration of the database to its accepted target condition.", "The recovery service is restoring the database toward its accepted target condition.", "The recovery service's target restoration is nonactualized."],
    "counter" => ["CRE:111[1](SOURCE=factory,TARGET=part)", "active target fabrication", "The factory is fabricating a replacement part.", "Creation or replacement belongs to CRE unless a separate REP claim asserts restoration of the target."]
  },
  "2" => {
    "ordinary" => ["community_system", "participants", "The participants completed one coordinated transformation that realized the shared restoration condition.", "The participants are coordinating one restorative transformation toward the shared restoration condition.", "The coordinated systemic restoration process is nonactualized."],
    "physical" => ["facility", "zones", "The facility completed coordinated restoration across its coupled zones.", "The coupled zones are undergoing coordinated restoration toward the facility's shared condition.", "The facility-wide coordinated restoration is nonactualized."],
    "program" => ["cluster", "nodes", "The cluster completed coordinated restoration of service across its nodes.", "The cluster nodes are undergoing coordinated restoration toward one shared service condition.", "The coordinated cluster restoration process is nonactualized."],
    "counter" => ["CON:121[1](PARTICIPANTS=nodes,EXPRESSION=updates)", "active coordinated exchange", "The nodes are coordinating updates.", "Coordination alone belongs to CON and does not entail systemic restoration."]
  }
}.freeze

def examples_for(id)
  address = id.split(":").last
  second, third = address[1], address[2]
  phase_index = { "0" => 2, "1" => 3, "2" => 4 }.fetch(third)
  content = EXAMPLE_CONTENT.fetch(second)
  scope_label = { "0" => "internal restoration", "1" => "target restoration", "2" => "systemic restoration" }.fetch(second)
  phase_label = { "0" => "completed", "1" => "ongoing", "2" => "nonactualized" }.fetch(third)
  entity, target, ordinary = content.fetch("ordinary").values_at(0, 1, phase_index)
  physical_entity, physical_target, physical = content.fetch("physical").values_at(0, 1, phase_index)
  program_entity, program_target, program = content.fetch("program").values_at(0, 1, phase_index)
  counter_graph, counter_gloss, counter_english, counter_analysis = content.fetch("counter")
  role_key = { "0" => "CONDITION", "1" => "SOURCE", "2" => "PARTICIPANTS" }.fetch(second)
  scope_analysis = {
    "0" => "The restorative transformation originates within one reference entity and does not require a distinct external source.",
    "1" => "One distinct source and one target remain separately identified while the source causes restorative change in the target.",
    "2" => "One coordinated restorative transformation makes one shared restoration condition realized across multiple participants in a shared system."
  }.fetch(second)
  entries = [
    ["ordinary_conversation", "#{id}[1](ENTITY=#{entity},#{role_key}=#{target})", "#{phase_label} #{scope_label}", ordinary, "#{scope_analysis} The assertion does not add a mechanism, record, validation, schedule, or guarantee beyond the invariant."],
    ["physical_or_spatial", "MAT(OBJECT=#{physical_entity})+#{id}[1](ENTITY=#{physical_entity},#{role_key}=#{physical_target})", "material realization plus #{phase_label} #{scope_label}", physical, "#{scope_analysis} MAT/LIF owns concrete mechanics; REP owns restorative direction and scope."],
    ["temporal_or_sequential", "#{id}[1](ENTITY=#{entity},#{role_key}=#{target})+ORI(INTERVAL=service_window)", "#{phase_label} #{scope_label} during an explicit interval", "During the service window, #{ordinary.sub(/\A./) { |letter| letter.downcase }}", "ORI supplies temporal location; lexical phase is not tense or schedule."],
    ["cross_family_compound", "DAT(BASELINE=d)+LOG(CRITERION=k)+#{id}[1](ENTITY=#{entity},#{role_key}=#{target})", "baseline and criterion plus #{phase_label} #{scope_label}", "The baseline and criterion specify the accepted condition toward which the restorative transformation moves.", "#{scope_analysis} DAT and LOG describe references; neither performs restoration."],
    ["executable_or_programming", "#{id}[1](ENTITY=#{program_entity},#{role_key}=#{program_target})", "assert #{phase_label} #{scope_label}", program, "#{scope_analysis} Checkpoints, validation, replacement, coordination, and recoverability require separate DAT/LOG/CRE/CON/REP:2xx assertions."],
    ["counterexample", counter_graph, counter_gloss, counter_english, counter_analysis]
  ]
  entries.map do |category, graph, gloss, english, analysis|
    {
      "category" => category,
      "semantic_graph" => graph,
      "literal_gloss" => gloss,
      "natural_english" => english,
      "runtime_state" => 1,
      "contour" => category == "executable_or_programming" ? "level assertion or sharply falling execution" : "level declaration",
      "role_registers" => role_registers,
      "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid",
      "analysis" => analysis,
      "pseudocode" => category == "executable_or_programming" ? "assert(restorative_process.matches?(#{id.inspect}))" : nil
    }.compact
  end
end
scored_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  phase2_title, phase2_definition = PHASE2.fetch(id)
  winner_title, winner_invariant = ROOTS.fetch(id)
  alternatives = ALT_TITLES.fetch(id)
  candidates = [
    ["current_phase2", phase2_title, phase2_definition],
    ["restorative_transformation", winner_title, winner_invariant],
    ["maintenance_action", alternatives[0], alternative_invariant(id, "maintenance_action")],
    ["corrective_validation", alternatives[1], alternative_invariant(id, "corrective_validation")],
    ["replacement_reconstruction", alternatives[2], alternative_invariant(id, "replacement_reconstruction")]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2")["why_it_fits"],
    "candidates" => candidates.map { |candidate_id, title, invariant| candidate(id, candidate_id, title, invariant) },
    "recommended_candidate_id" => "restorative_transformation",
    "recommendation_reason" => "Only this architecture preserves one substrate-neutral Repair process center, changes only scope across columns and phase across each triplet, composes directly with canonical REP:0xx conditions, and avoids absorbing domain mechanics, maintenance, validation, replacement, records, resources, probability, or scheduling.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  title, invariant = ROOTS.fetch(id)
  scope, phase = lexical_axes(id)
  second, third = id[-2], id[-1]
  process = { "0" => "internal-restoration process", "1" => "target-restoration process", "2" => "systemic-restoration process" }.fetch(second)
  center = {
    "0" => "originates within one reference entity and changes that entity toward its applicable internal restoration condition without requiring a distinct external source",
    "1" => "uses one distinct source to cause one reference target to enter its applicable target restoration condition while source and target remain separately identified",
    "2" => "coordinates restorative change by which one shared restoration condition becomes realized across multiple participant entities within one shared system"
  }.fetch(second)
  article = phase == "active" ? "an" : "a"
  scope_guard = {
    "0" => "If a distinct external source causes the change, use target restoration; if one shared condition is realized across several participants, use systemic restoration.",
    "1" => "The restorative source remains distinct from one target. If the change originates inside the target without a distinct source, use internal restoration; if one shared condition becomes realized across several participants, use systemic restoration.",
    "2" => "One coordinated restorative transformation must realize one shared restoration condition across multiple participants. Several unrelated repairs or one source restoring one target do not satisfy systemic scope."
  }.fetch(second)
  runtime = case third
            when "0"
              {
                "0" => "Denies that this #{process} reached completion in the stated restoration context; it does not assert that the active or nonactualized sibling holds.",
                "1" => "Affirms that this #{process} reached completion and realized the applicable restoration condition, without asserting the concrete mechanism, record, validation, permanence, maintenance, replacement, or continuing recoverability.",
                "2/num" => "Leaves unresolved whether this #{process} reached completion or whether that completed result remains applicable; the lexical root stays completed."
              }
            when "1"
              {
                "0" => "Denies that this #{process} is presently ongoing or states that it has ceased; completion, reversal, and nonactualized availability remain undecided.",
                "1" => "Affirms that this #{process} is presently ongoing toward the applicable restoration condition, without guaranteeing completion, persistence of the result, recognition, validation, maintenance, or future success.",
                "2/num" => "Leaves unresolved whether this #{process} is presently ongoing; the runtime marker does not select the completed or nonactualized lexical sibling."
              }
            else
              {
                "0" => "Denies that this #{process} holds even as a valid nonactualized transformation in the stated context; it does not assert activity or completion.",
                "1" => "Affirms this #{process} as nonactualized—neither ongoing nor completed—without adding plan, intention, queue, schedule, permission, readiness, probability, or future time.",
                "2/num" => "Leaves unresolved even the assertion that this #{process} is a valid nonactualized transformation; lexical nonactualization and runtime uncertainty remain distinct."
              }
            end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => title,
    "invariant_definition" => invariant,
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_1" => "Selects a restorative process, action, or transformation rather than a restoration-condition entity, recoverability affordance, resource, record, rule, or schedule.",
      "second_trit" => "Selects #{scope} scope: this root #{center}; no competing family or temporal phase is added by this axis.",
      "third_trit" => "Selects the #{phase} phase of the same #{process}; planning, queueing, schedule, futurity, permission, probability, and runtime truth status remain separate."
    },
    "inclusion_boundary" => "Includes only #{article} #{phase} substrate-neutral restorative transformation that #{center}. #{scope_guard} The transformation may be realized physically, biologically, computationally, informationally, socially, or conceptually, but it does not itself assert the bearer, concrete mechanics, movement path, record, observer knowledge, validation, maintenance, replacement, resource, recoverability, probability, schedule, or causal history beyond the scope roles required by the invariant.",
    "excluded_meanings" => [
      "The restoration condition, bearer, restorative source, target, participant, material object, organism, software component, institution, checkpoint, or data record as an entity.",
      "Spatial movement, return, route traversal, physical force, biological mechanism, data copying, structural reconfiguration, creation, replacement, or reconstruction as such without the REP restorative transformation claim.",
      "Planning, intention, staging, queueing, scheduling, permission, readiness, probability, futurity, obligation, or specification—especially for lexical 1x2.",
      "Inspection, validation, verification, certification, evidence collection, belief revision, diagnosis, recognition, or measurement of a restoration condition.",
      "Maintenance, preservation, routine servicing, warning, containment, neutral coordination, fabrication, replacement, reconstruction, or mere communication about restoration.",
      "Recoverability, repairability, restorative capacity, remedy availability, caregiver relation, service contract, resource readiness, probability, or other continuing capacity or relation."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "REP:0xx owns internal, target, and shared restoration-condition entities. REP:1xx owns restorative transformations toward realizing those conditions. REP:2xx remains reserved for recoverability, repairability, and enabling restoration relations. Internal restoration has no required distinct external source. Target restoration preserves one source and one target as distinct roles. Systemic restoration requires one coordinated transformation that realizes one shared restoration condition across multiple participants. A completed REP:1xx root entails that the applicable restoration condition was realized by the stated transformation at completion; it does not entail that the result persists, that it was recorded or validated, that maintenance continues, or that a continuing REP:2xx affordance holds unless separately asserted.",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime,
    "lexical_runtime_distinction" => "The lexical third trit permanently selects the #{phase} member of this process triplet. Runtime `[2]/num` instead qualifies the truth, applicability, or resolution of a token of that already-selected root; it never changes the root into a planned, future, or different-phase process.",
    "catalogue_title_guard" => third == "2" ? "The word `nonactualized` in the concise catalogue title denotes a valid restorative process that is neither ongoing nor completed. It does not assert capability, readiness, probability, permission, intention, schedule, future time, or eventual realization." : "The concise catalogue title is controlled by the invariant definition and must not be broadened with unstated mechanics, records, validation, maintenance, replacement, result persistence, or temporal semantics.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + REP:0xx identifies the internal, target, or shared restoration condition realized by or guiding the restorative process.",
      "#{id} + MAT/MOV/LIF specifies physical mechanics, return path, or living effects without reducing restoration to those domains.",
      "#{id} + DAT/MIN/LOG specifies a checkpoint, recognition, evidence, or validation while keeping the restorative process independent.",
      "#{id} + CRE/STR/CON distinguishes replacement, reconstruction, structural reconfiguration, and coordination from restoration itself."
    ],
    "later_era_notes" => "Later eras may lexicalize heal, mend, repair, rehabilitate, remediate, recalibrate, reconcile, recover, reset, restore-from-backup, return-to-service, and disaster recovery as descendants or typed compounds. Era Zero must preserve the internal-origin / one-source-one-target / coordinated-multi-participant contrast and must not let nonactualized 1x2 roots acquire planning or modal-strength semantics.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end


STRESS_CONCEPTS = [
  ["restore", "one_root_or_compound", "Select REP:100–122 by inward, target, or systemic scope and completed, active, or nonactualized phase; domain mechanics remain separate."],
  ["repair", "one_root_or_compound", "REP:1xx supplies restorative transformation when movement toward an applicable restoration condition is meant; the repaired condition itself is REP:0xx."],
  ["heal", "compound", "REP restorative process plus LIF biological bearer and mechanism; healing need not be internally originating."],
  ["recover", "one_root_or_compound", "REP:1xx when a restorative transformation is meant; regained condition may instead be REP:0x1 and historical change requires ORI."],
  ["rehabilitate", "compound", "REP target or systemic restoration plus LIF/CON/STR details of function, participant roles, and training."],
  ["remediate", "one_root_or_compound", "REP target restoration plus domain roots for the defect, environment, data, or rule being remediated."],
  ["recalibrate", "compound", "REP restoration plus MAT/LOG measurement and criterion semantics."],
  ["reconcile", "compound", "REP restoration plus CON/DAT/LOG for social, record, or accounting reconciliation."],
  ["return to service", "compound", "REP restoration plus ORI transition and CON/DAT/STR service-state semantics."],
  ["back to normal", "compound", "REP restorative process or realized condition plus an explicit or resolved normality criterion."],
  ["improve", "underspecified", "Improvement need not be restoration; it may be CRE enhancement, learning, optimization, or generic change."],
  ["transform", "unresolved", "Generic transformation lacks Repair-family direction, scope, phase, and applicable restoration condition."],
  ["change", "unresolved", "Generic change must not be forced into REP without restoration-relative semantics."],
  ["fix", "underspecified", "May mean REP restoration, LOG correction, DAT edit, MAT repair, or CRE replacement; translator must resolve sense."],
  ["correct", "different_family_or_compound", "LOG owns correctness; REP applies only when a process moves a bearer toward a restoration condition."],
  ["maintain", "different_process_or_compound", "Preserving an already acceptable condition is not necessarily restorative change; maintenance may compound with REP when it restores."],
  ["service equipment", "underspecified", "May be maintenance, inspection, cleaning, replacement, or target restoration; do not force one atomic root."],
  ["self-repair completed", "one_root", "REP:100 states completion of restorative transformation originating within one entity."],
  ["self-repair active", "one_root", "REP:101 states ongoing restorative transformation originating within one entity."],
  ["self-repair nonactualized", "one_root", "REP:102 affirms a valid inward restorative transformation that is neither ongoing nor completed."],
  ["autonomic healing", "one_root_or_compound", "REP:10x by phase with LIF when healing originates within the organism."],
  ["self-healing polymer", "compound", "REP:10x supplies inward restoration while MAT supplies polymer mechanism."],
  ["automatic retry recovery", "compound", "REP:10x supplies internally originating recovery while DAT/LOG supplies retry and success conditions."],
  ["garbage collection recovery", "compound", "REP:10x only when the internal process restores an applicable condition; DAT/CRE owns memory operations."],
  ["immune recovery", "compound", "REP internal restoration plus LIF physiology; an external treatment would instead support target restoration."],
  ["internal restoration uncertain", "runtime_state", "REP:101[2]/num leaves ongoing status unresolved and does not select REP:102."],
  ["confirmed nonactualized self-restoration", "one_root_plus_runtime", "REP:102[1] affirms nonactualization without plan, capability, schedule, or probability."],
  ["completed self-restoration disputed", "one_root_plus_runtime", "REP:100[2]/num keeps completed lexical phase while leaving the token assertion unresolved."],
  ["self-restoration scheduled", "root_plus_time", "REP:102 plus ORI or scheduling grammar; lexical nonactualization never means scheduled."],
  ["self-restoration possible", "root_plus_modality_or_affordance", "REP:102 identifies the process as nonactualized; ORI modality or REP:2xx must supply possibility or capacity."],
  ["self-restoration impossible", "future_affordance_plus_negation", "Negated REP:2xx recoverability is distinct from REP:102 nonactualization."],
  ["self-maintenance", "different_process_or_compound", "Maintenance can preserve rather than restore; add REP:10x only if an actual restorative change occurs."],
  ["self-test", "different_family", "LOG/DAT/MIN owns testing and observation; testing does not restore."],
  ["self-correcting code", "compound", "REP:10x when the program actually returns itself to a restoration condition; LOG/DAT specifies the correction."],
  ["target repair completed", "one_root", "REP:110 states completed restoration caused in one target by one distinct source."],
  ["target repair active", "one_root", "REP:111 states ongoing source-to-target restorative transformation."],
  ["target repair nonactualized", "one_root", "REP:112 states a valid source-to-target restorative transformation that is not ongoing or completed."],
  ["technician repairs panel", "one_root_or_compound", "REP:111 with LIF agent and MAT panel mechanics."],
  ["doctor treats patient", "compound", "REP:111 only when treatment is restorative; LIF owns patient, physiology, and clinical action."],
  ["medicine heals patient", "compound", "MAT/LIF supplies substance and biological mechanism while REP:111 supplies target restoration."],
  ["patch software", "compound", "REP:111 supplies target restoration; DAT/LOG/CRE supplies code change and validity."],
  ["restore database", "compound", "REP:11x by phase with DAT for database and checkpoint semantics."],
  ["repair road", "compound", "REP:11x with MAT/STR for material and structural mechanics."],
  ["recalibrate sensor", "compound", "REP:11x with MAT/DAT/LOG measurement and criterion."],
  ["reconcile account", "compound", "REP:11x only when the account is restored to an accepted condition; DAT/LOG owns records and correctness."],
  ["clean contaminated surface", "compound", "REP:11x may supply restoration while MAT/WRN supplies substance and adverse condition."],
  ["replace broken component", "compound", "CRE owns replacement and REP:11x may assert that the target system is thereby restored."],
  ["rebuild target", "compound", "CRE/STR owns reconstruction; REP:11x separately asserts restorative direction."],
  ["target restoration uncertain", "runtime_state", "REP:111[2]/num questions ongoing restoration rather than selecting REP:112."],
  ["confirmed nonactualized target repair", "one_root_plus_runtime", "REP:112[1] affirms the process without saying it is queued, scheduled, possible, or intended."],
  ["repair appointment", "different_family_or_compound", "DAT/ORI owns the appointment; REP:112 may name the nonactualized process only as a separate assertion."],
  ["repair queue", "different_family_or_compound", "DAT/LOG owns queued work; REP:112 does not lexicalize the queue."],
  ["repair plan", "different_family_or_compound", "MIN/DAT/LOG owns the plan; REP:112 names only a nonactualized restorative process."],
  ["repair permission", "different_family_or_compound", "LOG owns permission; permission neither performs nor guarantees target restoration."],
  ["repair readiness", "future_affordance_or_compound", "REP:2xx and resources express enabling capacity; REP:112 alone does not."],
  ["repair failed", "compound", "An active or completed attempted process plus LOG/WRN outcome claims; the successful-completion invariant of REP:110 must not be asserted if the target condition was not realized."],
  ["repair attempt", "compound_or_gap", "REP:111 may apply while genuinely moving toward restoration; mere effort without restorative transformation requires agency/action semantics."],
  ["repair stopped", "root_plus_event_boundary", "Denied or ceased REP:111 plus ORI boundary; stopping does not imply completed restoration."],
  ["repair continued", "root_plus_contour", "REP:111 plus continuation contour or temporal grammar."],
  ["repair repeated", "root_plus_iteration", "REP:11x plus iteration grammar; repetition is not inside the atom."],
  ["system restoration completed", "one_root", "REP:120 states completion of one coordinated systemic restorative transformation."],
  ["system restoration active", "one_root", "REP:121 states ongoing coordinated systemic restorative transformation."],
  ["system restoration nonactualized", "one_root", "REP:122 states a valid coordinated systemic restoration that is neither ongoing nor completed."],
  ["disaster recovery", "one_root_or_compound", "REP:12x by phase when one shared restoration condition is coordinated across participants; WRN/ORI supplies disaster and timing."],
  ["restore service cluster", "one_root_or_compound", "REP:12x if coordinated restoration realizes one shared service condition across nodes."],
  ["community rebuilding", "compound", "REP:121 only for coordinated restoration of a shared condition; CRE/STR/LIF/CON supplies rebuilding and participants."],
  ["ecosystem recovery", "compound", "REP:12x plus LIF/MAT/CON when one shared restoration condition spans interacting participants."],
  ["hospital recovery operation", "compound", "REP:12x if coordinated across system participants; LIF/CON/DAT supplies institution and coordination."],
  ["network failover recovery", "compound", "REP:12x may assert shared restoration; DAT/CON/STR supplies failover mechanism and topology."],
  ["coordinated rollback", "compound", "REP:12x plus DAT checkpoint and CON coordination; rollback alone is not necessarily restoration."],
  ["mass healing", "compound", "Use REP:12x only for one correlated shared restoration condition, not merely many independent healing events."],
  ["many independent repairs", "multiple_roots_not_one_systemic_process", "Use separate REP:10x or REP:11x assertions unless one coordinated shared restoration condition is involved."],
  ["one technician repairs two unrelated targets", "multiple_target_processes", "Use per-target REP:11x claims unless the targets participate in one coordinated systemic restoration."],
  ["coordination without restoration", "different_family", "CON owns coordination; no REP:12x root applies unless restorative change occurs."],
  ["system maintenance", "different_process_or_compound", "Routine preservation is not automatically systemic restoration; use REP only when the shared condition is being restored."],
  ["system restoration uncertain", "runtime_state", "REP:121[2]/num leaves ongoing systemic restoration unresolved rather than selecting REP:122."],
  ["confirmed nonactualized systemic restoration", "one_root_plus_runtime", "REP:122[1] affirms nonactualization without a plan, resources, or eventual success."],
  ["staged recovery resources", "compound_not_one_root", "DAT/MAT/CRE supplies plans and resources; REP:122 does not assert preparation or readiness."],
  ["future system recovery", "root_plus_time", "REP:122 plus ORI future relation; nonactualized does not itself mean future."],
  ["likely recovery", "root_plus_probability", "REP process plus explicit probability or evidence; no third trit encodes likelihood."],
  ["completed restoration still active", "invalid_same_event_claim", "REP:1x0 and REP:1x1 cannot describe the same event phase at one reference time without separate segments."],
  ["active then completed restoration", "two_time_indexed_roots", "Relate REP:1x1 earlier to REP:1x0 later; roots do not encode the transition timing."],
  ["nonactualized then active restoration", "two_time_indexed_roots", "Relate REP:1x2 earlier to REP:1x1 later; no plan or inevitability is implied."],
  ["restored condition", "entity_not_process", "REP:0x1 owns the presently realized restoration condition; REP:1xx is used only when the transformation is asserted."],
  ["restoration standard", "entity_or_rule_not_process", "REP:0x0 identifies the condition and LOG may define its criterion; REP:1xx does not name the standard."],
  ["recoverable", "future_rep_affordance", "Reserved for REP:2xx capacity or relation review; it is not an active or nonactualized process."],
  ["repairable", "future_rep_affordance", "Reserved for REP:2xx; a target can be repairable while no restoration occurs."],
  ["healing capacity", "future_rep_affordance", "REP:2xx with LIF; capacity is distinct from actual healing transformation."],
  ["backup", "different_family", "DAT owns the backup record; restoring from it requires a separate REP process."],
  ["restore point", "different_family", "DAT owns the checkpoint; it is neither the restoration condition nor the restoration process."],
  ["validation passed", "different_family_or_compound", "LOG/DAT owns validation; REP:1x0 applies only if a restorative transformation also completed."],
  ["replacement completed", "different_family_or_compound", "CRE owns substitution; REP applies only if replacement restored the target or system condition."],
  ["return home", "different_family", "MOV owns spatial return; no restorative transformation is implied."],
  ["return to health", "compound", "REP restorative process plus LIF health and ORI transition."],
  ["reverse degradation", "compound", "WRN names degradation and REP names restoration; REP does not encode a generic inverse operator."],
  ["prevent damage", "different_family_or_compound", "Prevention and protection are not restoration because no movement from a less acceptable condition is required."],
  ["contain fault", "different_family_or_compound", "STR/LOG/WRN owns containment; containment may support but does not equal restoration."],
  ["create improved version", "different_family", "CRE owns generation or enhancement; improvement beyond the restoration condition is not REP restoration."],
  ["restoration versus maintenance", "scope_resolution_test", "REP:1xx moves toward realizing a restoration condition; maintenance can merely preserve an already realized condition."],
  ["restoration versus validation", "scope_resolution_test", "REP:1xx performs restorative change; LOG/DAT tests or records whether criteria hold."],
  ["restoration versus replacement", "scope_resolution_test", "REP supplies restorative direction; CRE supplies substitution or reconstruction mechanics."],
  ["restoration versus recoverability", "scope_resolution_test", "REP:1xx is actualized by phase; REP:2xx will own capacities and enabling relations."],
  ["restoration versus condition", "scope_resolution_test", "REP:0xx names the acceptable condition; REP:1xx names transformation toward realizing it."],
  ["restoration versus adverse process", "scope_resolution_test", "REP moves toward an applicable restoration condition; WRN moves toward a less acceptable condition."],
  ["nonactualized versus uncertain", "scope_resolution_test", "REP:102[1] affirms a nonactualized process; REP:101[2]/num leaves an active-process assertion uncertain."]
].freeze

stress_tests = STRESS_CONCEPTS.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("REP1-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "REP:100–122 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5,
    "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "REP:100–122 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER,
    "triplets" => { "REP:100–102" => "internal restoration: completed / active / nonactualized", "REP:110–112" => "source-to-target restoration: completed / active / nonactualized", "REP:120–122" => "coordinated systemic restoration: completed / active / nonactualized" },
    "scope_separation" => { "inward" => "the restorative transformation originates within one reference entity", "outward" => "one distinct source causes restorative transformation in one reference target", "systemic" => "one coordinated transformation realizes one shared restoration condition across multiple participants" },
    "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true,
    "triplets_coherent" => true, "current_candidates_challenged" => true, "cross_family_collisions_explicit" => true,
    "runtime_state_separated" => true, "nonactualized_process_rule_preserved" => true,
    "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true,
    "canonicalized" => canonicalized_now
  }
}

stress = { "metadata" => { "title" => "REP:100–122 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# REP:100–122 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Repair process meanings from first principles. It compares five genuinely different semantic architectures at every address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level decision\n\nThe strongest architecture makes `REP:1xx` a substrate-neutral restorative-transformation grid. `REP:100–102` expresses restorative change originating within one reference entity. `REP:110–112` expresses restorative change caused in one target by one distinct source. `REP:120–122` expresses one coordinated transformation by which a shared restoration condition becomes realized across multiple participants. The third trit changes only completion phase.\n\n"
review << "The grid composes directly with canonical `REP:0xx`: internal, target, and shared restoration conditions provide the semantic destination while `REP:1xx` supplies transformation toward realization. It excludes concrete mechanics, generic change, maintenance, validation, records, replacement, reconstruction, coordination alone, resources, recoverability, probability, planning, and scheduling.\n\n"
IDS.each do |id|
  score_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n"
  review << "### Fixed generated forms\n\n- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### Why the current meaning was probably chosen\n\n#{score_root['current_meaning_rationale']}\n\n"
  review << "### Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  score_root.fetch("candidates").each do |candidate_item|
    values = EraZeroValidation::SCORE_KEYS.map { |key| candidate_item.dig("scores", key) }
    review << "| #{candidate_item['title']} | #{values.join(' | ')} | **#{candidate_item['total']}/80** |\n"
  end
  review << "\n"
  score_root.fetch("candidates").each do |candidate_item|
    analysis = candidate_item.fetch("analysis")
    review << "#### #{candidate_item['title']}\n\n**Invariant candidate:** #{candidate_item['invariant_candidate']}\n\n- Fit: #{analysis['why_it_fits']}\n- Useful coverage: #{analysis['useful_coverage']}\n- Territory consumed: #{analysis['semantic_territory_consumed']}\n- Conflicts and limitations: #{analysis['conflicts_or_future_limitations']}\n\n"
  end
  review << "### Recommended permanent semantic specification\n\n**Title:** #{spec['proposed_title']}\n\n**Invariant:** #{spec['invariant_definition']}\n\n**Boundary:** #{spec['inclusion_boundary']}\n\n**Excluded meanings:**\n\n"
  spec.fetch("excluded_meanings").each { |item| review << "- #{item}\n" }
  review << "\n**Address justification:**\n\n"
  spec.fetch("address_justification").each { |axis, explanation| review << "- `#{axis}`: #{explanation}\n" }
  review << "\n**Nearest neighbors:** #{spec['nearest_neighbors'].map { |neighbor| "`#{neighbor}`" }.join(', ')}\n\n**Same-family boundary:** #{spec['same_family_contrast']}\n\n**Runtime meanings:**\n\n"
  spec.fetch("runtime_state_interpretation").each { |state, meaning| review << "- `[#{state}]`: #{meaning}\n" }
  review << "\n**Lexical/runtime distinction:** #{spec['lexical_runtime_distinction']}\n\n### Examples\n\n| Type | Semantic graph | Literal gloss | Natural English | State | Result |\n| --- | --- | --- | --- | ---: | --- |\n"
  spec.fetch("examples").each { |example| review << "| #{example['category']} | `#{example['semantic_graph']}` | #{example['literal_gloss']} | #{example['natural_english']} | #{example['runtime_state']} | #{example['use_status']} |\n" }
  review << "\n"
end
review << "## Triplet coherence\n\n| Triplet | Shared process | `0` completed | `1` active | `2` nonactualized |\n| --- | --- | --- | --- | --- |\n| REP:100–102 | one restorative transformation originates within one reference entity and moves it toward its internal restoration condition | transformation reached completion and condition was realized | same transformation ongoing | same transformation nonactualized |\n| REP:110–112 | one distinct source causes one reference target to enter its target restoration condition | transformation reached completion and condition was realized | same transformation ongoing | same transformation nonactualized |\n| REP:120–122 | one coordinated restorative transformation realizes a shared restoration condition across multiple participants | transformation reached completion and condition was realized | same transformation ongoing | same transformation nonactualized |\n\n**Scope guard:** inward change requires no distinct source; outward restoration keeps one source and one target distinct; systemic restoration requires one shared condition and coordinated realization across multiple participants. *Nonactualized* on `REP:102`, `REP:112`, and `REP:122` never supplies capability, readiness, probability, permission, intention, schedule, future time, or eventual realization.\n\n"
review << "## Ownership matrix\n\n| Root | Owns | Belongs elsewhere or remains compound |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | mechanics, generic change, maintenance, validation, records, replacement, coordination alone, resources, recoverability, probability, scheduling, and result persistence |\n" }
review << "\n## Intentionally reserved concepts\n\nMaintain, inspect, validate, certify, replace, reconstruct, coordinate, schedule, queue, plan, supply resources, and assert recoverability remain other-family assertions, future REP affordances, or typed compounds. Generic *change*, *transform*, *fix*, *improve*, *service*, and *recover* require sense resolution.\n\n"
review << "## Stress test\n\n#{stress_tests.length} English restorative-process concepts were routed through single roots, compounds, grammar, other families, future REP affordances, or explicit unresolved gaps. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** approved under `migrations/#{STEM}_semantic_approval.yaml`; this remains the adversarial evidence record.\n" : "\n**Recommendation:** approve only after reusable packet validation, combined REP condition/process soundness validation, and current-state regression. Until then all nine roots remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# REP:100–122 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "LIF healing; MAT self-repair mechanics; LOG correction; DAT self-recovery record", "1" => "LIF care; CRE replacement; MAT repair mechanics; LOG validation", "2" => "CON coordination; STR system reconfiguration; DAT rollback; CRE reconstruction" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | REP keeps only the restorative transformation and its inward, target, or systemic scope |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Same-family safeguards\n\n- `REP:0xx` owns restoration-condition entities; `REP:1xx` owns restorative transformations; `REP:2xx` remains reserved for recoverability and enabling restoration capacities or relations.\n- Internal restoration originates within one reference entity and does not require a distinct external source. It does not mean self-testing, maintenance, or mere spontaneous improvement.\n- Target restoration is asymmetric: one distinct source causes restorative change in one target. It does not mean care communication, validation, replacement, or resource assignment.\n- Systemic restoration coordinates realization of one shared restoration condition across multiple participants. It does not mean neutral coordination, several unrelated repairs, or a system-wide maintenance schedule.\n- A completed process entails that its applicable restoration condition was realized at completion; persistence of the result, records, validation, maintenance, and continuing `REP:2xx` relations require separate claims.\n- Lexical `1x2` means a nonactualized process only. It does not encode capability, readiness, probability, permission, intention, plan, queue, schedule, or future time; runtime `[2]/num` leaves an assertion unresolved and never changes lexical phase.\n\n## Reserved compounds and gaps\n\nHeal, recalibrate, reconcile, restore from backup, replace, reconstruct, validate, maintain, coordinate, and return to service remain typed compounds or other-family processes around the REP restorative center. Generic *fix*, *recover*, *improve*, *service*, *change*, and *transition* require sense resolution.\n\n**CONCLUSION: REP:100–122 STANDS ALONE ONLY FOR SUBSTRATE-NEUTRAL RESTORATIVE TRANSFORMATION; MATERIAL, SPATIAL, BIOLOGICAL, COGNITIVE, COMMUNICATIVE, NORMATIVE, INFORMATIONAL, CREATIVE, STRUCTURAL, WARNING, AND TEMPORAL CLAIMS REMAIN SEPARATE.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built #{RANGE} review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
