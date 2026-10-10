#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "REP:200–222"
STEM = "REP_200_222"
IDS = EraZeroValidation.ids_for_range(RANGE)
SEMANTIC_CENTER = "restorative-transformation affordance: internal recoverability, source-target restorative applicability, and systemic restoration pathways"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "REP:200" => ["stable resilience", "An entity has a dependable inward capacity to withstand damage and return to valid function."],
  "REP:201" => ["active regeneration", "An entity's capacity to heal, adapt, restore, or correct itself is presently available."],
  "REP:202" => ["reserve recoverability", "Recovery remains possible through dormant backups, reserves, or undeveloped regenerative capacity."],
  "REP:210" => ["maintenance bond", "A stable relation establishes responsibility, compatibility, or access for repairing a target."],
  "REP:211" => ["active care relation", "One participant is actively sustaining, healing, correcting, or restoring another target."],
  "REP:212" => ["unconfirmed repairability", "A target may be repairable or compatible with a remedy, but the relation is not yet verified."],
  "REP:220" => ["stable redundancy", "A system has established backup, substitution, and recovery relationships that preserve function."],
  "REP:221" => ["adaptive recovery network", "A distributed system is actively reallocating support and repair capacity around damage."],
  "REP:222" => ["possible recovery path", "A system-level route back to valid function could exist but has not yet been demonstrated."]
}.freeze

ROOTS = {
  "REP:200" => ["persistent internal recoverability", "A persistent capacity of one reference entity to undergo internally originating restoration under qualifying conditions, independently of whether that capacity is presently operative."],
  "REP:201" => ["operative internal recoverability", "A capacity of one reference entity to undergo internally originating restoration that is presently operative under the applicable conditions."],
  "REP:202" => ["latent internal recoverability", "A capacity of one reference entity to undergo internally originating restoration that exists without being presently operative under the applicable conditions."],
  "REP:210" => ["persistent source-target restorative relation", "A persistent restorative applicability relation between one distinct source and one reference target that can enable source-to-target restoration under qualifying conditions, independently of whether that relation is presently operative."],
  "REP:211" => ["operative source-target restorative relation", "A restorative applicability relation between one distinct source and one reference target that presently enables that source to cause target restoration under the applicable conditions."],
  "REP:212" => ["latent source-target restorative relation", "A restorative applicability relation between one distinct source and one reference target that exists without presently enabling that source to cause target restoration under the applicable conditions."],
  "REP:220" => ["persistent systemic restoration pathway", "A persistent pathway relation across multiple participants in one shared system through which one shared restoration condition can become realized, independently of whether that pathway is presently operative."],
  "REP:221" => ["operative systemic restoration pathway", "A pathway relation across multiple participants in one shared system that presently enables one shared restoration condition to become realized among them."],
  "REP:222" => ["latent systemic restoration pathway", "A pathway relation across multiple participants in one shared system through which one shared restoration condition can become realized but that is not presently operative."]
}.freeze

ALT_TITLES = {
  "REP:200" => ["persistent internal resistance capacity", "persistent internal maintenance capacity", "persistent internal recovery resource"],
  "REP:201" => ["operative internal resistance capacity", "operative internal maintenance capacity", "operative internal recovery resource"],
  "REP:202" => ["latent internal resistance capacity", "latent internal maintenance capacity", "latent internal recovery resource"],
  "REP:210" => ["persistent target protection relation", "persistent target service relation", "persistent target remedy resource"],
  "REP:211" => ["operative target protection relation", "operative target service relation", "operative target remedy resource"],
  "REP:212" => ["latent target protection relation", "latent target service relation", "latent target remedy resource"],
  "REP:220" => ["persistent systemic resilience network", "persistent systemic maintenance network", "persistent systemic backup network"],
  "REP:221" => ["operative systemic resilience network", "operative systemic maintenance network", "operative systemic backup network"],
  "REP:222" => ["latent systemic resilience network", "latent systemic maintenance network", "latent systemic backup network"]
}.freeze

SCORE_BASES = {
  "phase2_mixed" => [5, 7, 8, 5, 4, 7, 8, 8],
  "restoration_affordance" => [10, 10, 10, 10, 9, 10, 10, 10],
  "protective_resilience" => [9, 8, 7, 8, 6, 9, 9, 9],
  "maintenance_service_relation" => [8, 8, 7, 7, 6, 9, 10, 8],
  "backup_resource_network" => [8, 8, 7, 7, 5, 9, 9, 9]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, physiology, health, immunity, regeneration mechanisms, care roles, and social participants. REP can classify a living bearer as recoverable or linked to a restorative source without replacing biological facts.",
  "MOV" => "MOV owns position, displacement, routes, approach, traversal, and return. A restorative source may travel along a route, but REP:2xx names only the typed capacity or relation enabling restoration.",
  "MAT" => "MAT owns substance, force, energy, contact, compatibility, material reserves, and physical coupling. Those properties may realize repairability or a restoration pathway, but REP supplies restorative enablement and scope.",
  "MIN" => "MIN owns awareness, expectation, confidence, diagnosis, intention, and belief in recovery. Recoverability and restorative applicability may hold without any observer knowing or believing that they hold.",
  "CON" => "CON owns service relationships, channels, coordination, requests, and participant exchange. A communicative or social relation may help realize a restoration pathway but is not itself restorative enablement.",
  "WRN" => "WRN owns faults, hazards, degradation, impairment, and adverse propagation. REP:2xx states capacity for restoration, not the adverse condition or process from which restoration may be needed.",
  "STR" => "STR owns structural interfaces, compatibility, dependency, topology, redundancy, and reconfiguration affordances. Structure may realize a restoration relation or pathway, but REP adds typed restorative enablement.",
  "LOG" => "LOG owns validity, constraint satisfaction, permission, compatibility rules, preconditions, and quantified inference. REP:2xx is not authorization, a probability judgment, or a rule saying restoration may occur.",
  "DAT" => "DAT owns evidence, measurements, repair records, backups, checkpoints, provenance, and information-flow graphs. A record or backup can support or describe a REP affordance but is not the recoverability, restorative relation, or pathway itself.",
  "CRE" => "CRE owns creation, design, replacement, reconstruction, mutation, and fabrication. Creating a remedy or pathway is separate from the resulting REP restorative affordance.",
  "ORI" => "ORI owns general possibility, necessity, time, manifestation, and modality. REP:2xx states a typed restorative affordance or relation; it does not encode unrestricted possibility, probability, schedule, or future time."
}.freeze

def phase_words(id)
  case id[-1]
  when "0" then ["persistent", "persistent independently of current operation"]
  when "1" then ["operative", "presently operative"]
  else ["latent", "existing without present operation"]
  end
end

def scope_words(id)
  case id[-2]
  when "0" then ["inward", "one reference entity and its internally originating restorative change", "internal recoverability"]
  when "1" then ["outward", "one distinct restorative source relative to one reference target", "source-target restorative applicability relation"]
  else ["systemic", "one shared restoration condition across multiple participants in a shared system", "systemic restoration pathway"]
  end
end

def score_profile(id, candidate_id)
  values = SCORE_BASES.fetch(candidate_id).dup
  second = id[-2].to_i
  third = id[-1].to_i
  case candidate_id
  when "phase2_mixed"
    values[0] -= 1 if [0, 1].include?(second)
    values[3] -= 1 if third == 2
  when "restoration_affordance"
    values[6] += 1 if second == 1
    values[4] += 1 if second == 0
  when "protective_resilience"
    values[1] += 1 if second == 0
    values[6] += 1 if second == 1
  when "maintenance_service_relation"
    values[7] += 1 if second == 2
    values[3] -= 1 if second == 1
  when "backup_resource_network"
    values[7] += 1 if second == 1
    values[4] -= 1 if second == 2
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, candidate_id)
  scope, _scope_description, center = scope_words(id)
  phase, phase_description = phase_words(id)
  case candidate_id
  when "phase2_mixed"
    {
      "why_it_fits" => "The Phase 2 label follows the #{phase_description} #{scope} slot and uses familiar Repair vocabulary such as resilience, regeneration, repairability, care, redundancy, and recovery paths.",
      "useful_coverage" => "It reaches common talk about self-healing, remedies, service relations, backups, redundancy, and distributed recovery.",
      "semantic_territory_consumed" => "It mixes restorative capacity, actual care processes, protection, maintenance responsibility, observer verification, resources, probability, and system behavior.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one lexical-status contrast; REP:211 duplicates active target restoration, REP:212 conflates uncertainty with latency, and REP:222 absorbs possibility and evidence."
    }
  when "restoration_affordance"
    {
      "why_it_fits" => "It makes first-trit 2 the capacity or qualifying relation for the matching canonical REP:1#{id[-2]}x transformation while preserving #{scope} scope and #{phase} expression.",
      "useful_coverage" => "It covers recoverability, repairability, remedy applicability, rehabilitative compatibility, restoration channels, disaster-recovery paths, and systemic recovery affordances.",
      "semantic_territory_consumed" => "Only the substrate-neutral restorative affordance that enables #{center}. Conditions, actual restoration, mechanics, records, resources, service obligations, protection, and modality remain separate.",
      "conflicts_or_future_limitations" => "The technical words applicability and pathway must be restricted to restorative enablement rather than generic compatibility or route identity, but the invariant and compounds make that boundary explicit."
    }
  when "protective_resilience"
    {
      "why_it_fits" => "Resistance, immunity, shielding, and resilience are related to Repair and can be expressed at #{phase} #{scope} scope.",
      "useful_coverage" => "It would cover withstand, resist, absorb, shield, prevent failure, preserve operation, and fail-safe behavior.",
      "semantic_territory_consumed" => "It consumes prevention and protection before restorative transformation is needed.",
      "conflicts_or_future_limitations" => "WRN/STR/LOG and domain mechanics own resistance and protection; something can be highly recoverable yet unable to withstand the initiating damage."
    }
  when "maintenance_service_relation"
    {
      "why_it_fits" => "Internal maintenance capacity, target service relationships, and systemic maintenance networks are plausible Repair affordances at #{scope} scope.",
      "useful_coverage" => "It would cover maintainability, responsibility, service access, care relations, support contracts, and maintenance organizations.",
      "semantic_territory_consumed" => "It consumes preservation, obligation, participant roles, communication, scheduling, and service administration.",
      "conflicts_or_future_limitations" => "CON owns service relations, LOG owns obligations, DAT/ORI owns schedules, and maintainability does not require a capacity to restore an unrealized condition."
    }
  else
    {
      "why_it_fits" => "Reserves, remedies, backups, spare parts, and redundant networks are concrete enablers of restoration at #{scope} scope.",
      "useful_coverage" => "It would cover medicine, tools, replacement parts, backups, golden images, reserve capacity, and redundant support nodes.",
      "semantic_territory_consumed" => "It consumes material, informational, creative, and organizational resources rather than the typed restorative capacity or relation.",
      "conflicts_or_future_limitations" => "MAT, DAT, CRE, LIF, and CON own the resources and participants; possessing a resource does not entail that it applies to or can restore the bearer."
    }
  end
end

def alternative_invariant(id, candidate_id)
  title = ALT_TITLES.fetch(id)[{"protective_resilience" => 0, "maintenance_service_relation" => 1, "backup_resource_network" => 2}.fetch(candidate_id)]
  case candidate_id
  when "protective_resilience"
    "The #{title} by which adverse transformation at the selected scope can be resisted before restoration is required."
  when "maintenance_service_relation"
    "The #{title} by which an acceptable condition can be preserved through service at the selected scope."
  else
    "The #{title} constituted by a stored or assigned remedy resource at the selected scope."
  end
end

def atoms_slot_phrase(id)
  scope, scope_description, = scope_words(id)
  phase, = phase_words(id)
  "#{phase} #{scope} restorative capacity or relation concerning #{scope_description}"
end

def candidate(id, candidate_id, title, invariant)
  values = score_profile(id, candidate_id)
  scores = EraZeroValidation::SCORE_KEYS.zip(values).to_h
  {
    "candidate_id" => candidate_id,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => candidate_analysis(id, candidate_id),
    "scores" => scores,
    "total" => scores.values.sum,
    "maximum" => scores.length * 10
  }
end

def nearest_neighbors(id)
  second = id[-2]
  third = id[-1]
  siblings = %w[0 1 2].reject { |value| value == third }.map { |value| "REP:2#{second}#{value}" }
  column = case second
           when "0" then %w[REP:100 REP:101 REP:102 REP:000]
           when "1" then %w[REP:110 REP:111 REP:112 REP:010]
           else %w[REP:120 REP:121 REP:122 REP:020]
           end
  siblings + column
end

def runtime_meanings(id)
  title = ROOTS.fetch(id).first
  third = id[-1]
  if third == "0"
    {
      "0" => "Denies that the #{title} persists in the stated restoration context; it does not select the operative or latent sibling and does not establish a different restorative affordance.",
      "1" => "Affirms that the #{title} persists independently of current operation, without asserting that internal, target, or systemic restoration is occurring.",
      "2/num" => "Leaves unresolved whether the #{title} persists; the lexical root remains the persistent member and does not become latent."
    }
  elsif third == "1"
    {
      "0" => "Denies that the #{title} is presently operative, without thereby asserting that no persistent or latent restorative affordance exists.",
      "1" => "Affirms that the #{title} is presently operative under the applicable conditions, without asserting that the corresponding restorative transformation is underway.",
      "2/num" => "Leaves current operation of the #{title} unresolved; runtime uncertainty does not change the lexical operative status or select the latent sibling."
    }
  else
    {
      "0" => "Denies that the #{title} exists as the stated nonoperative restorative affordance; this does not establish that an operative sibling holds.",
      "1" => "Affirms the #{title} as existing but not presently operative; it does not assert hiddenness from an observer, uncertainty, probability, or future activation.",
      "2/num" => "Leaves unresolved even the assertion that the #{title} exists latently; this token-level uncertainty is distinct from lexical third-trit 2."
    }
  end
end

def examples_for(id)
  second = id[-2]
  title = ROOTS.fetch(id).first
  phase, = phase_words(id)
  case second
  when "0"
    subject = "one reference entity"
    role = "ENTITY=e,CAPACITY=r"
    ordinary = "This device #{phase == 'persistent' ? 'retains its internal recoverability whether or not it is currently operative' : phase == 'operative' ? 'has internal recoverability that is operative now' : 'retains internal recoverability that is not operative now'}."
    physical = "The organism has the stated capacity for internally originating restoration without asserting that healing is occurring."
    temporal = "During the observation interval, the same device #{phase == 'operative' ? 'has operative internal recoverability' : 'has the stated internal-recoverability status'}."
    program = "The service reports whether its self-recovery capacity has the stated status without asserting a recovery event."
    counter_graph = "REP:101[1](ENTITY=e,CONDITION=c)"
    counter_gloss = "active internal restoration"
    counter_english = "The service is recovering now."
    counter_analysis = "Use REP:101 for the ongoing restorative transformation; #{id} names capacity for that transformation, not its occurrence."
  when "1"
    subject = "one restorative source and one target"
    role = "SOURCE=s,TARGET=t"
    ordinary = "The remedy and this target #{phase == 'persistent' ? 'remain linked by a restorative applicability relation whether or not it is currently operative' : phase == 'operative' ? 'are linked by a restorative relation that is operative now' : 'retain a restorative relation that is not operative now'}."
    physical = "The treatment and the patient have the stated restorative applicability relation without asserting administration or healing."
    temporal = "During the service window, the source–target relation #{phase == 'operative' ? 'presently enables target restoration' : 'has the stated restorative status'}."
    program = "The recovery system reports whether one checkpoint and one database have the stated restorative applicability relation without asserting rollback."
    counter_graph = "REP:111[1](SOURCE=s,TARGET=t)"
    counter_gloss = "active target restoration"
    counter_english = "The source is restoring the target now."
    counter_analysis = "Use REP:111 for the ongoing restorative transformation; #{id} names the relation that can enable it, not the restoration process."
  else
    subject = "multiple participants in one shared system"
    role = "SYSTEM=k,PARTICIPANTS=p,CONDITION=c"
    ordinary = "The participants #{phase == 'persistent' ? 'remain connected by a systemic restoration pathway whether or not it is currently operative' : phase == 'operative' ? 'are connected by a systemic restoration pathway that is operative now' : 'retain a systemic restoration pathway that is not operative now'}."
    physical = "The facility zones have the stated restoration pathway without asserting that facility-wide restoration is occurring."
    temporal = "For this interval, the shared system #{phase == 'operative' ? 'has an operative systemic restoration pathway' : 'has the stated pathway status'}."
    program = "The recovery graph reports whether one shared service condition can be restored across nodes without asserting that recovery has begun."
    counter_graph = "REP:121[1](SYSTEM=k,PARTICIPANTS=p,CONDITION=c)"
    counter_gloss = "active systemic restoration"
    counter_english = "The participants are restoring the shared system now."
    counter_analysis = "Use REP:121 for the ongoing coordinated process; #{id} names the pathway that can enable it, not the restoration itself."
  end
  registers = second == "0" ? "mid register for the reference entity; low register for its recoverability" : second == "1" ? "high register for the distinct restorative source; low register for the target" : "sustained register for the shared system; parallel registers for participants"
  rows = [
    ["ordinary_conversation", "#{id}[1](#{role})", "affirm #{title} of #{subject}", ordinary, "The example asserts only restorative affordance, not a restoration event."],
    ["physical_or_spatial", "MAT(REALIZATION=m)+#{id}[1](#{role})", "material realization plus #{title}", physical, "MAT/LIF supplies concrete realization; REP supplies restorative enablement and scope."],
    ["temporal_or_sequential", "#{id}[1](#{role})+ORI(INTERVAL=w)", "#{title} during interval w", temporal, "ORI locates the claim in time; lexical third-trit status is not tense."],
    ["cross_family_compound", "DAT(RECORD=d)+STR(PATH=p)+#{id}[1](#{role})", "record and realization plus #{title}", "The record and structural path concern the restorative affordance, which still must hold independently.", "DAT and STR describe evidence or realization; neither substitutes for the REP affordance."],
    ["executable_or_programming", "#{id}[1](#{role})", "assert #{title}", program, "The executable test must preserve reference identity and scope roles explicitly."],
    ["counterexample", counter_graph, counter_gloss, counter_english, counter_analysis]
  ]
  rows.map do |category, graph, gloss, english, analysis|
    {
      "category" => category,
      "semantic_graph" => graph,
      "literal_gloss" => gloss,
      "natural_english" => english,
      "runtime_state" => 1,
      "contour" => category == "executable_or_programming" ? "level assertion or sharply falling execution" : "level declaration",
      "role_registers" => registers,
      "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid",
      "analysis" => analysis,
      "pseudocode" => category == "executable_or_programming" ? "assert(restorative_affordance.matches?(#{id.inspect}))" : nil
    }.compact
  end
end
scored_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  phase2_title, phase2_definition = PHASE2.fetch(id)
  winner_title, winner_definition = ROOTS.fetch(id)
  alternatives = ALT_TITLES.fetch(id)
  candidates = [
    ["phase2_mixed", phase2_title, phase2_definition],
    ["restoration_affordance", winner_title, winner_definition],
    ["protective_resilience", alternatives[0], alternative_invariant(id, "protective_resilience")],
    ["maintenance_service_relation", alternatives[1], alternative_invariant(id, "maintenance_service_relation")],
    ["backup_resource_network", alternatives[2], alternative_invariant(id, "backup_resource_network")]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "phase2_mixed")["why_it_fits"],
    "candidates" => candidates.map { |candidate_id, title, definition| candidate(id, candidate_id, title, definition) },
    "recommended_candidate_id" => "restoration_affordance",
    "recommendation_reason" => "Only the restoration-affordance architecture keeps one Repair semantic center, aligns each column with its canonical REP:1xx transformation, changes only persistent/operative/latent status within each triplet, and leaves conditions, processes, mechanics, protection, maintenance, resources, records, observer knowledge, and general modality separate.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  title, definition = ROOTS.fetch(id)
  scope, scope_description, center = scope_words(id)
  phase, phase_description = phase_words(id)
  second = id[-2]
  scope_guard = case second
                when "0" then "The recoverability belongs to one reference entity and concerns internally originating restoration; a distinct restorative source selects the outward column."
                when "1" then "The restorative applicability relation keeps one distinct source and one reference target separate; actual target restoration remains a REP:11x process."
                else "The pathway spans multiple participants and enables realization of one shared restoration condition; unrelated repairable entities do not form one systemic pathway."
                end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => title,
    "invariant_definition" => definition,
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_2" => "Selects a restorative capacity or enabling relationship rather than a restoration-condition entity or an actual restorative transformation.",
      "second_trit" => "Selects #{scope} scope: #{scope_description}; this root names the affordance for #{center} and no competing family claim.",
      "third_trit" => "Selects #{phase_description} expression of the same #{center}; runtime truth status, tense, probability, permission, and process phase remain separate."
    },
    "inclusion_boundary" => "Includes only the #{phase_description} substrate-neutral restorative affordance for #{center}. #{scope_guard} It may be realized physically, biologically, computationally, informationally, socially, or conceptually, but it does not assert that the matching REP:1xx transformation occurs, that a REP:0xx restoration condition is realized, or that mechanics, evidence, knowledge, protection, maintenance, resources, probability, temporal, or modal conditions hold.",
    "excluded_meanings" => [
      "The restoration condition, bearer, restorative source, target, participant, or shared system as an entity or realized state.",
      "An actual internal restoration, source-to-target restoration, or coordinated systemic restoration process at any completion phase.",
      "Physical force, energy, contact, compatibility, route, biological mechanism, structural dependency, communicative channel, data-flow edge, remedy, backup, spare, or caregiver as such.",
      "Detection, verification, diagnosis, evidence, service messages, belief, confidence, attribution, probability, expected success, or recovery score.",
      "Resistance, immunity, shielding, filtering, prevention, maintenance, preservation, service responsibility, replacement, or other protective or resource affordance.",
      "Readiness, plan, schedule, future time, permission, necessity, unrestricted possibility, or guaranteed occurrence or success of restoration."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "REP:0xx names restoration-condition entities: internal, target, and shared acceptable conditions. REP:1xx names actual restorative transformations: internal restoration, source-to-target restoration, and coordinated systemic restoration. REP:2xx names only the corresponding restorative affordance: inward recoverability, outward source-target restorative applicability, or a systemic restoration pathway. An affordance does not entail that its process begins or completes; an actual process does not entail that the affordance persists afterward. Persistent 2x0 identity may co-occur with its operative or latent sibling, while operative and latent are mutually exclusive for the same affordance at one reference time.",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_meanings(id),
    "lexical_runtime_distinction" => "Lexical third trit #{id[-1]} permanently selects the #{phase} member of this restorative-affordance triplet. Runtime `[2]/num` instead marks a token-level assertion pending, remembered, or unresolved. Thus `#{id}[1]` affirms the lexical concept, while a persistent or operative sibling carrying `[2]/num` remains that sibling and never becomes a latent root.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + REP:0xx identifies the internal, target, or shared restoration condition associated with the restorative affordance.",
      "#{id} + REP:1xx distinguishes a restorative affordance from its actual restoration process.",
      "#{id} + MAT/MOV/LIF/STR/CON specifies physical, spatial, biological, structural, or communicative realization without reducing the REP meaning to that realization.",
      "#{id} + DAT/MIN/LOG specifies evidence, recognition, formal conditions, or probability while keeping the restorative affordance independent.",
      "#{id} + CRE/WRN states replacement, reconstruction, or the adverse condition from which restoration is needed without importing those meanings into the atom."
    ],
    "later_era_notes" => "Later eras may lexicalize recoverable, repairable, healable, treatable, remediable, restorable-from-backup, service-compatible, rehabilitable, disaster-recoverable, and failover-capable descendants. Era Zero must retain the internal-recoverability / one-source-one-target restorative-applicability / shared-multi-participant pathway contrast and keep persistent, operative, and latent lexical status separate from runtime uncertainty and general modality.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

STRESS_CONCEPTS = [
  ["recoverable", "one_root_or_compound", "REP:200, 201, or 202 by persistent, operative, or latent inward recoverability; add the bearer and restoration domain separately."],
  ["repairable", "one_root_or_compound", "REP restorative affordance by scope and lexical status; repairability of a target normally selects REP:2x1."],
  ["restorable", "one_root_or_compound", "Select internal, target, or systemic REP:2xx according to the structure of the enabling capacity or relation."],
  ["healable", "compound", "REP recoverability or target restorative applicability plus LIF biological bearer and mechanism."],
  ["treatable", "compound", "REP:2x1 when one treatment source applies to one target; LIF/MAT supplies clinical mechanism."],
  ["remediable", "one_root_or_compound", "REP:2xx supplies restorative affordance while DAT, LOG, MAT, or another family supplies the defect domain."],
  ["rehabilitable", "compound", "REP restorative applicability plus LIF/CON/STR for function and participant roles."],
  ["salvageable", "compound", "REP target repairability plus MAT/CRE for material recovery and retained identity."],
  ["fixable", "underspecified", "May mean REP repairability, LOG correctability, DAT editability, or CRE replaceability; resolve the sense."],
  ["possible recovery", "affordance_plus_modality", "REP supplies typed recoverability or pathway; ORI/LOG supplies unrestricted possibility or probability."],
  ["likely recovery", "affordance_plus_probability", "REP supplies the restorative affordance while explicit probability grammar supplies likelihood."],
  ["guaranteed recovery", "compound_or_invalid_inference", "REP affordance alone never guarantees success; add LOG/ORI necessity and process/result claims if justified."],
  ["persistent internal recoverability", "one_root", "REP:200 preserves one entity's inward restoration capacity independently of current operation."],
  ["operative internal recoverability", "one_root", "REP:201 states that inward recoverability is presently operative under applicable conditions."],
  ["latent internal recoverability", "one_root", "REP:202 states that inward recoverability exists without being presently operative."],
  ["self-healing capacity", "one_root_or_compound", "REP:2x0 by status when restoration originates within the bearer; LIF/MAT supplies mechanism."],
  ["self-repair capability", "one_root", "REP:2x0 by lexical status when one entity can undergo internally originating restoration."],
  ["regenerative capacity", "compound", "REP internal recoverability plus LIF or MAT regeneration semantics."],
  ["automatic recovery capability", "compound", "REP internal recoverability plus DAT/LOG automation and trigger conditions."],
  ["fault tolerance", "different_family_or_compound", "Resistance to fault effects is protection, not necessarily recoverability; WRN/STR/LOG may apply."],
  ["resilient", "underspecified", "May mean resistance, continued function, fast recovery, or typed recoverability; do not equate all resilience with REP:2xx."],
  ["withstands damage", "different_family", "Protection or resistance can prevent degradation without providing capacity to restore after degradation."],
  ["returns after damage", "compound", "WRN supplies adverse condition, REP:2xx capacity, and REP:1xx actual restoration if it occurs."],
  ["internal recovery occurring", "process_root", "REP:100–102 by phase names the transformation; REP:2x0 names its capacity."],
  ["internally restored condition", "condition_root", "REP:000–002 by status names the restoration condition rather than recoverability or process."],
  ["persistent recoverability uncertain", "one_root_plus_runtime", "REP:200[2]/num leaves the persistent claim unresolved and does not select REP:202."],
  ["latent recoverability affirmed", "one_root_plus_runtime", "REP:202[1] affirms a real but nonoperative capacity without adding hiddenness or probability."],
  ["operative recoverability denied", "one_root_plus_runtime", "REP:201[0] denies present operation without establishing REP:202 or REP:200."],
  ["hidden recoverability", "one_root_plus_epistemic_claim", "REP:202 supplies nonoperation only; DAT/MIN must separately state that observers have not discovered it."],
  ["unknown recoverability", "runtime_or_epistemic_claim", "Use runtime [2]/num or DAT/MIN uncertainty; lexical latency does not mean unknown."],
  ["scheduled self-recovery", "affordance_plus_time", "REP recoverability plus ORI/DAT schedule; no REP:2xx third trit encodes scheduling."],
  ["recovery resource available", "resource_plus_affordance", "MAT/DAT/CRE owns the resource; REP:201 applies only if the typed capacity is currently operative."],
  ["backup exists", "different_family", "DAT owns the backup record; its existence does not prove internal recoverability."],
  ["spare part exists", "different_family", "MAT/CRE owns the spare; it may or may not apply to a target."],
  ["persistent source-target restorative relation", "one_root", "REP:210 preserves one source-target restorative applicability relation independently of current operation."],
  ["operative source-target restorative relation", "one_root", "REP:211 states that one source-target relation presently enables target restoration."],
  ["latent source-target restorative relation", "one_root", "REP:212 states that the relation exists without presently enabling target restoration."],
  ["remedy applies to target", "one_root", "REP:2x1 by lexical status when one distinct restorative source is applicable to one target."],
  ["medicine can treat patient", "compound", "REP target restorative relation plus MAT/LIF remedy and patient semantics."],
  ["patch applies to software", "compound", "REP:2x1 supplies restorative applicability while DAT/LOG supplies version and compatibility constraints."],
  ["checkpoint can restore database", "compound", "REP:2x1 supplies checkpoint-to-target restorative applicability; DAT owns checkpoint and database."],
  ["tool can repair device", "compound", "REP:2x1 supplies tool-to-target restorative applicability; MAT/CRE owns tool and mechanics."],
  ["donor compatible with recipient", "compound", "REP:2x1 only when compatibility enables restoration; LIF/LOG/MAT supplies biological and formal constraints."],
  ["service available for target", "underspecified_compound", "CON service relation and REP restorative applicability are separate; availability alone does not prove repairability."],
  ["technician responsible for target", "different_family", "CON/LOG owns role and obligation; responsibility does not entail ability to restore."],
  ["caregiver assigned", "different_family_or_compound", "LIF/CON owns care role; REP relation applies only if actual restorative enablement is asserted."],
  ["active care", "process_or_relation", "Actual sustaining or healing is REP:111 plus LIF/CON; operative applicability alone does not perform care."],
  ["maintenance bond", "different_family_or_compound", "CON/LOG owns service responsibility; REP:210 applies only to restorative enablement."],
  ["warranty", "different_family", "LOG/CON owns contractual coverage; a warranty does not make a target repairable."],
  ["repair permission", "different_family", "LOG permission neither establishes nor removes a restorative applicability relation."],
  ["repair appointment", "different_family_or_compound", "DAT/ORI owns the appointment; REP affordance may hold independently."],
  ["unconfirmed repairability", "runtime_or_epistemic_claim", "Use runtime uncertainty or DAT/MIN evidence; REP:212 means a real latent relation, not an unverified possibility."],
  ["source restoring target now", "process_root", "REP:111 is the active target restoration process; REP:211 names the enabling relation."],
  ["target restored", "condition_or_completed_process", "REP:011 names current target condition and REP:110 completed target restoration; REP:2x1 alone asserts neither."],
  ["operative relation uncertain", "one_root_plus_runtime", "REP:211[2]/num questions current operation while preserving the operative lexical selection."],
  ["latent relation affirmed", "one_root_plus_runtime", "REP:212[1] affirms the relation exists but is not currently operative."],
  ["persistent relation denied", "one_root_plus_runtime", "REP:210[0] denies persistent identity without choosing the operative or latent sibling."],
  ["source compatible but unavailable", "compound", "REP:210 or 212 may hold while availability is denied; compatibility and current operation are distinct."],
  ["source available but incompatible", "resource_plus_negated_affordance", "A resource may exist while REP restorative applicability is false."],
  ["one remedy for two unrelated targets", "multiple_relations", "Use separate REP:2x1 relations unless one shared-system restoration pathway is asserted."],
  ["persistent systemic restoration pathway", "one_root", "REP:220 preserves one restoration-enabling pathway across multiple participants independently of current operation."],
  ["operative systemic restoration pathway", "one_root", "REP:221 states that the shared-system pathway presently enables coordinated restoration."],
  ["latent systemic restoration pathway", "one_root", "REP:222 states that the pathway exists without being presently operative."],
  ["disaster recovery pathway", "one_root_or_compound", "REP:2x2 by status when one pathway enables a shared restoration condition across participants."],
  ["failover path", "compound", "REP systemic restoration pathway plus DAT/CON/STR topology and failover rules."],
  ["recovery network", "one_root_or_compound", "REP:2x2 if the network enables coordinated shared restoration; CON/STR owns network structure."],
  ["mutual aid network", "compound", "REP systemic pathway plus CON/LIF participant and social-relation semantics."],
  ["ecosystem recovery pathway", "compound", "REP:2x2 plus LIF/MAT/CON when one shared restoration condition spans participants."],
  ["restoration supply chain", "compound", "REP pathway plus MOV/CON/MAT resources and transport; the supply chain is not automatically operative."],
  ["redundancy", "different_family_or_compound", "STR/DAT owns duplicate structure or data; redundancy may realize a REP pathway but is not identical to restorative enablement."],
  ["backup network", "different_family_or_compound", "DAT/CON/STR owns backup resources and topology; REP applies only if they enable shared restoration."],
  ["adaptive recovery network", "process_plus_affordance", "Active reallocation is a process; REP:221 only states the pathway is currently operative."],
  ["system reallocating support", "process_or_compound", "CON/STR/REP:121 describes coordinated restorative action; pathway operation alone does not assert reallocation."],
  ["system recovery occurring", "process_root", "REP:120–122 by phase names coordinated restoration; REP:2x2 names its enabling pathway."],
  ["shared restored condition", "condition_root", "REP:020–022 by status names the shared restoration condition, not its pathway."],
  ["possible recovery path", "affordance_plus_modality_or_runtime", "REP:222 means an existing latent pathway; mere possibility or lack of evidence requires ORI or runtime uncertainty."],
  ["path not demonstrated", "epistemic_claim", "DAT/MIN owns demonstration status; a REP pathway may exist or fail independently."],
  ["pathway scheduled for activation", "affordance_plus_time", "REP:222 plus ORI/DAT schedule; lexical latency never means scheduled."],
  ["pathway ready", "one_root_or_compound", "REP:221 when currently operative; operational readiness criteria may require LOG/DAT."],
  ["many independent recoverable machines", "multiple_roots_not_systemic", "Use separate REP:2x0 claims; independent capacities do not form one shared restoration pathway."],
  ["one technician repairs many independent targets", "multiple_target_relations", "Use per-target REP:2x1 and process claims unless a coordinated shared restoration pathway exists."],
  ["communication network only", "different_family", "CON reachability does not entail capacity to restore a shared condition."],
  ["structural dependency only", "different_family", "STR dependency can realize or obstruct a pathway but is not restorative enablement by itself."],
  ["persistent pathway uncertain", "one_root_plus_runtime", "REP:220[2]/num leaves the persistent pathway assertion unresolved and does not select REP:222."],
  ["latent pathway affirmed", "one_root_plus_runtime", "REP:222[1] affirms an existing nonoperative pathway without probability or future time."],
  ["operative pathway denied", "one_root_plus_runtime", "REP:221[0] denies current operation without establishing persistence or latency."],
  ["persistent plus operative recoverability", "two_compatible_roots", "REP:200 and REP:201 may co-occur because identity persistence and current operation are independent claims."],
  ["persistent plus latent recoverability", "two_compatible_roots", "REP:200 and REP:202 may co-occur while the capacity is not currently operative."],
  ["operative and latent simultaneously", "invalid_same_reference_claim", "REP:201 and REP:202 are mutually exclusive for the same capacity at one reference time."],
  ["persistent plus operative relation", "two_compatible_roots", "REP:210 and REP:211 may co-occur because persistent identity is neutral about current operation."],
  ["persistent plus latent relation", "two_compatible_roots", "REP:210 and REP:212 may co-occur because persistent identity is neutral about current operation."],
  ["operative and latent relation simultaneously", "invalid_same_reference_claim", "REP:211 and REP:212 are mutually exclusive at one time."],
  ["persistent plus operative pathway", "two_compatible_roots", "REP:220 and REP:221 may co-occur because persistent identity is neutral about current operation."],
  ["persistent plus latent pathway", "two_compatible_roots", "REP:220 and REP:222 may co-occur because persistent identity is neutral about current operation."],
  ["operative and latent pathway simultaneously", "invalid_same_reference_claim", "REP:221 and REP:222 are mutually exclusive at one time."],
  ["affordance versus condition", "scope_resolution_test", "REP:2xx names restorative capacity or relation; REP:0xx names the restoration condition."],
  ["affordance versus process", "scope_resolution_test", "REP:2xx names restorative capacity or relation; REP:1xx names actual restoration by phase."],
  ["recoverability versus resistance", "scope_resolution_test", "Recoverability enables restoration after or from loss; resistance prevents or withstands adverse change."],
  ["restorative relation versus service relation", "scope_resolution_test", "REP:2x1 enables target restoration; CON/LOG owns service, responsibility, and obligation."],
  ["restoration pathway versus network", "scope_resolution_test", "REP:2x2 supplies restorative enablement; CON/STR/DAT owns network structure and resources."],
  ["latent versus unknown", "scope_resolution_test", "REP:202[1] affirms nonoperative recoverability; REP:201[2]/num leaves operative status unresolved."],
  ["typed affordance versus general possibility", "scope_resolution_test", "REP:2xx asserts a specific capacity or relation; ORI owns unrestricted possibility."],
  ["restoration affordance versus backup", "scope_resolution_test", "REP states capacity or relation; DAT/MAT/CRE owns the backup or spare resource."],
  ["restoration affordance versus maintenance", "scope_resolution_test", "REP enables restoring an unrealized condition; maintenance can preserve an already realized condition."],
  ["restoration affordance versus protection", "scope_resolution_test", "REP enables restorative transformation; protection prevents or limits adverse transformation."]
].freeze
stress_tests = STRESS_CONCEPTS.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("REP2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "REP:200–222 adversarial semantic candidates",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9,
    "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS,
    "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "REP:200–222 recommended permanent semantic specification",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER,
    "triplets" => {
      "REP:200–202" => "internal recoverability: persistent / operative / latent",
      "REP:210–212" => "source-target restorative applicability: persistent / operative / latent",
      "REP:220–222" => "systemic restoration pathway: persistent / operative / latent"
    },
    "scope_separation" => {
      "inward" => "one reference entity; capacity for internally originating restoration",
      "outward" => "one distinct restorative source and one reference target; applicability that can enable target restoration",
      "systemic" => "multiple participants in one shared system; pathway that can enable realization of one shared restoration condition"
    },
    "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true,
    "triplets_coherent" => true, "current_candidates_challenged" => true, "cross_family_collisions_explicit" => true,
    "runtime_state_separated" => true, "entity_process_affordance_layers_separated" => true,
    "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true,
    "canonicalized" => canonicalized_now
  }
}

stress = {
  "metadata" => {
    "title" => "REP:200–222 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary",
    "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true
  },
  "tests" => stress_tests
}

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# REP:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Repair capacity/relation meanings from first principles. It compares five genuinely different architectures at every address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level decision\n\nThe strongest architecture makes `REP:2xx` the restorative-affordance layer paired with canonical `REP:1xx`. `REP:200–202` says whether one reference entity has capacity for internally originating restoration. `REP:210–212` says whether one distinct restorative source and one target have an applicability relation that can enable target restoration. `REP:220–222` says whether one shared restoration condition has an enabling pathway across multiple participants in a shared system.\n\n"
review << "This replaces the Phase 2 mixture of resilience, protection, actual regeneration, maintenance responsibility, active care, observer verification, backups, adaptive processes, and mere possibility. Those candidates were useful prompts but blurred conditions, affordances, processes, resources, service relations, evidence, protection, and modality. The recommended grid uses one persistent/operative/latent contrast and remains neutral about substrate, observer knowledge, mechanics, resources, protection, scheduling, and actual realization.\n\n"

IDS.each do |id|
  score_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n"
  review << "### Fixed generated forms\n\n- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### Why the Phase 2 meaning was probably chosen\n\n#{score_root['current_meaning_rationale']}\n\n"
  review << "### Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  score_root.fetch("candidates").each do |item|
    values = EraZeroValidation::SCORE_KEYS.map { |key| item.dig("scores", key) }
    review << "| #{item['title']} | #{values.join(' | ')} | **#{item['total']}/80** |\n"
  end
  review << "\n"
  score_root.fetch("candidates").each do |item|
    analysis = item.fetch("analysis")
    review << "#### #{item['title']}\n\n**Invariant candidate:** #{item['invariant_candidate']}\n\n- Fit: #{analysis['why_it_fits']}\n- Useful coverage: #{analysis['useful_coverage']}\n- Territory consumed: #{analysis['semantic_territory_consumed']}\n- Conflicts and limitations: #{analysis['conflicts_or_future_limitations']}\n\n"
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

review << "## Nine-root contrast matrix\n\n| Root | Permanent ownership | Exact lexical status | Nearest excluded concept |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  _phase, phase_description = phase_words(id)
  review << "| #{id} | #{root['proposed_title']} | #{phase_description} | REP:0xx condition, REP:1xx process, mechanics, protection, maintenance, resources, records, service obligation, or general modality |\n"
end
review << "\n## Triplet coherence\n\n| Triplet | Shared affordance | `0` persistent | `1` operative | `2` latent |\n| --- | --- | --- | --- | --- |\n| REP:200–202 | one entity has capacity for internally originating restoration | identity persists independently of operation | recoverability presently operative | recoverability exists but is not operative |\n| REP:210–212 | one source-target restorative applicability relation can enable target restoration | relation persists independently of operation | relation presently enables restoration | relation exists but is not operative |\n| REP:220–222 | one systemic pathway can enable realization of a shared restoration condition | pathway persists independently of operation | pathway presently enables restoration | pathway exists but is not operative |\n\nPersistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time. Lexical latency never means uncertainty, hiddenness from an observer, probability, plan, schedule, or future time.\n\n"
review << "## English ownership and reservations\n\nThe roots own substrate-neutral *internal recoverability*, *source-target restorative applicability*, and *systemic restoration pathway* only under their exact invariants. Physical resources and compatibility belong to MAT; biological mechanism to LIF; routes, service relations, and network topology to MOV/CON/STR; backups and evidence to DAT; beliefs to MIN; protection and adverse conditions to WRN; formal rules to LOG; replacement and reconstruction to CRE; unrestricted possibility and time to ORI. *Resilient*, *maintainable*, *serviceable*, *backup*, *spare*, *care relation*, *possible recovery*, *ready*, *hidden*, and *scheduled* remain compounds or sense-resolution tasks.\n\n"
review << "## Stress test\n\n#{stress_tests.length} unique concepts were routed through single roots, REP conditions or processes, compounds, other families, runtime state, grammar, or explicit gaps. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** approved under `migrations/#{STEM}_semantic_approval.yaml`; this file remains the adversarial evidence record.\n" : "\n**Recommendation:** approve only after reusable packet validation, full REP:000–222 soundness validation, and current-state regression. Until then all nine roots remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# REP:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "LIF regeneration; MAT repair mechanics; WRN resistance; DAT recovery record", "1" => "CON service relation; MAT compatibility; LOG permission; CRE remedy resource", "2" => "STR redundancy; CON coordination; DAT backup graph; ORI possibility" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | REP keeps only the restorative affordance for the matching internal, target, or systemic restoration transformation |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Same-family safeguards\n\n- `REP:0xx` owns restoration-condition entities; `REP:1xx` owns actual restorative transformations; `REP:2xx` owns only capacities and relations that can enable those transformations.\n- Internal recoverability belongs to one reference entity and concerns internally originating restoration; it does not assert a restored condition, recovery event, observer knowledge, resource, or probability.\n- Source-target restorative applicability preserves one distinct source and one target. It does not assert contact, service responsibility, permission, care, replacement, target restoration, or guaranteed success.\n- A systemic restoration pathway spans multiple participants and enables realization of one shared restoration condition. It does not assert neutral communication, unrelated recoverabilities, an active recovery process, backups, redundancy, or general possibility.\n- Persistent roots are operation-neutral and may co-occur with operative or latent siblings. Operative and latent are mutually exclusive for the same affordance at one reference time. Runtime `[0]`, `[1]`, or `[2]/num` never changes lexical status.\n\n## Reserved compounds and gaps\n\nResistance, immunity, resilience, maintainability, service responsibility, care relations, resources, spares, backups, checkpoints, redundancy, replacement, reconstruction, observability, hiddenness, likelihood, readiness, scheduling, and future activation remain compounds, other-family claims, or explicit gaps.\n\n**CONCLUSION: REP:200–222 STANDS ALONE ONLY FOR SUBSTRATE-NEUTRAL RESTORATIVE AFFORDANCE; MATERIAL, SPATIAL, BIOLOGICAL, STRUCTURAL, COGNITIVE, COMMUNICATIVE, NORMATIVE, INFORMATIONAL, CREATIVE, WARNING, AND GENERAL MODAL CLAIMS REMAIN SEPARATE.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built #{RANGE} review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
