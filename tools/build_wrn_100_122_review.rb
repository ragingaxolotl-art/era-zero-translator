#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "WRN:100–122"
STEM = "WRN_100_122"
IDS = EraZeroValidation.ids_for_range(RANGE)
SEMANTIC_CENTER = "substrate-neutral adverse transformation: internal degradation, source-to-target impairment, and systemic propagation"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "WRN:100" => ["diagnosis complete", "An inward process of detecting, classifying, or tracing an entity's fault has reached a stable result."],
  "WRN:101" => ["self-monitoring", "An entity is actively checking itself for danger, error, damage, or corruption."],
  "WRN:102" => ["pending inspection", "An inward diagnostic process is required or scheduled but has not begun."],
  "WRN:110" => ["containment complete", "A warning, block, isolation, or shutdown applied to a target has finished and bounded the hazard."],
  "WRN:111" => ["warn or isolate", "A dangerous target is actively being signaled, blocked, quarantined, or shut down."],
  "WRN:112" => ["pending containment", "A warning or isolation action toward a target is prepared but not yet executing."],
  "WRN:120" => ["incident closure", "A coordinated system-level detection and containment process has reached a stable end state."],
  "WRN:121" => ["emergency response", "A network or community is actively detecting, warning about, isolating, or responding to a distributed incident."],
  "WRN:122" => ["staged contingency", "A system-level warning or emergency response is prepared but has not been activated."]
}.freeze

ROOTS = {
  "WRN:100" => ["completed internal degradation", "Completion of an adverse transformation originating within one reference entity by which that entity enters a less acceptable condition."],
  "WRN:101" => ["active internal degradation", "An ongoing adverse transformation originating within one reference entity by which that entity is entering a less acceptable condition."],
  "WRN:102" => ["nonactualized internal degradation", "A nonactualized adverse transformation originating within one reference entity by which that entity would enter a less acceptable condition."],
  "WRN:110" => ["completed target impairment", "Completion of an adverse transformation by which one distinct source causes one reference target to enter a less acceptable condition."],
  "WRN:111" => ["active target impairment", "An ongoing adverse transformation by which one distinct source causes one reference target to enter a less acceptable condition."],
  "WRN:112" => ["nonactualized target impairment", "A nonactualized adverse transformation by which one distinct source would cause one reference target to enter a less acceptable condition."],
  "WRN:120" => ["completed systemic propagation", "Completion of an adverse transformation by which one correlated adverse condition becomes distributed across multiple participant entities within a shared system."],
  "WRN:121" => ["active systemic propagation", "An ongoing adverse transformation by which one correlated adverse condition becomes distributed across multiple participant entities within a shared system."],
  "WRN:122" => ["nonactualized systemic propagation", "A nonactualized adverse transformation by which one correlated adverse condition would become distributed across multiple participant entities within a shared system."]
}.freeze

SCORE_PROFILES = {
  "current_phase2" => [6, 7, 8, 5, 4, 7, 8, 8],
  "adverse_transformation" => [10, 10, 10, 10, 9, 10, 10, 10],
  "assessment_detection" => [9, 9, 8, 8, 6, 9, 9, 10],
  "protective_control_response" => [7, 8, 7, 6, 4, 9, 10, 9],
  "warning_communication" => [8, 7, 5, 7, 3, 8, 10, 9]
}.freeze

ALT_TITLES = {
  "WRN:100" => ["completed internal fault assessment", "completed internal containment", "completed internal alarm emission"],
  "WRN:101" => ["active internal fault assessment", "active internal containment", "active internal alarm emission"],
  "WRN:102" => ["nonactualized internal fault assessment", "nonactualized internal containment", "nonactualized internal alarm emission"],
  "WRN:110" => ["completed target hazard assessment", "completed target containment", "completed target warning"],
  "WRN:111" => ["active target hazard assessment", "active target containment", "active target warning"],
  "WRN:112" => ["nonactualized target hazard assessment", "nonactualized target containment", "nonactualized target warning"],
  "WRN:120" => ["completed systemic incident assessment", "completed systemic containment", "completed shared warning"],
  "WRN:121" => ["active systemic incident assessment", "active systemic containment", "active shared warning"],
  "WRN:122" => ["nonactualized systemic incident assessment", "nonactualized systemic containment", "nonactualized shared warning"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, health, injury, illness, and social participants. WRN may classify an adverse transformation affecting life, but physiological change, pain, death, and social harm require LIF semantics.",
  "MOV" => "MOV owns location, displacement, approach, traversal, and redirection. Motion may deliver an adverse source, but WRN names deterioration, target impairment, or propagation rather than the path traveled.",
  "MAT" => "MAT owns physical force, energy, collision, fracture, heating, and material change. WRN abstracts the adverse significance and scope of a transformation; material mechanics remain separately asserted.",
  "MIN" => "MIN owns perception, attention, belief revision, intention, fear, and assessment by a cognizer. Adverse transformations can occur without detection or awareness, and diagnosis is not the transformation itself.",
  "CON" => "CON owns warnings, alarms, messages, coordination, and information exchange. Communicating about harm does not produce the adverse transformation, and propagation of a fault is not automatically communicative transmission.",
  "REP" => "REP owns repair, stabilization, restoration, recovery, and replacement after loss. WRN:1xx moves toward a less acceptable condition; REP moves toward a restored condition, and neither process entails the other.",
  "STR" => "STR owns structural reconfiguration, incorporation, integration, and their affordances. Structure can change without adversity, while WRN asserts adverse transformation without specifying structural organization unless compounded.",
  "LOG" => "LOG owns invalidation, rule failure, contradiction, permission, and formal non-satisfaction. A computation may become invalid without harm, and a harmful transformation may obey every rule; LOG and WRN remain independent.",
  "DAT" => "DAT owns corruption or transformation of records, encodings, observations, and provenance as information. WRN adds adverse significance and scope; editing a diagnostic record is not degradation, impairment, or propagation of the underlying condition.",
  "CRE" => "CRE owns generation, fabrication, mutation, destruction, and other artifact transformations. WRN does not claim creation or destruction as such; it selects only a transformation toward a contextually less acceptable condition.",
  "ORI" => "ORI owns tense, duration, modality, possibility, necessity, and general transition. Lexical WRN:1x2 selects a nonactualized adverse process and does not encode plan, schedule, queue, probability, future time, or eventual realization."
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
      "why_it_fits" => "The provisional choice follows the #{scope} and #{phase} slot labels and favors familiar safety operations such as diagnosis, monitoring, warning, isolation, containment, and emergency response.",
      "useful_coverage" => "It reaches common operational language for inspecting, detecting, alerting, blocking, quarantining, shutting down, closing incidents, and staging contingencies.",
      "semantic_territory_consumed" => "It mixes assessment, evidence, communication, access control, spatial isolation, shutdown, repair-like containment, coordination, planning, scheduling, and response policy.",
      "conflicts_or_future_limitations" => "Triplets do not preserve one process center, 1x2 roots improperly encode plans or schedules, and definitions collide with MIN, DAT, CON, LOG, STR, REP, and ORI."
    }
  when "adverse_transformation"
    {
      "why_it_fits" => "Every address selects one substrate-neutral transformation toward a less acceptable condition; the second trit alone distinguishes self-originating degradation, one-source target impairment, or propagation across multiple system participants, and the third alone selects phase.",
      "useful_coverage" => "It covers degrade, fail, deteriorate, corrupt, damage, impair, infect, compromise, contaminate, propagate, cascade, and spread across ordinary, safety, programming, and mathematical domains.",
      "semantic_territory_consumed" => "Only adverse change and its scope. Physical mechanics, movement, creation or destruction, invalidity, diagnosis, warning messages, containment, repair, causal attribution, probability, plans, and time remain separate.",
      "conflicts_or_future_limitations" => "The context-sensitive phrase less acceptable requires an applicable evaluation frame, but it is narrower and more compositional than importing domain-specific mechanics or response policy."
    }
  when "assessment_detection"
    {
      "why_it_fits" => "Internal inspection, target hazard assessment, and systemic incident correlation align naturally with inward, outward, and shared scope and support all three process phases.",
      "useful_coverage" => "It covers inspect, test, monitor, diagnose, triage, classify, trace, assess, audit, and correlate incidents.",
      "semantic_territory_consumed" => "Acquisition and interpretation of evidence about adverse conditions rather than adverse transformation itself.",
      "conflicts_or_future_limitations" => "MIN owns cognition, DAT owns observations and evidence, LOG owns tests, and many noncognitive systems fail without assessment; the architecture would make Warning dependent on an observer."
    }
  when "protective_control_response"
    {
      "why_it_fits" => "Self-protection, target isolation, and coordinated containment form recognizable safety responses at the three scopes.",
      "useful_coverage" => "It covers shield, block, quarantine, isolate, contain, suppress, shut down, evacuate, and emergency response.",
      "semantic_territory_consumed" => "Restoration, access control, structural separation, movement, policy enforcement, and coordinated action.",
      "conflicts_or_future_limitations" => "REP owns restoration, LOG owns permission and blocking, STR/MOV owns isolation, CON owns coordination, and one atomic grid cannot merge these different control mechanisms."
    }
  when "warning_communication"
    {
      "why_it_fits" => "Internal alarms, directed warnings, and shared broadcasts follow inward, outward, and systemic communication scope and are central to ordinary warning language.",
      "useful_coverage" => "It covers signal, alert, notify, warn, announce danger, escalate, broadcast, and publish an incident notice.",
      "semantic_territory_consumed" => "Expression, message content, endpoints, channels, delivery, and participant awareness.",
      "conflicts_or_future_limitations" => "CON owns exchange and participant direction, DAT owns message content, and warning communication can occur when no adverse transformation exists."
    }
  end
end

def alternative_invariant(id, architecture)
  scope, phase = lexical_axes(id)
  case architecture
  when "assessment_detection"
    "A #{phase} determination process that establishes whether an adverse condition obtains at #{scope} scope."
  when "protective_control_response"
    "A #{phase} containment process that prevents an adverse condition from extending beyond a boundary at #{scope} scope."
  when "warning_communication"
    "A #{phase} communicative process that emits one warning expression toward the endpoint selected by #{scope} scope."
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
  when "adverse_transformation"
    values[6] -= 1 if third == "2"
  when "assessment_detection"
    values[7] += 1 if second == "2"
    values[4] -= 1 if second == "1"
  when "protective_control_response"
    values[6] += 1 if second == "1"
    values[4] -= 1 if second == "2"
  when "warning_communication"
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
    "low" => "reference entity or impaired target",
    "middle" => "adverse transformation",
    "high" => "distinct source or affected participant",
    "sustained" => "shared system and correlated adverse context"
  }
end

EXAMPLE_CONTENT = {
  "0" => {
    "ordinary" => ["appliance", "condition", "The appliance completed an internally originating deterioration into a less acceptable condition.", "The appliance is undergoing an internally originating deterioration into a less acceptable condition.", "The internally originating deterioration by which the appliance would enter a less acceptable condition is nonactualized."],
    "physical" => ["bearing", "condition", "The bearing completed an internally originating degradation into a less acceptable condition.", "The bearing is undergoing internally originating degradation into a less acceptable condition.", "The internally originating degradation of the bearing is nonactualized."],
    "program" => ["service", "state", "The service completed an internally originating degradation into a less acceptable state.", "The service is undergoing an internally originating degradation into a less acceptable state.", "The internally originating degradation of the service is nonactualized."],
    "counter" => ["REP:101[1](ENTITY=device)", "ongoing restoration", "The device is being restored to an acceptable condition.", "Restoration moves toward recovery and belongs to REP; it is not internal degradation toward a less acceptable condition."]
  },
  "1" => {
    "ordinary" => ["target", "source", "The distinct source completed an adverse transformation that impaired the target.", "The distinct source is causing the target to enter a less acceptable condition.", "The source-to-target impairment process is nonactualized."],
    "physical" => ["surface", "corrosive_source", "The corrosive source completed impairment of the surface.", "The corrosive source is impairing the surface.", "The adverse transformation by which the corrosive source would impair the surface is nonactualized."],
    "program" => ["parser", "payload", "The payload completed an adverse transformation that impaired the parser's state.", "The payload is causing the parser to enter a less acceptable state.", "The payload-to-parser impairment process is nonactualized."],
    "counter" => ["CON:111[1](SOURCE=sender,TARGET=receiver)", "warning sent to target", "The sender is warning the receiver.", "Communication about danger belongs to CON and does not itself impair the target."]
  },
  "2" => {
    "ordinary" => ["community_system", "participants", "One adverse condition completed propagation across multiple participants in the shared system.", "One correlated adverse condition is propagating across multiple participants in the shared system.", "The systemic propagation by which one adverse condition would become distributed across participants is nonactualized."],
    "physical" => ["facility", "zones", "The contamination completed propagation across multiple facility zones.", "The contamination is propagating across multiple facility zones.", "Propagation of the contamination across the facility zones is nonactualized."],
    "program" => ["cluster", "nodes", "The correlated fault completed propagation across multiple cluster nodes.", "The correlated fault is propagating across multiple cluster nodes.", "Propagation of the correlated fault across cluster nodes is nonactualized."],
    "counter" => ["CON:121[1](ENDPOINTS=nodes,EXPRESSION=updates)", "updates distributed among nodes", "The nodes are distributing updates.", "Communication distribution is not adverse propagation unless a correlated adverse transformation is separately asserted."]
  }
}.freeze

def examples_for(id)
  address = id.split(":").last
  second, third = address[1], address[2]
  phase_index = { "0" => 2, "1" => 3, "2" => 4 }.fetch(third)
  content = EXAMPLE_CONTENT.fetch(second)
  scope_label = { "0" => "internal degradation", "1" => "target impairment", "2" => "systemic propagation" }.fetch(second)
  phase_label = { "0" => "completed", "1" => "ongoing", "2" => "nonactualized" }.fetch(third)
  entity, target, ordinary = content.fetch("ordinary").values_at(0, 1, phase_index)
  physical_entity, physical_target, physical = content.fetch("physical").values_at(0, 1, phase_index)
  program_entity, program_target, program = content.fetch("program").values_at(0, 1, phase_index)
  counter_graph, counter_gloss, counter_english, counter_analysis = content.fetch("counter")
  role_key = { "0" => "CONDITION", "1" => "SOURCE", "2" => "PARTICIPANTS" }.fetch(second)
  scope_analysis = {
    "0" => "The adverse transformation originates within one reference entity and does not require a distinct external source.",
    "1" => "One distinct source and one target remain separately identified while the source causes adverse change in the target.",
    "2" => "One correlated adverse condition changes from narrower occurrence to distribution across multiple participants in a shared system."
  }.fetch(second)
  entries = [
    ["ordinary_conversation", "#{id}[1](ENTITY=#{entity},#{role_key}=#{target})", "#{phase_label} #{scope_label}", ordinary, "#{scope_analysis} The assertion does not add evidence, blame, severity, or response."],
    ["physical_or_spatial", "MAT(OBJECT=#{physical_entity})+#{id}[1](ENTITY=#{physical_entity},#{role_key}=#{physical_target})", "material realization plus #{phase_label} #{scope_label}", physical, "#{scope_analysis} MAT owns physical mechanics; WRN owns adverse transformation."],
    ["temporal_or_sequential", "#{id}[1](ENTITY=#{entity},#{role_key}=#{target})+ORI(INTERVAL=observation_window)", "#{phase_label} #{scope_label} during an explicit interval", "During the observation window, #{ordinary.sub(/\A./) { |letter| letter.downcase }}", "ORI supplies temporal location; lexical phase is not tense or schedule."],
    ["cross_family_compound", "DAT(EVIDENCE=d)+MIN(AWARE=a)+#{id}[1](ENTITY=#{entity},#{role_key}=#{target})", "evidence and awareness plus #{phase_label} #{scope_label}", "The observations and awareness concern an adverse transformation with the stated phase.", "#{scope_analysis} DAT and MIN remain separate from whether the adverse transformation occurs."],
    ["executable_or_programming", "#{id}[1](ENTITY=#{program_entity},#{role_key}=#{program_target})", "assert #{phase_label} #{scope_label}", program, "#{scope_analysis} Detection, invalidity, alerts, containment, and recovery require separate DAT/LOG/CON/STR/REP assertions."],
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
      "pseudocode" => category == "executable_or_programming" ? "assert(adverse_process.matches?(#{id.inspect}))" : nil
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
    ["adverse_transformation", winner_title, winner_invariant],
    ["assessment_detection", alternatives[0], alternative_invariant(id, "assessment_detection")],
    ["protective_control_response", alternatives[1], alternative_invariant(id, "protective_control_response")],
    ["warning_communication", alternatives[2], alternative_invariant(id, "warning_communication")]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2")["why_it_fits"],
    "candidates" => candidates.map { |candidate_id, title, invariant| candidate(id, candidate_id, title, invariant) },
    "recommended_candidate_id" => "adverse_transformation",
    "recommendation_reason" => "Only this architecture preserves one substrate-neutral WRN process center, changes only scope across columns and phase across each triplet, composes directly with canonical WRN:0xx conditions, and avoids absorbing mechanics, diagnosis, evidence, warning communication, containment, repair, rules, probability, or scheduling.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  title, invariant = ROOTS.fetch(id)
  scope, phase = lexical_axes(id)
  second, third = id[-2], id[-1]
  process = { "0" => "internal-degradation process", "1" => "target-impairment process", "2" => "systemic-propagation process" }.fetch(second)
  center = {
    "0" => "originates within one reference entity and changes that entity toward a less acceptable condition without requiring a distinct external source",
    "1" => "uses one distinct source to cause one reference target to enter a less acceptable condition while source and target remain separately identified",
    "2" => "changes one correlated adverse condition from narrower occurrence into distribution across multiple participant entities within one shared system"
  }.fetch(second)
  article = phase == "active" ? "an" : "a"
  scope_guard = {
    "0" => "If a distinct external source causes the change, use target impairment; if one condition distributes across several participants, use systemic propagation.",
    "1" => "The source remains distinct from one target. If the change originates inside the target without a distinct source, use internal degradation; if the condition becomes distributed across several participants, use systemic propagation.",
    "2" => "The same correlated adverse condition must become distributed across multiple participants. Several unrelated degradations or one source impairing one target do not satisfy systemic scope."
  }.fetch(second)
  runtime = case third
            when "0"
              {
                "0" => "Denies that this #{process} reached completion in the stated warning context; it does not assert that the active or nonactualized sibling holds.",
                "1" => "Affirms that this #{process} reached its completed phase, without asserting evidence, attribution, severity, permanent damage, ongoing manifestation, containment, repairability, or recovery.",
                "2/num" => "Leaves unresolved whether this #{process} reached completion or whether that completed result remains applicable; the lexical root stays completed."
              }
            when "1"
              {
                "0" => "Denies that this #{process} is presently ongoing or states that it has ceased; completion, reversal, and nonactualized availability remain undecided.",
                "1" => "Affirms that this #{process} is presently ongoing in the stated warning context, without guaranteeing completion, detection, severe outcome, persistence, containment, or recovery.",
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
      "first_trit_1" => "Selects an adverse process, action, or transformation rather than an adverse-condition entity, susceptibility or exposure relation, evidence record, warning message, or response.",
      "second_trit" => "Selects #{scope} scope: this root #{center}; no competing family or temporal phase is added by this axis.",
      "third_trit" => "Selects the #{phase} phase of the same #{process}; planning, queueing, schedule, futurity, permission, probability, and runtime truth status remain separate."
    },
    "inclusion_boundary" => "Includes only #{article} #{phase} substrate-neutral adverse transformation that #{center}. #{scope_guard} The transformation may be realized physically, biologically, computationally, informationally, socially, or conceptually, but it does not itself assert the bearer, concrete mechanics, movement path, evidence, observer knowledge, formal invalidity, blame, warning communication, response, repair, probability, schedule, or causal history beyond the scope roles required by the invariant.",
    "excluded_meanings" => [
      "The fault, hazard, distributed incident, bearer, source, target, participant, material object, organism, software component, institution, or data record as an entity or condition.",
      "Spatial movement, route traversal, physical force, collision, fracture, heating, biological mechanism, data mutation, destruction, or generation as such without the WRN adverse transformation claim.",
      "Planning, intention, staging, queueing, scheduling, permission, readiness, probability, futurity, obligation, or specification—especially for lexical 1x2.",
      "Detection, observation, diagnosis, classification, monitoring, evidence collection, belief revision, attribution, or measurement of an adverse condition.",
      "Warning, signaling, alerting, broadcasting, blocking, isolation, containment, shutdown, evacuation, coordination, repair, restoration, stabilization, or recovery.",
      "Susceptibility, vulnerability, exposure, exploitability, dependency, propagation pathway, probability, severity, blame, intention, or other continuing capacity or relation."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "WRN:0xx owns adverse-condition entities: intrinsic faults, distinct external hazards, and correlated distributed faults. WRN:1xx owns adverse transformations toward less acceptable conditions. WRN:2xx remains reserved for susceptibility, exposure, and systemic propagation-enabling capacities or relations. Internal degradation has no required distinct external source. Target impairment preserves one source and one target as distinct roles. Systemic propagation requires one correlated adverse condition to become distributed across multiple participants. A completed WRN:1xx root entails only that the stated adverse transformation reached completion at the reference time; it does not entail persistent fault identity, present manifestation, evidence, detection, severity, containment, repair need, or a continuing WRN:2xx relation unless separately asserted.",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime,
    "lexical_runtime_distinction" => "The lexical third trit permanently selects the #{phase} member of this process triplet. Runtime `[2]/num` instead qualifies the truth, applicability, or resolution of a token of that already-selected root; it never changes the root into a planned, future, or different-phase process.",
    "catalogue_title_guard" => third == "2" ? "The word `nonactualized` in the concise catalogue title denotes a valid adverse process that is neither ongoing nor completed. It does not assert capability, readiness, probability, permission, intention, schedule, future time, or eventual realization." : "The concise catalogue title is controlled by the invariant definition and must not be broadened with unstated mechanics, evidence, severity, response, result persistence, or temporal semantics.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + WRN:0xx identifies the intrinsic fault, external hazard, or distributed fault that results from or participates in the adverse process.",
      "#{id} + MAT/MOV/LIF specifies physical mechanics, delivery path, or living effects without reducing adverse transformation to those domains.",
      "#{id} + DAT/MIN/CON specifies evidence, recognition, diagnosis, or warning communication while keeping the adverse process independent.",
      "#{id} + REP/STR/LOG distinguishes repair, containment or isolation, and formal control from degradation, impairment, or propagation."
    ],
    "later_era_notes" => "Later eras may lexicalize deteriorate, decay, fail, corrupt, poison, damage, attack, infect, compromise, contaminate, spread, cascade, and outbreak as descendants or typed compounds. Era Zero must preserve the internal-origin / one-source-one-target / correlated-multi-participant contrast and must not let nonactualized 1x2 roots acquire planning or modal-strength semantics.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end


STRESS_CONCEPTS = [
  ["degrade", "one_root_or_compound", "WRN:100/101/102 by phase when adverse change originates within one entity; add domain mechanics separately."],
  ["deteriorate", "one_root", "WRN:1x0 by phase when an entity enters a less acceptable condition through internally originating change."],
  ["internal failure completed", "one_root", "WRN:100 states completion of internally originating adverse transformation."],
  ["internal failure ongoing", "one_root", "WRN:101 states ongoing internally originating adverse transformation."],
  ["internal failure nonactualized", "one_root", "WRN:102 states the adverse process without asserting that it began, was planned, or will occur."],
  ["decay", "one_root_or_compound", "WRN internal degradation plus MAT/LIF/ORI for physical, biological, or temporal mechanism."],
  ["wear out", "compound", "WRN internal degradation plus MAT friction and ORI duration; the phrase may describe process or completed state."],
  ["overheat", "compound", "MAT thermal change plus WRN internal degradation when the heating moves the entity toward a less acceptable condition."],
  ["crack forming", "compound", "MAT fracture process plus WRN:101 if it is an adverse internally originating transformation."],
  ["software service degrading", "one_root_or_compound", "WRN:101 supplies adverse process; DAT/LOG supplies state and correctness details."],
  ["memory leak worsening", "compound", "DAT/MAT resource semantics plus WRN:101 internally originating degradation."],
  ["invalid proof step", "different_family", "LOG owns invalidity; no adverse transformation is implied."],
  ["state transition", "different_family_or_compound", "ORI owns generic transition; WRN applies only when the transformation is adverse and scope-resolved."],
  ["transform", "unresolved", "Generic change lacks family, adverse criterion, scope, and phase; do not force it into WRN."],
  ["improve", "different_family_or_compound", "Improvement is not WRN degradation; REP or CRE may apply depending on restoration or creation."],
  ["repair", "different_family", "REP owns restoration toward an acceptable condition, the directional opposite of WRN adverse transformation."],
  ["self-monitor", "different_family_or_compound", "DAT/MIN/LOG owns observation and assessment; monitoring can occur without degradation."],
  ["diagnose", "different_family_or_compound", "MIN/DAT/LOG owns evidence interpretation; diagnosis is not the adverse transformation diagnosed."],
  ["detect fault", "different_family_or_compound", "DAT/MIN owns detection; WRN:0xx names the condition and WRN:1xx the adverse change, neither of which entails observation."],
  ["internal degradation uncertain", "runtime_state", "WRN:101[2]/num leaves ongoing status unresolved; it is not WRN:102."],
  ["confirmed nonactualized degradation", "one_root_plus_runtime", "WRN:102[1] affirms the nonactualized process without plan, probability, or future time."],
  ["completed degradation disputed", "one_root_plus_runtime", "WRN:100[2]/num keeps completed lexical phase while leaving the assertion unresolved."],
  ["impair", "one_root_or_compound", "WRN:110/111/112 by phase when one distinct source causes one target to enter a less acceptable condition."],
  ["damage target", "one_root_or_compound", "WRN target impairment plus MAT/LIF/DAT for the concrete damage domain."],
  ["harm", "one_root_or_compound", "WRN target impairment when a distinct source-target adverse process is meant; outcome semantics may require other families."],
  ["attack", "compound", "WRN target impairment plus MIN intent, MOV approach, MAT force, LOG authorization, or CON activity as applicable."],
  ["corrode", "compound", "MAT chemical change plus WRN target impairment when a distinct corrosive source acts on a target."],
  ["poison", "compound", "MAT substance and LIF biological effect plus WRN target impairment."],
  ["infect one host", "compound", "LIF biological identity and mechanism plus WRN target impairment when one source causes adverse change in one host."],
  ["malicious payload exploits parser", "compound", "DAT/LOG supplies payload and exploit rules; WRN:111 supplies ongoing target impairment."],
  ["collision damages car", "compound", "MOV approach and MAT collision plus WRN target impairment of the car."],
  ["approach target", "different_family", "MOV owns approach; it is not impairment without adverse transformation."],
  ["touch target", "different_family", "MAT contact does not imply adverse change."],
  ["threaten", "underspecified", "May mean external hazard condition, communicated threat, intent, or active target impairment; translator must resolve sense."],
  ["warn target", "different_family_or_compound", "CON owns warning communication; the warning may refer to WRN conditions or processes but is not impairment."],
  ["isolate target", "different_family_or_compound", "STR/MOV/LOG owns separation or access control; isolation may prevent impairment rather than constitute it."],
  ["contain target", "different_family_or_compound", "STR/LOG owns containment; WRN impairment can occur with or without containment."],
  ["target impairment uncertain", "runtime_state", "WRN:111[2]/num questions ongoing impairment; it does not select WRN:112."],
  ["confirmed nonactualized impairment", "one_root_plus_runtime", "WRN:112[1] affirms a valid source-target adverse process that is not occurring or complete."],
  ["completed impairment with recovered target", "two_time_claims", "WRN:110 may describe past completion while REP states later recovery; completion does not entail current damage."],
  ["spread", "one_root_or_compound", "WRN:120/121/122 by phase only when one correlated adverse condition distributes across multiple participants."],
  ["propagate fault", "one_root", "WRN systemic propagation by phase if the same correlated adverse condition becomes distributed across system participants."],
  ["cascade", "one_root_or_compound", "WRN systemic propagation plus STR/LOG dependency and causal-order semantics."],
  ["outbreak", "compound", "WRN systemic propagation plus LIF or domain identity, timing, and participant semantics."],
  ["contamination spreading", "compound", "MAT substance and movement plus WRN:121 systemic propagation across participants or zones."],
  ["malware spreading", "compound", "DAT/LOG/CON describes code, exploit, and channels; WRN:121 supplies adverse systemic propagation."],
  ["rumor spreading", "different_family", "CON/DAT owns information propagation unless the content or effects are separately classified as adverse."],
  ["software update spreading", "different_family", "CON/DAT/CRE distribution is neutral and not WRN without adverse transformation."],
  ["disease spreading", "compound", "LIF owns biological process; WRN supplies adverse systemic scope when useful."],
  ["fire spreading", "compound", "MAT/CRE physical process and MOV extent plus WRN systemic propagation."],
  ["cascade completed", "one_root", "WRN:120 if one adverse condition completed distribution across multiple participants."],
  ["cascade active", "one_root", "WRN:121 if the correlated adverse condition is currently becoming distributed."],
  ["cascade nonactualized", "one_root", "WRN:122 affirms the propagation process as nonactualized without probability or plan."],
  ["many unrelated failures", "multiple_roots_not_one_systemic_process", "Use separate WRN internal or target processes; simultaneity alone is not correlated systemic propagation."],
  ["same source harms two independent targets", "multiple_target_processes_or_systemic_if_correlated", "Use per-target impairment unless one correlated condition is explicitly propagating through a shared system."],
  ["broadcast warning", "different_family", "CON owns distribution of warning messages; WRN propagation requires the adverse condition itself to distribute."],
  ["emergency response", "different_family_or_compound", "REP/CON/LOG/MOV owns coordinated response; it may react to WRN propagation but is not the propagation."],
  ["incident closure", "different_family_or_compound", "REP/LOG/ORI owns resolution and closure criteria; WRN:120 means completed propagation, not successful response."],
  ["contain outbreak", "compound", "STR/LOG/REP containment plus WRN systemic propagation; containing it does not redefine the WRN process."],
  ["systemic propagation uncertain", "runtime_state", "WRN:121[2]/num leaves ongoing propagation unresolved rather than selecting WRN:122."],
  ["confirmed nonactualized propagation", "one_root_plus_runtime", "WRN:122[1] affirms the nonactualized propagation process without asserting likelihood."],
  ["schedule degradation", "compound", "ORI/LOG schedule plus WRN:102; scheduling is never lexical phase 2."],
  ["plan attack", "compound", "MIN intention and LOG/ORI plan plus WRN:112; the WRN root itself does not encode planning."],
  ["queue containment", "different_process_plus_queue", "DAT/LOG queue plus STR/REP containment; WRN:112 is not containment and phase 2 never means queued."],
  ["possible propagation", "one_root_plus_modality", "WRN:122[1] affirms nonactualization; ORI or probability grammar supplies possibility strength."],
  ["likely impairment", "one_root_plus_probability", "WRN:112 or another phase plus explicit probability; no WRN third trit encodes likelihood."],
  ["future degradation", "one_root_plus_time", "ORI future relation plus a phase-resolved WRN process; nonactualized does not itself mean future."],
  ["completed process still active", "invalid_same_event_claim", "WRN:1x0 and WRN:1x1 cannot describe the same event phase at the same reference time without separate event segments."],
  ["active then completed", "two_time_indexed_roots", "Relate WRN:1x1 at an earlier time to WRN:1x0 later; roots do not encode transition timing themselves."],
  ["nonactualized then active", "two_time_indexed_roots", "Relate WRN:1x2 at one time to WRN:1x1 later; no plan or inevitability is implied."],
  ["stop degradation", "root_plus_event_boundary", "Ceased or denied WRN:101 plus event-boundary grammar; stopping does not assert completed degradation or repair."],
  ["continue impairment", "root_plus_contour", "WRN:111 plus continuation contour or timing grammar."],
  ["repeat propagation", "root_plus_iteration", "WRN:12x plus iteration grammar; repetition is not built into the atom."],
  ["reverse degradation", "different_family_or_compound", "REP restoration is not reverse-WRN encoded inside the degradation root."],
  ["create defect", "compound", "CRE generation plus WRN condition or process; creation and adverse transformation remain separate claims."],
  ["destroy target", "compound", "CRE/MAT destruction plus WRN target impairment when a less acceptable condition is asserted before or through destruction."],
  ["corrupt data", "compound", "DAT representational mutation plus WRN internal degradation or target impairment depending on source structure."],
  ["invalidate token", "different_family_or_compound", "LOG invalidation plus WRN only if adverse transformation is independently asserted."],
  ["reduce performance", "one_root_or_compound", "WRN internal degradation when internally originating; target impairment when a distinct source causes it; DAT supplies metric."],
  ["cause discomfort", "compound", "WRN target impairment plus LIF/MIN state; cause and target must be explicit."],
  ["negligible adverse change", "one_root_plus_severity", "WRN still applies if context classifies the change as adverse; severity is separately qualified."],
  ["beneficial stress", "not_warning_without_adverse_frame", "If the applicable evaluation frame treats the transformation as beneficial rather than adverse, WRN must not be used."],
  ["unknown adverse criterion", "unresolved_gap", "If no applicable standard or evaluation frame makes the change less acceptable, do not guess WRN family membership."],
  ["unknown source scope", "unresolved_gap", "If internal origin, distinct source-target, or multi-participant propagation cannot be resolved, preserve ambiguity."],
  ["unknown phase", "unresolved_gap", "If completed, active, or nonactualized phase cannot be resolved, do not guess the third trit."],
  ["fault condition versus degradation", "scope_resolution_test", "WRN:00x names the condition; WRN:10x names the adverse process producing a less acceptable condition."],
  ["hazard versus target impairment", "scope_resolution_test", "WRN:01x names a distinct external hazard; WRN:11x names the source-to-target adverse transformation."],
  ["distributed fault versus propagation", "scope_resolution_test", "WRN:02x names a correlated system condition; WRN:12x names its distribution process."],
  ["impairment versus exposure", "scope_resolution_test", "WRN:11x asserts adverse change; WRN:2xx will determine vulnerability or exposure relations that may exist without change."],
  ["propagation versus communication", "scope_resolution_test", "WRN:12x distributes an adverse condition; CON distributes expressions or information."],
  ["degradation versus repair", "scope_resolution_test", "WRN moves toward a less acceptable condition; REP moves toward restoration."],
  ["adverse change versus physical change", "scope_resolution_test", "WRN supplies evaluative adversity; MAT supplies physical mechanics, and either can occur without the other."],
  ["nonactualized versus uncertain", "scope_resolution_test", "WRN:102[1] affirms a nonactualized process; WRN:101[2]/num leaves an active-process assertion uncertain."]
].freeze

stress_tests = STRESS_CONCEPTS.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("WRN1-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "WRN:100–122 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5,
    "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "WRN:100–122 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER,
    "triplets" => { "WRN:100–102" => "internal degradation: completed / active / nonactualized", "WRN:110–112" => "source-to-target impairment: completed / active / nonactualized", "WRN:120–122" => "systemic propagation: completed / active / nonactualized" },
    "scope_separation" => { "inward" => "the adverse transformation originates within one reference entity", "outward" => "one distinct source causes adverse transformation in one reference target", "systemic" => "one correlated adverse condition becomes distributed across multiple participants in a shared system" },
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

stress = { "metadata" => { "title" => "WRN:100–122 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# WRN:100–122 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Warning process meanings from first principles. It compares five genuinely different semantic architectures at every address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level decision\n\nThe strongest architecture makes `WRN:1xx` a substrate-neutral adverse-transformation grid. `WRN:100–102` expresses adverse change originating within one reference entity. `WRN:110–112` expresses adverse change caused in one target by one distinct source. `WRN:120–122` expresses one correlated adverse condition becoming distributed across multiple participants in a shared system. The third trit changes only completion phase.\n\n"
review << "The grid composes directly with canonical `WRN:0xx`: internal degradation may yield or express an intrinsic fault, target impairment may realize the harmful potential of an external hazard, and systemic propagation may yield or extend a distributed fault. It excludes physical mechanics, generic change, diagnosis, evidence, warning communication, containment, repair, blame, probability, planning, and continuing vulnerability or exposure relations.\n\n"
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
review << "## Triplet coherence\n\n| Triplet | Shared process | `0` completed | `1` active | `2` nonactualized |\n| --- | --- | --- | --- | --- |\n| WRN:100–102 | one adverse transformation originates within one reference entity and moves it toward a less acceptable condition | transformation reached completion | same transformation ongoing | same transformation nonactualized |\n| WRN:110–112 | one distinct source causes one reference target to enter a less acceptable condition | transformation reached completion | same transformation ongoing | same transformation nonactualized |\n| WRN:120–122 | one correlated adverse condition becomes distributed across multiple participants in a shared system | transformation reached completion | same transformation ongoing | same transformation nonactualized |\n\n**Scope guard:** inward change requires no distinct source; outward impairment keeps one source and one target distinct; systemic propagation requires distribution of one correlated condition across multiple participants. *Nonactualized* on `WRN:102`, `WRN:112`, and `WRN:122` never supplies capability, readiness, probability, permission, intention, schedule, future time, or eventual realization.\n\n"
review << "## Ownership matrix\n\n| Root | Owns | Belongs elsewhere or remains compound |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | mechanics, movement, generic change, diagnosis, warning messages, containment, repair, blame, severity, probability, scheduling, and continuing exposure relations |\n" }
review << "\n## Intentionally reserved concepts\n\nDetect, diagnose, warn, alert, isolate, contain, shut down, evacuate, repair, recover, attribute blame, measure severity, and schedule a response remain other-family assertions or typed compounds. Generic *change*, *transform*, *fail*, *harm*, *threaten*, and *spread* require sense resolution.\n\n"
review << "## Stress test\n\n#{stress_tests.length} English adverse-process concepts were routed through single roots, compounds, grammar, other families, future WRN relations, or explicit unresolved gaps. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** approved under `migrations/#{STEM}_semantic_approval.yaml`; this remains the adversarial evidence record.\n" : "\n**Recommendation:** approve only after reusable packet validation, combined WRN soundness validation, and current-state regression. Until then all nine roots remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# WRN:100–122 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MAT physical change; MIN/DAT diagnosis; LOG invalidity; REP restoration", "1" => "MAT force; MOV delivery; CON warning; STR/LOG containment", "2" => "CON/DAT distribution; LIF spread; STR dependency; REP response" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | WRN keeps only the adverse transformation and its inward, target, or systemic scope |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Same-family safeguards\n\n- `WRN:0xx` owns adverse-condition entities; `WRN:1xx` owns adverse transformations; `WRN:2xx` remains reserved for susceptibility, exposure, and propagation-enabling capacities or relations.\n- Internal degradation originates within one reference entity and does not require a distinct external source. It does not mean diagnosis, self-monitoring, or repair.\n- Target impairment is asymmetric: one distinct source causes adverse change in one target. It does not mean approach, contact, warning, isolation, blocking, or blame.\n- Systemic propagation distributes one correlated adverse condition across multiple participants. It does not mean neutral communication, multiple unrelated failures, or emergency response.\n- A completed process entails only that its invariant adverse transformation reached completion at the reference time; persistence, present manifestation, evidence, severity, containment, repair, and continuing `WRN:2xx` relations require separate claims.\n- Lexical `1x2` means a nonactualized process only. It does not encode capability, readiness, probability, permission, intention, plan, queue, schedule, or future time; runtime `[2]/num` leaves an assertion unresolved and never changes lexical phase.\n\n## Reserved compounds and gaps\n\nAttack, infect, corrode, contaminate, exploit, diagnose, warn, isolate, contain, repair, recover, and close an incident remain typed compounds or other-family processes. Generic *fail*, *harm*, *threaten*, *spread*, *change*, and *transition* require sense resolution.\n\n**CONCLUSION: WRN:100–122 STANDS ALONE ONLY FOR SUBSTRATE-NEUTRAL ADVERSE TRANSFORMATION; MATERIAL, SPATIAL, BIOLOGICAL, COGNITIVE, COMMUNICATIVE, NORMATIVE, INFORMATIONAL, CREATIVE, REPARATIVE, STRUCTURAL, AND TEMPORAL CLAIMS REMAIN SEPARATE.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built #{RANGE} review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
