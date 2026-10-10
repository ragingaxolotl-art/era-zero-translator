#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "REP:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "REP_000_022"
SEMANTIC_CENTER = "restoration-condition entities: internal, target-oriented, and shared acceptable conditions"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "REP:000" => ["restored integrity", "An entity's inward health, function, or correctness has been returned to a stable condition."],
  "REP:001" => ["active recovery state", "An entity is presently healing, recalibrating, or returning its own function toward integrity."],
  "REP:002" => ["recoverable damage", "An entity remains damaged or incomplete but preserves an inward basis for future recovery."],
  "REP:010" => ["repaired target", "An external target is in a stable restored, healed, or corrected condition."],
  "REP:011" => ["target under care", "An external target is presently being supported, healed, corrected, or maintained."],
  "REP:012" => ["queued repair target", "A damaged target is identified and recoverable but repair is not yet under way."],
  "REP:020" => ["restored system", "A community, network, habitat, or infrastructure has regained stable shared function."],
  "REP:021" => ["system recovery state", "A distributed system is actively healing, restoring service, or coordinating maintenance."],
  "REP:022" => ["preserved restore point", "A backup, seed, reserve, or prior system state is retained for future restoration but is not currently deployed."]
}.freeze

ROOTS = {
  "REP:000" => { title: "persistent internal restoration condition", phase: "persistent", scope: "inward", kind: "internal restoration condition", invariant: "An acceptable condition internal to one reference entity that remains identified as that entity's restoration standard independently of whether it is presently realized." },
  "REP:001" => { title: "manifest internal restoration condition", phase: "manifest", scope: "inward", kind: "internal restoration condition", invariant: "An acceptable condition internal to one reference entity that is presently realized as that entity's restored state." },
  "REP:002" => { title: "dormant internal restoration condition", phase: "dormant", scope: "inward", kind: "internal restoration condition", invariant: "An acceptable condition internal to one reference entity that remains identified as its restoration standard without being presently realized." },
  "REP:010" => { title: "persistent target restoration condition", phase: "persistent", scope: "outward", kind: "target restoration condition", invariant: "An acceptable condition of one distinct reference target that remains identified as that target's restoration standard independently of whether it is presently realized." },
  "REP:011" => { title: "manifest target restoration condition", phase: "manifest", scope: "outward", kind: "target restoration condition", invariant: "An acceptable condition of one distinct reference target that is presently realized as that target's restored state." },
  "REP:012" => { title: "dormant target restoration condition", phase: "dormant", scope: "outward", kind: "target restoration condition", invariant: "An acceptable condition of one distinct reference target that remains identified as its restoration standard without being presently realized." },
  "REP:020" => { title: "persistent shared restoration condition", phase: "persistent", scope: "systemic", kind: "shared restoration condition", invariant: "One correlated acceptable condition that remains identified across multiple participant entities within a shared system as their restoration standard independently of its present realization pattern." },
  "REP:021" => { title: "manifest shared restoration condition", phase: "manifest", scope: "systemic", kind: "shared restoration condition", invariant: "One correlated acceptable condition that is presently realized across multiple participant entities within a shared system as their restored state." },
  "REP:022" => { title: "dormant shared restoration condition", phase: "dormant", scope: "systemic", kind: "shared restoration condition", invariant: "One correlated acceptable condition that remains identified across multiple participant entities within a shared system as their restoration standard without being presently realized." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 8, 4, 4, 7, 9, 7] },
  "restoration_condition_entities" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "restorative_resource_entities" => { scores: [8, 8, 8, 7, 6, 9, 9, 8] },
  "maintenance_status_entities" => { scores: [7, 8, 8, 6, 6, 8, 10, 8] },
  "recovery_record_entities" => { scores: [9, 8, 6, 8, 4, 9, 8, 10] }
}.freeze

ALT_TITLES = {
  "REP:000" => ["persistent internal remedy reserve", "persistent internal maintenance state", "persistent internal baseline record"],
  "REP:001" => ["engaged internal remedy reserve", "current internal maintenance state", "active internal baseline record"],
  "REP:002" => ["dormant internal remedy reserve", "deferred internal maintenance state", "stored internal baseline record"],
  "REP:010" => ["persistent target remedy", "persistent target maintenance status", "persistent target repair record"],
  "REP:011" => ["engaged target remedy", "current target maintenance status", "active target repair record"],
  "REP:012" => ["dormant target remedy", "deferred target maintenance status", "stored target repair record"],
  "REP:020" => ["persistent shared recovery reserve", "persistent systemic maintenance status", "persistent shared restore record"],
  "REP:021" => ["engaged shared recovery reserve", "current systemic maintenance status", "active shared restore record"],
  "REP:022" => ["dormant shared recovery reserve", "deferred systemic maintenance status", "stored shared restore record"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, biological health, injury, illness, care roles, and social collectives. REP can identify a restoration condition for a living participant, but it does not define physiology, subjective well-being, or social identity.",
  "MOV" => "MOV owns position, return, approach, traversal, and shared motion. Returning to a place can participate in restoration, but REP names an acceptable restored condition rather than a displacement or route.",
  "MAT" => "MAT owns substance, energy, physical integrity, force, contact, fracture, and shape. REP adds restoration-relative acceptability; an intact material object need not be restored, and a restored condition need not be physical.",
  "MIN" => "MIN owns belief, memory, attention, intention, satisfaction, and perceived normality. A restoration condition may be unknown or disputed and still remain identified; observer uncertainty is runtime or MIN, not lexical dormancy.",
  "CON" => "CON owns care communication, service requests, coordination, and participant exchange. Communicating or coordinating repair does not constitute a restored condition.",
  "WRN" => "WRN owns faults, hazards, degradation, impairment, propagation, susceptibility, exposure, and adverse pathways. A dormant REP restoration condition does not assert damage or danger; WRN must separately state the adverse condition or process.",
  "STR" => "STR owns positions, interfaces, arrangements, transformations, and structural affordances. A restoration condition may include structural facts, but REP does not replace the arrangement or topology itself.",
  "LOG" => "LOG owns correctness, validity, rule satisfaction, permission, and constraints. A logically valid state need not be the restoration condition, and restoration-relative acceptability may be contextually defined without becoming formal truth.",
  "DAT" => "DAT owns baselines, checkpoints, backups, records, measurements, schemas, and provenance. A record may describe or preserve a restoration condition but is not the condition itself.",
  "CRE" => "CRE owns generation, fabrication, replacement, reconstruction, and destruction as transformations. A new or recreated artifact may realize restoration, but creation is not identical to the acceptable condition achieved.",
  "ORI" => "ORI owns time, prior states, manifestation, possibility, and necessity. REP persistent, manifest, and dormant statuses are restoration-specific and never encode pastness, futurity, probability, or unrestricted modality."
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
    values[0] -= 1 if ["0", "2"].include?(third)
    values[3] -= 1 if second == "2"
  when "restoration_condition_entities"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "restorative_resource_entities"
    values[4] -= 2 if second == "1"
    values[2] -= 1 if third == "2"
  when "maintenance_status_entities"
    values[1] -= 2 if second == "2"
    values[3] -= 1 if third == "0"
  when "recovery_record_entities"
    values[4] -= 2 if second == "1"
    values[2] -= 1 if second == "2"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional title follows the #{root.fetch(:scope)} and #{root.fetch(:phase)} slot labels and uses familiar Repair vocabulary such as restored, recovery, care, repair, maintenance, and restore point.",
      "useful_coverage" => "It reaches common talk about health, service recovery, healed targets, maintenance queues, backups, and recovered systems.",
      "semantic_territory_consumed" => "Across the block it mixes restored conditions, active repair processes, recoverability affordances, damage, schedules, care relations, backup records, resources, and future deployment.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one entity/condition center; active roots duplicate REP:1xx processes and dormant roots absorb WRN damage, DAT backups, ORI future time, and REP:2xx recoverability."
    }
  when "restoration_condition_entities"
    {
      "why_it_fits" => "The first trit stays entity/condition; the second alone selects an acceptable condition internal to one entity, assigned to one distinct target, or correlated across multiple system participants; the third alone selects persistent identity, present realization, or dormancy.",
      "useful_coverage" => "It supplies compact atoms for restored state, accepted baseline, recovered service, healed condition, target restoration, shared recovery, and comparison to a restoration reference across ordinary and technical domains.",
      "semantic_territory_consumed" => "Only the identity and present realization of a substrate-neutral restoration condition. Damage, repair processes, recoverability, resources, records, rules, observer belief, and time remain separate.",
      "conflicts_or_future_limitations" => "The phrase acceptable condition requires an applicable restoration frame, but factoring the frame from its record or rule yields stable atoms and avoids domain-specific notions of health, correctness, or physical integrity."
    }
  when "restorative_resource_entities"
    {
      "why_it_fits" => "Internal reserves, target remedies, and shared recovery resources are tangible Repair-family entities that can persist, engage, or remain dormant.",
      "useful_coverage" => "It would cover medicine, spare parts, backup power, repair tools, repair agents, seed stock, and recovery reserves.",
      "semantic_territory_consumed" => "It consumes matter, artifacts, care roles, stored data, and deployment status rather than the restored condition those resources may help realize.",
      "conflicts_or_future_limitations" => "MAT and CRE own physical resources, LIF owns caregivers and medicine as living or biological entities, DAT owns backups, and one resource does not guarantee restoration."
    }
  when "maintenance_status_entities"
    {
      "why_it_fits" => "Maintained, under maintenance, and maintenance-deferred states are familiar Repair concepts at inward, target, and systemic scope.",
      "useful_coverage" => "It would cover serviceable, under care, due for maintenance, supported, patched, and coordinated maintenance states.",
      "semantic_territory_consumed" => "It mixes current condition, service process, obligation, schedule, and responsibility.",
      "conflicts_or_future_limitations" => "REP:1xx should own maintenance processes, REP:2xx recoverability relations, LOG obligations, ORI schedules, and CON coordination; the architecture would not stay atomic."
    }
  when "recovery_record_entities"
    {
      "why_it_fits" => "Baselines, repair records, checkpoints, and restore points are strongly associated with recovery and map naturally to inward, target, and shared scope.",
      "useful_coverage" => "It would cover golden images, known-good configurations, medical charts, repair histories, backups, snapshots, and rollback points.",
      "semantic_territory_consumed" => "Representations of restoration conditions rather than those conditions themselves.",
      "conflicts_or_future_limitations" => "DAT owns records, provenance, checkpoints, and backups; a record can be wrong, missing, or undeployable while the underlying restoration condition remains meaningful."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "restorative_resource_entities"
    "A #{root.fetch(:phase)} restorative resource assigned to #{root.fetch(:scope)} scope."
  when "maintenance_status_entities"
    "A #{root.fetch(:phase)} maintenance-status condition at #{root.fetch(:scope)} scope."
  when "recovery_record_entities"
    "A #{root.fetch(:phase)} data record describing a restoration reference at #{root.fetch(:scope)} scope."
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
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "REP:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "REP:#{first}#{x}#{third}" }
  process = "REP:1#{second}#{third}"
  relation = "REP:2#{second}#{third}"
  (siblings + scopes + [process, relation]).uniq
end

def roles
  {
    "low" => "reference entity or target whose restoration condition is asserted",
    "middle" => "acceptable restoration condition as the asserted figure",
    "high" => "distinct target or restoration-frame reference",
    "sustained" => "shared system and the participants bearing one correlated restoration condition"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} remains identified as the applicable restoration standard; it does not select the manifest or dormant sibling and does not establish a different acceptable condition.",
      "1" => "Affirms the continuing identity of this #{root.fetch(:kind)} without deciding whether it is presently realized, how it was established, whether it is recorded, or whether restoration is possible.",
      "2/num" => "Leaves unresolved whether the persistent #{root.fetch(:kind)} remains identified; the token stays the stable lexical root and does not become the manifest or dormant sibling."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently realized; its continuing identity, past or future realization, restoration process, and bearer condition remain otherwise undecided.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently realized, without asserting how it was achieved, how long it will last, whether anyone recognizes it, or whether a repair process is occurring.",
      "2/num" => "Leaves unresolved whether this #{root.fetch(:kind)} is presently realized; runtime uncertainty does not select the persistent or dormant lexical sibling."
    }
  else
    {
      "0" => "Denies that the identified #{root.fetch(:kind)} is currently unrealized; it does not by itself affirm persistence, present realization, or any particular bearer condition.",
      "1" => "Affirms that this #{root.fetch(:kind)} remains identified but is not presently realized, without asserting damage, cause, concealment, impossibility, schedule, or future realization.",
      "2/num" => "Leaves unresolved whether the lexical dormant condition holds; lexical third-trit 2 still names identified-but-unrealized status, while runtime `[2]/num` marks uncertainty about the whole assertion."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entries = case id[-2]
            when "0"
              english = {
                "0" => "This account's acceptable internal condition remains the same even while its current condition is being checked.",
                "1" => "The service is presently back in its accepted internal operating condition.",
                "2" => "The device's accepted internal condition is still defined, but the device is not in it now."
              }.fetch(id[-1])
              physical = {
                "0" => "The bearing retains one accepted internal tolerance condition across inspections.",
                "1" => "The bearing is presently within its restored internal tolerance condition.",
                "2" => "The bearing's restored tolerance condition remains identified although the bearing is not presently within it."
              }.fetch(id[-1])
              program = {
                "0" => "The service object retains one accepted internal operating condition across deployments.",
                "1" => "The service presently satisfies its restored internal operating condition.",
                "2" => "The service's restored internal condition is defined but not currently realized."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](ENTITY=e,CONDITION=c)", "affirm #{root.fetch(:phase)} internal restoration condition", english, "The root asserts the restoration condition, not a repair action or belief about it."],
                ["physical_or_spatial", "MAT(BODY=b,TOLERANCE=t)+#{id}[1](ENTITY=b,CONDITION=c)", "material bearer plus #{root.fetch(:phase)} internal restoration condition", physical, "MAT supplies physical facts; REP supplies restoration-relative condition status."],
                ["temporal_or_sequential", "#{id}[1](ENTITY=e,CONDITION=c)+ORI(INTERVAL=w)", "internal restoration condition during interval w", "During the inspection interval, the entity has the stated internal restoration-condition status.", "ORI supplies time; the lexical third trit supplies realization status, not tense."],
                ["cross_family_compound", "DAT(RECORD=d)+LOG(CRITERION=k)+#{id}[1](ENTITY=e,CONDITION=c)", "record and criterion plus internal restoration condition", "The record and criterion describe the accepted condition without becoming that condition.", "DAT and LOG may specify a reference; REP asserts restoration-relative condition identity or realization."],
                ["executable_or_programming", "#{id}[1](ENTITY=service,CONDITION=known_good)", "assert #{root.fetch(:phase)} internal restoration condition", program, "The predicate concerns the service's condition, not the checkpoint record or recovery routine."],
                ["counterexample", "REP:101[1](PATIENT=e,PROCESS=p)", "active inward restoration process", "The service is currently recovering.", "An occurring restoration process belongs to REP:1xx, not this condition/entity block."]
              ]
            when "1"
              english = {
                "0" => "The accepted restored condition for that target remains the same across service visits.",
                "1" => "That target is presently in its accepted restored condition.",
                "2" => "That target's restored condition is still identified, but the target does not presently realize it."
              }.fetch(id[-1])
              physical = {
                "0" => "The panel's accepted repaired surface condition remains its restoration reference.",
                "1" => "The repaired panel presently realizes its accepted target condition.",
                "2" => "The panel's accepted repaired condition is identified although the damaged panel does not realize it now."
              }.fetch(id[-1])
              program = {
                "0" => "The database target retains one accepted restored condition across migrations.",
                "1" => "The database target presently matches its accepted restored condition.",
                "2" => "The target's restored condition remains defined although the database does not currently match it."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](TARGET=t,CONDITION=c)", "affirm #{root.fetch(:phase)} target restoration condition", english, "The outward column selects one distinct target, not an external remedy source."],
                ["physical_or_spatial", "MAT(BODY=t,SURFACE=s)+#{id}[1](TARGET=t,CONDITION=c)", "material target plus #{root.fetch(:phase)} restoration condition", physical, "MAT supplies physical configuration; REP supplies restoration-relative target condition."],
                ["temporal_or_sequential", "#{id}[1](TARGET=t,CONDITION=c)+ORI(INTERVAL=w)", "target restoration condition during interval w", "During the service interval, the target has the stated restoration-condition status.", "ORI supplies temporal scope; dormancy is not scheduling."],
                ["cross_family_compound", "LIF(PATIENT=t)+DAT(RECORD=d)+#{id}[1](TARGET=t,CONDITION=c)", "living target and record plus target restoration condition", "The patient's record describes a restoration condition that remains distinct from biology and documentation.", "LIF and DAT supply bearer and record; REP supplies restoration-relative condition."],
                ["executable_or_programming", "#{id}[1](TARGET=database,CONDITION=accepted_state)", "assert #{root.fetch(:phase)} target restoration condition", program, "A migration or restore operation is separately asserted with REP:1xx."],
                ["counterexample", "REP:111[1](AGENT=a,TARGET=t,PROCESS=p)", "active restoration of a target", "The technician is repairing the panel.", "An occurring target-directed restoration process belongs to REP:1xx, not this condition root."]
              ]
            else
              english = {
                "0" => "The shared acceptable condition for the service cluster remains identified across its participating nodes.",
                "1" => "The participating services presently realize one shared restored condition.",
                "2" => "The shared restored condition remains identified, but the participants do not presently realize it."
              }.fetch(id[-1])
              physical = {
                "0" => "The facility retains one accepted shared operating condition across its coupled rooms.",
                "1" => "The coupled rooms presently realize the facility's shared restored condition.",
                "2" => "The facility's shared restored condition is identified although it is not presently realized across the rooms."
              }.fetch(id[-1])
              program = {
                "0" => "The cluster retains one accepted shared operating condition across node restarts.",
                "1" => "The cluster nodes presently realize one correlated restored service condition.",
                "2" => "The cluster's shared restored condition remains defined but is not currently realized across the nodes."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},CONDITION=c)", "affirm #{root.fetch(:phase)} shared restoration condition", english, "The root requires one correlated acceptable condition across multiple participants."],
                ["physical_or_spatial", "MAT(SUBSTRATES={a,b})+#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},CONDITION=c)", "material participants plus #{root.fetch(:phase)} shared restoration condition", physical, "MAT supplies physical facts; REP supplies the shared restoration-relative condition."],
                ["temporal_or_sequential", "#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},CONDITION=c)+ORI(INTERVAL=w)", "shared restoration condition during interval w", "Across the interval, the shared system has the stated restoration-condition status.", "ORI supplies the interval; REP supplies shared scope and realization status."],
                ["cross_family_compound", "CON(DEPENDENCIES=g)+DAT(MEASUREMENTS=d)+#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},CONDITION=c)", "dependencies and measurements plus shared restoration condition", "The dependency graph and measurements describe how one shared restored condition is assessed.", "CON and DAT describe linkage and evidence; neither alone constitutes the restoration condition."],
                ["executable_or_programming", "#{id}[1](SYSTEM=cluster,PARTICIPANTS=nodes,CONDITION=service_ok)", "assert #{root.fetch(:phase)} shared restoration condition", program, "The assertion requires one correlated shared condition rather than a list of unrelated healthy nodes."],
                ["counterexample", "REP:001[1](ENTITY=a,CONDITION=x)+REP:001[1](ENTITY=b,CONDITION=y)", "two unrelated manifest internal conditions", "Two machines happen to be working for unrelated reasons.", "Multiple independent conditions are not one systemic REP:02x claim without a shared correlated restoration condition."]
              ]
            end
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
      "pseudocode" => category == "executable_or_programming" ? "assert(restoration_condition.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "restoration_condition_entities", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "restorative_resource_entities", alt[0], alternative_invariant(id, "restorative_resource_entities")),
    candidate(id, "maintenance_status_entities", alt[1], alternative_invariant(id, "maintenance_status_entities")),
    candidate(id, "recovery_record_entities", alt[2], alternative_invariant(id, "recovery_record_entities"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "restoration_condition_entities",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one substrate-neutral restoration-condition center, follows inward/target/shared scope exactly, and gives every triplet one persistent/manifest/dormant realization axis while reserving processes, affordances, resources, records, rules, observer states, and time for later REP layers or other families.",
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
  state_label = { "0" => "persistent/realization-neutral", "1" => "manifest/presently realized", "2" => "dormant/presently unrealized" }.fetch(third)
  scope_explanation = {
    "0" => "one acceptable restoration condition internal to one reference entity",
    "1" => "one acceptable restoration condition assigned to one distinct reference target",
    "2" => "one correlated acceptable restoration condition across multiple participants in a shared system"
  }.fetch(second)
  scope_boundary = {
    "0" => "The claim is about the entity's own restoration condition, not a condition assigned to another target, an observer's judgment, or a baseline record.",
    "1" => "The claim preserves one distinct target whose restoration condition is asserted. A remedy source, caregiver, repair action, resource, schedule, and repairability remain separate.",
    "2" => "The claim requires one correlated restoration condition across multiple participants. A coincidental collection of unrelated acceptable conditions is not systemic, and the structure linking participants is separate."
  }.fetch(second)
  triplet_logic = if third == "0"
                    "The persistent member is realization-neutral: it may co-occur with the manifest sibling or the dormant sibling at the same reference time. It asserts continuity of restoration-condition identity rather than a third mutually exclusive realization value."
                  else
                    "The persistent sibling may also hold because it asserts restoration-condition identity across time. Manifest and dormant siblings are mutually exclusive for the same condition at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved."
                  end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects an entity or condition: #{root.fetch(:title)} is an acceptable restoration condition, not a restoration process, capacity, enabling relation, resource, record, rule, or schedule.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Repair-family column.",
      "third_trit" => "Selects the #{state_label} member by condition identity or present realization while leaving runtime truth status, observer knowledge, tense, probability, and restoration process separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral claim about #{scope_explanation}. #{scope_boundary} It is neutral about physical or biological constitution, observer knowledge, record accuracy, formal validity, damage, fault, repair method, recoverability, probability, timing, and cause.",
    "excluded_meanings" => [
      "The person, organism, material object, software component, institution, or system that bears, defines, observes, records, or realizes the restoration condition.",
      "Physical intactness, biological health, logical validity, data correctness, cleanliness, availability, or social reconciliation without the separate restoration-relative claim.",
      "Damage, fault, hazard, degradation, injury, illness, error, outage, conflict, or any other adverse condition merely because restoration might be desirable.",
      "Baseline record, checkpoint, backup, golden image, measurement, diagnosis, belief, criterion, policy, acceptance rule, or evidence about the condition.",
      "Repairing, healing, recalibrating, restoring, maintaining, replacing, rebuilding, recovering, or coordinating restoration as a process.",
      "Repairability, recoverability, restorative capacity, remedy resource, caregiver, service relationship, scheduled restoration, future realization, cause, or guarantee of success."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`REP:0xx` owns restoration conditions as entities; `REP:1xx` remains the layer for actual restoration processes; `REP:2xx` remains the layer for recoverability, repairability, and enabling restoration relations. Present realization in 0xx does not name the process that achieved or maintains it, and an identified restoration condition does not entail that restoration is possible. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} member of this restoration-condition triplet. Runtime `[2]/num` instead leaves the truth or applicability of that already-selected root unresolved; it never changes realization status. Thus a dormant root affirmed with `[1]` is a confirmed identified-but-unrealized condition, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + MAT/LIF supplies the physical or living bearer and concrete acceptable state without reducing restoration to matter or biology.",
      "#{id} + LOG/DAT supplies an acceptance criterion, baseline record, or checkpoint while keeping rule and representation distinct from the condition.",
      "#{id} + WRN supplies the adverse condition from which restoration is assessed without making damage part of the REP atom.",
      "#{id} + REP:1xx/2xx may later express actual restoration or recoverability as separate processes and affordances."
    ],
    "later_era_notes" => "Later eras may lexicalize healthy, healed, repaired, clean, reconciled, online, recovered, serviceable, reset, calibrated, and restored-to-version distinctions. Era Zero should preserve the substrate-neutral restoration-condition center and derive domain-specific senses compositionally. The persistent root must not be treated as mutually exclusive with its manifest or dormant sibling.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


stress_rows = [
  ["restored", "one_root_or_compound", "Select the appropriate REP:0xx scope and realization status; the word alone does not identify bearer, criterion, or process."],
  ["recovered", "one_root_or_compound", "REP:001, 011, or 021 can assert a presently realized restoration condition; a past recovery event requires REP:1xx plus time."],
  ["healthy", "compound", "LIF owns biological health; REP:001 or 011 applies only when that health is asserted as a presently realized restoration condition."],
  ["healed", "compound", "LIF/MAT supplies the living or material condition and REP:0x1 supplies present realization; healing as an action belongs to REP:1xx."],
  ["repaired", "compound", "MAT/STR describes the artifact state and REP:011 can assert its target restoration condition; the repair event remains REP:1xx."],
  ["functional", "compound", "Domain and LOG roots define function or criterion; REP adds restoration-relative status only when restoration is intended."],
  ["working again", "compound", "REP:0x1 supplies realized restored condition, ORI supplies again/prior contrast, and domain roots define working."],
  ["clean", "compound", "MAT or domain vocabulary owns physical or data cleanliness; REP applies only when clean is the restoration condition."],
  ["intact", "compound", "MAT owns physical integrity; REP does not make every intact object restored."],
  ["valid", "different_family_or_compound", "LOG owns validity; a valid result is not necessarily a restoration condition."],
  ["correct", "different_family_or_compound", "LOG/DAT owns correctness; REP applies only when correctness is the identified restored state."],
  ["available", "different_family_or_compound", "DAT/CON/STR may own availability; REP:0x1 is added only for restoration-relative service status."],
  ["back to normal", "compound", "REP:0x1 supplies current restored condition while the applicable normality criterion must be supplied or contextually resolved."],
  ["known-good state", "one_root_plus_compound", "REP:000 identifies an internal restoration condition; DAT/LOG supplies the recorded or validated known-good criterion."],
  ["restoration standard", "one_root", "REP:000, 010, or 020 identifies the applicable restoration condition according to scope."],
  ["baseline", "underspecified", "A DAT baseline record or LOG criterion may describe a REP restoration condition but is not identical to it."],
  ["golden image", "different_family_or_compound", "DAT owns the image; REP:000 may identify the condition it represents."],
  ["restore point", "different_family_or_compound", "DAT owns the checkpoint or record; REP owns the restoration condition referenced by it."],
  ["backup", "different_family", "DAT owns stored backup information or MAT a spare object; neither is itself a REP:0xx condition."],
  ["snapshot", "different_family", "DAT owns the snapshot representation; its subject may have a REP condition."],
  ["accepted configuration", "compound", "STR/DAT supplies configuration and LOG acceptance; REP:001 may assert present realization as a restored condition."],
  ["persistent internal restoration condition", "one_root", "REP:000 preserves the identity of one acceptable condition internal to one entity regardless of present realization."],
  ["manifest internal restoration condition", "one_root", "REP:001 asserts that the entity presently realizes its identified internal restoration condition."],
  ["dormant internal restoration condition", "one_root", "REP:002 asserts that the identified internal restoration condition is not presently realized."],
  ["persistent target restoration condition", "one_root", "REP:010 preserves the identity of one acceptable condition assigned to one distinct target."],
  ["manifest target restoration condition", "one_root", "REP:011 asserts that one distinct target presently realizes its restoration condition."],
  ["dormant target restoration condition", "one_root", "REP:012 asserts that one distinct target does not presently realize its identified restoration condition."],
  ["persistent shared restoration condition", "one_root", "REP:020 preserves one correlated restoration condition across multiple participants."],
  ["manifest shared restoration condition", "one_root", "REP:021 asserts present realization of one correlated restoration condition across multiple participants."],
  ["dormant shared restoration condition", "one_root", "REP:022 asserts that one identified shared restoration condition is not presently realized."],
  ["persistent and manifest internal", "two_compatible_roots", "REP:000 and REP:001 may co-occur because identity persistence and present realization are independent claims."],
  ["persistent and dormant internal", "two_compatible_roots", "REP:000 and REP:002 may co-occur because the condition remains identified while unrealized."],
  ["manifest and dormant internal simultaneously", "invalid_same_reference_claim", "REP:001 and REP:002 cannot both hold for the same condition at the same reference time."],
  ["persistent and manifest target", "two_compatible_roots", "REP:010 and REP:011 may co-occur."],
  ["persistent and dormant target", "two_compatible_roots", "REP:010 and REP:012 may co-occur."],
  ["manifest and dormant target simultaneously", "invalid_same_reference_claim", "REP:011 and REP:012 are mutually exclusive for one condition at one time."],
  ["persistent and manifest shared", "two_compatible_roots", "REP:020 and REP:021 may co-occur."],
  ["persistent and dormant shared", "two_compatible_roots", "REP:020 and REP:022 may co-occur."],
  ["manifest and dormant shared simultaneously", "invalid_same_reference_claim", "REP:021 and REP:022 are mutually exclusive for one condition at one time."],
  ["confirmed dormant condition", "one_root_plus_runtime", "REP:002[1], REP:012[1], or REP:022[1] affirms identified-but-unrealized status."],
  ["manifest condition uncertain", "runtime_state", "A ...1 root carrying [2]/num remains lexically manifest while its token assertion is unresolved; it does not become ...2."],
  ["dormant condition uncertain", "runtime_state", "A ...2 root carrying [2]/num questions the dormant claim rather than changing it to manifest."],
  ["unknown restoration condition", "runtime_or_gap", "Runtime uncertainty or MIN/DAT expresses ignorance; lexical dormancy does not mean unknown."],
  ["condition not recorded", "one_root_plus_negation", "A REP condition may remain identified while a DAT record claim is denied."],
  ["recorded but not realized", "compound", "DAT asserts the record and REP:0x2 asserts identified-but-unrealized restoration status."],
  ["realized but not recognized", "compound", "REP:0x1 may hold while MIN recognition is denied."],
  ["damaged", "different_family_or_compound", "WRN/MAT/LIF owns damage or degradation; REP:0x2 does not itself assert damage."],
  ["faulty", "different_family", "WRN owns adverse fault conditions; dormancy in REP is not a latent fault."],
  ["unsafe", "different_family_or_compound", "WRN/LOG owns hazard or safety judgment; REP does not mean safe."],
  ["broken", "different_family_or_compound", "MAT/WRN or domain vocabulary owns breakage; REP only states restoration-relative condition."],
  ["unhealthy", "different_family_or_compound", "LIF and WRN describe health/adversity; REP:002 may separately say an internal restored condition is unrealized."],
  ["repairing", "future_rep_process", "Actual ongoing repair belongs to REP:1xx, not the REP:0xx entity/condition layer."],
  ["healing", "future_rep_process", "The process belongs to REP:1xx with LIF; a currently healed condition may use REP:0x1."],
  ["recovering", "future_rep_process", "An active recovery operation belongs to REP:1xx, not REP:001."],
  ["maintaining", "future_rep_process", "Maintenance activity belongs to REP:1xx; a maintained condition may be expressed compositionally."],
  ["recalibrating", "future_rep_process", "The transformation belongs to REP:1xx with MAT/LOG/STR criteria."],
  ["restoring a database", "future_rep_process", "REP:1xx will own the restoration operation; DAT owns the database and checkpoint."],
  ["repairable", "future_rep_affordance", "Recoverability or repairability belongs to REP:2xx, not a dormant REP:0xx condition."],
  ["recoverable", "future_rep_affordance", "A capacity for future restoration belongs to REP:2xx and must not be inferred from REP:002/012/022."],
  ["irreparable", "future_rep_affordance_plus_negation", "Negated REP:2xx capacity is distinct from an unrealized restoration condition."],
  ["restorative resource", "different_family_or_compound", "MAT/CRE/LIF owns a tool, spare, medicine, or caregiver; REP:0xx does not name the resource."],
  ["spare part", "different_family", "MAT/CRE owns the artifact and its intended use; it is not a restoration condition."],
  ["medicine", "different_family_or_compound", "MAT/LIF owns the substance and biological role; REP processes may describe treatment."],
  ["caregiver", "different_family", "LIF/CON owns the participant and care relation."],
  ["repair queue", "compound", "DAT/ORI owns queued work and scheduling; a target's dormant restoration condition does not mean queued."],
  ["scheduled maintenance", "compound", "ORI plus REP:1xx process expresses schedule; third trit 2 does not encode future time."],
  ["delay in repair", "compound", "ORI timing plus REP:1xx process; not a REP:0xx condition."],
  ["replacement", "different_family_or_future_process", "CRE owns creation/substitution and REP:1xx may supply restoration purpose."],
  ["reconstruction", "different_family_or_future_process", "CRE/STR owns rebuilding mechanics; REP:1xx may supply restoration action."],
  ["return to a place", "different_family", "MOV owns spatial return; it is not restoration merely because English says return."],
  ["return to service", "compound", "REP:0x1 supplies current restored condition, while ORI/MOV or REP:1xx may express the transition."],
  ["rollback", "compound", "DAT identifies prior state and REP:1xx expresses restoration process; REP:0x1 can describe the achieved condition."],
  ["reset", "future_process_or_compound", "A reset operation belongs to REP:1xx/CRE; its resulting acceptable condition can use REP:0x1."],
  ["service online again", "compound", "CON/DAT/STR describes service availability, ORI supplies again, and REP:021 may assert shared restored condition."],
  ["recovered cluster", "one_root_or_compound", "REP:021 applies only when one correlated shared restoration condition is realized across participants."],
  ["many healthy machines", "multiple_roots_not_one_systemic_root", "Use separate REP:001 claims unless one correlated shared restoration condition is asserted."],
  ["shared service-level target", "compound", "LOG/DAT defines the target; REP:020 may identify it as a shared restoration condition."],
  ["partially restored system", "compound_or_unresolved", "REP:021 requires the stated shared condition to be realized; partial realization needs participant-level claims, quantification, or later vocabulary."],
  ["mixed recovered and unrecovered nodes", "multiple_roots_or_quantification", "Use participant-level REP:001/002 claims unless the exact shared condition itself is realized or unrealized system-wide."],
  ["restored relationship", "compound", "CON owns the relation and REP supplies restoration-relative condition when reconciliation is intended."],
  ["reconciled group", "compound", "CON/LIF supplies social relation and participants; REP:021 may assert a shared restored condition."],
  ["corrected dataset", "compound", "DAT/LOG supplies data and correctness; REP:011 applies only when this is the target's identified restoration condition."],
  ["repaired structure", "compound", "STR/MAT supplies structure and integrity; REP:011 supplies realized target restoration status."],
  ["healed organism", "compound", "LIF supplies biological condition; REP:001 or 011 supplies realization according to reference framing."],
  ["self-restored process", "compound", "REP:001 can assert the entity's condition; the self-directed restoration event remains REP:1xx."],
  ["target restored by agent", "compound", "REP:011 asserts target condition while REP:1xx and LIF/CRE separately assert agent and action."],
  ["system restored through coordination", "compound", "REP:021 asserts shared condition while CON and REP:1xx assert coordination and restoration process."],
  ["future restored state", "compound_or_grammar", "ORI future/modal qualification applies to a REP condition; dormant lexical status alone does not mean future."],
  ["past restored state", "compound_or_grammar", "ORI past reference plus REP:0x1; lexical manifestation does not encode tense."],
  ["possible restoration condition", "compound_or_runtime", "ORI modality or runtime uncertainty qualifies the REP claim; third trit 2 means unrealized, not merely possible."],
  ["permanent restoration condition", "one_root_or_compound", "REP:0x0 identifies persistence; unrestricted permanence may require ORI/LOG qualification."],
  ["temporary restored condition", "compound", "REP:0x1 plus ORI duration; manifest does not entail persistence."],
  ["restoration condition versus criterion", "scope_resolution_test", "REP names the acceptable condition; LOG names the rule by which it is accepted."],
  ["restoration condition versus record", "scope_resolution_test", "REP names the condition; DAT names its representation, backup, or checkpoint."],
  ["restoration condition versus process", "scope_resolution_test", "REP:0xx names condition; REP:1xx is reserved for actual restoration."],
  ["restoration condition versus capacity", "scope_resolution_test", "REP:0xx names condition; REP:2xx is reserved for recoverability and enabling relations."],
  ["restoration condition versus health", "scope_resolution_test", "REP supplies restoration-relative status; LIF owns biological health."],
  ["restoration condition versus integrity", "scope_resolution_test", "REP supplies restoration-relative status; MAT/STR owns physical or structural integrity."],
  ["restoration condition versus validity", "scope_resolution_test", "REP supplies restoration-relative status; LOG owns validity."],
  ["restoration condition versus absence of fault", "scope_resolution_test", "A REP condition does not logically equal negation of every WRN condition unless a separate rule states equivalence."]
].freeze

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("REP0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "REP:000–022 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/REP_000_022_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "REP:000–022 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "REP:000–002" => "internal restoration condition: persistent / manifest / dormant", "REP:010–012" => "target restoration condition: persistent / manifest / dormant", "REP:020–022" => "shared restoration condition: persistent / manifest / dormant" }, "triplet_logic" => { "persistent_member" => "asserts restoration-condition identity across time and is realization-neutral", "manifest_dormant_members" => "mutually exclusive for the same restoration condition at the same reference time", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/REP_000_022_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "REP:000–022 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# REP:000–022 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Repair entity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `REP:0xx` the substrate-neutral entity/condition layer for restoration. The inward triplet identifies an acceptable condition internal to one entity, the outward triplet identifies the acceptable condition of one distinct target, and the systemic triplet identifies one correlated acceptable condition across multiple participants. Persistence, present realization, and dormancy supply the exact third-trit contrast.\n\nThe third-trit grid is deliberately not a three-way exclusive partition. Each `...0` member asserts persistence of restoration-condition identity and is neutral about present realization, so it may co-occur with either its `...1` or `...2` sibling. The `...1` and `...2` siblings are mutually exclusive for the same condition at the same reference time. Runtime `[2]/num` remains uncertainty about the selected claim rather than a lexical sibling.\n\nThe design rejects the provisional mixture of restored states, active recovery processes, recoverability, damage, care, maintenance queues, backups, and future deployment. Processes remain for `REP:1xx`, affordances and enabling relations for `REP:2xx`, and domain states, records, rules, observer states, and time for their respective families.\n\n"

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
review << "| REP:000–002 | one acceptable restoration condition internal to one entity | remains identified regardless realization | presently realized | identified but presently unrealized |\n"
review << "| REP:010–012 | one acceptable restoration condition assigned to one target | remains identified regardless realization | presently realized by the target | identified but presently unrealized by the target |\n"
review << "| REP:020–022 | one correlated acceptable restoration condition across system participants | remains one shared identity | presently realized across participants | identified but presently unrealized across participants |\n\n"
review << "**Triplet logic:** the `0` column is persistence-neutral with respect to present realization and may co-occur with `1` or `2`; only `1` versus `2` is mutually exclusive at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | bearer constitution, damage/fault, health/integrity/validity facts, records/checkpoints, acceptance rules, observer belief, restoration processes, recoverability, resources, scheduling, and causation |\n" }
review << "\n## Concepts intentionally reserved\n\nHealing, repair, recalibration, recovery, maintenance, replacement, reconstruction, rollback, reset, repairability, recoverability, restorative resources, caregivers, backups, checkpoints, acceptance rules, domain-specific health or integrity, partial restoration, scheduling, and historical transition remain sense-resolved compounds, other-family meanings, or later REP process/affordance work.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later REP layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# REP:000–022 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "LIF health; MAT integrity; LOG correctness; DAT baseline record", "1" => "LIF patient/care; CRE replacement; REP restoration process; LOG target criterion", "2" => "CON coordination; STR system configuration; DAT service record; ORI transition history" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | REP keeps only restoration-condition identity and realization; every competing layer stays separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A restoration condition is not the entity bearing it, the material or biological constitution that realizes it, the rule accepting it, or the record describing it.\n- An inward restoration condition is not self-repair, health, correctness, absence of every fault, or confidence that the entity is restored.\n- A target restoration condition identifies the acceptable condition of one distinct target; it does not identify a remedy source, caregiver, repair queue, or target-directed restoration process.\n- A shared restoration condition requires one correlated acceptable condition across multiple participants; several unrelated restored entities, a dependency graph, or simultaneous repairs do not suffice.\n- A dormant condition is identified but unrealized; it does not entail damage, impossibility, recoverability, hiddenness, uncertainty, scheduling, or future realization.\n- A manifest condition does not entail a completed or ongoing repair process, permanence, recognition, documentation, or absence of every adverse condition.\n- Each persistent `...0` root is neutral about the present `...1`/`...2` condition and may co-occur with either. Only manifest `...1` and dormant `...2` are mutually exclusive for one condition at one reference time.\n- Runtime `[2]/num` leaves a selected assertion unresolved and never selects the lexical dormant root.\n\n**CONCLUSION: REP:0XX STANDS ALONE ONLY FOR RESTORATION-CONDITION IDENTITY AND PRESENT REALIZATION; BEARERS, DOMAIN FACTS, DAMAGE, RECORDS, RULES, BELIEFS, PROCESSES, AFFORDANCES, RESOURCES, TIME, AND CAUSATION REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built REP:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
