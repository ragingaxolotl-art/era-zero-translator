#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "LOG:200–222"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "LOG_200_222"
SEMANTIC_CENTER = "formal-evaluation affordances: internal evaluability, constraint-target applicability, and systemic joint-evaluability"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "LOG:200" => ["stable decidability", "An inward question has a dependable capacity to be resolved under the available rules."],
  "LOG:201" => ["active computability", "A calculation or inference is currently possible with available rules and resources."],
  "LOG:202" => ["latent rule applicability", "A rule or solution capacity exists but required conditions, bindings, or resources are absent."],
  "LOG:210" => ["implication relation", "A stable formal relationship connects a premise, input, or condition to a conclusion or target."],
  "LOG:211" => ["active entailment", "A target is actively being derived, constrained, or validated by a premise or rule."],
  "LOG:212" => ["conditional dependency", "A possible implication or constraint relation exists but its conditions or truth remain unresolved."],
  "LOG:220" => ["consistent rule space", "A formal system has stable relationships that preserve validity across its rules and values."],
  "LOG:221" => ["active recursive system", "Logical processes are actively composing, iterating, or operating in parallel within one rule space."],
  "LOG:222" => ["formal possibility space", "A consistent program, proof, or solution could exist within the rules but has not been constructed."]
}.freeze

ROOTS = {
  "LOG:200" => { title: "persistent internal formal evaluability", phase: "persistent", scope: "inward", kind: "internal formal evaluability", invariant: "A persistent capacity of one reference entity to undergo formal evaluation under its applicable internal criterion, independently of whether that capacity is presently operative." },
  "LOG:201" => { title: "operative internal formal evaluability", phase: "operative", scope: "inward", kind: "internal formal evaluability", invariant: "A capacity of one reference entity to undergo formal evaluation under its applicable internal criterion that is presently operative." },
  "LOG:202" => { title: "latent internal formal evaluability", phase: "latent", scope: "inward", kind: "internal formal evaluability", invariant: "A capacity of one reference entity to undergo formal evaluation under its applicable internal criterion that exists without being presently operative." },
  "LOG:210" => { title: "persistent constraint-target applicability", phase: "persistent", scope: "outward", kind: "constraint-target applicability", invariant: "A persistent formal applicability relation between one specified constraint and one distinct reference target that can enable target constraint application, independently of whether that relation is presently operative." },
  "LOG:211" => { title: "operative constraint-target applicability", phase: "operative", scope: "outward", kind: "constraint-target applicability", invariant: "A formal applicability relation between one specified constraint and one distinct reference target that presently enables target constraint application." },
  "LOG:212" => { title: "latent constraint-target applicability", phase: "latent", scope: "outward", kind: "constraint-target applicability", invariant: "A formal applicability relation between one specified constraint and one distinct reference target that exists without presently enabling target constraint application." },
  "LOG:220" => { title: "persistent systemic joint-evaluability", phase: "persistent", scope: "systemic", kind: "systemic joint-evaluability", invariant: "A persistent capacity of multiple participants under one shared formal regime to undergo one coordinated joint evaluation, independently of whether that capacity is presently operative." },
  "LOG:221" => { title: "operative systemic joint-evaluability", phase: "operative", scope: "systemic", kind: "systemic joint-evaluability", invariant: "A capacity of multiple participants under one shared formal regime to undergo one coordinated joint evaluation that is presently operative." },
  "LOG:222" => { title: "latent systemic joint-evaluability", phase: "latent", scope: "systemic", kind: "systemic joint-evaluability", invariant: "A capacity of multiple participants under one shared formal regime to undergo one coordinated joint evaluation that exists without being presently operative." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 9, 4, 5, 8, 8, 9] },
  "formal_evaluability_affordances" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "consequence_entailment_relations" => { scores: [9, 8, 10, 7, 8, 10, 8, 10] },
  "consistency_compatibility_relations" => { scores: [8, 8, 9, 7, 7, 9, 9, 10] },
  "permission_authorization_relations" => { scores: [8, 7, 8, 6, 5, 9, 10, 8] }
}.freeze

ALT_TITLES = {
  "LOG:200" => ["persistent internal consequence relation", "persistent internal consistency", "persistent internal authorization"],
  "LOG:201" => ["operative internal consequence relation", "operative internal consistency", "operative internal authorization"],
  "LOG:202" => ["latent internal consequence relation", "latent internal consistency", "latent internal authorization"],
  "LOG:210" => ["persistent target entailment", "persistent target compatibility", "persistent target permission"],
  "LOG:211" => ["operative target entailment", "operative target compatibility", "operative target permission"],
  "LOG:212" => ["latent target entailment", "latent target compatibility", "latent target permission"],
  "LOG:220" => ["persistent systemic consequence relation", "persistent systemic consistency", "persistent systemic authorization regime"],
  "LOG:221" => ["operative systemic consequence relation", "operative systemic consistency", "operative systemic authorization regime"],
  "LOG:222" => ["latent systemic consequence relation", "latent systemic consistency", "latent systemic authorization regime"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological capacities, agents, and social roles. A living bearer may be formally evaluable, but LOG:2xx does not encode life, health, intelligence, office, or agency.",
  "MOV" => "MOV owns position, routes, displacement, and motion affordances. A route may be evaluated under constraints, but formal evaluability or applicability is not movement, reachability, or a spatial path.",
  "MAT" => "MAT owns substance, energy, force, contact, material compatibility, and physical capacities. Material properties may make evaluation implementable, but LOG:2xx does not encode sensors, energy, mechanism, or physical coupling.",
  "MIN" => "MIN owns attention, belief, expectation, confidence, understanding, and cognitive capacity. Formal evaluability can hold without anyone knowing, believing, understanding, or intending that it holds.",
  "CON" => "CON owns communication, social linkage, participation, access, and authority-bearing interaction. A channel may carry evaluation inputs, but reachability, permission, and institutional authorization are not formal evaluability.",
  "WRN" => "WRN owns hazards, faults, adverse processes, susceptibility, exposure, and propagation pathways. Inability to evaluate may be adverse, but LOG:2xx does not assert danger, failure, warning, or vulnerability.",
  "STR" => "STR owns arrangements, interfaces, dependencies, structural compatibility, and transformation affordances. Structure may realize evaluability, but LOG:2xx adds only typed formal-evaluation enablement.",
  "REP" => "REP owns restoration conditions, transformations, and affordances. A repair may be formally evaluable, but LOG:2xx is not recoverability, repair applicability, or a restoration pathway.",
  "DAT" => "DAT owns values, representations, schemas, code, proof objects, computational resources, and information flow. Such data may enable evaluation, but it is not the formal evaluability or constraint-target applicability relation itself.",
  "CRE" => "CRE owns generation, construction, transformation, and productive capacities. Creating a criterion, evaluator, or result is separate from whether the specified evaluation is enabled.",
  "ORI" => "ORI owns general possibility, necessity, probability, time, cause, and ontological qualification. LOG:2xx asserts a typed formal affordance or applicability relation, never unrestricted possibility or futurity."
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
  when "formal_evaluability_affordances"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "consequence_entailment_relations"
    values[1] -= 1 if second == "1"
    values[3] -= 1 if third == "2"
  when "consistency_compatibility_relations"
    values[2] -= 1 if second == "2"
    values[5] -= 1 if second == "0"
  when "permission_authorization_relations"
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
      "why_it_fits" => "The provisional titles use central Logic vocabulary—decidability, computability, applicability, implication, entailment, consistency, recursion, and possibility—and roughly reflect #{root.fetch(:scope)} scope and #{root.fetch(:phase)} status.",
      "useful_coverage" => "They reach theorem proving, calculation, dependency, constraint solving, program execution, and formal-system design.",
      "semantic_territory_consumed" => "Across the block they mix evaluability, actual derivation, implication, result validity, computational resources, recursive processes, observer uncertainty, and unrestricted modality.",
      "conflicts_or_future_limitations" => "The three triplets have no shared invariant center and the third trit shifts among stability, activity, missing conditions, unresolved truth, and mere possibility."
    }
  when "formal_evaluability_affordances"
    {
      "why_it_fits" => "First-trit 2 becomes the capacity or qualifying relation enabling the matching LOG:1xx evaluation; the second trit changes only inward, target, or systemic scope; and the third changes only persistent, operative, or latent status.",
      "useful_coverage" => "It supports evaluable, checkable, decidable-in-context, applicable constraint, type applicability, joint evaluability, interoperable validation, and capability-aware programming.",
      "semantic_territory_consumed" => "Only typed enablement for formal evaluation. Rule identity, actual evaluation, result polarity, algorithms, resource bounds, entailment, consistency, permission, evidence, and modality remain separate.",
      "conflicts_or_future_limitations" => "The English words decidable and computable have stronger technical senses, so the permanent title uses evaluability and those stronger claims require compounds or later specialization."
    }
  when "consequence_entailment_relations"
    {
      "why_it_fits" => "Implication and entailment are core formal relations and can be framed at inward, target, or systemic scope with persistent, operative, or latent status.",
      "useful_coverage" => "It would cover implies, entails, follows from, depends formally on, proves, derives, and guarantees.",
      "semantic_territory_consumed" => "It consumes premise-to-conclusion consequence rather than capacity to conduct a formal evaluation.",
      "conflicts_or_future_limitations" => "Consequence relations require distinct premise and conclusion roles that fit the outward column better than inward or systemic columns, weakening the nine-root cube."
    }
  when "consistency_compatibility_relations"
    {
      "why_it_fits" => "Consistency and compatibility are formal relations that matter internally, between a constraint and target, and across a system.",
      "useful_coverage" => "It would cover noncontradiction, compatibility, satisfiability, coherence, composability, and conflict freedom.",
      "semantic_territory_consumed" => "It consumes one positive relation among propositions, constraints, values, or participants.",
      "conflicts_or_future_limitations" => "An evaluable object need not be consistent, and an inconsistent system can still be evaluated; structural and material compatibility also collide with STR and MAT."
    }
  when "permission_authorization_relations"
    {
      "why_it_fits" => "Rules often determine whether an entity, target action, or shared operation is permitted, and authorization can be persistent, operative, or latent.",
      "useful_coverage" => "It would cover permitted, allowed, authorized, licensed, eligible, forbidden, and access-controlled.",
      "semantic_territory_consumed" => "It consumes normative or institutional authority rather than formal evaluation capability.",
      "conflicts_or_future_limitations" => "Permission requires principals, authority, policy, and usually social or communicative relations in LIF, CON, and DAT; evaluability is independent of permission."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "consequence_entailment_relations"
    "A #{root.fetch(:phase)} formal consequence or entailment relation at #{root.fetch(:scope)} logical scope."
  when "consistency_compatibility_relations"
    "A #{root.fetch(:phase)} formal consistency or compatibility relation at #{root.fetch(:scope)} scope."
  when "permission_authorization_relations"
    "A #{root.fetch(:phase)} permission or authorization relation at #{root.fetch(:scope)} scope."
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
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "LOG:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "LOG:#{first}#{x}#{third}" }
  entity = "LOG:0#{second}#{third}"
  process = "LOG:1#{second}#{third}"
  (siblings + scopes + [entity, process]).uniq
end

def roles
  {
    "low" => "reference entity or participant whose formal evaluability is asserted",
    "middle" => "formal-evaluation capacity or applicability relation as the asserted figure",
    "high" => "applicable internal criterion, specified constraint, or distinct target",
    "sustained" => "shared formal regime and multiple jointly evaluable participants"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} persists in the stated formal context; it does not select the operative or latent sibling and does not establish a different logical relation.",
      "1" => "Affirms that this #{root.fetch(:kind)} persists independently of current operation, without asserting that a formal evaluation is occurring or that any result holds.",
      "2/num" => "Leaves unresolved whether this persistent #{root.fetch(:kind)} claim holds; runtime uncertainty does not change the lexical root into operative or latent status."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently operative; it does not deny persistent identity or affirm the latent sibling, impossibility, or rule absence.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently operative under the applicable conditions, without asserting that the corresponding evaluation is underway or completed.",
      "2/num" => "Leaves current operation of this #{root.fetch(:kind)} unresolved; token uncertainty does not select the persistent or latent lexical sibling."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} exists as the stated nonoperative formal affordance; it does not establish that an operative sibling holds or that evaluation is impossible.",
      "1" => "Affirms this #{root.fetch(:kind)} as existing but not presently operative, without encoding hiddenness, uncertainty, probability, future activation, missing resources, or permission.",
      "2/num" => "Leaves unresolved even the assertion that this latent #{root.fetch(:kind)} exists; lexical latency remains distinct from runtime assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "account" : id[-2] == "1" ? "device" : "network"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},CRITERION=c" : id[-2] == "1" ? "TARGET=#{entity},CONSTRAINT=c" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},REGIME=c"
  status_text = { "0" => "persists independently of present operation", "1" => "is presently operative", "2" => "exists but is not presently operative" }.fetch(id[-1])
  ordinary = "The #{root.fetch(:kind)} for the #{entity} #{status_text}."
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts formal-evaluation enablement and lexical status, not an actual evaluation or result."],
    ["physical_or_spatial", "MAT(BEARER=#{entity})+#{id}[1](#{graph_roles})", "material bearer plus #{root.fetch(:phase)} formal-evaluation affordance", "The machine has the stated formal-evaluation affordance while MAT separately describes sensors and mechanics.", "Formal affordance and physical implementation remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} formal-evaluation affordance during interval w", "During interval w, the affordance has the stated lexical status.", "ORI supplies time and does not replace persistent, operative, or latent status."],
    ["cross_family_compound", "DAT(INPUT=d)+#{id}[1](#{graph_roles})", "represented input plus #{root.fetch(:phase)} formal-evaluation affordance", "The data supplies represented inputs while LOG supplies formal evaluability or applicability.", "DAT resources and LOG enablement remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} formal-evaluation affordance", "A runtime tracks whether the selected evaluation affordance has the stated status without asserting execution or outcome.", "Capability, evaluation process, and result remain distinct."],
    ["counterexample", "LOG:101[1](ENTITY=#{entity},CRITERION=c)", "active internal formal evaluation", "The formal evaluation is running now.", "Use LOG:1xx for the actual evaluation process; #{id} names only its enabling capacity or applicability relation."]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(evaluation_affordance.status == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "formal_evaluability_affordances", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "consequence_entailment_relations", alt[0], alternative_invariant(id, "consequence_entailment_relations")),
    candidate(id, "consistency_compatibility_relations", alt[1], alternative_invariant(id, "consistency_compatibility_relations")),
    candidate(id, "permission_authorization_relations", alt[2], alternative_invariant(id, "permission_authorization_relations"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "formal_evaluability_affordances",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one formal-evaluation-enablement center, follows inward/target/systemic scope exactly, and gives every triplet one persistent/operative/latent axis while reserving rule entities, actual evaluations, results, algorithms, resources, consequence, consistency, permission, and modality for other roots or composition.",
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
    "0" => "one reference entity and its capacity for evaluation under an applicable internal criterion",
    "1" => "one specified formal constraint and one distinct reference target joined by an applicability relation",
    "2" => "multiple participants jointly evaluable under one shared formal regime"
  }.fetch(second)
  scope_boundary = {
    "0" => "The capacity belongs to one entity without requiring a distinct external target. The criterion, evaluator, actual evaluation, data, and result remain separate.",
    "1" => "The relation preserves one specified constraint and one distinct target. Assignment, authority, execution, and pass/fail outcome remain separate.",
    "2" => "The capacity requires multiple participants to be jointly evaluable under one shared regime. Several independently evaluable entities do not constitute one systemic affordance."
  }.fetch(second)
  triplet_logic = "Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time. Lexical latency affirms an existing but nonoperative affordance; runtime `[2]/num` separately marks uncertainty about any selected status."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_2" => "Selects a formal-evaluation capacity or applicability relation rather than a rule entity, an actual evaluation process, represented data, a result value, or unrestricted modality.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Logic-family column.",
      "third_trit" => "Selects the #{state_label} status of the same formal-evaluation affordance while leaving runtime truth status, actual evaluation, result polarity, observer knowledge, tense, probability, permission, and scheduling separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral formal-evaluation affordance at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about rule storage or authority, acceptance versus rejection, truth, proof correctness, resource sufficiency, computational complexity, observer belief, scheduling, probability, timing, and cause.",
    "excluded_meanings" => [
      "The formal criterion, target constraint, or shared regime as an entity, and its persistent, operative, or dormant rule status.",
      "The completed, active, or nonactualized evaluation process and any acceptance, rejection, truth, validity, satisfaction, or violation result.",
      "Data inputs, variables, bindings, records, schemas, source code, proof objects, algorithms, evaluators, or stored outputs.",
      "Physical, biological, communicative, structural, restorative, creative, or adverse capacity or transformation.",
      "Entailment, implication, consequence, consistency, compatibility, permission, authority, enforcement, sanction, performance, complexity, or resource sufficiency.",
      "Observer knowledge, evidence, intention, plan, readiness, queue, schedule, future time, unrestricted possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`LOG:0xx` owns formal constraint entities and their identity or operation. `LOG:1xx` owns the corresponding completed, active, or nonactualized evaluation processes. `LOG:2xx` owns only typed formal-evaluation enablement: internal evaluability, constraint-target applicability, and systemic joint-evaluability. A rule does not entail evaluability, evaluability does not entail an actual evaluation, and an evaluation does not entail a positive result. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} status of this formal-evaluation affordance. Runtime `[2]/num` instead leaves the already-selected status claim unresolved; it never changes affordance status. Thus a latent root affirmed with `[1]` is a confirmed existing-but-nonoperative affordance, while a persistent or operative root carrying `[2]/num` remains lexically persistent or operative but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + LOG:0xx supplies the criterion or regime whose evaluation is enabled without reducing the affordance to its rule.",
      "#{id} + LOG:1xx states that the corresponding formal evaluation is actually completed, active, or nonactualized.",
      "#{id} + DAT/MAT/STR supplies represented inputs, algorithms, resources, and implementation while preserving the LOG affordance boundary.",
      "#{id} + ORI/CON may express timing, modality, permission, or authority as separate qualifications."
    ],
    "later_era_notes" => "Later eras may lexicalize decidability, computability, tractability, satisfiability, entailment, consistency, permission, proof availability, and resource-bounded evaluation. Era Zero should preserve the substrate-neutral formal-evaluation-enablement center and derive stronger technical claims compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


logic_affordance_stress_base = [
  ["evaluable", "one_root", "LOG:2xx by scope and status asserts the typed capacity or applicability relation enabling formal evaluation."],
  ["checkable", "one_root_or_compound", "Use LOG:2xx for formal checkability; sensing, data availability, and observer knowledge remain separate."],
  ["decidable", "compound_or_later_specialization", "LOG internal evaluability is necessary for contextual decidability, but termination and algorithmic guarantees require DAT and later technical vocabulary."],
  ["computable", "compound_or_later_specialization", "Computability requires LOG evaluability plus DAT algorithm and representation semantics; resource or complexity claims remain separate."],
  ["applicable rule", "one_root", "LOG:210–212 states a relation between one specified constraint and one distinct target according to lexical status."],
  ["constraint applies now", "one_root", "LOG:211 states that the constraint-target applicability relation is presently operative."],
  ["constraint could apply later", "compound", "LOG:212 may assert an existing latent relation, while ORI separately supplies future time; mere possibility alone is insufficient."],
  ["eligible for evaluation", "one_root_or_compound", "LOG:2xx can express formal evaluability; institutional eligibility or permission requires CON, LIF, or authority compounds."],
  ["jointly evaluable", "one_root", "LOG:220–222 applies when multiple participants can undergo one coordinated joint evaluation under a shared regime."],
  ["independently evaluable participants", "multiple_roots_not_systemic", "Use separate LOG:2x0 claims; independent capacities do not establish systemic joint-evaluability."],
  ["formal consequence", "reserved_relation", "Entailment or implication is intentionally not collapsed into general evaluability and remains compound or later specialization."],
  ["entails", "reserved_relation", "Premise-to-conclusion entailment requires distinct consequence roles and is not the LOG:2xx affordance center."],
  ["implies", "reserved_relation", "Implication is a consequence relation rather than capacity to evaluate a bearer or target."],
  ["consistent", "reserved_relation", "Consistency is a result or relation among formal contents; an inconsistent object may still be evaluable."],
  ["compatible", "compound_or_different_family", "Formal compatibility may support applicability, while structural or material compatibility belongs to STR or MAT."],
  ["satisfiable", "compound_or_later_specialization", "Satisfiability requires a formal content and model relation beyond generic evaluation affordance."],
  ["permitted", "compound_or_different_family", "Permission requires policy, authority, and often participants; evaluability is independent of authorization."],
  ["authorized", "compound_or_different_family", "CON/LIF/DAT supplies principal and authority semantics; LOG:2xx does not itself grant access."],
  ["possible", "different_family", "ORI owns unrestricted possibility; LOG:2xx asserts a specific typed evaluation affordance that actually exists."],
  ["probable evaluation", "different_family", "ORI or runtime confidence expresses probability; no lexical LOG:2xx status means probable."],
  ["evaluation running", "process_layer", "LOG:1xx owns actual evaluation phase; LOG:2xx only states capacity or applicability."],
  ["evaluation completed", "process_layer", "LOG:1x0 owns completion and determination of a result; affordance alone entails no process."],
  ["rule exists", "entity_layer", "LOG:0xx owns rule identity; a defined rule may lack an applicable target or evaluator."],
  ["rule operative", "entity_layer", "LOG:0x1 owns operation of a constraint; an operative rule need not be evaluable for a particular target."],
  ["accepted", "result_not_affordance", "Acceptance is result polarity and is not entailed by evaluability or applicability."],
  ["rejected", "result_not_affordance", "Rejection is result polarity and must remain separate from LOG:2xx."],
  ["true", "result_or_relation", "Truth is not capacity for evaluation and is not selected by persistent, operative, or latent status."],
  ["proof exists", "compound", "DAT owns proof representation; consequence and verification relations remain distinct from evaluability."],
  ["algorithm exists", "compound", "DAT/CRE owns the algorithm artifact or construction; LOG:2xx may state that an evaluation is enabled."],
  ["resources available", "compound", "DAT/MAT owns computational resources; their availability may realize operative evaluability but is not identical to it."],
  ["persistent internal evaluability", "one_root", "LOG:200 preserves one entity's internal formal-evaluation capacity independently of current operation."],
  ["operative internal evaluability", "one_root", "LOG:201 states that one entity's internal formal-evaluation capacity is presently operative."],
  ["latent internal evaluability", "one_root", "LOG:202 states that the capacity exists without being presently operative."],
  ["persistent constraint-target applicability", "one_root", "LOG:210 preserves one specified constraint-target applicability relation independently of present operation."],
  ["operative constraint-target applicability", "one_root", "LOG:211 states that one specified constraint presently applies as an evaluation-enabling relation to one target."],
  ["latent constraint-target applicability", "one_root", "LOG:212 states that the relation exists without presently enabling target evaluation."],
  ["persistent systemic joint-evaluability", "one_root", "LOG:220 preserves one coordinated joint-evaluation capacity across participants under one regime."],
  ["operative systemic joint-evaluability", "one_root", "LOG:221 states that the coordinated joint-evaluation capacity is presently operative."],
  ["latent systemic joint-evaluability", "one_root", "LOG:222 states that the capacity exists without being presently operative."],
  ["persistent plus operative evaluability", "two_compatible_roots", "LOG:200 and LOG:201 may co-occur because persistent identity is neutral about current operation."],
  ["persistent plus latent evaluability", "two_compatible_roots", "LOG:200 and LOG:202 may co-occur while the capacity is not presently operative."],
  ["operative and latent evaluability simultaneously", "invalid_same_reference_claim", "LOG:201 and LOG:202 are mutually exclusive for the same capacity at one reference time."],
  ["persistent plus operative applicability", "two_compatible_roots", "LOG:210 and LOG:211 may co-occur because persistence and current operation are independent claims."],
  ["persistent plus latent applicability", "two_compatible_roots", "LOG:210 and LOG:212 may co-occur while the relation is nonoperative."],
  ["operative and latent applicability simultaneously", "invalid_same_reference_claim", "LOG:211 and LOG:212 are mutually exclusive at one reference time."],
  ["persistent plus operative joint-evaluability", "two_compatible_roots", "LOG:220 and LOG:221 may co-occur because identity persistence is neutral about current operation."],
  ["persistent plus latent joint-evaluability", "two_compatible_roots", "LOG:220 and LOG:222 may co-occur while the systemic capacity is nonoperative."],
  ["operative and latent joint-evaluability simultaneously", "invalid_same_reference_claim", "LOG:221 and LOG:222 are mutually exclusive at one reference time."],
  ["latent evaluability affirmed", "runtime_and_lexical", "LOG:202[1] affirms an existing nonoperative capacity without adding uncertainty or future time."],
  ["operative evaluability uncertain", "runtime_and_lexical", "LOG:201[2]/num leaves current operation unresolved while preserving the operative lexical selection."],
  ["persistent evaluability denied", "runtime_and_lexical", "LOG:200[0] denies persistent identity without selecting the operative or latent sibling."],
  ["unknown evaluability", "runtime_or_epistemic", "Use runtime [2]/num or MIN/DAT evidence; lexical latency does not mean unknown."],
  ["hidden applicability", "compound", "LOG:212 supplies nonoperation only; MIN/DAT separately states that observers have not discovered the relation."],
  ["scheduled activation", "compound", "LOG:2x2 plus ORI/DAT may describe scheduled activation; lexical latency never means scheduled."],
  ["evaluation affordance versus rule", "scope_resolution_test", "LOG:2xx owns enablement while LOG:0xx owns the criterion or regime entity."],
  ["evaluation affordance versus process", "scope_resolution_test", "LOG:2xx owns enablement while LOG:1xx owns actual evaluation by phase."],
  ["evaluability versus consequence", "scope_resolution_test", "Capacity to evaluate does not entail any premise-to-conclusion relation."],
  ["evaluability versus consistency", "scope_resolution_test", "An object can be evaluable whether it proves consistent or inconsistent."],
  ["applicability versus permission", "scope_resolution_test", "A constraint may formally apply even when no authority permits acting on the result."],
  ["evaluability versus data availability", "scope_resolution_test", "DAT owns inputs and resources; LOG states the typed evaluation affordance realized through them."],
  ["evaluability versus understanding", "scope_resolution_test", "MIN owns comprehension and confidence; formal evaluability can hold without human understanding."],
  ["evaluability versus physical capability", "scope_resolution_test", "MAT/STR owns implementation capacity; LOG owns only formal-evaluation enablement."],
  ["evaluability versus restoration", "scope_resolution_test", "REP owns restoration affordance; LOG may state that the restoration is formally evaluable."],
  ["evaluability versus general possibility", "scope_resolution_test", "LOG:2xx asserts a specific existing affordance; ORI owns unrestricted possibility, necessity, and probability."],
  ["one constraint applicable to many unrelated targets", "multiple_relations", "Use separate LOG:2x1 claims unless one shared regime establishes coordinated joint-evaluability."],
  ["shared schema validation capability", "compound", "LOG systemic joint-evaluability plus DAT schema and representations; schema identity is not absorbed into LOG."],
  ["distributed compliance capability", "one_root_or_compound", "LOG:22x applies only when participants can undergo one coordinated joint evaluation under one shared regime."],
  ["network reachability only", "different_family", "CON reachability may implement evaluation but does not entail joint-evaluability."],
  ["common rule without joint evaluation", "entity_not_affordance", "LOG:02x may define a shared regime even when LOG:22x joint-evaluability is absent."]
].freeze

logic_affordance_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the root's invariant without adding rule storage, evaluation process, result polarity, or authority."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} affordance claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} with data", "compound", "DAT supplies inputs, algorithms, or resources while #{id} supplies formal-evaluation enablement."],
    ["#{root[:title]} under rule", "compound", "LOG:0xx supplies the criterion or regime while #{id} supplies the corresponding evaluation affordance."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or confidence while #{id} remains an objective formal-affordance claim."],
    ["#{root[:title]} actualized", "compound", "LOG:1xx supplies actual evaluation phase while #{id} supplies only the enabling capacity or applicability relation."]
  ]
end

stress_rows = logic_affordance_stress_base + logic_affordance_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("LOG2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "LOG:200–222 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/LOG_200_222_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "LOG:200–222 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "LOG:200–202" => "internal formal evaluability: persistent / operative / latent", "LOG:210–212" => "constraint-target applicability: persistent / operative / latent", "LOG:220–222" => "systemic joint-evaluability: persistent / operative / latent" }, "triplet_logic" => { "affordance_statuses" => "persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time", "latent_member" => "affirms an existing nonoperative affordance without hiddenness, probability, planning, scheduling, or futurity", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/LOG_200_222_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "LOG:200–222 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# LOG:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Logic relation/capacity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `LOG:2xx` the substrate-neutral formal-evaluation-affordance layer paired with canonical `LOG:1xx`. The inward triplet states one entity's capacity for evaluation under its internal criterion, the outward triplet states one specified constraint's applicability to one distinct target, and the systemic triplet states capacity for one coordinated joint evaluation across multiple participants under one shared regime. Persistent, operative, and latent supply the exact third-trit contrast.\n\nPersistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time. Lexical latency means an existing but nonoperative affordance, not uncertainty, missing evidence, probability, permission, scheduling, or future time. Runtime `[2]/num` remains uncertainty about the selected status. The design rejects the provisional mixture of decidability, computability, implication, entailment, active derivation, consistency, recursion, resource conditions, and formal possibility. Rule entities remain `LOG:0xx`; actual evaluations remain `LOG:1xx`; consequence, consistency, algorithms, authority, results, and modality remain separate or compounded.\n\n"

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
review << "| LOG:200–202 | one entity's capacity for evaluation under its internal criterion | capacity persists | capacity operative | capacity exists nonoperatively |\n"
review << "| LOG:210–212 | one specified constraint's applicability to one distinct target | relation persists | relation operative | relation exists nonoperatively |\n"
review << "| LOG:220–222 | multiple participants' capacity for one joint evaluation under one regime | capacity persists | capacity operative | capacity exists nonoperatively |\n\n"
review << "**Triplet logic:** persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | rule identity, actual evaluation, represented resources, result polarity, entailment, consistency, algorithms, permission, scheduling, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nTruth and falsity, acceptance and rejection, satisfaction and violation, proof objects, conclusion content, arithmetic values, entailment, implication, consistency, satisfiability, algorithms, resource complexity, authority, permission, enforcement, scheduling, readiness, queues, and unrestricted modality remain other-family meanings, later vocabulary, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later specialization, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# LOG:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "DAT computability; MIN understanding; ORI possibility", "1" => "entailment; STR/MAT compatibility; CON permission", "2" => "consistency; DAT distributed computation; CON coordination" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | LOG keeps only typed formal-evaluation enablement; rule, process, result, algorithm, resources, authority, consequence, and modality remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A formal-evaluation affordance is not the rule or regime, an actual evaluation, represented data, an algorithm, a resource, an evaluator, or a result.\n- Internal evaluability does not entail technical decidability, computability, tractability, termination, resource sufficiency, understanding, or successful evaluation.\n- Constraint-target applicability does not entail assignment, permission, authority, execution, satisfaction, violation, consequence, or structural/material compatibility.\n- Systemic joint-evaluability requires one coordinated evaluation under one shared regime; several independently evaluable participants are insufficient.\n- A latent affordance exists but is not operative; it is not unknown, merely possible, planned, queued, scheduled, future, or prohibited.\n- Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time.\n- Runtime `[2]/num` leaves a selected status assertion unresolved and never selects lexical latency.\n\n**CONCLUSION: LOG:2XX STANDS ALONE ONLY FOR TYPED FORMAL-EVALUATION ENABLEMENT; RULES, ACTUAL EVALUATIONS, RESULTS, DATA, ALGORITHMS, RESOURCES, CONSEQUENCE, CONSISTENCY, AUTHORITY, PERMISSION, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built LOG:200–222 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
