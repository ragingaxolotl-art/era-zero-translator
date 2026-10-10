#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "WRN:200–222"
STEM = "WRN_200_222"
IDS = EraZeroValidation.ids_for_range(RANGE)
SEMANTIC_CENTER = "adverse-transformation affordance: internal susceptibility, source-to-target exposure, and systemic propagation pathways"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "WRN:200" => ["stable vulnerability", "An entity has a known, persistent inward susceptibility to error, attack, damage, or failure."],
  "WRN:201" => ["active susceptibility", "A vulnerability is presently exposed or capable of being exploited."],
  "WRN:202" => ["hidden vulnerability", "A weakness could exist within an entity but is dormant, inaccessible, or not yet discovered."],
  "WRN:210" => ["known exposure relation", "A stable relation connects a hazard to a target it can affect."],
  "WRN:211" => ["active attack relation", "A hazard is actively exploiting, damaging, misleading, or corrupting a target."],
  "WRN:212" => ["uncertain threat relation", "A possible harmful relation between source and target exists but cause, reach, or severity is unresolved."],
  "WRN:220" => ["stable risk structure", "A system has known dependencies through which danger or failure could propagate."],
  "WRN:221" => ["cascading risk", "Vulnerabilities or failures are actively interacting across a system and increasing shared danger."],
  "WRN:222" => ["catastrophe possibility", "A coherent system-level failure or corruption state could occur but has not been realized."]
}.freeze

ROOTS = {
  "WRN:200" => ["persistent internal susceptibility", "A persistent susceptibility of one reference entity to undergo internally originating degradation under qualifying conditions, independently of whether that susceptibility is presently operative."],
  "WRN:201" => ["operative internal susceptibility", "A susceptibility of one reference entity to undergo internally originating degradation that is presently operative under the applicable conditions."],
  "WRN:202" => ["latent internal susceptibility", "A susceptibility of one reference entity to undergo internally originating degradation that exists without being presently operative under the applicable conditions."],
  "WRN:210" => ["persistent source-target exposure relation", "A persistent exposure relation between one distinct hazard source and one reference target that can enable source-to-target impairment under qualifying conditions, independently of whether that relation is presently operative."],
  "WRN:211" => ["operative source-target exposure relation", "An exposure relation between one distinct hazard source and one reference target that presently enables that source to cause target impairment under the applicable conditions."],
  "WRN:212" => ["latent source-target exposure relation", "An exposure relation between one distinct hazard source and one reference target that exists without presently enabling that source to cause target impairment under the applicable conditions."],
  "WRN:220" => ["persistent systemic propagation pathway", "A persistent pathway relation across multiple participants in one shared system through which one correlated adverse condition can become distributed, independently of whether that pathway is presently operative."],
  "WRN:221" => ["operative systemic propagation pathway", "A pathway relation across multiple participants in one shared system that presently enables one correlated adverse condition to become distributed among them."],
  "WRN:222" => ["latent systemic propagation pathway", "A pathway relation across multiple participants in one shared system through which one correlated adverse condition can become distributed but that is not presently operative."]
}.freeze

ALT_TITLES = {
  "WRN:200" => ["persistent internal fault observability", "persistent internal resistance capacity", "persistent internal risk relation"],
  "WRN:201" => ["operative internal fault observability", "operative internal resistance capacity", "operative internal risk relation"],
  "WRN:202" => ["latent internal fault observability", "latent internal resistance capacity", "latent internal risk relation"],
  "WRN:210" => ["persistent target-threat observability", "persistent target-shielding capacity", "persistent target-risk relation"],
  "WRN:211" => ["operative target-threat observability", "operative target-shielding capacity", "operative target-risk relation"],
  "WRN:212" => ["latent target-threat observability", "latent target-shielding capacity", "latent target-risk relation"],
  "WRN:220" => ["persistent systemic incident observability", "persistent systemic containability", "persistent systemic risk relation"],
  "WRN:221" => ["operative systemic incident observability", "operative systemic containability", "operative systemic risk relation"],
  "WRN:222" => ["latent systemic incident observability", "latent systemic containability", "latent systemic risk relation"]
}.freeze

SCORE_BASES = {
  "phase2_mixed" => [5, 7, 8, 5, 4, 7, 8, 8],
  "adverse_affordance" => [10, 10, 10, 10, 9, 10, 10, 10],
  "adverse_observability" => [9, 8, 7, 8, 5, 9, 8, 10],
  "protective_affordance" => [9, 8, 7, 8, 5, 9, 9, 9],
  "risk_quantification" => [8, 7, 6, 7, 4, 9, 9, 10]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, health, injury, illness, immunity as a biological mechanism, and social participants. WRN can classify a living bearer as susceptible, exposed, or connected by a propagation pathway, but it does not replace biological facts.",
  "MOV" => "MOV owns position, displacement, routes, approach, traversal, and delivery. A hazard may travel along a route, but WRN:2xx names only the adverse affordance or pathway that makes degradation, impairment, or propagation possible.",
  "MAT" => "MAT owns physical force, energy, contact, porosity, conductivity, fracture, and material coupling. Those properties may realize vulnerability or exposure, but WRN supplies the adverse significance and scope relation.",
  "MIN" => "MIN owns awareness, fear, expectation, diagnosis, confidence, and perceived risk. Susceptibility and exposure may hold without any observer knowing or believing that they hold.",
  "CON" => "CON owns channels, reachability for expressions, alerts, and participant exchange. A communicative channel may realize a propagation pathway, but neutral message reachability is not itself a WRN pathway.",
  "REP" => "REP owns resistance, protection, repairability, stabilization, restoration, recovery, and maintenance. A WRN susceptibility or pathway states what adverse process can occur; it does not state capacity to prevent or reverse it.",
  "STR" => "STR owns structural interfaces, dependency, containment, topology, and incorporation or integration affordances. Structural connectivity may realize exposure or propagation, but it does not become Warning-family semantics unless adverse enablement is asserted.",
  "LOG" => "LOG owns validity, constraint satisfaction, permission, exploit preconditions as formal rules, and quantified inference. WRN:2xx is not invalidity, authorization, a probability judgment, or a rule saying that harm may occur.",
  "DAT" => "DAT owns evidence, measurements, risk records, vulnerability reports, provenance, and information-flow graphs. A record can describe a WRN affordance but is not the susceptibility, exposure, or pathway itself.",
  "CRE" => "CRE owns creation, design, destruction, mutation, and fabrication. Creating a vulnerability or pathway is a separate process from the resulting WRN adverse affordance.",
  "ORI" => "ORI owns general possibility, necessity, time, manifestation, and modality. WRN:2xx states a typed adverse affordance or relation; it does not encode unrestricted possibility, probability, schedule, or future time."
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
  when "0" then ["inward", "one reference entity and its internally originating adverse change", "internal susceptibility"]
  when "1" then ["outward", "one distinct hazard source relative to one reference target", "source-target exposure relation"]
  else ["systemic", "one correlated adverse condition across multiple participants in a shared system", "systemic propagation pathway"]
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
  when "adverse_affordance"
    values[6] += 1 if second == 1
    values[4] += 1 if second == 0
  when "adverse_observability"
    values[1] += 1 if second == 0
    values[6] += 1 if second == 1
  when "protective_affordance"
    values[7] += 1 if second == 2
    values[3] -= 1 if second == 1
  when "risk_quantification"
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
      "why_it_fits" => "The Phase 2 label follows the #{phase_description} #{scope} slot and uses familiar Warning vocabulary such as vulnerability, exposure, attack, risk, and catastrophe.",
      "useful_coverage" => "It reaches common security and safety language for weaknesses, threats, exploitation, cascading failures, and system risk.",
      "semantic_territory_consumed" => "It mixes capacities, present processes, observer knowledge, uncertainty, probability, severity, causal interaction, and outcome states.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one lexical-status contrast; WRN:211 duplicates active impairment, WRN:212 conflates uncertainty with lexical meaning, and WRN:222 absorbs ORI modality."
    }
  when "adverse_affordance"
    {
      "why_it_fits" => "It makes first-trit 2 the capacity or qualifying relation for the matching canonical WRN:1#{id[-2]}x transformation while preserving #{scope} scope and #{phase} expression.",
      "useful_coverage" => "It covers vulnerability, exposure, attack surface, propagation paths, contagion routes, fault trees, and failure channels in ordinary safety, software, networks, and mathematics.",
      "semantic_territory_consumed" => "Only the substrate-neutral adverse affordance that enables #{center}. Actual faults, hazards, processes, mechanics, evidence, risk estimates, controls, and modality remain separate.",
      "conflicts_or_future_limitations" => "The technical word pathway must be restricted to adverse enablement rather than physical or communicative route identity, but the invariant and compounds make that boundary explicit."
    }
  when "adverse_observability"
    {
      "why_it_fits" => "Detectability of internal faults, target threats, and systemic incidents is important to warning systems and can be expressed at #{phase} #{scope} scope.",
      "useful_coverage" => "It would cover observability, diagnosability, monitor coverage, alarm reach, traceability, and incident visibility.",
      "semantic_territory_consumed" => "It consumes evidence acquisition and interpretation rather than the adverse capacity or relation itself.",
      "conflicts_or_future_limitations" => "DAT owns observations and records, MIN owns recognition and belief, CON owns alert delivery, and harm can be enabled even when completely unobservable."
    }
  when "protective_affordance"
    {
      "why_it_fits" => "Resistance, shielding, and systemic containability are plausible Warning-related capacities at #{scope} scope and support all three lexical statuses.",
      "useful_coverage" => "It would cover immunity, resilience, shielding, filtering, isolation, containment, and fail-safe behavior.",
      "semantic_territory_consumed" => "It consumes prevention, control, and recovery capacities rather than the adverse affordance that makes harmful transformation possible.",
      "conflicts_or_future_limitations" => "REP owns restoration and resistance, STR owns containment and separation, LOG owns blocking rules, and protective capacity is directionally opposite to vulnerability."
    }
  else
    {
      "why_it_fits" => "Risk, likelihood, and impact are natural Warning-family relations and can be scoped inward, toward a target, or across a system.",
      "useful_coverage" => "It would cover risk scores, attack likelihood, expected loss, severity, confidence, and catastrophe forecasts.",
      "semantic_territory_consumed" => "It consumes quantitative or epistemic judgment about adverse outcomes rather than the capacity or pathway that makes them possible.",
      "conflicts_or_future_limitations" => "LOG owns probability and inference, DAT owns measured values, MIN owns confidence, and one risk number usually combines likelihood, severity, time, and context."
    }
  end
end

def alternative_invariant(id, candidate_id)
  title = ALT_TITLES.fetch(id)[{"adverse_observability" => 0, "protective_affordance" => 1, "risk_quantification" => 2}.fetch(candidate_id)]
  case candidate_id
  when "adverse_observability"
    "The #{title} by which evidence of an adverse condition at the selected scope can be made available to an observer."
  when "protective_affordance"
    "The #{title} by which adverse transformation at the selected scope can be prevented from being realized."
  else
    "The #{title} that assigns an evaluated likelihood-and-impact relation to an adverse outcome at the selected scope."
  end
end

def atoms_slot_phrase(id)
  scope, scope_description, = scope_words(id)
  phase, = phase_words(id)
  "#{phase} #{scope} adverse capacity or relation concerning #{scope_description}"
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
  siblings = %w[0 1 2].reject { |value| value == third }.map { |value| "WRN:2#{second}#{value}" }
  column = case second
           when "0" then %w[WRN:100 WRN:101 WRN:102 WRN:000]
           when "1" then %w[WRN:110 WRN:111 WRN:112 WRN:010]
           else %w[WRN:120 WRN:121 WRN:122 WRN:020]
           end
  siblings + column
end

def runtime_meanings(id)
  title = ROOTS.fetch(id).first
  third = id[-1]
  if third == "0"
    {
      "0" => "Denies that the #{title} persists in the stated warning context; it does not select the operative or latent sibling and does not assert safety.",
      "1" => "Affirms that the #{title} persists independently of current operation, without asserting that degradation, impairment, or propagation is occurring.",
      "2/num" => "Leaves unresolved whether the #{title} persists; the lexical root remains the persistent member and does not become latent."
    }
  elsif third == "1"
    {
      "0" => "Denies that the #{title} is presently operative, without thereby asserting that no persistent or latent adverse affordance exists.",
      "1" => "Affirms that the #{title} is presently operative under the applicable conditions, without asserting that the corresponding adverse transformation is underway.",
      "2/num" => "Leaves current operation of the #{title} unresolved; runtime uncertainty does not change the lexical operative status or select the latent sibling."
    }
  else
    {
      "0" => "Denies that the #{title} exists as the stated nonoperative adverse affordance; this does not establish that an operative sibling holds.",
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
    role = "ENTITY=e,SUSCEPTIBILITY=v"
    ordinary = "This account #{phase == 'persistent' ? 'retains an internal susceptibility whether or not it is currently operative' : phase == 'operative' ? 'has an internal susceptibility that is operative now' : 'retains an internal susceptibility that is not operative now'}."
    physical = "The battery has the stated susceptibility to internally originating thermal degradation without asserting that degradation is occurring."
    temporal = "During the observation interval, the same device #{phase == 'operative' ? 'has an operative internal susceptibility' : 'has the stated internal-susceptibility status'}."
    program = "The service reports whether an internally originating failure mode has the stated susceptibility status without asserting a failure event."
    counter_graph = "WRN:101[1](ENTITY=e,CONDITION=c)"
    counter_gloss = "active internal degradation"
    counter_english = "The service is degrading now."
    counter_analysis = "Use WRN:101 for the ongoing adverse transformation; #{id} names susceptibility to that transformation, not its occurrence."
  when "1"
    subject = "one hazard source and one target"
    role = "SOURCE=s,TARGET=t"
    ordinary = "The hazard and this target #{phase == 'persistent' ? 'remain linked by an exposure relation whether or not it is currently operative' : phase == 'operative' ? 'are linked by an exposure relation that is operative now' : 'retain an exposure relation that is not operative now'}."
    physical = "The corrosive source and the surface have the stated exposure relation without asserting contact or impairment."
    temporal = "During the service window, the source–target relation #{phase == 'operative' ? 'presently enables impairment' : 'has the stated exposure status'}."
    program = "The security monitor reports whether one payload and one parser have the stated exposure relation without asserting exploitation or damage."
    counter_graph = "WRN:111[1](SOURCE=s,TARGET=t)"
    counter_gloss = "active target impairment"
    counter_english = "The source is impairing the target now."
    counter_analysis = "Use WRN:111 for the ongoing adverse transformation; #{id} names an exposure relation that can enable it, not the attack or impairment process."
  else
    subject = "multiple participants in one shared system"
    role = "SYSTEM=k,PARTICIPANTS=p,CONDITION=c"
    ordinary = "The participants #{phase == 'persistent' ? 'remain connected by an adverse propagation pathway whether or not it is currently operative' : phase == 'operative' ? 'are connected by an adverse propagation pathway that is operative now' : 'retain an adverse propagation pathway that is not operative now'}."
    physical = "The facility zones have the stated contamination-propagation pathway without asserting that contamination is spreading."
    temporal = "For this interval, the shared system #{phase == 'operative' ? 'has an operative adverse propagation pathway' : 'has the stated pathway status'}."
    program = "The dependency graph reports whether one correlated fault can propagate across nodes without asserting that propagation has begun."
    counter_graph = "WRN:121[1](SYSTEM=k,PARTICIPANTS=p,CONDITION=c)"
    counter_gloss = "active systemic propagation"
    counter_english = "The correlated fault is propagating across the system now."
    counter_analysis = "Use WRN:121 for the ongoing distribution process; #{id} names the pathway that can enable it, not the propagation itself."
  end
  registers = second == "0" ? "mid register for the reference entity; low register for its susceptibility" : second == "1" ? "high register for the distinct source; low register for the target" : "sustained register for the shared system; parallel registers for participants"
  rows = [
    ["ordinary_conversation", "#{id}[1](#{role})", "affirm #{title} of #{subject}", ordinary, "The example asserts only adverse affordance, not an adverse event."],
    ["physical_or_spatial", "MAT(REALIZATION=m)+#{id}[1](#{role})", "material realization plus #{title}", physical, "MAT supplies physical realization; WRN supplies adverse significance and scope."],
    ["temporal_or_sequential", "#{id}[1](#{role})+ORI(INTERVAL=w)", "#{title} during interval w", temporal, "ORI locates the claim in time; lexical third-trit status is not tense."],
    ["cross_family_compound", "DAT(EVIDENCE=d)+STR(PATH=p)+#{id}[1](#{role})", "evidence and realization plus #{title}", "The evidence and structural path concern the adverse affordance, which still must hold independently.", "DAT and STR describe evidence or realization; neither substitutes for the WRN affordance."],
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
      "pseudocode" => category == "executable_or_programming" ? "assert(adverse_affordance.matches?(#{id.inspect}))" : nil
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
    ["adverse_affordance", winner_title, winner_definition],
    ["adverse_observability", alternatives[0], alternative_invariant(id, "adverse_observability")],
    ["protective_affordance", alternatives[1], alternative_invariant(id, "protective_affordance")],
    ["risk_quantification", alternatives[2], alternative_invariant(id, "risk_quantification")]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "phase2_mixed")["why_it_fits"],
    "candidates" => candidates.map { |candidate_id, title, definition| candidate(id, candidate_id, title, definition) },
    "recommended_candidate_id" => "adverse_affordance",
    "recommendation_reason" => "Only the adverse-affordance architecture keeps one Warning semantic center, aligns each column with its canonical WRN:1xx transformation, changes only persistent/operative/latent status within each triplet, and leaves conditions, processes, mechanics, evidence, observer knowledge, risk estimates, protective controls, and general modality separate.",
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
                when "0" then "The susceptibility belongs to one reference entity and concerns internally originating degradation; a distinct hazard source selects the outward column."
                when "1" then "The exposure relation keeps one distinct hazard source and one reference target separate; actual target impairment remains a WRN:11x process."
                else "The pathway spans multiple participants and enables distribution of one correlated adverse condition; unrelated vulnerabilities do not form one systemic pathway."
                end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => title,
    "invariant_definition" => definition,
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_2" => "Selects an adverse capacity or enabling relationship rather than an adverse-condition entity or an actual adverse transformation.",
      "second_trit" => "Selects #{scope} scope: #{scope_description}; this root names the affordance for #{center} and no competing family claim.",
      "third_trit" => "Selects #{phase_description} expression of the same #{center}; runtime truth status, tense, probability, permission, and process phase remain separate."
    },
    "inclusion_boundary" => "Includes only the #{phase_description} substrate-neutral adverse affordance for #{center}. #{scope_guard} It may be realized physically, biologically, computationally, informationally, socially, or conceptually, but it does not assert that the matching WRN:1xx transformation occurs, that a WRN:0xx adverse condition manifests, or that mechanics, evidence, knowledge, severity, probability, control, recovery, temporal, or modal conditions hold.",
    "excluded_meanings" => [
      "The intrinsic fault, external hazard, distributed fault, bearer, source, target, participant, or system as an entity or adverse condition.",
      "An actual internal degradation, source-to-target impairment, or systemic propagation process at any completion phase.",
      "Physical force, energy, contact, permeability, route, biological mechanism, structural dependency, communicative channel, or data-flow edge as such.",
      "Detection, observability, diagnosis, evidence, warning messages, belief, confidence, attribution, severity, probability, expected loss, or risk score.",
      "Resistance, immunity, shielding, filtering, isolation, containment, blocking, repairability, recovery, or other protective affordance.",
      "Readiness, plan, schedule, future time, permission, necessity, unrestricted possibility, or guaranteed occurrence of harm."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "WRN:0xx names adverse-condition entities: intrinsic faults, distinct external hazards, and correlated distributed faults. WRN:1xx names actual adverse transformations: internal degradation, source-to-target impairment, and systemic propagation. WRN:2xx names only the corresponding adverse affordance: inward susceptibility, outward source-target exposure, or a systemic propagation pathway. An affordance does not entail that its process begins or completes; an actual process does not entail that the affordance persists afterward. Persistent 2x0 identity may co-occur with its operative or latent sibling, while operative and latent are mutually exclusive for the same affordance at one reference time.",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_meanings(id),
    "lexical_runtime_distinction" => "Lexical third trit #{id[-1]} permanently selects the #{phase} member of this adverse-affordance triplet. Runtime `[2]/num` instead marks a token-level assertion pending, remembered, or unresolved. Thus `#{id}[1]` affirms the lexical concept, while a persistent or operative sibling carrying `[2]/num` remains that sibling and never becomes a latent root.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + WRN:0xx identifies the intrinsic fault, external hazard, or distributed fault associated with the adverse affordance.",
      "#{id} + WRN:1xx distinguishes an adverse affordance from its actual degradation, impairment, or propagation process.",
      "#{id} + MAT/MOV/LIF/STR/CON specifies physical, spatial, biological, structural, or communicative realization without reducing the WRN meaning to that realization.",
      "#{id} + DAT/MIN/LOG specifies evidence, recognition, formal conditions, severity, or probability while keeping the adverse affordance independent.",
      "#{id} + REP/CRE states protection, repair, recovery, or creation of the affordance without importing those processes into the atom."
    ],
    "later_era_notes" => "Later eras may lexicalize weak, vulnerable, exposed, attackable, infectable, permeable, exploitable, contagious, cascade-prone, or blast-radius descendants. Era Zero must retain the internal-susceptibility / one-source-one-target exposure / correlated-multi-participant pathway contrast and keep persistent, operative, and latent lexical status separate from runtime uncertainty and general modality.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

LEGACY_TEMPLATE_STRESS_CONCEPTS = [
  ["reconfigurable", "one_root", "WRN:200, 201, or 202 by enduring, available, or latent internal reconfiguration capacity."],
  ["flexible", "compound_or_other_family", "MAT owns physical flexibility; WRN:2x0 applies only when own constituent assignments can change."],
  ["adaptable", "underspecified_compound", "May mean structural reconfigurability, mental adaptation, biological adaptation, or repair; resolve the domain."],
  ["mutable structure", "one_root_or_compound", "WRN:2x0 covers structural reconfigurability; LOG/DAT may constrain mutation rules or representation."],
  ["modular", "compound", "WRN internal reconfigurability plus identifiable constituent positions and often target incorporability."],
  ["configurable", "compound_or_one_root", "WRN:2x0 if constituent placement can change; DAT/LOG if only parameter values or rules change."],
  ["extensible", "one_root_or_compound", "Target incorporability by lexical status, often combined with defined interface and capacity limits."],
  ["plugin-ready", "compound", "WRN:211 plus DAT interface description and LOG type or permission constraints."],
  ["spare slot", "entity_plus_compound", "WRN:002 names a vacant constituent position; WRN:2x1 is added only for a particular target's incorporability."],
  ["storage capacity", "different_family_or_compound", "Quantity and physical volume belong to MAT/LOG; WRN:2x0 is not generic capacity."],
  ["load-bearing", "different_family", "MAT physical work or force capacity, not internal reconfiguration capacity."],
  ["structurally resilient", "different_family_or_compound", "REP/MAT owns recovery and physical resilience; WRN may state preserved reconfigurability separately."],
  ["self-repairing", "different_family", "REP owns repairability; rearrangeability is insufficient."],
  ["host accepts component", "one_root", "WRN:210, 211, or 212 by established, operative, or unresolved target incorporability."],
  ["fits", "compound_or_one_root", "WRN target incorporability when fit means admission as a constituent; physical dimensions add MAT."],
  ["compatible", "underspecified_compound", "Could be structural incorporability, LOG type validity, CON protocol compatibility, or DAT schema compatibility."],
  ["interface-compatible", "compound", "WRN target incorporability plus WRN interface entity and usually LOG/DAT interface constraints."],
  ["socket match", "compound", "WRN incorporability plus MAT geometry/contact; matching does not assert insertion."],
  ["mountable", "compound", "WRN target incorporability plus a later attachment/support relation and often MAT force constraints."],
  ["attachable", "compound_or_gap", "Attachment is a continuing relation not collapsed into incorporability; use a compound or preserve the gap."],
  ["containable", "compound_or_gap", "Containment requires boundary and relation semantics; incorporability applies only if constituent status is intended."],
  ["support relation", "different_semantic_direction", "Physical support or structural dependence is intentionally not the atomic winner; compose MAT/WRN/LOG as needed."],
  ["depends on", "different_family_or_compound", "LOG, DAT, CON, MAT, or WRN may own the dependency sense; target incorporability does not imply dependence."],
  ["part of", "entity_or_compound", "Actual constituency is expressed through WRN:0xx arrangement/position plus an explicit relation or result; WRN:2x1 only qualifies incorporation."],
  ["member of", "different_family_or_compound", "LOG set membership or LIF social membership; do not force into WRN target incorporability."],
  ["contains", "entity_or_compound", "WRN composite/position plus containment relation; a host can contain without admitting the target as a constituent."],
  ["integrable", "one_root", "WRN:220, 221, or 222 by enduring, operative, or unrealized systemic integrability."],
  ["composable", "one_root_or_compound", "WRN systemic integrability when structures can become peer constituents of a higher-order whole."],
  ["interoperable", "compound", "CON communication and LOG protocol constraints plus WRN systemic integrability only if one composite structure is possible."],
  ["federatable", "compound", "WRN systemic integrability plus LOG autonomy and CON coordination rules."],
  ["clusterable", "one_root_or_compound", "WRN systemic integrability; MOV shared location and LOG cluster policy remain separate."],
  ["mergeable systems", "compound", "WRN systemic integrability plus DAT/LOG identity and conflict rules."],
  ["assemblable", "compound", "WRN integrability plus CRE/MAT if fabrication or physical joining is intended."],
  ["shared architecture", "entity_or_relation", "WRN:020–022 owns the composite arrangement; WRN:2x2 owns only qualifying integrability."],
  ["topology", "entity_or_different_relation", "WRN arrangement or MOV frame may represent topology; it is not automatically an integrability affordance."],
  ["governance", "different_family_or_compound", "LOG authority and LIF institution with CON coordination; intentionally rejected as the WRN systemic atom."],
  ["coordination", "different_family", "CON communication/coordination does not imply structural integrability."],
  ["network compatibility", "compound", "CON/DAT/LOG protocol claims plus WRN integrability when a higher-order structure is at issue."],
  ["rearrange", "process_root", "Use WRN:100–102 by phase; WRN:2x0 states only the capacity for that transformation."],
  ["incorporate", "process_root", "Use WRN:110–112 by phase; WRN:2x1 states only the target-qualifying relation."],
  ["integrate", "process_root", "Use WRN:120–122 by phase; WRN:2x2 states only the systemic qualifying relation or possibility."],
  ["build", "different_family_or_compound", "CRE owns creation; structural affordances can be inputs to building but are not the build event."],
  ["construct", "different_family_or_compound", "CRE/MAT owns construction; WRN:2xx may describe reconfigurability or integrability of inputs."],
  ["repair", "different_family", "REP owns repair and recoverability; a separate WRN claim is needed only if repair restores a structural affordance."],
  ["transport", "different_family", "MOV/MAT owns transport; structural fit is a separate possible condition."],
  ["communicate", "different_family", "CON owns exchange; structural integrability is neither necessary nor sufficient."],
  ["type compatible", "different_family", "LOG owns formal type compatibility; WRN applies only to structural constituent organization."],
  ["schema compatible", "different_family_or_compound", "DAT/LOG owns schema compatibility; WRN applies if instantiated structures can combine."],
  ["API compatible", "compound", "LOG/DAT/CON own protocol validity and exchange; WRN integrability may be separately asserted."],
  ["scheduled integration", "compound", "ORI/LOG schedule plus WRN:122 for a nonactualized process; WRN:2xx never encodes schedule."],
  ["possible integration", "ambiguous_root_or_process", "WRN:122 is a nonactualized process; WRN:222 is an unrealized qualifying possibility. Choose by whether the claim is about an event or a relation."],
  ["likely integration", "compound", "Probability plus WRN:122 or 222; neither root carries likelihood."],
  ["ready to integrate", "compound", "Readiness requires an explicit runtime or LOG/ORI condition; WRN:221 states only operative integrability."],
  ["permitted to integrate", "compound", "LOG permission plus WRN:2x2; permission does not establish structural integrability."],
  ["reconfiguration capacity in use", "two_claims", "WRN:201 states available capacity and WRN:101 states the active process; neither entails the other."],
  ["stable capacity currently uncertain", "one_root_plus_runtime", "WRN:200[2]/num: stable lexical capacity with unresolved token-level assertion."],
  ["latent capacity affirmed", "one_root_plus_runtime", "WRN:202[1]: the latent capacity is asserted as real although unavailable."],
  ["operative target fit denied", "one_root_plus_runtime", "WRN:211[0]: deny current operation without asserting WRN:212."],
  ["unresolved fit affirmed", "one_root_plus_runtime", "WRN:212[1]: affirm that qualification remains unresolved; not the same as WRN:210[2]."],
  ["enduring integrability uncertain", "one_root_plus_runtime", "WRN:220[2]/num: uncertainty about an enduring relation, not lexical unrealized possibility."],
  ["unrealized integrability affirmed", "one_root_plus_runtime", "WRN:222[1]: affirm the unrealized structural possibility without asserting process, probability, or plan."],
  ["drawer fits but is not inserted", "one_root", "WRN:210 or 211 can hold without WRN:110/111 because a qualifying relation does not entail the incorporation process."],
  ["drawer inserted despite no enduring fit", "process_plus_state", "WRN:110 may be true while WRN:210 is false; successful process does not guarantee persistent affordance."],
  ["modules integrable but communicating separately", "one_root_plus_other_family", "WRN:2x2 and CON relations are independent; the modules may be structurally integrable without any shared exchange."],
  ["modules communicating but not integrable", "different_family_plus_negation", "CON may hold while WRN integrability is denied because successful exchange does not establish a higher-order structural affordance."],
  ["two parts already form a composite", "entity_or_process", "Use WRN:020/021 for the arrangement or WRN:120 for completed integration; not WRN:2x2 alone."],
  ["one host absorbs one subsystem", "target_incorporability", "Preserved host and one target select WRN:2x1, not systemic WRN:2x2."],
  ["two hosts can form a new cluster", "systemic_integrability", "Peer inputs and a higher-order whole select WRN:2x2, not target WRN:2x1."],
  ["unknown host identity", "unresolved_gap", "If preserved host versus peer-input scope is unknown, do not guess outward or systemic address."],
  ["unknown affordance status", "unresolved_gap", "If stable, active, or lexical unresolved status cannot be determined, preserve ambiguity rather than guessing the third trit."],
  ["physical clearance only", "different_family_or_compound", "MAT geometry may show clearance; WRN incorporability additionally requires constituent qualification."],
  ["logical rule says allowed but structure cannot accept", "two_claims", "LOG permission can be true while WRN target incorporability is false."],
  ["blueprint says composable but implementation is not", "two_claims", "DAT specification can claim compatibility while WRN systemic integrability is denied."],
  ["repair makes structure reconfigurable", "compound", "REP process plus WRN:201 result claim; repair and reconfigurability remain distinct."],
  ["design for modularity", "compound", "CRE/DAT design plus a nonactualized or asserted WRN affordance; design does not establish the affordance."],
  ["future extensibility", "compound", "ORI future relation plus WRN target incorporability; the WRN root itself is tenseless."],
  ["general possibility", "different_family", "ORI owns unrestricted possibility; WRN:222 is narrowly systemic and structural."],
  ["system necessity", "different_family", "ORI/LOG owns necessity; integrability says what can structurally combine, not what must."],
  ["structural possibility becomes active", "two_time_indexed_claims", "Relate WRN:222 at one time to WRN:221 at another; the roots do not encode the transition by themselves."],
  ["capacity versus active process", "scope_resolution_test", "WRN:201[1] asserts available reconfiguration capacity; WRN:101[1] asserts reconfiguration is occurring."],
  ["fit relation versus incorporation", "scope_resolution_test", "WRN:211[1] asserts operative incorporability; WRN:111[1] asserts the target is actually being incorporated."],
  ["integrability relation versus integration", "scope_resolution_test", "WRN:221[1] asserts operative systemic integrability; WRN:121[1] asserts integration is occurring."]
].freeze

STRESS_CONCEPTS = [
  ["vulnerable", "one_root_or_compound", "WRN:200, 201, or 202 by persistent, operative, or latent internal susceptibility; add the relevant degradation domain separately."],
  ["susceptible", "one_root", "WRN:2x0 when one entity has an adverse affordance for internally originating degradation and scope is resolved."],
  ["weak", "underspecified", "May mean WRN susceptibility, MAT low strength, REP low resistance, MIN low confidence, or another domain; resolve the sense."],
  ["fault-prone", "one_root_or_compound", "WRN internal susceptibility plus LOG/DAT fault criteria; proneness does not assert a fault or failure event."],
  ["failure-prone", "one_root_or_compound", "WRN internal susceptibility plus a domain-specific failure definition; probability remains separate."],
  ["fragile", "compound", "WRN internal susceptibility plus MAT force threshold or REP low resistance; fragility is not one untyped atom."],
  ["brittle", "different_family_or_compound", "MAT owns material brittleness; add WRN susceptibility only when adverse degradation affordance is asserted."],
  ["unstable", "underspecified", "May denote dynamic instability, logical inconsistency, social volatility, or WRN susceptibility; do not force it into Warning."],
  ["buggy", "compound", "WRN intrinsic fault or susceptibility plus DAT/LOG software semantics; distinguish condition, affordance, and active degradation."],
  ["defective", "condition_not_affordance", "WRN:00x names an intrinsic adverse condition; WRN:2x0 states susceptibility and does not entail an existing defect."],
  ["persistent susceptibility", "one_root", "WRN:200 preserves internal-susceptibility identity independently of whether it is currently operative."],
  ["operative susceptibility", "one_root", "WRN:201 states that internal susceptibility is presently operative under applicable conditions without asserting degradation."],
  ["latent susceptibility", "one_root", "WRN:202 states that internal susceptibility exists but is not presently operative."],
  ["hidden vulnerability", "one_root_plus_epistemic_claim", "WRN:202 supplies latent nonoperation only; DAT/MIN must separately state that observers have not discovered it."],
  ["unknown vulnerability", "runtime_state_or_epistemic_claim", "Use runtime [2]/num or DAT/MIN uncertainty; lexical WRN:202 does not mean unknown."],
  ["possible vulnerability", "affordance_plus_modality", "A WRN susceptibility root identifies the typed affordance; ORI/LOG supplies unrestricted possibility or probability."],
  ["likely vulnerability", "affordance_plus_probability", "WRN supplies susceptibility while LOG or probability grammar supplies likelihood; third trit never means likely."],
  ["scheduled vulnerability scan", "different_process_plus_time", "DAT/LOG/MIN owns scanning and ORI owns schedule; no WRN:2xx root encodes the scan."],
  ["self-monitoring", "different_family", "DAT/MIN owns observation of one entity; susceptibility may exist with no monitoring."],
  ["diagnosable", "different_family_or_compound", "DAT/MIN/LOG owns diagnosability; adverse susceptibility and evidence availability are independent."],
  ["observable fault", "compound", "WRN:0xx fault condition plus DAT evidence availability; WRN:2xx is not observability."],
  ["resistant", "different_family", "REP owns resistance or prevention capacity; resistance is directionally opposite to adverse susceptibility."],
  ["immune", "different_family_or_compound", "LIF and REP own biological or protective immunity; denial of WRN susceptibility may be added but is not the same atom."],
  ["self-protecting", "different_family_or_compound", "REP/LOG/STR owns protective action or control; WRN internal susceptibility does not protect."],
  ["self-healing", "different_family", "REP owns recovery capacity and repair; susceptibility neither entails nor denies self-healing."],
  ["internally degrading", "process_root", "WRN:100–102 by phase names adverse transformation; WRN:2x0 names susceptibility to it."],
  ["internal fault present", "condition_root", "WRN:000–002 by manifestation status names the adverse condition rather than susceptibility or process."],
  ["persistent susceptibility currently uncertain", "one_root_plus_runtime", "WRN:200[2]/num leaves the persistent claim unresolved and does not select WRN:202."],
  ["latent susceptibility affirmed", "one_root_plus_runtime", "WRN:202[1] affirms a real but nonoperative susceptibility without adding hiddenness or likelihood."],
  ["operative susceptibility denied", "one_root_plus_runtime", "WRN:201[0] denies present operation without establishing that WRN:202 or WRN:200 holds."],
  ["exposed to", "one_root", "WRN:2x1 by lexical status when one distinct hazard source and one target have an impairment-enabling relation."],
  ["exposure", "one_root_or_compound", "WRN source-target exposure relation if adverse enablement is meant; physical contact, publicity, and experience belong elsewhere."],
  ["attack surface", "compound", "WRN source-target exposure plus STR interfaces and LOG exploit conditions; it is not one atomic surface entity."],
  ["exploitable", "compound", "WRN:2x1 supplies adverse exposure while LOG/DAT supplies exploit rule or flaw; exploitation itself is WRN:11x plus domain mechanics."],
  ["reachable by hazard", "compound", "WRN exposure plus MOV reachability or CON channel facts; spatial or network reach alone is neutral."],
  ["within blast radius", "compound", "WRN exposure relation plus MAT/MOV extent and force; it does not assert that damage occurs."],
  ["permeable to toxin", "compound", "WRN exposure plus MAT permeability and LIF/MAT toxin semantics; permeability alone is not adverse."],
  ["at risk from source", "one_root_or_compound", "WRN exposure when the phrase means impairment-enabling relation; likelihood and severity require separate LOG/DAT claims."],
  ["persistent exposure relation", "one_root", "WRN:210 preserves one source-target adverse-enablement relation independently of current operation."],
  ["operative exposure relation", "one_root", "WRN:211 states that the source-target relation presently enables impairment but not that impairment is occurring."],
  ["latent exposure relation", "one_root", "WRN:212 states that the source-target relation exists without presently enabling impairment."],
  ["uncertain threat relation", "runtime_state_or_epistemic_claim", "Use WRN:210/211/212 with runtime [2]/num or DAT/MIN evidence claims; lexical 212 means latent, not uncertain."],
  ["active attack", "process_or_compound", "WRN:111 supplies active target impairment; MIN, MOV, MAT, DAT, or LOG supplies intent and mechanics as applicable."],
  ["hazard exists", "condition_root", "WRN:010–012 names the distinct external hazard condition; an exposure relation to a target must be separately asserted."],
  ["hazard touches target", "different_family_or_compound", "MAT contact does not entail adverse exposure; WRN applies only if impairment enablement is asserted."],
  ["hazard approaches target", "different_family", "MOV owns approach; proximity may coexist with exposure but is neither necessary nor sufficient."],
  ["hazard warns target", "different_family", "CON owns warning communication; a source may warn without being able to impair the target."],
  ["target blocked from source", "different_family_or_compound", "LOG/STR owns blocking or separation; it may make WRN exposure latent or false but is not the exposure atom."],
  ["target shielded", "different_family_or_compound", "REP/MAT/STR owns protection; shield status and adverse exposure must be asserted separately."],
  ["source authorized to act", "different_family", "LOG permission neither establishes nor removes a WRN exposure relation."],
  ["source likely to harm target", "compound", "WRN exposure or impairment plus LOG probability; likely is not encoded by lexical status."],
  ["exposure window", "compound", "ORI interval plus WRN source-target exposure; the WRN relation itself is tenseless."],
  ["operative exposure uncertain", "one_root_plus_runtime", "WRN:211[2]/num questions current operation while preserving the operative lexical selection."],
  ["latent exposure affirmed", "one_root_plus_runtime", "WRN:212[1] affirms an existing nonoperative relation and does not mean a merely possible or unknown relation."],
  ["impairment without enduring exposure", "process_plus_relation_status", "WRN:111 may occur while WRN:210 is denied; an event does not guarantee a persistent enabling relation."],
  ["exposure without impairment", "one_root", "WRN:210 or 211 can hold without WRN:11x because an affordance does not entail its realization."],
  ["propagation pathway", "one_root", "WRN:2x2 by lexical status when one adverse condition can distribute across multiple participants in one shared system."],
  ["failure path", "one_root_or_compound", "WRN systemic pathway plus STR/LOG dependency structure; a neutral dependency edge alone is not adverse."],
  ["contagion route", "compound", "WRN systemic pathway plus LIF biological identity and MOV/CON transmission realization."],
  ["infection channel", "compound", "WRN systemic pathway plus LIF and CON/MAT channel semantics; no propagation event is entailed."],
  ["cascade path", "one_root_or_compound", "WRN systemic pathway when one correlated adverse condition can distribute; add STR/LOG dependency details."],
  ["fault tree", "compound", "DAT representation and LOG causal structure may describe a WRN propagation pathway but are not the pathway itself."],
  ["blast path", "compound", "WRN systemic pathway plus MAT force and MOV extent; the adverse distribution need not be active."],
  ["shared vulnerability", "underspecified", "May be several independent susceptibilities or one systemic propagation pathway; correlation and participant structure must be resolved."],
  ["common-mode failure channel", "compound", "WRN systemic pathway plus STR dependency and LOG common-cause criteria."],
  ["persistent propagation pathway", "one_root", "WRN:220 preserves pathway identity independently of whether it presently enables propagation."],
  ["operative propagation pathway", "one_root", "WRN:221 states that the pathway presently enables one correlated adverse condition to distribute."],
  ["latent propagation pathway", "one_root", "WRN:222 states that the pathway exists but does not presently enable distribution."],
  ["catastrophe possibility", "compound_not_atom", "Use WRN affordance plus ORI/LOG possibility and DAT/LOG outcome criteria; WRN:222 is a latent pathway, not catastrophe modality."],
  ["cascading risk", "compound", "WRN propagation pathway or process plus LOG/DAT probability and severity; risk does not collapse into pathway identity."],
  ["failure spreading", "process_root", "WRN:120–122 by phase names the propagation process; WRN:2x2 names the pathway that can enable it."],
  ["distributed fault present", "condition_root", "WRN:020–022 names the correlated adverse condition across participants; the pathway remains a separate relation."],
  ["neutral network route", "different_family", "MOV/CON/STR owns neutral routes and channels; WRN applies only when adverse propagation enablement is asserted."],
  ["broadcast channel", "different_family", "CON owns expression distribution; a warning broadcast is not an adverse propagation pathway."],
  ["dataflow edge", "different_family_or_compound", "DAT/CON owns information flow; add WRN only when it enables distribution of an adverse condition."],
  ["structural dependency", "different_family_or_compound", "STR/LOG owns dependency; it becomes a WRN compound only when adverse propagation enablement is asserted."],
  ["many unrelated failures", "not_systemic_pathway", "Separate inward or target roots are required; simultaneity does not create one correlated pathway."],
  ["same source can harm two independent targets", "multiple_exposure_relations", "Use two WRN:2x1 exposure relations unless one adverse condition can propagate among participants through a shared system."],
  ["participants connected but immune", "other_family_plus_negation", "STR/CON connectivity can hold while WRN propagation enablement is denied due to REP/LIF protection."],
  ["pathway exists but propagation stopped", "relation_plus_process_boundary", "WRN:220 may remain true while WRN:121 is denied or ceased; process cessation does not erase persistent pathway identity."],
  ["operative pathway uncertain", "one_root_plus_runtime", "WRN:221[2]/num leaves present operation unresolved and does not select WRN:222."],
  ["latent pathway affirmed", "one_root_plus_runtime", "WRN:222[1] affirms a real nonoperative pathway without probability, plan, or future activation."],
  ["persistent and operative susceptibility", "compatible_lexical_states", "WRN:200 and WRN:201 may co-occur for one susceptibility because persistence is operation-neutral."],
  ["persistent and latent exposure", "compatible_lexical_states", "WRN:210 and WRN:212 may co-occur because persistent identity does not assert current operation."],
  ["operative and latent same affordance", "incompatible_same_time_claim", "WRN:2x1 and WRN:2x2 are mutually exclusive for the same affordance at one reference time."],
  ["latent becomes operative", "two_time_indexed_claims", "Relate WRN:2x2 at an earlier time to WRN:2x1 later; the roots do not encode activation by themselves."],
  ["operative becomes latent", "two_time_indexed_claims", "Relate WRN:2x1 at an earlier time to WRN:2x2 later; no repair or containment process is entailed."],
  ["affordance versus condition", "scope_resolution_test", "WRN:0xx identifies an adverse condition; WRN:2xx identifies capacity or relation enabling a WRN:1xx process."],
  ["affordance versus process", "scope_resolution_test", "WRN:2xx can hold without any WRN:1xx event, and a WRN:1xx event does not guarantee the affordance persists."],
  ["latent versus uncertain", "scope_resolution_test", "WRN:202[1] affirms nonoperation; WRN:201[2]/num preserves operative lexical status while leaving its truth unresolved."],
  ["pathway versus route", "scope_resolution_test", "WRN systemic pathway asserts adverse propagation enablement; MOV/CON/STR routes can be entirely neutral."],
  ["exposure versus contact", "scope_resolution_test", "WRN exposure asserts impairment enablement; MAT contact alone does not."],
  ["susceptibility versus risk score", "scope_resolution_test", "WRN susceptibility is an adverse affordance; LOG/DAT supplies quantified likelihood and impact."],
  ["protective control removes operation", "compound", "REP/STR/LOG control may change WRN:201 or 211 to a latent sibling, but the control and status transition remain separate claims."],
  ["create a vulnerability", "compound", "CRE generation plus the resulting WRN susceptibility; the creation process is not encoded in WRN:2xx."],
  ["repair a vulnerability", "compound", "REP repair plus denial or status change of WRN susceptibility; repair is not the adverse affordance."],
  ["measure exposure", "compound", "DAT measurement plus WRN source-target relation; the measurement can be wrong while the relation still holds."],
  ["calculate risk", "different_family_or_compound", "LOG/DAT computes likelihood and impact from WRN conditions and affordances; the result is not itself a WRN root."],
  ["warn about a pathway", "compound", "CON warning expression plus DAT content referring to a WRN systemic pathway."],
  ["future exposure", "one_root_plus_time", "ORI future relation plus a status-resolved WRN exposure root; lexical latency does not mean future."],
  ["scheduled activation of pathway", "compound", "ORI/LOG schedule plus status and process claims; WRN:222 does not encode scheduling."],
  ["unknown scope", "unresolved_gap", "If internal susceptibility, one-source-one-target exposure, or systemic pathway cannot be distinguished, preserve ambiguity."],
  ["unknown lexical status", "unresolved_gap", "If persistent, operative, or latent status cannot be resolved, use runtime uncertainty or leave the address unspecified rather than guessing."],
  ["no applicable adverse criterion", "not_warning", "If no evaluation frame classifies the enabled transformation as adverse, do not use WRN even when a neutral capacity or route exists."]
].freeze

stress_tests = STRESS_CONCEPTS.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("WRN2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "WRN:200–222 adversarial semantic candidates",
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
    "title" => "WRN:200–222 recommended permanent semantic specification",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER,
    "triplets" => {
      "WRN:200–202" => "internal susceptibility: persistent / operative / latent",
      "WRN:210–212" => "source-target exposure: persistent / operative / latent",
      "WRN:220–222" => "systemic propagation pathway: persistent / operative / latent"
    },
    "scope_separation" => {
      "inward" => "one reference entity; susceptibility to internally originating degradation",
      "outward" => "one distinct hazard source and one reference target; exposure that can enable impairment",
      "systemic" => "multiple participants in one shared system; pathway that can enable distribution of one correlated adverse condition"
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
    "title" => "WRN:200–222 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary",
    "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true
  },
  "tests" => stress_tests
}

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# WRN:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Warning capacity/relation meanings from first principles. It compares five genuinely different architectures at every address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level decision\n\nThe strongest architecture makes `WRN:2xx` the adverse-affordance layer paired with canonical `WRN:1xx`. `WRN:200–202` says whether one reference entity is susceptible to internally originating degradation. `WRN:210–212` says whether one distinct hazard source and one target have an exposure relation that can enable impairment. `WRN:220–222` says whether one correlated adverse condition has a propagation pathway across multiple participants in a shared system.\n\n"
review << "This replaces the Phase 2 mixture of vulnerability, observer knowledge, current exploitation, uncertainty, cascading risk, and catastrophe possibility. Those candidates were useful prompts but blurred conditions, affordances, processes, evidence, probability, severity, and modality. The recommended grid uses one persistent/operative/latent contrast and remains neutral about substrate, observer knowledge, mechanics, likelihood, protective response, and actual realization.\n\n"

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
  review << "| #{id} | #{root['proposed_title']} | #{phase_description} | WRN:0xx condition, WRN:1xx process, mechanics, evidence, protection, risk score, or general modality |\n"
end
review << "\n## Triplet coherence\n\n| Triplet | Shared affordance | `0` persistent | `1` operative | `2` latent |\n| --- | --- | --- | --- | --- |\n| WRN:200–202 | one entity is susceptible to internally originating degradation | identity persists independently of operation | susceptibility presently operative | susceptibility exists but is not operative |\n| WRN:210–212 | one source-target exposure relation can enable impairment | relation persists independently of operation | exposure presently enables impairment | exposure exists but does not presently enable impairment |\n| WRN:220–222 | one systemic pathway can enable distribution of one correlated adverse condition | pathway persists independently of operation | pathway presently enables distribution | pathway exists but is not operative |\n\nPersistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time. Lexical latency never means uncertainty, hiddenness from an observer, probability, plan, schedule, or future time.\n\n"
review << "## English ownership and reservations\n\nThe roots own substrate-neutral *susceptibility*, adverse *source-target exposure*, and adverse *systemic propagation pathway* only under their exact invariants. Physical weakness and permeability belong to MAT; biological mechanism to LIF; routes and channels to MOV/CON/STR; evidence and observability to DAT/MIN; resistance and protection to REP; probability and validity to LOG; creation to CRE; unrestricted possibility and time to ORI. *Weak*, *fragile*, *exploitable*, *attack surface*, *contagious*, *cascade-prone*, *risk*, *likely*, *hidden*, and *scheduled* remain compounds or sense-resolution tasks.\n\n"
review << "## Stress test\n\n#{stress_tests.length} unique concepts were routed through single roots, WRN conditions or processes, compounds, other families, runtime state, grammar, or explicit gaps. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** approved under `migrations/#{STEM}_semantic_approval.yaml`; this file remains the adversarial evidence record.\n" : "\n**Recommendation:** approve only after reusable packet validation, full WRN:000–222 soundness validation, and current-state regression. Until then all nine roots remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# WRN:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MAT weakness; LIF predisposition; REP low resistance; DAT observability", "1" => "MOV reachability; MAT contact; CON channels; LOG exploit rules", "2" => "STR dependency; CON transmission; DAT flow graphs; ORI possibility" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | WRN keeps only the adverse affordance for the matching degradation, impairment, or propagation transformation |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Same-family safeguards\n\n- `WRN:0xx` owns adverse-condition entities; `WRN:1xx` owns actual adverse transformations; `WRN:2xx` owns only capacities and relations that can enable those transformations.\n- Internal susceptibility belongs to one reference entity and concerns internally originating degradation; it does not assert a fault, degradation event, observer knowledge, or probability.\n- Source-target exposure preserves one distinct hazard source and one target. It does not assert contact, approach, warning, permission, attack, impairment, blame, or severity.\n- A systemic propagation pathway spans multiple participants and enables distribution of one correlated adverse condition. It does not assert neutral communication, unrelated failures, an active cascade, or catastrophe probability.\n- Persistent roots are operation-neutral and may co-occur with operative or latent siblings. Operative and latent are mutually exclusive for the same affordance at one reference time. Runtime `[0]`, `[1]`, or `[2]/num` never changes lexical status.\n\n## Reserved compounds and gaps\n\nWeakness, fragility, immunity, exploitability, attack surface, blast radius, contagion, cascade risk, observability, hiddenness, likelihood, severity, expected loss, protection, containment, repair, readiness, scheduling, and future activation remain compounds, other-family claims, or explicit gaps.\n\n**CONCLUSION: WRN:200–222 STANDS ALONE ONLY FOR SUBSTRATE-NEUTRAL ADVERSE AFFORDANCE; MATERIAL, SPATIAL, BIOLOGICAL, STRUCTURAL, COGNITIVE, COMMUNICATIVE, NORMATIVE, INFORMATIONAL, CREATIVE, REPARATIVE, AND GENERAL MODAL CLAIMS REMAIN SEPARATE.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built #{RANGE} review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
